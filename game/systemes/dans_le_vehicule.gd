# Se colle sur le camping-car, et prend sa pose avec lui.
#
# POURQUOI CE SCRIPT EXISTE.
#
# Les deux corps de l'ouverture etaient ancres sur le FOSSE, comme le reste du
# site du crash. C'est juste pour ce qui est au sol — les objets a ramasser, la
# portiere, Jesse — mais faux pour ce qui est DEDANS : le camping-car penche de
# neuf degres de tangage et seize de roulis, et deux corps poses a plat a cote
# de lui ne sont pas a l'arriere du vehicule, ils sont dans le sable.
#
# C'est ce qu'on voyait en 0.56.0, et c'etait ecrit dans la note de version.
#
# ON NE RECOPIE PAS SA TRANSFORMATION, ON LA SUIT. Les trois angles vivent dans
# desert.gd, dans des constantes commentees ; les redire ici en ferait une
# seconde verite qui divergerait au premier reglage. Le vehicule est pose par le
# desert, on lui demande ou il est, et on se met dedans.
#
# Le decalage est exprime DANS SON REPERE : « deux metres vers l'arriere, un
# demi-metre au-dessus du plancher » reste vrai que la caisse soit a plat ou
# couchee dans un fosse.
class_name DansLeVehicule
extends Node3D

## Ou l'on se place par rapport au vehicule, dans son propre repere.
@export var decalage: Vector3 = Vector3.ZERO

## Le nom du noeud a suivre, tel que desert.gd le baptise.
@export var vehicule: String = "CampingCar"

## ON SE POSE UNE FOIS, OU ON SUIT ?
##
## Par defaut on se pose et on n'y revient plus, et c'est ce qu'il faut pour la
## plupart : les deux corps sont poses dans l'habitacle, puis TRACTES — un
## suivi continu leur reprendrait la position a chaque image et ils ne
## quitteraient jamais le camping-car.
##
## Mais la fumee du moteur et les phares appartiennent a la CAISSE. Elle est
## gelee tant qu'on ne l'a pas demarree, donc se poser une fois suffisait ; le
## jour ou elle repart, ils restaient en arriere, plantes dans le sable a
## l'endroit du crash pendant qu'on s'eloigne. « La fumee suit le camping-car
## au lieu de rester au sol a l'endroit du crash » — retour du 23/08/2026,
## dernier point de code du lot F.
@export var suit: bool = false


func _ready() -> void:
	# Le camping-car est instancie par desert.gd pendant SON _ready : on ne peut
	# pas le trouver depuis le notre. Une image d'attente suffit, et c'est la
	# meme raison qu'au reglage de visibilite de l'ancrage.
	await get_tree().process_frame
	var d := Desert.courant(self)
	if d == null:
		push_error("dans_le_vehicule : aucun desert dans la scene")
		return
	var cc := d.get_node_or_null(NodePath(vehicule)) as Node3D
	if cc == null:
		push_error("dans_le_vehicule : le desert ne pose aucun '%s'" % vehicule)
		return
	# ON NE REPLIE PAS SUR LA POSITION DE LA SCENE EN CAS D'ECHEC — meme regle
	# que l'ancrage : un placement rate qui laisse le noeud ou il etait, c'est
	# la panne qu'on repare, pas une solution de secours.
	global_transform = cc.global_transform.translated_local(decalage)

	_cible = cc
	set_physics_process(suit)


## Le vehicule qu'on suit, garde quand on doit y revenir.
var _cible: Node3D


# ON SUIT DANS LA PHYSIQUE, PAS DANS LE RENDU.
#
# La caisse est un VehicleBody3D : sa transformation est ecrite par le moteur
# physique. La lire dans _process revient a la lire entre deux mises a jour, et
# la fumee tremblerait d'un demi-metre en arriere a chaque image — le genre de
# defaut qu'on met sur le compte des particules.
func _physics_process(_delta: float) -> void:
	if _cible == null or not is_instance_valid(_cible):
		set_physics_process(false)
		return
	global_transform = _cible.global_transform.translated_local(decalage)
