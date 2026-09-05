# LE MOTEUR DU CAMPING-CAR S'ENTEND-IL QUAND IL ROULE ?
#
#     godot --path game --script res://verifs/diag_moteur_rv.gd
#
# Un RELEVE, pas un test. Benjamin, 0.58.52 : « le camping-car ne fait pas de
# bruit quand il roule ». Le MoteurAudio du camping-car est cable — deux
# couches, ralenti et roulage. Ce releve pose Walter au volant par le vrai
# chemin du jeu (le demarreur reussi, le volant pris), met les gaz cinq
# secondes, et imprime ce que chaque lecteur fait a cet instant : tourne-t-il,
# a quel volume, a quelle hauteur, a quelle distance de l'oreille.
#
# Sous --audio-driver Dummy, « playing » reste vrai : on lit l'etat des
# lecteurs, pas ce qui sort des haut-parleurs. C'est ce qui decide.
extends SceneTree

const POSE := 60

var _n := 0
var _etape := 0
var _monde: Node
var _mission: Node
var _rv: Vehicule
var _depuis := 0


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
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
	if _etape == 0:
		if _n < POSE:
			return false
		_mission = _trouver(root, "Mission")
		_rv = _trouver(root, "CampingCar") as Vehicule
		if _rv == null:
			printerr("ECHEC pas de CampingCar conduisible")
			quit(1)
			return true
		var etapes: Array = _mission.call("etapes")
		for k in etapes.size():
			if str((etapes[k] as Dictionary).get("cle", "")) == "sortir_du_fosse":
				_mission.call("aller_a", k)
		for dem in root.get_tree().get_nodes_in_group("demarreur"):
			dem.emit_signal("reussi")
		_rv.call("prendre_le_volant")
		Input.action_press("gaz")
		_depuis = _n
		_etape = 1
		_releve("au moment ou l'on prend le volant")
		return false
	if _etape == 1 and _n == _depuis + 120:
		_releve("apres 2 s de gaz")
	if _etape == 1 and _n == _depuis + 300:
		_releve("apres 5 s de gaz")
		Input.action_release("gaz")
		quit(0)
		return true
	return false


func _releve(quand: String) -> void:
	var m := _rv.get_node_or_null("MoteurAudio")
	printerr("--- %s : %.1f km/h, regime %.2f, vmax %.0f, freeze=%s"
			% [quand, _rv.vitesse_kmh(), _rv.regime(), _rv.vitesse_max_kmh(), _rv.freeze])
	if m == null:
		printerr("    PAS DE MoteurAudio sur le camping-car")
		return
	printerr("    tourne=%s  regime_lisse=%.2f  a %s" % [m.get("_tourne"), m.get("_regime_lisse"), m.global_position])
	var couches: Array = m.get("_couches")
	for i in couches.size():
		var p := couches[i] as AudioStreamPlayer3D
		var nom := p.stream.resource_path.get_file() if p.stream != null else "aucun"
		printerr("    couche %d %-16s playing=%s  volume %6.1f dB  pitch %.2f  unit_size %.0f  max %.0f"
				% [i, nom, p.playing, p.volume_db, p.pitch_scale, p.unit_size, p.max_distance])
	var r := m.get("_roulement") as AudioStreamPlayer3D
	if r != null:
		printerr("    roulement %-16s playing=%s  volume %6.1f dB"
				% [r.stream.resource_path.get_file() if r.stream != null else "aucun", r.playing, r.volume_db])
	else:
		printerr("    roulement : aucun")
	var cam := root.get_viewport().get_camera_3d()
	var vp := _trouver(root, "Rendu") as SubViewport
	if vp != null and vp.get_camera_3d() != null:
		cam = vp.get_camera_3d()
	if cam != null:
		printerr("    camera a %.1f m du moteur (%s), listener 3D du viewport de rendu = %s"
				% [cam.global_position.distance_to(m.global_position), cam.name,
				str(vp.audio_listener_enable_3d) if vp != null else "?"])
	var aztek := _trouver(root, "Vehicule") as Vehicule
	if aztek != null:
		var ma := aztek.get_node_or_null("MoteurAudio")
		if ma != null:
			var ca: Array = ma.get("_couches")
			var noms: Array[String] = []
			for p in ca:
				noms.append((p as AudioStreamPlayer3D).stream.resource_path.get_file())
			printerr("    (l'Aztek, pour comparer : %d couches %s, roulement=%s)"
					% [ca.size(), ", ".join(noms), ma.get("_roulement") != null])
