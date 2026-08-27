# Verifie que les commandes deplacent le vehicule dans le bon sens.
#
#   godot --path game --script res://verifs/test_sens.gd
#
# Ecrit pour trancher empiriquement une question de convention plutot que de
# la deduire de la documentation — et garde ensuite comme non-regression : le
# VehicleBody3D de Godot pousse vers +Z alors que le nez pointe vers -Z, et
# c'est exactement le genre de piege qui revient a la premiere refonte.
#
# Sort en 0 si avancer avance, en 1 sinon.
extends SceneTree

const IMAGES_POSE := 40      # le temps que la caisse se pose sur ses roues
const IMAGES_TEST := 150

var _vehicule: Node
var _depart: Vector3
var _nez: Vector3
var _n := 0


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


func _process(_d: float) -> bool:
	_n += 1

	if _n == IMAGES_POSE:
		_vehicule = _chercher(root)
		if _vehicule == null:
			printerr("aucun vehicule conduisible trouve")
			quit(1)
			return true
		# ON DIT LEQUEL, et ce n'est pas de la coquetterie : c'est la ligne qui
		# aurait fait gagner une demi-heure. Voir _chercher.
		print("vehicule      « %s » en %s" % [_vehicule.name, _vehicule.global_position])
		_depart = _vehicule.global_position
		_nez = -_vehicule.global_transform.basis.z

	if _n > IMAGES_POSE and _vehicule != null:
		# On appelle la logique du controleur avec une commande d'avance
		# franche, sans passer par le clavier.
		_vehicule.call("_propulser", 1.0, _vehicule.call("vitesse_kmh"))
		_vehicule.steering = 0.0

	if _n < IMAGES_TEST:
		return false

	var delta: Vector3 = _vehicule.global_position - _depart
	var projection := delta.dot(_nez)
	print("nez           %s" % _nez)
	print("deplacement   %s  (%.2f m)" % [delta, delta.length()])
	print("projection    %.3f m sur le nez" % projection)
	print("")
	if projection > 0.5:
		print("OK : la commande d'avance fait avancer (%.2f m)" % projection)
		quit(0)
	elif projection < -0.5:
		printerr("ECHEC : la commande d'avance fait RECULER (%.2f m)" % projection)
		quit(1)
	else:
		printerr("ECHEC : le vehicule n'a pas bouge de facon exploitable")
		quit(1)
	return true


# LA VOITURE DU JOUEUR, ET PAS LE PREMIER VENU.
#
# CE QUE CETTE FONCTION RENDAIT AVANT : le premier VehicleBody3D de l'arbre.
# C'etait juste tant qu'il n'y en avait qu'un. Depuis que le camping-car est
# conduisible et que la partie COMMENCE dans le fosse, elle rendait une caisse
# de onze tonnes couchee dans une cuvette, moteur eteint — qui ne bouge pas
# d'un centimetre, quelle que soit la commande. La suite accusait donc les
# commandes du jeu d'etre cassees pendant que la voiture roulait tres bien
# trois cents metres plus loin.
#
# Rien ne prevenait : le message disait « le vehicule n'a pas bouge », ce qui
# etait rigoureusement exact. C'est le piege 54 sous sa forme « premier
# trouve » — voir docs/11-pieges.md.
#
# On prend donc celui que le monde nomme « Vehicule », c'est-a-dire l'Aztek
# posee dans la rue par scenes/monde.tscn, et on retombe sur l'ancien
# comportement s'il n'existe pas — un jour ou la voiture changera de nom, mieux
# vaut mesurer quelque chose que rien.
func _chercher(n: Node) -> Node:
	var nomme := _par_nom(n, "Vehicule")
	return nomme if nomme != null else _premier(n)


func _par_nom(n: Node, nom: String) -> Node:
	if n is VehicleBody3D and n.name == nom:
		return n
	for e in n.get_children():
		var t := _par_nom(e, nom)
		if t != null:
			return t
	return null


func _premier(n: Node) -> Node:
	if n is VehicleBody3D:
		return n
	for e in n.get_children():
		var t := _premier(e)
		if t != null:
			return t
	return null
