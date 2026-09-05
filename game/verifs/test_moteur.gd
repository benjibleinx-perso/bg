# Verifie que le moteur produit reellement du son une fois au volant.
#
#   godot --path game --script res://verifs/test_moteur.gd
#
# Le son du moteur ne demarre qu'en montant dans le vehicule. Un couplage
# rate entre le controleur et l'audio ne se voit pas : le jeu tourne, la
# voiture roule, et il n'y a simplement rien a entendre.
extends SceneTree

const POSE := 60
const ROULAGE := 180

var _n := 0
var _c: Node
var _v: VehicleBody3D
var _m: Node
var _bus := -1
var _crete := -200.0
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


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	if _c == null:
		_c = _trouver(root, "Controleur")
		_v = _trouver(root, "Vehicule") as VehicleBody3D
		_m = _trouver(root, "MoteurAudio")
		_bus = AudioServer.get_bus_index("Effets")
		if _c == null or _v == null or _m == null:
			printerr("noeuds introuvables (controleur/vehicule/moteur)")
			quit(1)
			return true

		print("--- couches ---")
		var lecteurs := 0
		for e in _m.get_children():
			if e is AudioStreamPlayer3D and (e as AudioStreamPlayer3D).stream != null:
				lecteurs += 1
		_verifier(lecteurs >= 3, "%d lecteurs avec un flux assigne" % lecteurs)
		_verifier(_bus >= 0, "bus Effets present")

		print("--- on monte, puis on accelere ---")
		_c.call("_monter")
		return false

	# On pousse le vehicule, comme le ferait une touche maintenue.
	_v.call("_propulser", 1.0, _v.call("vitesse_kmh"))
	if _n > POSE + 30:
		_crete = maxf(_crete, AudioServer.get_bus_peak_volume_left_db(_bus, 0))

	if _n < POSE + ROULAGE:
		return false

	print("--- mesure ---")
	print("       vitesse atteinte  %.1f km/h" % _v.call("vitesse_kmh"))
	print("       crete bus Effets  %.1f dB" % _crete)
	_verifier(_crete > -60.0, "le moteur produit du son au volant")
	if _crete > -60.0 and _crete < -35.0:
		print("       (faible : verifier moteur_volume dans reglages.tres)")

	# CHAQUE BOUCLE DE CHAQUE VEHICULE BOUCLE VRAIMENT, ET JOUE ENCORE.
	#
	# Le camping-car ne faisait pas de bruit en roulant — retour de Benjamin
	# sur la 0.58.52 — et ce controle-ci ne regardait que la voiture. Ses deux
	# couches etaient importees « detecter depuis le WAV » (loop_mode 0) : le
	# code les marque en boucle a l'execution, mais sur un flux importe sans
	# boucle la fin de boucle vaut zero, le lecteur s'arrete a la premiere
	# image, et « playing » retombe a faux pendant que tout le reste est
	# cable comme il faut. Un lecteur qui ne joue plus trois secondes apres
	# le depart designe l'import ; un flux dont la fin de boucle ne depasse
	# pas le debut le designe avant meme de jouer.
	print("--- les boucles de chaque vehicule ---")
	var moteurs: Array[Node] = []
	_recenser(root, "MoteurAudio", moteurs)
	_verifier(moteurs.size() >= 2,
			"%d moteur(s) audio dans le monde (voiture et camping-car)" % moteurs.size())
	for m in moteurs:
		var proprietaire := m.get_parent().name
		if m.has_method("demarrer"):
			m.call("demarrer")
		var couches: Array = m.call("couches") if m.has_method("couches") else []
		_verifier(not couches.is_empty(), "%s : %d couche(s)" % [proprietaire, couches.size()])
		for p in couches:
			var lecteur := p as AudioStreamPlayer3D
			var nom := lecteur.stream.resource_path.get_file() if lecteur.stream != null else "aucun"
			var boucle := false
			if lecteur.stream is AudioStreamWAV:
				var w := lecteur.stream as AudioStreamWAV
				boucle = w.loop_mode != AudioStreamWAV.LOOP_DISABLED \
						and w.loop_end > w.loop_begin
				_verifier(boucle, "%s : %s est une boucle (mode %d, de %d a %d)"
						% [proprietaire, nom, w.loop_mode, w.loop_begin, w.loop_end])
			elif lecteur.stream is AudioStreamOggVorbis:
				boucle = (lecteur.stream as AudioStreamOggVorbis).loop
				_verifier(boucle, "%s : %s est une boucle" % [proprietaire, nom])
			else:
				_verifier(false, "%s : %s n'est ni WAV ni OGG" % [proprietaire, nom])
			_verifier(lecteur.playing,
					"%s : %s joue encore apres %d images" % [proprietaire, nom, _n])

	print("")
	if _erreurs.is_empty():
		print("TEST MOTEUR OK")
		quit(0)
	else:
		printerr("TEST MOTEUR ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


# TOUS les noeuds de ce nom, pas le premier : il y a un MoteurAudio par
# vehicule, et c'est justement le second qu'on n'ecoutait pas. Piege 54.
func _recenser(n: Node, nom: String, vus: Array[Node]) -> void:
	if n.name == nom:
		vus.append(n)
	for e in n.get_children():
		_recenser(e, nom, vus)
