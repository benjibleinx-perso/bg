# EST-CE QUE LA TOLE EST POSEE SUR LA ROUTE ?
#
#     godot --headless --path game --script res://verifs/test_assiette.gd
#
# POURQUOI CETTE MESURE EXISTE : Guillaume, retour 2.0 — « Le RV vole quelques
# centimetres au dessus de la route. Le mettre a bon niveau de sol. » Il en
# volait vingt, et l'Aztek etait enfoncee de dix-neuf dans l'autre sens depuis
# le 27/07/2026.
#
# CE QUI REND CE DEFAUT INVISIBLE : rien ne le signale. Les roues touchent, la
# suspension travaille, la physique est juste — seule la tole est au mauvais
# endroit, et une voiture basse ressemble a une voiture basse.
#
# ON MESURE LES DEUX VEHICULES AU MEME ENDROIT, A PLAT. Le camping-car vit au
# fond du fosse, incline : mesure la-bas, il annoncait « 75 cm sous le sol »,
# ce qui melangeait l'assiette et la pente et ne decrivait rien. On le pose
# donc a cote de la voiture. Ce n'est pas un franchissement qu'on teste ici,
# c'est une geometrie : le deplacer est legitime, et sans lui il n'y a rien a
# lire.
#
# ET ON MESURE LA BOITE ENGLOBANTE EN GLOBAL, apres transformation : celle d'un
# maillage decrit sa geometrie dans son propre repere, et un modele pose a
# l'envers ou mis a l'echelle donnerait un nombre sans rapport (piege 5).
extends SceneTree

## Le temps laisse aux suspensions pour se poser apres qu'on a repose le
## camping-car. Mesure avant, on mesure une chute.
const POSE := 220
const DEPLACEMENT := 20

## Ce qu'on tolere entre le sol et le bas de la tole, en metres. Les deux
## modeles dessinent leurs propres roues : leur boite englobante descend donc
## jusqu'au plan de contact, et l'ecart attendu est zero.
const ECART_MAX := 0.03

var _n := 0
var _pose := false
var _erreurs: Array[String] = []


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


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


## Le bas de la tole, en hauteur globale. INF si le vehicule n'a aucun maillage.
func _bas_de_la_tole(v: Node3D) -> float:
	var bas := INF
	for m in v.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		if mi.mesh == null or not mi.visible:
			continue
		var boite := mi.global_transform * mi.mesh.get_aabb()
		bas = minf(bas, boite.position.y)
	return bas


## La hauteur du sol sous un corps, NAN s'il n'y a rien dessous.
func _sol_sous(corps: PhysicsBody3D) -> float:
	var espace := corps.get_world_3d().direct_space_state
	var haut := corps.global_position + Vector3.UP * 3.0
	var q := PhysicsRayQueryParameters3D.create(haut, haut - Vector3.UP * 40.0)
	q.exclude = [corps.get_rid()]
	var r := espace.intersect_ray(q)
	return NAN if r.is_empty() else (r["position"] as Vector3).y


func _process(_d: float) -> bool:
	_n += 1
	var voiture := _trouver(root, "Vehicule") as VehicleBody3D
	var rv := _trouver(root, "CampingCar") as VehicleBody3D
	if voiture == null or rv == null:
		_verifier(false, "les deux vehicules sont dans le monde")
		return _conclure()

	if not _pose and _n > DEPLACEMENT:
		rv.freeze = false
		rv.global_position = voiture.global_position + Vector3(9.0, 1.2, 0.0)
		rv.global_rotation = voiture.global_rotation
		rv.linear_velocity = Vector3.ZERO
		rv.angular_velocity = Vector3.ZERO
		_pose = true
		return false

	if _n < POSE:
		return false

	for v: VehicleBody3D in [voiture, rv]:
		var sol := _sol_sous(v)
		var tole := _bas_de_la_tole(v)
		if is_nan(sol) or is_inf(tole):
			_verifier(false, "%s a un sol sous lui et une tole a mesurer" % v.name)
			continue
		# Une mesure prise sur un vehicule encore en mouvement decrit son
		# rebond. On dit donc l'assiette avec le reste : un nombre juste sur
		# une caisse penchee resterait un nombre faux.
		var ecart := tole - sol
		print("    %-11s sol %.3f | bas de tole %.3f | %+.1f cm | assiette %.2f deg"
				% [v.name, sol, tole, ecart * 100.0,
						rad_to_deg(v.global_rotation.x)])
		_verifier(absf(ecart) <= ECART_MAX,
				"%s pose sa tole sur la route (%+.1f cm, seuil %.0f)"
						% [v.name, ecart * 100.0, ECART_MAX * 100.0])

	return _conclure()


func _conclure() -> bool:
	print("")
	if _erreurs.is_empty():
		print("TEST ASSIETTE OK")
		quit(0)
	else:
		printerr("TEST ASSIETTE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true
