# LE FILET : ce qui rattrape un corps passe sous le decor.
#
# AUCUN TERRAIN DU JEU N'A DE BORD. Le desert fait 460 m de cote et son sol
# s'arrete net ; au-dela il n'y a rien — ni bordure, ni rattrapage, et aucune
# erreur ne se leve. Le jeu repond toujours aux commandes pendant qu'on tombe
# a l'infini ; le seul symptome est un ecran qui devient bleu. La trace d'une
# partie du 04/09/2026 :
#
#     t=139.97  x=652.8  y=-3.7      au volant, gaz + gauche
#     t=140.62  x=643.9  y=-13.0     « vide »
#     t=161.63  x=528.3  y=-1887.1   449 km/h, toujours « au volant »
#
# Le pilote de la suite parcours est sorti par l'ouest, Benjamin par le sud,
# sur la piste, en jouant normalement. Trois semaines de « le camping-car est
# tombe dans le vide » sans lieu ni chiffre.
#
# CE QU'ON DEMANDE EST UN FILET, PAS UN MUR. Le terrain deborde volontairement
# la portee du brouillard pour qu'on ne voie pas sa limite ; un mur invisible
# y ferait apparaitre une limite qu'on ne voit toujours pas, mais contre
# laquelle on bute. Ici, on laisse tomber, et on remet debout.
#
# CE QUE CA FAIT, en trois temps :
#
#   1. a chaque image, si le sujet — celui que le controleur conduit — a ses
#      pieds ou ses quatre roues au sol, on RETIENT ou il est. La memoire
#      garde quelques secondes, et rien de plus ;
#   2. s'il passe sous `filet_altitude`, on choisit dans cette memoire la
#      position d'il y a `filet_recul` secondes — pas la derniere, qui est au
#      bord du trou — et on demande au controleur de l'y reposer ;
#   3. le controleur fait le fondu, repose LE SUJET (la voiture au volant, le
#      personnage a pied), secoue la camera, et ne touche a rien d'autre : ni
#      l'etape, ni la zone, ni les passages.
#
# LA MEMOIRE SE MESURE EN JOUANT, jamais en coordonnees ecrites. Une
# coordonnee de secours ecrite ici perimerait le jour ou le desert bouge —
# c'est arrive deux fois au panneau du desert.
#
# ET ELLE S'OUBLIE A CHAQUE TELEPORTATION. Un passage franchi, une porte
# passee, une partie recommencee : ce qu'on avait retenu decrit un autre
# endroit, a neuf cents metres. Reposer quelqu'un la-bas serait pire que le
# trou. Voir `oublier()`, appele par le controleur.
class_name Filet
extends Node

const GROUPE := "filet"

@export var reglages: Reglages

var _controleur: Node
var _trace: Node

## Par sujet, la liste chronologique des endroits ou il etait au sol :
## `{t, pos, cap}`. Elle ne garde que `filet_recul` + 1 s de passe.
var _memoire: Dictionary = {}

var _horloge: float = 0.0

## Combien de fois on a rattrape quelqu'un depuis le debut. Pour les
## verifications, et pour la trace.
var _rattrapages: int = 0

## Le dernier rattrapage : `{sujet, tombe, repose, cap}`. Pour les
## verifications : un filet qui ne dit pas ou il a repose ne se mesure qu'a
## ses effets, donc trop tard.
var _dernier: Dictionary = {}


func _ready() -> void:
	add_to_group(GROUPE)
	if reglages == null:
		push_error("filet : aucune ressource Reglages assignee")
		set_physics_process(false)
		return
	_controleur = _trouver_unique("Controleur")
	if _controleur == null:
		push_warning("FILET : pas de Controleur, personne ne sera rattrape")
		set_physics_process(false)
		return
	_trace = get_tree().get_first_node_in_group("trace")


