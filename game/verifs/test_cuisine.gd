# LE VERSEMENT SE JOUE-T-IL, ET PEUT-ON LE RATER ?
#
#     godot --headless --path game --script res://verifs/test_cuisine.gd
#
# CE QUE CE TEST NE FAIT PAS, ET C'EST L'ESSENTIEL.
#
# Il n'appelle jamais « incliner » sur la verseuse. Il envoie un VRAI evenement
# de souris dans la boucle d'entree du moteur et laisse le controleur le
# router. C'est la seule facon de voir le fil : la camera et l'interface vivent
# dans le SubViewport, ou Godot ne propage aucune entree, et deux systemes de
# ce projet y sont deja morts en silence — la roue des outils pendant deux
# jours, le son des passants pendant deux mesures.
#
# La question du piege 32 — « qu'est-ce qui, dans ce test, ne pourrait PAS
# arriver si le fil etait coupe ? » — a donc une reponse ici : l'inclinaison
# ne bougerait pas d'un pouce, et rien d'autre dans le test ne pourrait la
# faire bouger.
#
# ET IL JOUE COMME UN JOUEUR. Le pilote ne connait aucune constante du
# mini-jeu : il regarde OU LE FILET TOMBE — trop court, trop loin — et corrige
# dans ce sens, exactement ce qu'un humain fait en regardant l'ecran. Un test
# qui poserait directement la bonne inclinaison validerait un mini-jeu
# injouable.
extends SceneTree

const POSE := 40

## De combien le pilote bouge la souris a chaque image quand il corrige.
## Volontairement grossier : s'il fallait un geste fin pour y arriver, le
## mini-jeu serait trop dur et ce test le dirait.
const GESTE := 7.0

var _n := 0
var _etape := 0
var _v: Node
var _mission: Node
var _erreurs: Array[String] = []

var _incl_avant := 0.0
var _rate_recu := ""
var _reussi := false
var _essais := 0
var _ch: Node
var _ch_rate := ""
var _ch_reussi := false


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


func _bouger(dy: float) -> void:
	var e := InputEventMouseMotion.new()
	e.relative = Vector2(0.0, dy)
	e.screen_relative = e.relative
	Input.parse_input_event(e)


# Le pilote : il ne vise pas, il rattrape. Rend le mouvement de souris a faire.
func _corriger() -> float:
	if not _v.call("coule"):
		return GESTE
	var ecart: float = _v.call("ecart")
	if ecart < 0.0:
		return GESTE
	if ecart > 0.0:
		return -GESTE
	return 0.0


