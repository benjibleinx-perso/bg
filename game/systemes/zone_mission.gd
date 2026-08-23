# LA ZONE D'UNE MISSION : on ne part pas faire sa vie au milieu d'une scene.
#
# Demande par Guillaume le 23/08/2026, et decrite par lui en deux niveaux :
#
#   « Si le joueur s'eloigne trop, ET qu'il y a un personnage a proximite
#     faisant partie de la mission, celui-ci lui lancera un dialogue pour le
#     pousser a revenir. [...] Le second, si le joueur va encore plus loin,
#     l'ecran devient gris, un titre apparait au milieu de l'ecran style
#     "Vous quittez la zone de mission" avec un compte a rebours de 10
#     secondes. A la fin de ce decompte, c'est game over. »
#
# DEUX NIVEAUX, ET LE PREMIER EST LE PLUS IMPORTANT. Un jeu qui punit sans
# avoir prevenu est un jeu injuste ; celui qui previent PAR UN PERSONNAGE ne
# ressemble meme pas a une punition — Jesse rappelle qu'on a du travail, et le
# joueur revient de lui-meme sans avoir vu de regle.
#
# ELLE NE VAUT PAS PARTOUT, ET C'EST ECRIT EN DONNEES. « Cette feature ne sera
# active que pour les missions ou c'est logique de la mettre, ou tout se passe
# au meme endroit par exemple. » Une mission qui ne declare pas de zone n'en a
# pas ; une etape peut la couper avec "zone": false — l'etape ou l'on rejoint
# la piste, par exemple, consiste justement a s'en aller.
class_name ZoneMission
extends Control

## D'ou l'on lit la mission, le joueur, et a qui l'on annonce.
@export var mission: NodePath
@export var joueur: NodePath
@export var controleur: NodePath

## A qui demander de terminer la partie. Le scenario sait mettre en scene une
## mort ; cette zone ne sait que compter.
@export var scenario: NodePath

## Ce qu'on affiche si la mission n'a rien precise.
const TITRE_DEFAUT := "Vous quittez la zone de mission"
const ECHEC_DEFAUT := "Vous vous etes enfui"
const COMPTE_DEFAUT := 10.0

## Combien de temps avant qu'un rappel puisse se repeter, en secondes. Une
## phrase toutes les deux secondes ne pousse pas a revenir : elle apprend a ne
## plus lire le bandeau.
const ENTRE_DEUX_RAPPELS := 12.0

var _mission: Mission
var _joueur: Node3D
var _controleur: Node
var _scenario: Node

## La configuration en cours, relue a chaque etape. Vide = aucune zone.
var _zone: Dictionary = {}

## Le centre, resolu une fois par etape. C'est un NOEUD qu'on suit, pas une
## position figee : le camping-car de la mission 1 se conduit, et la zone doit
## le suivre plutot que de rester autour d'un trou dans le sable.
var _centre: Node3D

var _depuis_le_rappel: float = ENTRE_DEUX_RAPPELS
var _compte: float = -1.0


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mission = get_node_or_null(mission) as Mission
	_joueur = get_node_or_null(joueur) as Node3D
	_controleur = get_node_or_null(controleur)
	_scenario = get_node_or_null(scenario)
	if _mission != null:
		_mission.etape_changee.connect(_sur_etape)
	set_process(true)
	call_deferred("_relire")


func _sur_etape(_i: int) -> void:
	_relire()


# LA CONFIGURATION SE RELIT A CHAQUE ETAPE, et le centre avec.
#
# Une etape peut porter sa propre zone, sinon on prend celle de la mission.
# Ce qui compte est que « zone »: false COUPE la surveillance : sans ca, une
# etape qui demande de partir — rejoindre la piste, aller en ville — serait un
# echec annonce.
func _relire() -> void:
	_zone = {}
	_centre = null
	_compte = -1.0
	visible = false
	if _mission == null:
		return

	var etape: Variant = _mission.etape().get("zone", null)
	var globale: Variant = _mission.donnees().get("zone", null)
	var choisie: Variant = etape if etape != null else globale
	if typeof(choisie) != TYPE_DICTIONARY:
		# false, 0, absent : pas de zone. On le dit une fois, pas a chaque image.
		return

	_zone = choisie

	# ELLE NE VAUT QUE SUR UNE TRANCHE DE LA MISSION, et c'est ce qui la rend
	# declarable une seule fois.
	#
	# « Deux corps » se joue en deux endroits separes par trois semaines et
	# neuf cents metres : une zone posee autour du fosse rendrait la cuisine
	# du camping-car immediatement hors limite. On borne donc par etape, avec
	# le meme vocabulaire qu'ancrage.gd — « depuis » inclus, « jusqu_a »
	# inclus — plutot que de recopier la meme zone sur dix etapes.
	var depuis := str(_zone.get("depuis", ""))
	var jusqu_a := str(_zone.get("jusqu_a", ""))
	if depuis != "" and not (_mission.a_l_etape(depuis) or _mission.passee(depuis)):
		_zone = {}
		return
	if jusqu_a != "" and _mission.passee(jusqu_a) and not _mission.a_l_etape(jusqu_a):
		_zone = {}
		return

	var nom := str(_zone.get("ou", ""))
	if nom == "":
		nom = _mission.ou()
	if nom != "":
		# DEPUIS LA RACINE DE L'ARBRE, pas depuis `current_scene` : une suite
		# de verification instancie le monde a la main et ne le declare pas
		# comme scene courante. Le premier essai plantait sur un null, et le
		# jeu, lui, marchait — donc rien n'aurait signale le probleme avant
		# qu'une deuxieme scene existe.
		var racine: Node = get_tree().current_scene
		if racine == null:
			racine = get_tree().root
		_centre = racine.find_child(nom, true, false) as Node3D
	if _centre == null:
		push_warning("zone_mission : centre '%s' introuvable, zone ignoree" % nom)
		_zone = {}


