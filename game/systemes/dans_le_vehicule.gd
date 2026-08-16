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
