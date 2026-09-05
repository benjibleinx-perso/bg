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
var _fo: Node
var _fo_finie := false
var _fo_reussis := -1
var _jesse: Node
var _cap_avant := 0.0


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

		# AUCUN POINT D'UNE AUTRE SCENE N'EST OFFERT DANS LA CUISINE.
		#
		# La cuisine de « Deux corps » se joue dans l'interieur de la mission de
		# rodage, pose au meme endroit ; les points de celle-ci — la « Sortie »
		# sans etape, vers une coordonnee du desert — se proposaient au milieu
		# de la cuisine du flashback, et le pilote de la suite parcours s'est
		# retrouve a mille metres du tablier en appuyant a l'arrivee. Ce qui
		# est a moins de douze metres de la cuisine et ne vient pas de sa scene
		# ne doit pas etre disponible, quelle que soit l'etape.
		print("--- la cuisine n'offre que ses propres points ---")
		var centre := Vector3(300.0, 0.4, 1201.0)
		var etrangers: Array[String] = []
		var vus := 0
		for n in root.get_tree().get_nodes_in_group("point"):
			var p := n as Node3D
			if p == null or p.global_position.distance_to(centre) > 12.0:
				continue
			var scene: String = str(p.owner.name) if p.owner != null else "?"
			if scene == "CuisineCampingCar":
				continue
			vus += 1
			if bool(p.call("disponible", _mission)):
				etrangers.append("%s (%s)" % [p.name, scene])
		_verifier(vus > 0,
				"il y a bien des points d'une autre scene posees au meme endroit (%d)" % vus)
		_verifier(etrangers.is_empty(),
				"aucun n'est disponible ici (%s)"
				% ("aucun" if etrangers.is_empty() else ", ".join(etrangers)))

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
			# « molette » ne suffit plus a la distinguer : la fournee en a une
			# aussi. On demande ce qui n appartient qu a la plaque.
			if n.has_method("chaleur"):
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

	# ================================================ LA FOURNEE (battement B6)
	#
	# Le pilote joue pour de vrai : il lit ce que le ballon reclame, tourne la
	# molette jusqu'au bon flacon, et verse. Il doit reussir les trois — et le
	# mini-jeu doit poser une purete en consequence.
	if _etape == 11:
		Input.action_release("interagir")
		for n in root.get_tree().get_nodes_in_group("cuisine_souris"):
			if n.has_method("demande"):
				_fo = n
		if _fo == null:
			_verifier(false, "aucune fournee a terminer dans la cuisine")
			_etape = 14
			return false
		print("--- la fournee : le bon flacon, au bon moment ---")
		_verifier(_aller_a_l_etape("fournee"),
				"l'etape 'fournee' existe dans la mission")
		_fo.connect("finie", func(r: int) -> void: _fo_finie = true; _fo_reussis = r)
		_fo.call("armer")
		Input.action_press("interagir")
		_essais = _n
		_etape = 12
		return false

	if _etape == 12:
		if _fo_finie:
			_verifier(_fo_reussis == 3,
					"les trois ajouts sont justes quand on repond a temps (%d/3)"
					% _fo_reussis)
			_verifier(str(_mission.call("cle_etape")) != "fournee",
					"et la mission a avance : l'etape 'fournee' est passee")
			var p := _trouver(root, "Purete")
			_verifier(p != null and int(p.call("palier")) == 5,
					"trois ajouts justes donnent le haut de l echelle (%s)"
					% (str(p.call("nom")) if p != null else "?"))
			_etape = 13
			return false
		if _n > _essais + 1800:
			_verifier(false, "trente secondes sans que la fournee se termine")
			_etape = 13
			return false
		# On lit ce qui est reclame, on va au flacon, on verse.
		var veut: int = _fo.call("demande")
		if veut < 0:
			return false
		var a: int = _fo.call("choisi")
		if a < veut:
			_molette(1.0)
		elif a > veut:
			_molette(-1.0)
		else:
			_appuyer("gauche")
		return false

	# ------------------------------ ET RATER NE DOIT PAS BLOQUER LA MISSION
	if _etape == 13:
		Input.action_release("interagir")
		_fo.call("reinitialiser")
		_fo_finie = false
		_fo_reussis = -1
		_verifier(_aller_a_l_etape("fournee"), "on rejoue la fournee")
		_fo.call("armer")
		Input.action_press("interagir")
		_essais = _n
		_etape = 15
		return false

	# On ne touche a RIEN : les trois fenetres doivent expirer, la fournee se
	# terminer quand meme, et le produit ressortir au plancher.
	if _etape == 15:
		if _fo_finie:
			_verifier(_fo_reussis == 0,
					"ne rien faire rate les trois ajouts (%d/3)" % _fo_reussis)
			var p2 := _trouver(root, "Purete")
			_verifier(p2 != null and int(p2.call("palier")) == 1,
					"et le produit ressort au plancher (%s)"
					% (str(p2.call("nom")) if p2 != null else "?"))
			_verifier(str(_mission.call("cle_etape")) != "fournee",
					"mais la mission avance quand meme : on ne recommence pas")
			_etape = 14
			return false
		if _n > _essais + 1800:
			_verifier(false, "une fournee ou l'on ne fait rien ne se termine jamais")
			_etape = 14
		return false

	# ============================================ ON DOIT VOIR QUI CUISINE
	#
	# « Bien faire comprendre que c'est Jesse qui cuisine et Walter qui lui
	# donne des conseils. » Ca ne s'ecrit nulle part : Jesse est A la verrerie
	# et le joueur arrive derriere lui.
	#
	# CE QUE CE CONTROLE ATTRAPE, et qu'aucune capture ne montrerait : un PNJ
	# se tourne vers le joueur des qu'il approche. On amene donc Walter au plan
	# de travail et on regarde si Jesse se detourne de sa paillasse.
	if _etape == 14:
		Input.action_release("interagir")
		var jesse := _trouver(root, "JesseCuisine")
		var joueur := _trouver(root, "Joueur")
		if jesse == null or joueur == null:
			_verifier(false, "Jesse ou le joueur sont introuvables")
			_etape = 16
			return false
		print("--- on voit qui cuisine ---")
		# CE QU'ON MESURE, ET DEUX ESSAIS RATES AVANT D'Y ARRIVER.
		#
		# Le premier comparait l'avant de Jesse a la direction du noeud
		# « PaillasseCuisine » — qui n'est pas le meuble mais le porteur des
		# trois points, pose un metre en ARRIERE de lui. Il annoncait 117
		# degres sur un placement pourtant juste : le test avait tort, pas le
		# jeu.
		#
		# Le second amenait Walter a cote de lui et exigeait que son cap ne
		# bouge pas. Il etait vert — et il l'est reste APRES avoir coupe le
		# fil, ce qui est la seule question qui vaille (piege 32). La cause :
		# un Pnj ne pivote que si quelqu'un lui a passe le joueur a observer,
		# et seuls les habitants de MAISONS le recoivent. Jesse ne pivotait
		# jamais, donc il n'y avait rien a empecher.
		#
		# Reste ce qui est vrai et qui se mesure : il regarde VERS SA
		# PAILLASSE, celle qui est du cote des X negatifs. Ce controle rougit
		# si quelqu'un lui rend son ancienne orientation — face au mur du fond.
		_jesse = jesse
		_etape = 16
		return false

	if _etape == 16:
		# ON MESURE SUR LE CORPS, PAS SUR LE NOEUD.
		#
		# Troisieme essai, et le precedent annoncait -1.00 sur un placement
		# que la capture montre juste. La raison est ecrite dans pnj.gd : les
		# modeles rigges livres regardent vers +Z, donc leur geometrie est
		# suspendue a un pivot « Corps » retourne d'un demi-tour. L'avant du
		# noeud Pnj est ainsi l'exact oppose de l'avant qu'on VOIT.
		#
		# Lire le pivot rend la mesure vraie quelle que soit la parade : le
		# jour ou les modeles seront reimportes a l'endroit, ce controle
		# continuera de dire la meme chose.
		var corps := _trouver(_jesse, "Corps") as Node3D
		if corps == null:
			_verifier(false, "Jesse n'a pas de pivot 'Corps'")
			_etape = 17
			return false
		var avant := -corps.global_transform.basis.z
		avant.y = 0.0
		var accord := avant.normalized().dot(Vector3(-1.0, 0.0, 0.0))
		_verifier(accord > 0.7,
				"Jesse fait face a sa verrerie, pas au mur du fond (%.2f)"
				% accord)
		_etape = 17
		return false

	# =========================================== SORTIR DEPOSE DEVANT LA PORTE
	#
	# « Quand je suis sorti du camping car, je me suis retrouve sur la route
	# (loin du camping car et surtout, il y avait sur la route, pres de moi, un
	# AUTRE camping car, 2 dans la meme vue) puis le script "that is not them,
	# it's the firetruck" s'est lance. Gros bug. » — retour du 23/08/2026.
	#
	# CE QUI SE MESURE ICI, et c'est la racine possible du bug : la porte de
	# sortie porte une coordonnee ECRITE EN DUR, alors que la clairiere est
	# ancree sur une mesa et posee par le generateur. Les deux n'ont aucune
	# raison de rester d'accord — et le jour ou elles divergent, sortir
	# depose n'importe ou, y compris dans la zone qui declenche les pompiers.
	if _etape == 17:
		var sortie := _trouver(root, "PorteSortie")
		var cc0 := _trouver(root, "CampingCarClairiere")
		if sortie == null or cc0 == null:
			_verifier(false, "la porte de sortie ou le camping-car manque")
			_etape = 18
			return false
		print("--- sortir du camping-car depose devant le camping-car ---")
		var vers := str(sortie.get("emmene_vers"))
		_verifier(vers != "",
				"la sortie vise un endroit du monde, pas une coordonnee ecrite")

		# LE NOM VISE DOIT ETRE UNIQUE, et c'est le controle qui compte ici.
		#
		# Une recherche par nom rend le PREMIER noeud trouve. Le jeu contient
		# deux « PorteCampingCar » — celui de la clairiere et celui de la
		# mission de rodage, a cent metres l'un de l'autre — et viser ce nom
		# depuis la cuisine tombait sur le mauvais. Un controle qui se
		# contenterait de mesurer une distance aurait valide la mauvaise
		# porte : c'est exactement ce qui vient d'arriver.
		_verifier(_combien_de(root, vers) == 1,
				"un seul noeud s'appelle '%s' dans tout le jeu (%d)"
				% [vers, _combien_de(root, vers)])

		var depose: Vector3 = sortie.get("emmene_a")
		var cible := root.find_child(vers, true, false) as Node3D
		_verifier(cible != null, "l'endroit vise ('%s') existe" % vers)
		if cible != null:
			depose = cible.global_position
		var loin := depose.distance_to((cc0 as Node3D).global_position)
		print("    depose a %s, le camping-car est a %s"
				% [depose, (cc0 as Node3D).global_position])
		_verifier(loin < 12.0,
				"on ressort contre le camping-car qu'on vient de quitter"
				+ " (%.1f m)" % loin)
		_etape = 18
		return false

	# ============================== ET ON ARRIVE DANS LA CLAIRIERE, PAS AILLEURS
	#
	# Le meme défaut à l'entrée de la séquence : la crête du flashback portait
	# la même coordonnée écrite. On mesure les deux bouts, parce que réparer un
	# seul aurait laissé le bug se produire une fois sur deux.
	if _etape == 18:
		var crete := _trouver(root, "SortieCrash")
		var cc := _trouver(root, "CampingCarClairiere")
		if crete == null or cc == null:
			_verifier(false, "la crete du flashback ou le camping-car manque")
			_etape = 19
			return false
		print("--- on arrive dans la clairiere, devant le camping-car ---")
		var arrivee: Vector3 = crete.call("ou", crete)
		var loin := arrivee.distance_to((cc as Node3D).global_position)
		print("    on arrive a %s, le camping-car est a %s"
				% [arrivee, (cc as Node3D).global_position])
		# Assez près pour le voir entier, assez loin pour ne pas être dedans.
		_verifier(loin > 2.0 and loin < 25.0,
				"on arrive en vue du camping-car, sans etre dedans (%.1f m)"
				% loin)

		# ET LA ZONE QU'ON VIENT DE FRANCHIR RESTE-T-ELLE A PORTEE ?
		#
		# Un Area3D masque n'est PAS desactive : Godot ne coupe que le rendu.
		# Le decor du fosse disparait apres « sortir_du_fosse », mais sa zone
		# de sortie continue de scruter — et rien dans la boucle des passages
		# ne regarde la visibilite. Repasser dessus rejouerait le fondu, le
		# carton « Trois semaines plus tot » et le dialogue des pompiers.
		#
		# Si elle est loin, le defaut est theorique. Si elle est proche de la
		# clairiere, c'est l'explication du « script that is not them, it's the
		# firetruck s'est lance » que Guillaume decrit.
		var d := arrivee.distance_to((crete as Node3D).global_position)
		print("    la zone de la crete est a %.1f m de l'arrivee" % d)
		_verifier(d > 60.0,
				"la zone de la crete est hors de portee de la clairiere"
				+ " (%.1f m)" % d)
		_etape = 19
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


# Un appui bref sur une action, envoye dans la boucle d'entree. Le mini-jeu lit
# « is_action_just_pressed », donc il faut un vrai front montant : poser l'etat
# a la main ne le declencherait pas.
func _appuyer(action: String) -> void:
	Input.action_press(action)
	Input.action_release(action)


# Combien de noeuds portent ce nom dans tout l'arbre.
#
# Ecrit apres s'etre fait prendre : « PorteCampingCar » existe deux fois, la
# recherche rend le premier, et une mesure faite sur le mauvais noeud est verte
# ou rouge sans aucun rapport avec ce qu'on croit mesurer.
func _combien_de(n: Node, nom: String) -> int:
	var total := 1 if n.name == nom else 0
	for e in n.get_children():
		total += _combien_de(e, nom)
	return total
