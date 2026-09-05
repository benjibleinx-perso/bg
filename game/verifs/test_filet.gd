# LE FILET RATTRAPE-T-IL CE QUI TOMBE DU DECOR ?
#
#     godot --path game --fixed-fps 60 --script res://verifs/test_filet.gd
#
# CE QUE CE CONTROLE REPRODUIT : la partie du 04/09/2026. Un camping-car qui
# sort du desert par l'ouest a 62 km/h, et vingt secondes plus tard il est a
# 1 887 m sous le sol, a 450 km/h, toujours « au volant ». Puis Benjamin, le
# meme soir, par le sud, sur la piste, en jouant normalement.
#
# On joue les deux facons de tomber : a pied, en marchant vers l'ouest depuis
# le bord du desert ; au volant, en montant dans la voiture comme un joueur —
# E a la portiere — et en mettant les gaz vers le meme bord. Dans les deux cas
# on exige la meme chose : quelques secondes plus tard, le sujet est de
# nouveau AU SOL, a moins de trente metres de la ou il roulait, l'etape de la
# mission n'a pas bouge, et la trace porte l'evenement.
#
# CE QUI EST PLACE A LA MAIN, ET POURQUOI C'EST PERMIS ICI. Le joueur et la
# voiture sont poses au bord du desert : la question n'est pas « peut-on y
# arriver » — c'est la suite parcours qui la pose — mais « que se passe-t-il
# quand on en sort ». Ce qu'on mesure, le rattrapage, commence APRES la pose,
# et rien dans la pose ne le rend vrai. Piege 19, verifie.
#
# A PAS DE TEMPS FIXE : une suite qui joue rend deux verdicts sur le meme
# depot sans ca. Piege 43.
extends SceneTree

const POSE := 60

## Combien d'images on attend un rattrapage. A 60 par seconde, quinze
## secondes : il en faut six pour marcher jusqu'au bord, une pour tomber
## sous le seuil, et un fondu aller-retour.
const PATIENCE := 900

## Le bord ouest du desert : COTE / 2 a l'ouest du CENTRE de gen_desert.py.
## On le RELIT sur le sol plutot que de le recopier — voir _bord_ouest.
const DESERT_CENTRE := Vector3(900.0, 0.0, -900.0)

var _n := 0
var _etape := 0
var _monde: Node
var _controleur: Node
var _joueur: Joueur
var _vehicule: Vehicule
var _filet: Node
var _mission: Mission
var _camera: Node
var _erreurs: Array[String] = []

var _depuis := 0
var _etape_mission := ""
var _dernier_au_sol := Vector3.ZERO
var _rattrapages_avant := 0
var _bord := Vector3.ZERO


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
	# ON DEMARRE DEHORS. La partie s'ouvre dans le salon de Walter ; ici on
	# veut un personnage libre de ses pas, et le reglage se vide AVANT que le
	# controleur le lise dans son _ready.
	var c := _monde.find_child("Controleur", true, false)
	if c != null:
		c.set("commencer_chez", NodePath())
	root.add_child(_monde)


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


## Le sol sous un point, ou INF s'il n'y en a pas.
func _sol_sous(x: float, z: float) -> float:
	var espace := _joueur.get_world_3d().direct_space_state
	var requete := PhysicsRayQueryParameters3D.create(
			Vector3(x, 40.0, z), Vector3(x, -40.0, z))
	requete.collision_mask = 1
	var touche := espace.intersect_ray(requete)
	if touche.is_empty():
		return INF
	return (touche["position"] as Vector3).y


## OU S'ARRETE LE SOL, mesure : on avance vers l'ouest par pas d'un metre
## depuis le centre du desert jusqu'a ne plus rien toucher. Le chiffre de
## gen_desert.py — 670 — n'est pas recopie : le jour ou le terrain change,
## c'est le sol qui a raison.
func _bord_ouest(z: float) -> Vector3:
	var x := DESERT_CENTRE.x
	var dernier := Vector3.INF
	while x > DESERT_CENTRE.x - 400.0:
		var y := _sol_sous(x, z)
		if y == INF:
			break
		dernier = Vector3(x, y, z)
		x -= 1.0
	return dernier


func _sujet() -> Node3D:
	return _controleur.call("sujet") as Node3D


func _au_sol(s: Node3D) -> bool:
	if s is Joueur:
		return (s as Joueur).is_on_floor()
	if s is Vehicule:
		return (s as Vehicule).au_sol()
	return false


func _lacher_tout() -> void:
	for a in ["gaz", "frein", "gauche", "droite", "interagir", "sprint"]:
		Input.action_release(a)