# UN NOM DE NOEUD N'EST PAS UNE ADRESSE : on compte avant de s'en servir.
# Piege 54, paye deux fois dans la meme soiree.
func _trouver_unique(nom: String) -> Node:
	var trouves: Array[Node] = []
	_recenser(get_tree().get_root(), nom, trouves)
	if trouves.size() > 1:
		push_warning("FILET : %d noeuds nommes %s, on prend le premier"
				% [trouves.size(), nom])
	return trouves[0] if trouves.size() > 0 else null


func _recenser(noeud: Node, nom: String, vus: Array[Node]) -> void:
	if noeud.name == nom:
		vus.append(noeud)
	for enfant in noeud.get_children():
		_recenser(enfant, nom, vus)


func _physics_process(delta: float) -> void:
	_horloge += delta
	# Pendant un fondu, le sujet est a moitie teleporte : ni retenir, ni
	# rattraper. Et dans une maison, il n'y a pas de bord ou tomber.
	if bool(_controleur.call("en_transition")) or bool(_controleur.call("dedans")):
		return
	var sujet := _controleur.call("sujet") as Node3D
	if sujet == null:
		return
	# Un mort ne se rattrape pas : son corps est au ragdoll, et c'est l'ecran
	# de fin qui decide de ce qui suit.
	if sujet is Joueur and not (sujet as Joueur).vivant():
		return

	var ou := sujet.global_position
	if ou.y < reglages.filet_altitude:
		_rattraper(sujet, ou)
		return
	if _au_sol(sujet):
		_retenir(sujet, ou)


## Les pieds au sol, ou les quatre roues. Un sujet d'un autre type — il n'y
## en a pas aujourd'hui — n'est jamais retenu, donc jamais repose ailleurs
## qu'au point de secours.
func _au_sol(sujet: Node3D) -> bool:
	if sujet is Joueur:
		var j := sujet as Joueur
		return not j.traverse and j.is_on_floor()
	if sujet is Vehicule:
		return (sujet as Vehicule).au_sol()
	return false


func _retenir(sujet: Node3D, ou: Vector3) -> void:
	var liste: Array = _memoire.get(sujet, [])
	liste.append({"t": _horloge, "pos": ou, "cap": sujet.rotation.y})
	# On ne garde que ce qui peut encore servir. Le menage se fait ICI, au
	# sol, et jamais en l'air : pendant une chute, la memoire doit se figer
	# sur les derniers pas au sol, pas se vider a mesure qu'ils vieillissent.
	while liste.size() > 1 \
			and _horloge - float(liste[0]["t"]) > reglages.filet_recul + 1.0:
		liste.pop_front()
	_memoire[sujet] = liste


## L'ENDROIT OU REPOSER CE SUJET : le plus recent de ceux qui datent d'au
## moins `filet_recul` secondes ET qui sont a `filet_marge` metres du BORD.
## S'il n'y en a aucun, le plus ancien qu'on ait — c'est le cas d'un sujet
## qui tombe deux secondes apres avoir touche le sol pour la premiere fois.
##
## LE BORD, C'EST LE DERNIER PAS AU SOL, pas le point ou l'on passe sous le
## seuil. La premiere version mesurait la marge depuis ce point-la — et a
## pied, en courant, on est deja huit metres au-dela du bord quand on passe
## sous moins dix. Trois metres de marge depuis la-bas, c'etait trente
## centimetres du bord : la suite parcours y est retombee deux fois de
## suite, la trace le montre a la ligne.
func _endroit_sur(sujet: Node3D) -> Dictionary:
	var liste: Array = _memoire.get(sujet, [])
	if liste.is_empty():
		return {}
	var choisi: Dictionary = liste[0]
	var bord_pos: Vector3 = liste[liste.size() - 1]["pos"]
	var bord := Vector2(bord_pos.x, bord_pos.z)
	for e in liste:
		var p: Vector3 = e["pos"]
		if _horloge - float(e["t"]) >= reglages.filet_recul \
				and Vector2(p.x, p.z).distance_to(bord) >= reglages.filet_marge:
			choisi = e
	return choisi