func _process(delta: float) -> void:
	if _zone.is_empty() or _joueur == null or _centre == null:
		return

	_depuis_le_rappel += delta
	var d := _joueur.global_position.distance_to(_centre.global_position)
	var rappel := float(_zone.get("rappel", 30.0))
	var limite := float(_zone.get("limite", 55.0))

	# DEUXIEME NIVEAU : le decompte. Il se lance au franchissement et
	# s'annule des qu'on revient — revenir doit suffire, sans avoir a
	# rentrer plus loin que la ou l'on est sorti.
	if d > limite:
		if _compte < 0.0:
			_compte = float(_zone.get("compte", COMPTE_DEFAUT))
			visible = true
		_compte -= delta
		queue_redraw()
		if _compte <= 0.0:
			_compte = -1.0
			visible = false
			_abandonner()
		return

	if _compte >= 0.0:
		_compte = -1.0
		visible = false
		queue_redraw()

	# PREMIER NIVEAU : quelqu'un le rappelle. Rien ne se fige : ca passe par
	# le bandeau, le meme canal que les pensees de Walter.
	if d > rappel and _depuis_le_rappel >= ENTRE_DEUX_RAPPELS:
		_depuis_le_rappel = 0.0
		_rappeler()


# LE RAPPEL VIENT DE QUELQU'UN, pas du jeu.
#
# On cherche un PNJ de la mission a portee du CENTRE — pas du joueur : celui
# qui rappelle est reste sur place, c'est justement pour ca qu'il rappelle.
# Sans personne, on se rabat sur une phrase neutre : mieux vaut un bandeau
# impersonnel qu'un joueur qui meurt sans avoir ete prevenu.
func _rappeler() -> void:
	if _controleur == null:
		return
	var phrase := str(_zone.get("phrase", ""))
	var qui := _qui_rappelle()
	if qui != "" and phrase != "":
		_controleur.call("annoncer", "%s : %s" % [qui, phrase])
	elif phrase != "":
		_controleur.call("annoncer", phrase)
	else:
		_controleur.call("annoncer", "Vous vous eloignez")


func _qui_rappelle() -> String:
	var nom := str(_zone.get("qui", ""))
	if nom == "":
		return ""
	# Il faut qu'il soit LA. Un rappel de quelqu'un qui n'est pas dans la scene
	# — pas encore arrive, ou deja mort — est une voix qui sort de nulle part.
	for n in get_tree().get_nodes_in_group(Pnj.GROUPE):
		var p := n as Pnj
		if p != null and not p.abattu and p.visible \
				and p.global_position.distance_to(_centre.global_position) < 25.0:
			return nom
	return ""


func _abandonner() -> void:
	var titre := str(_zone.get("echec", ECHEC_DEFAUT))
	if _scenario != null and _scenario.has_method("perdre"):
		_scenario.call("perdre", titre)


## Le decompte en cours, en secondes, ou -1. Pour les verifications : un
## compte a rebours qui ne se lit pas ne se mesure qu'a ses effets, donc trop
## tard.
func compte() -> float:
	return _compte


## Y a-t-il une zone active ? Sert aussi aux tests, qui doivent pouvoir
## distinguer « la zone n'a pas reagi » de « il n'y a pas de zone ».
func active() -> bool:
	return not _zone.is_empty() and _centre != null


func _draw() -> void:
	if _compte < 0.0:
		return
	var police := get_theme_default_font()
	if police == null:
		return

	# L'ECRAN DEVIENT GRIS, comme demande. Un voile, pas un rideau : on doit
	# continuer a voir ou l'on va pour pouvoir revenir.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.35, 0.35, 0.36, 0.42))

	# LE BLOC EST HAUT DANS LE CADRE, pas au milieu : au centre, le nombre se
	# posait en plein sur le personnage — vu a la capture. On garde la zone
	# ou l'on regarde en marchant degagee, puisque tout l'enjeu est de
	# revenir en voyant ou l'on va.
	var titre := str(_zone.get("titre", TITRE_DEFAUT))
	_ecrire(police, titre, Vector2(size.x / 2.0, size.y * 0.20), 16,
			Color(0.949, 0.925, 0.867))
	# Le nombre entier, arrondi vers le HAUT : a 0,4 seconde restante il doit
	# rester « 1 » a l'ecran, pas « 0 » pendant presque une demi-seconde.
	_ecrire(police, "%d" % int(ceil(_compte)),
			Vector2(size.x / 2.0, size.y * 0.20 + 34.0), 28,
			Color(0.78, 0.13, 0.11))
	_ecrire(police, "Revenez", Vector2(size.x / 2.0, size.y * 0.20 + 56.0), 11,
			Color(0.68, 0.66, 0.62))


func _ecrire(police: Font, texte: String, ou: Vector2, taille: int,
		couleur: Color) -> void:
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, taille).x
	var p := ou - Vector2(largeur / 2.0, 0.0)
	var ombre := Color(0.0, 0.0, 0.0, couleur.a)
	for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		police.draw_string(get_canvas_item(), p + d, texte,
				HORIZONTAL_ALIGNMENT_LEFT, -1, taille, ombre)
	police.draw_string(get_canvas_item(), p, texte,
			HORIZONTAL_ALIGNMENT_LEFT, -1, taille, couleur)
