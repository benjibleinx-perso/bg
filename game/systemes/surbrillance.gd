# CE QUI SE SIGNALE DANS LE NOIR.
#
# Le script demande, pour les trois preuves du fosse : « trois objets au sol,
# REPERABLES PAR SURBRILLANCE AU SURVOL ». C'est le seul moment du jeu ou l'on
# cherche des objets menus, de nuit, dans du sable de la meme couleur qu'eux.
#
# Le premier essai en jeu a dit exactement ce que ca coute : « je vois bien les
# trois, mais je les traverse » — et plus tard « le truc jaune est pas
# ramassable ». Deux plaintes de lisibilite sur trois objets.
#
# DEUX ETATS, ET LA DIFFERENCE COMPTE AUTANT QUE L'EFFET.
#
#   loin   une lueur faible et constante. Elle dit « il y a quelque chose ici »,
#          ce qui est le probleme a resoudre : les trouver.
#   pres   plus vif. Elle dit « celui-la repond a F », ce qui est l'autre
#          probleme : savoir lequel des trois on va ramasser.
#
# Sans le second etat, on aurait trois objets qui brillent pareil et on
# appuierait au hasard. Sans le premier, on ne les chercherait plus : on les
# aurait trouves.
#
# ON N'ECRIT PAS DANS LEUR MATERIAU. Un overlay se pose par-dessus et se retire
# sans rien laisser ; toucher au materiau d'origine reviendrait a modifier un
# .glb livre depuis un script de jeu, et la teinte survivrait au ramassage.
extends Node

## La couleur de la lueur. Froide et pale : on est de nuit, aux phares, et une
## lueur chaude passerait pour un reflet du camping-car.
const TEINTE := Color(0.62, 0.78, 0.86)

## Ce que valent les deux etats, en intensite d'emission.
const LOIN := 0.22
const PRES := 0.75

## La vitesse a laquelle on passe de l'un a l'autre. Assez lent pour que ca
## respire, assez vif pour repondre au pas du joueur.
const VITESSE := 4.0

# Le point vise -> son overlay, pour ne le fabriquer qu'une fois.
var _overlays: Dictionary = {}
var _forces: Dictionary = {}

@export var controleur: NodePath
var _c: Node


func _ready() -> void:
	_c = get_node_or_null(controleur)


func _process(delta: float) -> void:
	var mission := Mission.courante(self)
	var joueur := get_tree().get_first_node_in_group("joueur") as Node3D
	if joueur == null:
		return
	# Le plus proche des points OFFERTS, c'est-a-dire celui sur lequel le F
	# agirait. On le redemande au controleur plutot que de refaire son calcul :
	# deux facons de designer le meme point finiraient par ne plus designer le
	# meme, et la lueur mentirait sur ce qui va se ramasser.
	var vise: Point = null
	if _c != null and _c.has_method("point_vise"):
		vise = _c.call("point_vise")

	for n in get_tree().get_nodes_in_group(Point.GROUPE):
		var p := n as Point
		if p == null or not p.surbrillance:
			continue
		# « disponible » et non « offert » : la lueur doit se voir DE LOIN,
		# puisque tout le probleme est de trouver ces objets. Sur « offert »,
		# elle ne se serait allumee qu'une fois le joueur a portee — un phare
		# qui ne s'allume qu'au port.
		var cible := 0.0
		if p.disponible(mission):
			cible = PRES if p == vise else LOIN
		var force := float(_forces.get(p, 0.0))
		force = move_toward(force, cible, VITESSE * delta)
		_forces[p] = force
		_appliquer(p, force)


func _appliquer(p: Point, force: float) -> void:
	var mat: StandardMaterial3D = _overlays.get(p)
	if mat == null:
		if force <= 0.001:
			return
		mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.albedo_color = TEINTE
		# Sans ca, la lueur disparait des qu'un grain de sable passe devant : on
		# veut qu'elle traverse un peu, c'est ce qui la rend reperable.
		mat.no_depth_test = false
		_overlays[p] = mat
		for mi in _maillages(p):
			mi.material_overlay = mat
	mat.albedo_color = Color(TEINTE.r, TEINTE.g, TEINTE.b, force)


# Les maillages sous ce point. Un point est un Node3D nu : sa geometrie est un
# enfant instancie, et elle peut etre a plusieurs etages.
static func _maillages(n: Node) -> Array[MeshInstance3D]:
	var trouves: Array[MeshInstance3D] = []
	for e in n.get_children():
		if e is MeshInstance3D:
			trouves.append(e)
		trouves.append_array(_maillages(e))
	return trouves