## Quand le sujet n'a rien en memoire, celle des AUTRES sert : descendre d'un
## vehicule au bord du trou et faire un pas, c'est tomber avec une memoire de
## pieton vide et une memoire de voiture pleine, a un metre de la.
func _endroit_sur_de_n_importe_qui() -> Dictionary:
	var meilleur: Dictionary = {}
	for s in _memoire.keys():
		var liste: Array = _memoire[s]
		if liste.is_empty():
			continue
		var e: Dictionary = liste[liste.size() - 1]
		if meilleur.is_empty() or float(e["t"]) > float(meilleur["t"]):
			meilleur = e
	return meilleur


func _rattraper(sujet: Node3D, tombe: Vector3) -> void:
	var e := _endroit_sur(sujet)
	if e.is_empty():
		e = _endroit_sur_de_n_importe_qui()
	var repose: Vector3
	var cap: float
	if e.is_empty() and not _dernier.is_empty():
		# ON N'A RIEN RETENU DEPUIS LE DERNIER RATTRAPAGE : il est retombe
		# avant d'avoir touche le sol. Ca arrive quand on repart droit vers le
		# trou — la suite parcours le fait, un joueur tetu aussi. On le remet
		# ou on l'a deja remis, dans le meme sens ; la premiere version le
		# renvoyait devant chez lui, a mille metres.
		repose = _dernier["repose"]
		cap = float(_dernier["cap"])
	elif e.is_empty():
		# Personne n'a jamais touche le sol depuis le dernier oubli : on tombe
		# des la premiere image apres une teleportation. Le point de secours
		# est celui du controleur — devant chez soi. C'est loin, et c'est
		# quand meme mieux que l'infini.
		repose = _controleur.call("point_de_secours")
		cap = 0.0
	else:
		repose = e["pos"]
		cap = float(e["cap"])
		if reglages.filet_demi_tour:
			cap += PI

	_rattrapages += 1
	_dernier = {"sujet": sujet, "tombe": tombe, "repose": repose, "cap": cap}
	# Ce qu'on avait retenu menait ici. On repart de zero pour que la
	# prochaine fois, s'il y en a une, s'appuie sur ce qu'on fera APRES.
	_memoire.clear()

	printerr("FILET : %s tombe en %s, repose en %s (%.0f m)" % [
			sujet.name, _lisible(tombe), _lisible(repose),
			Vector2(tombe.x, tombe.z).distance_to(Vector2(repose.x, repose.z))])
	if _trace != null and _trace.has_method("evenement"):
		_trace.call("evenement", "filet", {
			"sujet": sujet.name,
			"x": snappedf(tombe.x, 0.1), "y": snappedf(tombe.y, 0.1),
			"z": snappedf(tombe.z, 0.1),
			"vers_x": snappedf(repose.x, 0.1), "vers_y": snappedf(repose.y, 0.1),
			"vers_z": snappedf(repose.z, 0.1),
		})
	_controleur.call("rattraper", repose, cap)


static func _lisible(v: Vector3) -> String:
	return "(%.1f, %.1f, %.1f)" % [v.x, v.y, v.z]


## TOUT OUBLIER. Le controleur l'appelle a chaque teleportation — passage,
## porte, reprise — parce que ce qu'on avait retenu decrit l'endroit d'avant.
## Le dernier rattrapage aussi : il decrit le meme endroit d'avant.
func oublier() -> void:
	_memoire.clear()
	_dernier = {}


## Combien de rattrapages depuis le debut. Pour les verifications.
func rattrapages() -> int:
	return _rattrapages


## Le dernier rattrapage, ou un dictionnaire vide. Pour les verifications.
func dernier() -> Dictionary:
	return _dernier


## Combien d'endroits on retient pour ce sujet. Pour les verifications : une
## memoire qui ne se remplit pas est un filet qui ne rattrape que vers le
## point de secours, et ca ne se voit pas avant de tomber.
func endroits_retenus(sujet: Node3D) -> int:
	return (_memoire.get(sujet, []) as Array).size()
