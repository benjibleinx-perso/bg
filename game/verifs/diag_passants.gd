# Sur quoi tombent les trajets de passants, mesure au rayon.
#
#   godot --headless --path game --script res://verifs/diag_passants.gd
#
# Ce diagnostic existe parce que test_foule.gd compte comme « passe sous la
# carte » tout passant dont le y descend sous 0,05 m. Or le trottoir est a
# 0,18 m et la chaussee a 0,01 m : le meme compteur denonce donc une chute
# dans le vide et une simple marche sur la chaussee, qui n'ont ni la meme
# cause ni la meme correction.
#
# ON NE MESURE PAS LES 26 PASSANTS POSES, ON MESURE LES 231 TRAJETS.
#
# Les trajets du generateur portent tous y = 0.20, la hauteur du trottoir.
# C'est une INTENTION : elle est ecrite dans le fichier, elle ne prouve rien.
# Ce qui compte est ce qu'il y a REELLEMENT sous ce point, et seul un rayon le
# dit. Les vingt-six passants poses n'en sont qu'un echantillon tire au sort.
extends SceneTree

const ROUTES := "res://assets/ville/ville_lampes.json"

# Doivent correspondre a outils/gen_ville.py. Verifiees le 2026-08-08.
const H_TROTTOIR := 0.18
const Z_ROUTE := 0.01
const MARGE := 0.04

var _n := 0


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


func _sol_sous(espace: PhysicsDirectSpaceState3D, p: Vector3) -> float:
	# On part d'un metre au-dessus du point vise et on descend de trois : de
	# quoi traverser un trottoir manque et retrouver la chaussee dessous.
	var q := PhysicsRayQueryParameters3D.create(
			p + Vector3(0.0, 1.0, 0.0), p - Vector3(0.0, 2.0, 0.0))
	q.collide_with_areas = false
	var t := espace.intersect_ray(q)
	return NAN if t.is_empty() else float(t["position"].y)


func _process(_d: float) -> bool:
	_n += 1
	# La physique doit avoir construit ses formes avant qu'un rayon veuille
	# dire quelque chose. Trente images, comme les autres verifs.
	if _n < 30:
		return false

	var data = JSON.parse_string(FileAccess.get_file_as_string(ROUTES))
	var trajets: Array = data.get("pietons", [])
	print("--- %d trajet(s) de passant, mesure au rayon ---" % trajets.size())

	var espace := root.get_world_3d().direct_space_state
	var sur_trottoir := 0
	var sur_chaussee := 0
	var ailleurs := 0
	var dans_le_vide := 0
	var paliers := {}
	var exemples: Array[String] = []

	for t in trajets:
		var v: Array = t.get("depart", [])
		if v.size() < 3:
			continue
		var p := Vector3(float(v[0]), float(v[1]), float(v[2]))
		var y := _sol_sous(espace, p)
		if is_nan(y):
			dans_le_vide += 1
			continue
		var cm := roundi(y * 100.0)
		paliers[cm] = int(paliers.get(cm, 0)) + 1
		if absf(y - H_TROTTOIR) <= MARGE:
			sur_trottoir += 1
		elif absf(y - Z_ROUTE) <= MARGE:
			sur_chaussee += 1
			if exemples.size() < 6:
				exemples.append("  chaussee  x=%7.1f  z=%7.1f  sol a %5.2f m"
						% [p.x, p.z, y])
		else:
			ailleurs += 1
			if exemples.size() < 6:
				exemples.append("  ailleurs  x=%7.1f  z=%7.1f  sol a %5.2f m"
						% [p.x, p.z, y])

	var total := maxi(1, trajets.size())
	print("  sur le trottoir : %4d  (%.0f %%)" % [sur_trottoir,
			100.0 * sur_trottoir / total])
	print("  sur la chaussee : %4d  (%.0f %%)" % [sur_chaussee,
			100.0 * sur_chaussee / total])
	print("  ailleurs        : %4d  (%.0f %%)" % [ailleurs,
			100.0 * ailleurs / total])
	print("  aucun sol       : %4d" % dans_le_vide)
	print("  hauteurs de sol trouvees (cm : combien) : %s" % str(paliers))
	for e in exemples:
		print(e)

	# --- LES MURS SONT-ILS SOLIDES ? -------------------------------------
	#
	# « Les passants traversent les murs » est ecrit dans le journal et n'a
	# jamais ete mesure. La ville fabrique pourtant ses corps statiques a la
	# volee (ville.gd, create_trimesh_collision) et un passant masque la
	# couche 1. On verifie donc l'inverse de ce qu'on croit : depuis chaque
	# trajet, quatre rayons horizontaux a hauteur de torse. Une facade est a
	# environ 1,5 m du milieu du trottoir.
	print("")
	print("--- les murs, vus depuis les trajets ---")
	var avec_mur := 0
	var sans_mur := 0
	var noms := {}
	for t in trajets:
		var v: Array = t.get("depart", [])
		if v.size() < 3:
			continue
		var p := Vector3(float(v[0]), 1.0, float(v[2]))
		var touche := false
		for d in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			var q := PhysicsRayQueryParameters3D.create(p, p + d * 4.0)
			q.collide_with_areas = false
			var r := espace.intersect_ray(q)
			if not r.is_empty():
				touche = true
				# QUI arrete, pas SI quelque chose arrete. Un lampadaire et une
				# facade sont tous deux « un obstacle solide », et confondre les
				# deux ferait conclure que les murs existent alors qu'on aurait
				# mesure du mobilier.
				var n := (r["collider"] as Node)
				var nom := n.name if n.get_parent() == null else n.get_parent().name
				noms[nom] = int(noms.get(nom, 0)) + 1
				break
		if touche:
			avec_mur += 1
		else:
			sans_mur += 1
	print("  un obstacle solide a moins de 4 m : %d" % avec_mur)
	print("  rien du tout autour             : %d" % sans_mur)
	print("  ce qui arrete, par nom :")
	for nom in noms:
		print("    %-40s %d" % [nom, noms[nom]])

	quit(0)
	return true
