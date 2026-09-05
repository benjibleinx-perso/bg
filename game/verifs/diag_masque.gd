# OU EST LE MASQUE PAR RAPPORT A LA TETE DE WALTER ?
#
#     godot --path game --script res://verifs/diag_masque.gd
#
# Un RELEVE, pas un test. Depuis que Walter porte la chemise verte de la
# saison 1 (walt.glb du 04/09/2026), « le masque flotte au-dessus de son
# crane ». Le point d'accroche est l'os Head, avec un aplomb de 11 cm ecrit
# dans outils.json pour l'ancien squelette. Ce releve imprime, en metres
# depuis les pieds : la position de l'os Head, le sommet du crane du
# maillage, les yeux (reglages.oeil_hauteur), et la boite du masque. C'est
# l'ecart entre le bas du masque et les yeux qui designe la correction.
extends SceneTree

const POSE := 90

var _n := 0
var _monde: Node


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
	var c := _monde.find_child("Controleur", true, false)
	if c != null:
		c.set("commencer_chez", NodePath())
	root.add_child(_monde)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


func _boite_globale(n: Node, boite: AABB, premiere: bool) -> Array:
	# Rend [AABB, premiere] : l'union des boites de tous les MeshInstance3D
	# sous n, en coordonnees monde.
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
		var mi := n as MeshInstance3D
		var b := mi.global_transform * mi.get_aabb()
		if premiere:
			boite = b
			premiere = false
		else:
			boite = boite.merge(b)
	for e in n.get_children():
		var r := _boite_globale(e, boite, premiere)
		boite = r[0]
		premiere = r[1]
	return [boite, premiere]


func _process(_d: float) -> bool:
	_n += 1
	if _n == POSE:
		var eq := _trouver(root, "Equipement")
		if eq != null:
			eq.call("imposer_le_port", "masque", true)
	if _n == POSE + 30:
		_releve()
		quit(0)
		return true
	return false


func _releve() -> void:
	var joueur := _trouver(root, "Joueur") as Node3D
	var squelette := joueur.find_child("Skeleton3D", true, false) as Skeleton3D
	if squelette == null:
		printerr("ECHEC pas de squelette sur le joueur")
		return
	var pieds := joueur.global_position.y
	var reglages := joueur.get("reglages") as Reglages
	printerr("--- Walter : pieds a y=%.3f, yeux regles a %.2f m" % [pieds, reglages.oeil_hauteur if reglages != null else -1.0])

	var idx := squelette.find_bone("Head")
	if idx >= 0:
		var tete := squelette.global_transform * squelette.get_bone_global_pose(idx)
		printerr("    os Head : %.3f m au-dessus des pieds (global %s)" % [tete.origin.y - pieds, tete.origin])
		var enfants: Array[String] = []
		for b in squelette.get_bone_count():
			if squelette.get_bone_parent(b) == idx:
				enfants.append(squelette.get_bone_name(b))
				var e := squelette.global_transform * squelette.get_bone_global_pose(b)
				printerr("    os enfant %s : %.3f m au-dessus des pieds" % [squelette.get_bone_name(b), e.origin.y - pieds])
		if enfants.is_empty():
			printerr("    (Head n'a pas d'os enfant)")
	else:
		printerr("    PAS D'OS Head. Os : %s" % ", ".join(_noms(squelette)))

	# Le maillage du corps, sans le masque : on cherche les MeshInstance3D
	# qui ne sont pas sous une attache.
	var corps := AABB()
	var premiere := true
	for e in squelette.get_children():
		if e is MeshInstance3D:
			var r := _boite_globale(e, corps, premiere)
			corps = r[0]
			premiere = r[1]
	if not premiere:
		printerr("    corps : de %.3f a %.3f m au-dessus des pieds (sommet du crane a %.3f)"
				% [corps.position.y - pieds, corps.end.y - pieds, corps.end.y - pieds])

	var attache := squelette.find_child("Attache_Head", true, false) as Node3D
	if attache == null:
		printerr("    PAS D'ATTACHE Attache_Head")
		return
	printerr("    attache Head a %.3f m au-dessus des pieds, echelle %s" % [attache.global_position.y - pieds, attache.global_transform.basis.get_scale()])
	for m in attache.get_children():
		var n3 := m as Node3D
		var r := _boite_globale(n3, AABB(), true)
		var b: AABB = r[0]
		printerr("    %s : visible=%s, origine a %.3f m, boite de %.3f a %.3f m au-dessus des pieds (hauteur %.2f, largeur %.2f, profondeur %.2f), position locale %s, echelle %s"
				% [n3.name, n3.visible, n3.global_position.y - pieds,
				b.position.y - pieds, b.end.y - pieds, b.size.y, b.size.x, b.size.z,
				n3.position, n3.scale])
		# Le devant du masque par rapport au devant de la tete : l'avant d'un
		# noeud est -Z.
		var devant := -joueur.global_transform.basis.z
		var centre := b.get_center()
		var tete_xz := Vector3(attache.global_position.x, 0.0, attache.global_position.z)
		var av := (Vector3(centre.x, 0.0, centre.z) - tete_xz).dot(devant)
		printerr("    %s : centre a %.3f m devant l'os Head" % [n3.name, av])


func _noms(s: Skeleton3D) -> Array[String]:
	var r: Array[String] = []
	for b in s.get_bone_count():
		r.append(s.get_bone_name(b))
	return r