func _process(_d: float) -> bool:
	_n += 1

	if _etape == 0:
		if _n < POSE:
			return false
		var trouves := root.get_tree().get_nodes_in_group("cuisine_souris")
		if trouves.is_empty():
			printerr("ECHEC aucune verseuse dans le monde")
			quit(1)
			return true
		_v = trouves[0]
		_mission = _trouver(root, "Mission")

		print("--- le geste est branche ---")
		var pt := _trouver(root, "Reverser")
		_verifier(pt != null, "le point 'Reverser' existe dans la cuisine")
		_verifier(pt != null and str(pt.get("evenement")) == "",
				"il n'annonce plus rien tout seul : c'est le geste qui vaut l'etape")
		_verifier(str(_v.get_script().get_script_constant_map().get(
				"EVENEMENT", "")) == "action:verser_bien",
				"la verseuse declare l'evenement qu'elle remplace")

		_v.connect("rate", func(f: String) -> void: _rate_recu = f)
		_v.connect("reussi", func() -> void: _reussi = true)

		# ON SE MET A L'ETAPE, sinon l'evenement tombe dans le vide et le test
		# ne prouve rien de la chaine. C'est le seul placement que ce test
		# s'autorise, et il ne remplace aucun geste du joueur : les gestes,
		# eux, se jouent entierement.
		_verifier(_aller_a_l_etape("verser_bien"),
				"l'etape 'verser_bien' existe dans la mission")

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_v.call("armer")
		Input.action_press("interagir")
		_etape = 1
		return false

	# ------------------------------------------- la fiole est-elle en main ?
	if _etape == 1:
		print("--- tenir la touche met la fiole en main ---")
		_verifier(_v.call("capte_la_souris"),
				"la fiole est en main, et la souris ne tourne plus la camera")
		_incl_avant = _v.call("inclinaison")
		_bouger(GESTE * 4.0)
		_etape = 2
		return false

	# ------------------------------------------------- LE FIL DE LA SOURIS
	if _etape == 2:
		var maintenant: float = _v.call("inclinaison")
		_verifier(maintenant > _incl_avant,
				"un vrai evenement de souris incline la fiole (%.3f -> %.3f)"
				% [_incl_avant, maintenant])
		print("--- verser trop fort tombe a cote, et ca rate ---")
		_etape = 3
		return false

	# ---------------------------------------------------------- L'ECHEC
	#
	# On descend la souris a fond et on ne corrige rien : le jet doit passer
	# au-dela du becher, et le mini-jeu doit finir par le dire.
	if _etape == 3:
		_bouger(GESTE * 3.0)
		if _rate_recu != "":
			_verifier(_rate_recu == "long",
					"le liquide passe au-dela du becher : rate ('%s')" % _rate_recu)
			_etape = 4
			return false
		if _n > POSE + 600:
			_verifier(false, "verser a fond n'a jamais rate en dix secondes")
			_etape = 4
		return false

	# --------------------------------------------- ON RECOMMENCE, ET ON Y ARRIVE
	if _etape == 4:
		# L'echec laisse une seconde de lecture, puis la main revient. On
		# relache et on reprend la fiole comme le ferait un joueur.
		Input.action_release("interagir")
		_etape = 5
		return false

	if _etape == 5:
		Input.action_press("interagir")
		_essais = _n
		_etape = 6
		return false

	if _etape == 6:
		if _reussi:
			print("--- le becher se remplit au trait ---")
			_verifier(true, "le geste corrige remplit le becher (%d images)"
					% (_n - _essais))
			_verifier(str(_mission.call("cle_etape")) != "verser_bien",
					"et la mission a avance : l'etape 'verser_bien' est passee")
			_etape = 7
			return false
		if _rate_recu == "vide":
			_verifier(false, "le pilote a vide la fiole sans remplir le becher"
					+ " — la contenance est trop juste")
			_etape = 7
			return false
		if _n > _essais + 900:
			_verifier(false, "quinze secondes de corrections sans remplir le becher"
					+ " — le geste juste est hors d'atteinte")
			_etape = 7
			return false
		_bouger(_corriger())
		return false

	# ================================================== LA PLAQUE (battement B4)
	#
	# Le pilote ne connait pas la fenetre juste : il lit l'ecart — trop froid,
	# trop chaud — et donne un cran de molette dans le bon sens, comme un
	# joueur qui regarde les bulles et la mousse. Il DOIT y arriver, et il doit
	# aussi pouvoir tout perdre en poussant a fond.
	if _etape == 7:
		Input.action_release("interagir")
		var chauffes := root.get_tree().get_nodes_in_group("cuisine_souris")
		for n in chauffes:
			if n.has_method("molette"):
				_ch = n
		if _ch == null:
			_verifier(false, "aucune plaque a regler dans la cuisine")
			_etape = 11
			return false
		print("--- la plaque : le gaz a fond finit par faire deborder ---")
		_verifier(_aller_a_l_etape("chauffer_bien"),
				"l'etape 'chauffer_bien' existe dans la mission")
		_ch.connect("rate", func(f: String) -> void: _ch_rate = f)
		_ch.connect("reussi", func() -> void: _ch_reussi = true)
		_ch.call("armer")
		Input.action_press("interagir")
		_essais = _n
		_etape = 8
		return false

	if _etape == 8:
		# On pousse le gaz au maximum et on n'y touche plus.
		_molette(1.0)
		if _ch_rate != "":
			_verifier(_ch_rate == "deborde",
					"chauffer a fond fait deborder le ballon ('%s')" % _ch_rate)
			_etape = 9
			return false
		if _n > _essais + 900:
			_verifier(false, "quinze secondes de gaz a fond sans debordement"
					+ " — on ne peut pas rater la plaque")
			_etape = 9
		return false

	if _etape == 9:
		print("--- et en accompagnant, la fournee vient ---")
		Input.action_release("interagir")
		_essais = _n
		_etape = 10
		return false

	if _etape == 10:
		Input.action_press("interagir")
		if _ch_reussi:
			_verifier(true, "le produit est cuit en accompagnant la fenetre"
					+ " (%d images)" % (_n - _essais))
			_verifier(str(_mission.call("cle_etape")) != "chauffer_bien",
					"et la mission a avance : l'etape 'chauffer_bien' est passee")
			_etape = 11
			return false
		if _n > _essais + 2400:
			_verifier(false, "quarante secondes de corrections sans fournee"
					+ " — la fenetre est intenable")
			_etape = 11
			return false
		var e: float = _ch.call("ecart")
		if e < 0.0:
			_molette(1.0)
		elif e > 0.0:
			_molette(-1.0)
		return false

	Input.action_release("interagir")
	print("")
	if _erreurs.is_empty():
		print("la cuisine : tout est vert")
		quit(0)
	else:
		printerr("la cuisine : %d echec(s)" % _erreurs.size())
		quit(1)
	return true


# Un cran de molette, envoye dans la boucle d'entree comme le ferait la main du
# joueur. Meme raison qu'ailleurs : appeler « molette » sur la plaque
# validerait un routage qui n'existe peut-etre plus.
func _molette(sens: float) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_WHEEL_UP if sens > 0.0 else MOUSE_BUTTON_WHEEL_DOWN
	e.pressed = true
	Input.parse_input_event(e)


# Poser la mission sur une etape nommee. Rend faux si elle n'existe pas — un
# test qui sauterait silencieusement une etape absente validerait un jeu ou
# elle n'est pas branchee.
func _aller_a_l_etape(cle: String) -> bool:
	var etapes: Array = _mission.call("etapes")
	for k in etapes.size():
		if str((etapes[k] as Dictionary).get("cle", "")) == cle:
			_mission.call("aller_a", k)
			return true
	return false