func _process(_d: float) -> bool:
	_n += 1

	# ---------------------------------------------------------- 0. tout est la
	if _etape == 0:
		if _n < POSE:
			return false
		_controleur = _trouver(root, "Controleur")
		_joueur = _trouver(root, "Joueur") as Joueur
		_vehicule = _trouver(root, "Vehicule") as Vehicule
		_filet = _trouver(root, "Filet")
		_mission = Mission.courante(_monde)
		_camera = root.get_viewport().get_camera_3d()
		if _camera == null:
			var vp := _trouver(root, "Rendu") as SubViewport
			if vp != null:
				_camera = vp.get_camera_3d()
		for n in [["Controleur", _controleur], ["Joueur", _joueur],
				["Vehicule", _vehicule], ["Filet", _filet], ["Mission", _mission]]:
			if n[1] == null:
				printerr("  ECHEC %s introuvable" % n[0])
				quit(1)
				return true

		print("\n--- le filet est branche ---")
		_verifier(_filet.is_in_group("filet"), "le filet est dans son groupe")
		_verifier(_filet.is_physics_processing(),
				"il surveille (il a trouve le controleur et ses reglages)")
		_verifier(_controleur.has_method("rattraper"),
				"le controleur sait reposer le sujet")
		_verifier(_vehicule.has_method("au_sol"),
				"le vehicule sait dire si ses roues touchent")
		_verifier(_camera != null and _camera.has_method("secouer"),
				"la camera sait se secouer")

		_bord = _bord_ouest(-900.0)
		_verifier(_bord != Vector3.INF, "le desert a un bord ouest mesurable")
		if _bord == Vector3.INF:
			_etape = 9
			return false
		print("       le sol s'arrete a x = %.0f (y = %.2f)" % [_bord.x, _bord.y])
		var au_dela := _sol_sous(_bord.x - 30.0, _bord.z)
		_verifier(au_dela == INF,
				"et trente metres plus loin il n'y a rien dessous"
				+ (" (sol a y = %.1f)" % au_dela if au_dela != INF else ""))

		# --------------------------------------------------- 1. A PIED, A L'OUEST
		print("\n--- a pied, on marche vers l'ouest et on sort du terrain ---")
		var depart := Vector3(_bord.x + 8.0, _bord.y + 0.4, _bord.z)
		_joueur.global_position = depart
		_joueur.velocity = Vector3.ZERO
		# Le personnage marche par rapport a la CAMERA : « devant » est
		# (-sin cap, 0, -cos cap), donc un cap de +90 degres regarde vers -X.
		_joueur.rotation.y = PI / 2.0
		if _camera != null and _camera.has_method("recaler"):
			_camera.call("recaler")
		_etape_mission = _mission.cle_etape()
		_rattrapages_avant = int(_filet.call("rattrapages"))
		_depuis = _n
		_etape = 1
		return false

	if _etape == 1:
		var s := _sujet()
		if _n == _depuis + 30:
			Input.action_press("gaz")
		if _au_sol(s) and s.global_position.y > -1.0:
			_dernier_au_sol = s.global_position
		if int(_filet.call("rattrapages")) > _rattrapages_avant:
			_lacher_tout()
			_depuis = _n
			_etape = 2
			return false
		if _n > _depuis + PATIENCE:
			_lacher_tout()
			_verifier(false, "a pied, le filet ne rattrape jamais (le sujet est en %s, %d endroit(s) retenus)"
					% [s.global_position, int(_filet.call("endroits_retenus", s))])
			_etape = 3
		return false

	if _etape == 2:
		# On laisse le fondu se finir et la physique reposer le corps.
		if _n < _depuis + 90:
			return false
		var s := _sujet()
		var d: Dictionary = _filet.call("dernier")
		print("       tombe en %s, repose en %s" % [d.get("tombe"), d.get("repose")])
		print("       dernier point au sol vu par ce test : %s" % _dernier_au_sol)
		var ecart := Vector2(s.global_position.x, s.global_position.z).distance_to(
				Vector2(_dernier_au_sol.x, _dernier_au_sol.z))
		_verifier(s is Joueur, "le sujet repose est bien le personnage")
		_verifier(s.global_position.y > -1.0,
				"il est de nouveau au-dessus du sol (y = %.2f)" % s.global_position.y)
		_verifier(_au_sol(s), "et il a les pieds dessus")
		_verifier(ecart < 30.0,
				"a moins de trente metres de la ou il marchait (%.1f m)" % ecart)
		_verifier(s.global_position.x > _bord.x,
				"du bon cote du bord (x = %.1f, bord a %.1f)" % [s.global_position.x, _bord.x])
		# Le demi-tour : il regardait vers -X, il regarde maintenant vers +X.
		var devant := -s.global_transform.basis.z
		_verifier(devant.x > 0.5,
				"et il tourne le dos au vide (devant = %s)" % devant)
		_verifier(_mission.cle_etape() == _etape_mission,
				"l'etape de la mission n'a pas bouge ('%s')" % _mission.cle_etape())
		_verifier(not bool(_controleur.call("en_transition")),
				"le fondu est fini, le jeu a rendu la main")
		_etape = 3
		return false

	# ----------------------------------------------------- 3. AU VOLANT, PAREIL
	if _etape == 3:
		print("\n--- au volant, on met les gaz vers l'ouest et on sort du terrain ---")
		# La voiture est posee a quarante metres du bord, tournee vers lui ;
		# le personnage a sa portiere. Monter, lui, se JOUE : E a la portiere,
		# comme un joueur. Le vehicule ne devient le sujet du controleur que
		# par ce chemin-la, et c'est ce sujet-la que le filet doit reposer.
		var pos := Vector3(_bord.x + 40.0, _bord.y + 0.8, _bord.z)
		_vehicule.ignorer_les_chocs()
		_vehicule.linear_velocity = Vector3.ZERO
		_vehicule.angular_velocity = Vector3.ZERO
		_vehicule.global_position = pos
		_vehicule.rotation = Vector3(0.0, PI / 2.0, 0.0)
		_joueur.global_position = pos + Vector3(0.0, 0.0, 2.2)
		_joueur.velocity = Vector3.ZERO
		_joueur.rotation.y = 0.0
		if _camera != null and _camera.has_method("recaler"):
			_camera.call("recaler")
		_depuis = _n
		_etape = 4
		return false

	if _etape == 4:
		if _n < _depuis + 30:
			return false
		if _n == _depuis + 30:
			Input.action_press("interagir")
			return false
		if _n == _depuis + 32:
			Input.action_release("interagir")
			return false
		if _n < _depuis + 45:
			return false
		var au_volant := bool(_controleur.call("au_volant"))
		_verifier(au_volant, "E a la portiere met Walter au volant"
				+ ("" if au_volant else " — le jeu propose : « %s »" % _propose()))
		if not au_volant:
			_etape = 9
			return false
		_etape_mission = _mission.cle_etape()
		_rattrapages_avant = int(_filet.call("rattrapages"))
		_dernier_au_sol = Vector3.ZERO
		Input.action_press("gaz")
		_depuis = _n
		_etape = 5
		return false

	if _etape == 5:
		var s := _sujet()
		if _au_sol(s) and s.global_position.y > -1.0:
			_dernier_au_sol = s.global_position
		if int(_filet.call("rattrapages")) > _rattrapages_avant:
			_lacher_tout()
			_depuis = _n
			_etape = 6
			return false
		if _n > _depuis + PATIENCE:
			_lacher_tout()
			_verifier(false, "au volant, le filet ne rattrape jamais (le sujet est en %s, %d endroit(s) retenus)"
					% [s.global_position, int(_filet.call("endroits_retenus", s))])
			_etape = 9
		return false

	if _etape == 6:
		if _n < _depuis + 90:
			return false
		var s := _sujet()
		var d: Dictionary = _filet.call("dernier")
		print("       tombe en %s, repose en %s" % [d.get("tombe"), d.get("repose")])
		print("       dernier point au sol vu par ce test : %s" % _dernier_au_sol)
		var ecart := Vector2(s.global_position.x, s.global_position.z).distance_to(
				Vector2(_dernier_au_sol.x, _dernier_au_sol.z))
		_verifier(s is Vehicule, "le sujet repose est bien la voiture")
		_verifier(bool(_controleur.call("au_volant")), "et Walter est toujours au volant")
		_verifier(s.global_position.y > -1.0,
				"elle est de nouveau au-dessus du sol (y = %.2f)" % s.global_position.y)
		_verifier(_au_sol(s), "et elle a ses quatre roues dessus")
		_verifier(ecart < 30.0,
				"a moins de trente metres de la ou elle roulait (%.1f m)" % ecart)
		_verifier(s.global_position.x > _bord.x,
				"du bon cote du bord (x = %.1f, bord a %.1f)" % [s.global_position.x, _bord.x])
		var kmh := float(s.call("vitesse_kmh"))
		_verifier(kmh < 5.0, "a l'arret (%.1f km/h)" % kmh)
		_verifier(_mission.cle_etape() == _etape_mission,
				"l'etape de la mission n'a pas bouge ('%s')" % _mission.cle_etape())

		# ------------------------------------------------- 7. LA TRACE LE DIT
		print("\n--- et la trace le raconte ---")
		var chemin := "user://trace.jsonl"
		var lignes := 0
		var filets := 0
		if FileAccess.file_exists(chemin):
			for l in FileAccess.get_file_as_string(chemin).split("\n", false):
				lignes += 1
				if l.find("\"quoi\":\"filet\"") >= 0:
					filets += 1
		_verifier(lignes > 0, "la trace existe (%d ligne(s))" % lignes)
		_verifier(filets >= 2,
				"elle porte les deux rattrapages (%d evenement(s) 'filet')" % filets)
		_etape = 9
		return false

	print("")
	if _erreurs.is_empty():
		print("TEST FILET OK")
		quit(0)
	else:
		printerr("TEST FILET ECHEC  %d echec(s)" % _erreurs.size())
		quit(1)
	return true


## Ce que le jeu propose a l'ecran, pour que l'echec designe le coupable.
func _propose() -> String:
	var inv := _trouver(root, "Invite") as Label
	return inv.text if inv != null else "rien du tout"
