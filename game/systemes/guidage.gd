# SUIVRE UNE VOIX QUAND ON NE VOIT RIEN.
#
# POURQUOI. C'est l'ouverture du jeu, et le retour du 23/08/2026 la decrit
# entierement :
#
#   « Faire durer la sequence avec le masque. La vision est trouble et
#     illisible, on ne sait pas ou on est, ni ou on va vraiment. On peut se
#     deplacer mais on ne voit pas grand-chose. On entends la voix de Jesse
#     (faible et diffuse dans un acouphene) qui essaye de nous indiquer ou
#     aller "Par ici Mr.White", tout en etant panique. Il nous indique plus ou
#     moins des directions, que le joueur doit suivre pour avancer dans le
#     script. Avancer, Tourner a droite, l'autre droite (gauche, car il s'est
#     trompe de panique) Puis il propose a Walter d'enlever le masque. C'est la
#     qu'on voit le decor. »
#
# ET LA CONTRAINTE QUI DECIDE DE TOUT, deux lignes plus loin : « a ce moment-la,
# le joueur doit se trouver plus ou moins devant le RV, face a lui. Donc
# s'arranger pour que le petit trajet nous y amene alors qu'on ne voyait presque
# rien. »
#
# LE TRAJET EST DONC UNE BOUCLE. On part contre la portiere, on s'eloigne a
# l'aveugle, on tourne deux fois, et on se retrouve face au camping-car sans
# jamais l'avoir vu. Le dernier jalon est place pour ca, et une verification le
# mesure — un decor qui bouge de trois metres ferait mentir la mise en scene
# sans que rien ne plante.
#
# CE QU'IL NE SAIT PAS : ce que Jesse dit. Les phrases vivent dans la donnee de
# mission, avec leur jalon ; ce fichier compte des metres et annonce des
# numeros. C'est la meme discipline que la sirene et le filtre — un systeme qui
# reconnaitrait l'etape a son nom est le piege 39.
class_name Guidage
extends Node3D

## Emis a chaque jalon atteint, avec son rang. Le scenario y accroche la phrase
## suivante : savoir QUI parle et QUAND est son travail, pas le notre.
signal jalon_atteint(rang: int)

## Emis quand le dernier jalon est franchi. La mission en fait un evenement.
signal fini

const GROUPE := "guidage"

## Les jalons, dans l'ordre ou il faut les atteindre.
@export var jalons: Array[NodePath] = []

## A quelle distance un jalon compte comme atteint, en metres.
##
## GENEREUX, ET C'EST TOUT LE SUJET. On ne voit rien : exiger de marcher sur un
## point precis reviendrait a demander de viser dans le noir, et le joueur
## tournerait en rond a deux metres du but sans comprendre. Quatre metres, c'est
## « par la » — ce que Jesse dit, et tout ce qu'il peut dire.
@export_range(1.0, 10.0, 0.5) var rayon: float = 4.0

## Le point vers lequel on doit REGARDER a la fin. Le camping-car.
##
## Le dernier jalon dit ou l'on s'arrete ; celui-ci dit dans quel sens. Sans
## lui, on arrive au bon endroit en regardant le desert vide, et la surprise du
## retrait de masque tombe sur du sable.
@export var face_a: NodePath

var _joueur: Node3D
var _rang: int = 0


func _ready() -> void:
	add_to_group(GROUPE)
	set_process(false)


func observer(n: Node3D) -> void:
	_joueur = n
	set_process(n != null)


## L'ETAPE COURANTE DEMANDE-T-ELLE QU'ON SUIVE LA VOIX ?
##
## Lu a chaque image plutot que memorise : c'est ce qui fait qu'une partie
## rechargee au milieu de la sequence retrouve le bon etat sans qu'on ait rien
## de plus a sauvegarder.
func active() -> bool:
	var m := Mission.courante(self)
	if m == null or m.finie():
		return false
	return bool(m.etape().get("guidage", false))


## Le rang du jalon qu'on cherche en ce moment. Pour les verifications, et pour
## le scenario qui doit savoir quelle phrase repeter.
func rang() -> int:
	return _rang


