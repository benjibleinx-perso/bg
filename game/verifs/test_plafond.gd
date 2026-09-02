# CHAQUE VEHICULE PLAFONNE-T-IL A SA PROPRE VITESSE ?
#
#     godot --headless --path game --script res://verifs/test_plafond.gd
#
# POURQUOI CETTE MESURE EXISTE : Benjamin, en jouant la 0.58.51 — « le
# camping-car va beaucoup trop vite ». La masse et la poussee etaient propres a
# chaque vehicule depuis le 25/08/2026 ; la VITESSE MAXIMALE ne l'etait pas.
# Tous montaient aux 130 km/h de l'Aztek, y compris onze tonnes de tole poussees
# par les 4 000 N qu'il a fallu leur donner pour sortir du fosse.
#
# CE QU'ELLE NE FAIT PAS : relire `vitesse_max_propre_kmh` dans la scene. Ce
# serait verifier que le nombre est ecrit, pas qu'il agit — le camping-car
# portait deja onze tonnes ecrites et roulait a 1 350 kg. On mesure donc la
# POUSSEE que le vehicule decide, pied au plancher, a une vitesse donnee : elle
# doit tomber a zero au-dela du plafond et pas avant.
#
# ON N'ACCELERE PAS JUSQU'A LA VITESSE VOULUE, ON LA POSE. Atteindre 140 km/h
# demanderait huit cents metres de ligne droite et une minute par essai ; ce qui
# est teste ici n'est pas l'acceleration mais la DECISION prise a cette
# vitesse-la. La vitesse est donc imposee le long du nez du vehicule, et
# maintenue le temps que la physique tourne.
extends SceneTree

const POSE := 40

## Images de physique laissees au vehicule entre la pose de la vitesse et la
## lecture de sa poussee. Il en faut au moins une : `_propulser` decide dans
## `_physics_process`, et lire avant reviendrait a lire la decision precedente.
const ATTENTE := 4

## Les plafonds attendus, en km/h. Ils vivent dans les scenes ; ce tableau dit
## ce que le jeu doit en faire.
const PLAFOND_VOITURE := 130.0
const PLAFOND_CAMPING_CAR := 75.0

var _n := 0
var _essai := 0
var _attente := 0
var _prepare := false
var _erreurs: Array[String] = []
var _essais: Array[Dictionary] = []


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())

	# Deux vitesses par vehicule, une de chaque cote de son plafond. Une seule
	# ne dirait rien : un vehicule qui ne pousse JAMAIS passerait l'essai du
	# haut sans qu'on s'en apercoive.
	_essais = [
		{"noeud": "Vehicule", "kmh": PLAFOND_VOITURE - 20.0, "pousse": true},
		{"noeud": "Vehicule", "kmh": PLAFOND_VOITURE + 10.0, "pousse": false},
		{"noeud": "CampingCar", "kmh": PLAFOND_CAMPING_CAR - 15.0, "pousse": true},
		{"noeud": "CampingCar", "kmh": PLAFOND_CAMPING_CAR + 10.0, "pousse": false},
		# ET LA PREUVE QUE LES DEUX PLAFONDS SONT BIEN DISTINCTS : a 90 km/h le
		# camping-car doit avoir coupe, la voiture doit pousser encore. C'est
		# exactement la vitesse ou l'un doublait l'autre.
		{"noeud": "CampingCar", "kmh": 90.0, "pousse": false},
		{"noeud": "Vehicule", "kmh": 90.0, "pousse": true},
	]


func _verifier(ok: bool, msg: String) -> void:
	if ok:
		print("  ok   " + msg)
	else:
		_erreurs.append(msg)
		printerr("  ECHEC " + msg)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


## Pose le vehicule a la vitesse voulue, dans l'axe de son nez.
##
## La vitesse est SIGNEE le long de -Z pour le vehicule : posee autrement, le
## code croirait qu'on recule et la commande d'avance deviendrait un freinage.
func _lancer(v: VehicleBody3D, kmh: float) -> void:
	v.linear_velocity = -v.global_transform.basis.z * (kmh / 3.6)


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	if _essai >= _essais.size():
		return _conclure()

	var e := _essais[_essai]
	var nom: String = e["noeud"]
	var v := _trouver(root, nom) as VehicleBody3D
	if v == null:
		_verifier(false, "%s existe et se conduit" % nom)
		_essai += 1
		return false

	if not _prepare:
		# UN VEHICULE QUI N'EST PAS CONDUIT NE CALCULE RIEN : son
		# `_physics_process` est coupe tant que personne n'a pris le volant, et
		# `engine_force` garderait la valeur de la derniere image jouee.
		v.freeze = false
		v.call("prendre_le_volant")
		Input.action_press("gaz")
		_prepare = true
		_attente = ATTENTE

	_lancer(v, e["kmh"])

	if _attente > 0:
		_attente -= 1
		return false

	var kmh: float = v.call("vitesse_kmh")
	var plafond: float = v.call("vitesse_max_kmh")
	var pousse: bool = absf(v.engine_force) > 0.0
	var attendu: bool = e["pousse"]

	print("    %-11s a %5.1f km/h (plafond %.0f) : poussee %.0f N"
			% [nom, kmh, plafond, v.engine_force])
	_verifier(pousse == attendu,
			"%s %s a %.0f km/h" % [nom,
					"pousse encore" if attendu else "a coupe sa poussee",
					e["kmh"]])

	Input.action_release("gaz")
	v.call("quitter_le_volant")
	_prepare = false
	_essai += 1
	return false


func _conclure() -> bool:
	print("")
	if _erreurs.is_empty():
		print("TEST PLAFOND OK")
		quit(0)
	else:
		printerr("TEST PLAFOND ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true
