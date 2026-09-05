# POURQUOI LE POINT DU TABLIER N'EST-IL PAS PROPOSE ?
#
#     godot --path game --script res://verifs/diag_tablier.gd
#
# Un RELEVE, pas un test : la suite parcours arrive a 1,2 m de PointTablier,
# appuie soixante fois, et le jeu ne propose « rien du tout ». Ce releve pose
# le joueur au meme endroit, a la meme etape, et imprime tout ce qui decide
# de l'invite — pour designer le coupable au lieu de le deviner.
extends SceneTree

const POSE := 60

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


func _process(_d: float) -> bool:
	_n += 1
	if _n == POSE:
		_releve()
	if _n == POSE + 40:
		_apres()
		quit(0)
		return true
	return false


var _controleur: Node
var _joueur: Node3D
var _point: Node3D
var _mission: Mission


func _releve() -> void:
	_controleur = _trouver(root, "Controleur")
	_joueur = _trouver(root, "Joueur") as Node3D
	_mission = Mission.courante(_monde)
	var points: Array[Node] = []
	_compter(root, "PointTablier", points)
	printerr("--- %d noeud(s) PointTablier" % points.size())
	for p in points:
		printerr("    %s a %s" % [p.get_path(), (p as Node3D).global_position])
	_point = points[0] as Node3D if points.size() > 0 else null
	if _point == null or _mission == null:
		printerr("ECHEC point ou mission introuvable")
		quit(1)
		return
	var etapes: Array = _mission.etapes()
	for k in etapes.size():
		if str((etapes[k] as Dictionary).get("cle", "")) == "tablier":
			_mission.aller_a(k)
	printerr("--- etape : '%s'  objectif '%s'  ou '%s'"
			% [_mission.cle_etape(), _mission.objectif(), _mission.ou()])
	# A 1,2 m du point, comme le pilote.
	_joueur.global_position = _point.global_position + Vector3(0.0, -0.9, 1.2)
	_joueur.set("velocity", Vector3.ZERO)


func _apres() -> void:
	var d := _joueur.global_position.distance_to(_point.global_position)
	printerr("--- joueur a %.2f m du point (joueur %s, point %s)"
			% [d, _joueur.global_position, _point.global_position])
	printerr("    point.visible=%s  offert=%s  disponible=%s  portee=%.1f  etape='%s'  au_volant=%s  exige='%s'"
			% [_point.visible, _point.call("offert", _joueur, _mission),
			_point.call("disponible", _mission), _point.get("portee"),
			_point.get("etape"), _point.get("au_volant"), _point.get("exige")])
	printerr("    mission a_l_etape('tablier')=%s  cle='%s'"
			% [_mission.a_l_etape("tablier"), _mission.cle_etape()])
	var vise: Node = _controleur.call("point_vise")
	printerr("    controleur.point_vise = %s" % (vise.name if vise != null else "aucun"))
	printerr("    controleur : etat au_volant=%s dedans=%s transition=%s"
			% [_controleur.call("au_volant"), _controleur.call("dedans"),
			_controleur.call("en_transition")])
	var dial := _monde.find_child("Dialogue", true, false)
	if dial != null:
		printerr("    dialogue actif=%s  invite='%s'"
				% [dial.call("actif"), dial.call("invite")])
	var inv := _trouver(root, "Invite")
	printerr("    invite a l'ecran : '%s'" % (str(inv.get("text")) if inv != null else "?"))
	printerr("    joueur bloque=%s entrave=%s interieur=%s"
			% [_joueur.get("bloque"), _joueur.get("entrave"), _joueur.get("interieur")])
	var tir := _monde.find_child("Tir", true, false)
	if tir != null and tir.has_method("vise"):
		printerr("    tir vise=%s" % tir.call("vise"))
	var trac := _monde.find_child("Traction", true, false)
	if trac != null:
		printerr("    traction : active=%s invite='%s' porte_un_corps=%s"
				% [trac.call("active"), trac.call("invite"), trac.call("porte_un_corps")])
	printerr("    joueur geste_en_cours='%s'  controleur _geste_en_cours=%s  _bloque_par_la_cachette=%s"
			% [_joueur.call("geste_en_cours"), _controleur.get("_geste_en_cours"),
			_controleur.get("_bloque_par_la_cachette")])
	var tel := _monde.find_child("Telephone", true, false)
	if tel != null:
		printerr("    telephone sorti=%s" % tel.call("sorti"))
	var roue := _monde.find_child("Roue", true, false)
	if roue != null:
		printerr("    roue ouverte=%s" % roue.call("ouverte"))
	var cach := _monde.find_child("Cachette", true, false)
	if cach != null:
		printerr("    cachette ouverte=%s" % cach.call("ouverte"))
	var fin := _monde.find_child("FinDePartie", true, false)
	if fin != null:
		printerr("    fin actif=%s" % fin.call("actif"))
	var pause := _monde.find_child("Pause", true, false)
	if pause != null and pause.has_method("ouverte"):
		printerr("    pause ouverte=%s" % pause.call("ouverte"))
	printerr("    bandeau='%s'" % _controleur.call("bandeau"))
	# ET QUI ECRIT DANS L'INVITE ? On la pose a une valeur reconnaissable,
	# une image plus tard on regarde ce qu'elle est devenue.
	if inv != null:
		inv.set("text", "TEMOIN")
		await process_frame
		printerr("    une image apres avoir ecrit TEMOIN : '%s'" % str(inv.get("text")))
		await process_frame
		printerr("    deux images apres : '%s'" % str(inv.get("text")))


func _compter(n: Node, nom: String, vus: Array[Node]) -> void:
	if n.name == nom:
		vus.append(n)
	for e in n.get_children():
		_compter(e, nom, vus)