## LE TRAJET EST-IL FINI ? UN ETAT, ET PAS SEULEMENT UN SIGNAL.
##
## Le signal `fini` existe toujours — c'est lui qui fait tomber la derniere
## replique au bon moment — mais il ne peut pas etre le seul chemin, et ca a
## coute une heure.
##
## LE DECOR DU FOSSE EST INSTANCIE A L'EXECUTION. Le scenario branche donc ses
## signaux en retard, et le guidage est le premier mecanisme du jeu dont on a
## besoin des la premiere etape : selon la vitesse de la machine, le joueur
## pouvait finir son trajet AVANT que quiconque n'ecoute. Le signal partait dans
## le vide, l'ouverture attendait pour toujours, et le meme jeu marchait une
## fois sur deux.
##
## Un etat, lui, se constate a n'importe quel moment. C'est la meme parade que
## pour « volant » — voir Scenario._gerer_l_etat_present, et le commentaire qui
## l'accompagne : « un evenement ne se declenche qu'une fois ; un ETAT, on peut
## le constater a tout moment ».
func termine() -> bool:
	return _rang >= jalons.size()


## Combien de jalons en tout.
func total() -> int:
	return jalons.size()


## La distance qui reste jusqu'au jalon courant, ou -1 s'il n'y en a plus.
## Publique pour que la verification IMPRIME ce qu'elle compare.
func reste() -> float:
	var j := _jalon(_rang)
	if j == null or _joueur == null:
		return -1.0
	return _a_plat(_joueur.global_position, j.global_position)


func _process(_delta: float) -> void:
	if not active() or _joueur == null:
		return
	var j := _jalon(_rang)
	if j == null:
		return
	if _a_plat(_joueur.global_position, j.global_position) > rayon:
		return

	# ATTEINT. On avance d'un cran et on annonce — dans cet ordre, parce que le
	# scenario lit `rang()` pour choisir sa phrase et doit lire la NOUVELLE.
	_rang += 1
	if _rang >= jalons.size():
		_tourner_vers_la_fin()
		fini.emit()
		return
	jalon_atteint.emit(_rang)


# IL SE TOURNE VERS LE CAMPING-CAR, ET C'EST LA SEULE FOIS DU JEU.
#
# Prendre la main sur la camera d'un joueur est une chose qu'on ne fait pas :
# c'est meme la premiere plainte du retour, « repare la camera ». L'exception
# tient ici parce que le joueur ne VOIT rien — il n'a aucun moyen de savoir
# dans quel sens regarder, et Jesse vient de lui dire d'enlever son masque.
# Le premier plan lisible du jeu doit etre le camping-car retourne ; le laisser
# tomber sur du sable vide serait rater le seul moment de surprise de
# l'ouverture.
#
# On tourne la CAMERA et pas le personnage : c'est elle qui decide de ce qu'on
# voit, et le corps la suivra au premier pas.
func _tourner_vers_la_fin() -> void:
	var cible := get_node_or_null(face_a) as Node3D
	if cible == null or _joueur == null:
		return
	var vers := cible.global_position - _joueur.global_position
	vers.y = 0.0
	if vers.length_squared() < 0.0001:
		return
	var cap := atan2(-vers.x, -vers.z)
	var cam := _camera()
	if cam != null and cam.has_method("poser_le_cap"):
		cam.call("poser_le_cap", cap)
	else:
		_joueur.rotation.y = cap


# LA CAMERA DE POURSUITE, cherchee par son TYPE et gardee ensuite.
#
# Elle n'est dans aucun groupe et son chemin depend de la scene : le decor du
# fosse est instancie a l'execution, donc un NodePath ecrit ici viserait a cote.
# On la trouve une fois, on la garde — la recherche traverse tout l'arbre et
# n'a aucune raison d'etre refaite a chaque jalon.
func _camera() -> Node:
	if _cam == null:
		_cam = _chercher_camera(get_tree().root)
	return _cam


var _cam: Node


# LE CRITERE EST LA METHODE, PAS LA CLASSE. camera_poursuite.gd n'a pas de
# `class_name` — il n'en a jamais eu besoin, il est designe par un NodePath
# depuis monde.tscn. Lui en ajouter un pour ce seul usage rendrait un nom global
# au projet entier ; demander « sais-tu poser un cap ? » suffit et ne cree rien.
func _chercher_camera(n: Node) -> Node:
	if n is Camera3D and n.has_method("poser_le_cap"):
		return n
	for e in n.get_children():
		var t := _chercher_camera(e)
		if t != null:
			return t
	return null


func _jalon(i: int) -> Node3D:
	if i < 0 or i >= jalons.size():
		return null
	return get_node_or_null(jalons[i]) as Node3D


# A PLAT, comme partout dans ce fosse : la cuvette creuse 2,30 m, et une
# distance en trois dimensions ferait croire qu'on est plus loin du jalon qu'on
# ne l'est en marchant.
func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


## Tout reprendre au premier jalon. Recommencer une partie doit redonner le
## trajet entier, pas la fin d'un trajet deja fait.
func reinitialiser() -> void:
	_rang = 0
