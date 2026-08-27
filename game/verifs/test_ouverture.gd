# L'OUVERTURE AU MASQUE : Y VOIT-ON MOINS, VA-T-ON MOINS VITE, ET PEUT-ON
# RETIRER LE MASQUE DE N'IMPORTE OU ?
#
#     godot --headless --path game --script res://verifs/test_ouverture.gd
#
# Le lot C du retour du 23/08/2026 tient en cinq points, et trois se mesurent :
# la mission se joue de JOUR, Walter se traine tant qu'il porte le masque, et
# « retirer le masque » n'est plus reserve a un endroit precis.
#
# CE QUI NE SE MESURE PAS ICI : que le filtre soit assez opaque. Ca se juge sur
# une image — scenario « masque_a_gaz » — et ce fichier n'y touche pas. Il
# verifie seulement qu'il EST POSE, ce qui est une autre question.
extends SceneTree

const POSE := 50

var _n := 0
var _etape := 0
var _mission: Node
var _joueur: Node
var _erreurs: Array[String] = []

# L'IMAGE DE LA DERNIERE BASCULE D'ETAPE. Les attentes se comptent a partir
# d'elle et non depuis le debut : une phase ajoutee au milieu decalait sinon
# toutes les suivantes, et deux d'entre elles laissent au jeu le temps de poser
# une entrave ou de fondre un calque.
var _repere := 0

# Combien de fois Jesse a redit ou aller pendant qu'on ne bougeait pas.
var _relances := 0
var _derniere_relance := ""

# Le temps ecoule dans la phase courante, en secondes.
var _attente := 0.0


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


# « A DROITE » EST-IL VRAIMENT A DROITE ?
#
# C'est le seul controle de ce fichier qui mesure une MISE EN SCENE, et il
# existe parce que la scene ne pardonne pas : le joueur ne voit rien. Une
# consigne ecrite dans le fichier de mission et un jalon pose de l'autre cote,
# c'est quelqu'un qui tourne dans le noir en croyant s'etre trompe — et il n'a
# aucun moyen de verifier.
#
# TROIS FAITS, ET LE DERNIER EST CELUI QU'ON OUBLIERAIT :
#
#   1. le premier virage part vers la DROITE du joueur ;
#   2. le second part vers sa GAUCHE — c'est « l'autre droite », la seule
#      blague de la sequence, et elle ne marche que si le premier etait juste ;
#   3. le trajet se termine PRES DU CAMPING-CAR. « A ce moment-la, le joueur
#      doit se trouver plus ou moins devant le RV, face a lui. »
#
# On mesure des angles entre jalons, pas des positions absolues : le fosse est
# ancre sur un decor genere, et trois coordonnees recopiees s'en ecarteraient au
# premier changement de graine.
func _le_guidage() -> void:
	print("--- le trajet a l'aveugle ---")
	var g := root.get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
	if g == null:
		_verifier(false, "un guidage existe dans le fosse")
		return
	_verifier(g.total() == 3, "trois jalons (%d)" % g.total())
	if g.total() < 3:
		return

	var depart := _trouver(root, "DepartCrash") as Node3D
	var un := g.get_node_or_null(g.jalons[0]) as Node3D
	var deux := g.get_node_or_null(g.jalons[1]) as Node3D
	var trois := g.get_node_or_null(g.jalons[2]) as Node3D
	if depart == null or un == null or deux == null or trois == null:
		_verifier(false, "les trois jalons et la portiere sont en place")
		return

	# LE SIGNE DU PRODUIT VECTORIEL DIT LE COTE, et rien d'autre ne le dit
	# aussi simplement. On avance de A vers B, puis de B vers C : si le
	# troisieme point est a droite du cap qu'on tenait, le produit est negatif
	# autour de l'axe vertical.
	var premier := _cote(depart.global_position, un.global_position,
			deux.global_position)
	var second := _cote(un.global_position, deux.global_position,
			trois.global_position)
	_verifier(premier < 0.0,
			"le premier virage part a DROITE (%.2f)" % premier)
	_verifier(second > 0.0,
			"et le second a gauche — « l'autre droite » (%.2f)" % second)

	# ON S'ARRETE ASSEZ PRES POUR QUE LA CAISSE TIENNE DANS LE CADRE.
	#
	# CE CONTROLE A D'ABORD EXIGE QUE LE DERNIER PAS RAMENE VERS LE CAMPING-CAR,
	# et c'etait une exigence impossible : droite puis gauche est un ZIGZAG, et
	# un zigzag repart toujours dans la direction ou il allait. Aucun placement
	# des trois jalons ne peut a la fois tourner d'un cote, puis de l'autre, et
	# revenir sur ses pas.
	#
	# Ce que le retour demande n'est d'ailleurs pas de revenir : « a ce moment-la,
	# le joueur doit se trouver plus ou moins devant le RV, FACE A LUI ». C'est
	# une question de cadre, pas de distance parcourue — et le cap, c'est le
	# guidage qui le pose en tournant la camera vers la portiere au dernier
	# jalon. Il reste a garantir qu'on est assez pres pour la voir.
	#
	# VINGT METRES, ET LE CHIFFRE VIENT D'UNE IMAGE.
	#
	# Il valait seize, ecrits de tete, et le trajet en rendait dix-huit et demi.
	# La tentation etait de deplacer un jalon pour rentrer dans le seuil ; la
	# regle du projet dit l'inverse — un rendu se juge sur une capture, pas sur
	# un nombre qu'on a choisi soi-meme.
	#
	# Le scenario « crash_masque_tombe » pose la camera au dernier jalon, a
	# hauteur d'yeux, tournee comme le guidage la tourne. A dix-huit metres et
	# demi, le camping-car occupe la moitie du cadre, on voit les flammes autour
	# et Jesse debout a cote : c'est le plan que le retour demande, et il aurait
	# ete refuse par un seuil invente.
	#
	# Ce qui reste garde, c'est le vrai defaut : un dernier jalon si loin que la
	# caisse deviendrait un objet dans un paysage.
	var fin := _a_plat(trois.global_position, depart.global_position)
	_verifier(fin <= 20.0,
			"le trajet s'arrete a %.1f m de la portiere : la caisse tient dans"
					% fin + " le cadre quand le masque tombe")


# « A DROITE » EST-IL A DROITE DU JOUEUR, ET PAS SEULEMENT DU TRAJET ?
#
# Le controle du dessus mesure la mise en scene : le chemin tourne-t-il du bon
# cote. Celui-ci mesure ce que JESSE DIT, et c'est une autre question — le
# guidage traduit une geometrie en un mot, et si droite et gauche s'inversent
# dans cette traduction, le joueur obeit et s'eloigne. Il n'a aucun moyen de
# s'en apercevoir : il ne voit rien.
#
# ON TOURNE LA CAMERA, PAS LE JOUEUR, et on lui demande le mot a chaque fois.
# Quatre caps, quatre reponses attendues : c'est le seul controle du jeu ou une
# inversion de signe se voit sans lancer une partie.
#
# CE QUI ROUGIRAIT SI LE FIL ETAIT COUPE : tout. Sans camera trouvee, le guidage
# retombe sur l'orientation du corps, qui ne bouge pas ici — les quatre caps
# rendraient le meme mot, et trois des quatre lignes passeraient au rouge.
func _les_directions() -> void:
	print("--- ce que Jesse crie, et de quel cote ---")
	var g := root.get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
	if g == null or g.total() == 0:
		_verifier(false, "un guidage avec des jalons")
		return
	var j := _joueur as Node3D
	# Il l'observe deja — le scenario l'a branche — mais la suite ne doit pas
	# dependre de l'ordre dans lequel deux systemes se sont trouves.
	g.observer(j)
	var jalon := g.get_node_or_null(g.jalons[g.rang()]) as Node3D
	if jalon == null:
		_verifier(false, "le jalon courant est en place")
		return
	var cam := _trouver_camera(root)
	if cam == null:
		_verifier(false, "la camera de poursuite existe")
		return

	# LE CAP QUI REGARDE LE JALON, dans la convention de la camera : `cap()`
	# designe la direction du sujet VERS elle, donc le regard est l'oppose.
	# C'est le meme calcul que Guidage._tourner_vers_la_fin, et il doit le
	# rester.
	var vers := jalon.global_position - j.global_position
	vers.y = 0.0
	var face: float = atan2(-vers.x, -vers.z)
	var attendus := {
		face: Guidage.DEVANT,
		face + PI: Guidage.DERRIERE,
		face + PI * 0.5: Guidage.DROITE,
		face - PI * 0.5: Guidage.GAUCHE,
	}
	for cap in attendus:
		cam.call("poser_le_cap", cap)
		var dit: String = g.direction_du_jalon()
		var veut: String = attendus[cap]
		_verifier(dit == veut,
				"cap %+.0f deg du jalon : Jesse dit « %s », attendu « %s »"
						% [rad_to_deg(cap - face), dit, veut])

		# ET L'ANGLE VA DANS LE MEME SENS QUE LE MOT. Le picto ne lit pas le
		# mot, il lit l'angle : si les deux se contredisent, le chevron pointe
		# a gauche pendant que Jesse crie « a droite », et c'est le joueur qui
		# tranche — dans le noir, sans moyen de verifier. Les deux sortent du
		# meme calcul, ce qui est justement la raison de le mesurer une fois.
		var vu: float = g.angle_du_jalon()
		var accord := true
		match veut:
			Guidage.DROITE:
				accord = vu > 0.0
			Guidage.GAUCHE:
				accord = vu < 0.0
			Guidage.DEVANT:
				accord = absf(vu) < deg_to_rad(g.cone)
			Guidage.DERRIERE:
				accord = absf(vu) > deg_to_rad(180.0 - g.cone)
		_verifier(accord, "  et le picto pointe pareil (%+.0f deg)"
				% rad_to_deg(vu))
	# ON REPOSE LA CAMERA COMME ON L'A TROUVEE : la suite du fichier mesure le
	# masque, et une camera laissee de travers ne se verrait qu'a la capture.
	cam.call("poser_le_cap", face)

	# ET CHAQUE MOT A UNE PHRASE. Les deux sens du controle, comme le piege 56 :
	# une direction que le code peut emettre sans phrase dans la donnee, c'est
	# un silence exactement quand le joueur est perdu ; une phrase rangee sous
	# un mot que le code n'emet jamais, c'est du texte mort.
	var table: Dictionary = (_mission.call("etape") as Dictionary).get(
			"voix_relance", {})
	var mots := [Guidage.DEVANT, Guidage.DROITE, Guidage.GAUCHE,
			Guidage.DERRIERE]
	for mot in mots:
		var phrases: Array = table.get(mot, [])
		_verifier(not phrases.is_empty(),
				"« %s » a de quoi se crier (%d phrase(s))" % [mot, phrases.size()])
	for cle in table:
		_verifier(mots.has(str(cle)),
				"« %s » est une direction que le guidage emet" % str(cle))

	# ET ON LES ENTEND. C'est la regle du projet pour les voix : mesurer qu'un
	# fichier EXISTE la ou le jeu le cherche, pas qu'on a pense a l'enregistrer.
	# Le nom se calcule sur « [jeu] vo » — retoucher une phrase la rend muette
	# jusqu'a regeneration, et ce controle est le seul endroit qui le dira.
	var muettes := 0
	var dites := 0
	var toutes: Array = (_mission.call("etape") as Dictionary).get("voix", []).duplicate()
	for cle in table:
		toutes.append_array(table[cle] as Array)
	for p in toutes:
		if Dialogue.chemin_de("Jesse", p as Dictionary) == "":
			muettes += 1
			printerr("       muette : « %s »"
					% str((p as Dictionary).get("vo", "(pas de vo)")))
		else:
			dites += 1
	_verifier(muettes == 0,
			"les %d phrases de Jesse ont leur enregistrement (%d muette(s))"
					% [dites + muettes, muettes])


# ON RACCOURCIT LE SILENCE POUR NE PAS ATTENDRE CINQ SECONDES EN HEADLESS.
#
# C'est le seul reglage que cette suite touche, et elle mesure quand meme que
# le reglage LIVRE est utilisable : une relance a zero ne partirait jamais.
func _armer_la_relance() -> void:
	var g := root.get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
	if g == null:
		return
	_verifier(g.relance > 0.0 and g.relance <= 10.0,
			"Jesse repete toutes les %.1f s tant qu'on n'y est pas" % g.relance)
	g.relance = 0.4
	g.redire.connect(func(direction: String) -> void:
		_relances += 1
		_derniere_relance = direction)


func _trouver_camera(n: Node) -> Node:
	if n is Camera3D and n.has_method("poser_le_cap"):
		return n
	for e in n.get_children():
		var t := _trouver_camera(e)
		if t != null:
			return t
	return null


# De quel cote de la droite AB se trouve C ? Negatif = a droite.
func _cote(a: Vector3, b: Vector3, c: Vector3) -> float:
	var cap := b - a
	var suite := c - b
	cap.y = 0.0
	suite.y = 0.0
	if cap.length_squared() < 0.0001 or suite.length_squared() < 0.0001:
		return 0.0
	return cap.normalized().cross(suite.normalized()).y


func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


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


func _aller_a_l_etape(cle: String) -> bool:
	var etapes: Array = _mission.call("etapes")
	for k in etapes.size():
		if str((etapes[k] as Dictionary).get("cle", "")) == cle:
			_mission.call("aller_a", k)
			return true
	return false


func _process(d: float) -> bool:
	_n += 1
	_attente += d

	if _etape == 0:
		if _n < POSE:
			return false
		_mission = _trouver(root, "Mission")
		_joueur = _trouver(root, "Joueur")
		if _mission == null or _joueur == null:
			printerr("ECHEC la mission ou le joueur sont introuvables")
			quit(1)
			return true

		print("--- la mission se joue de jour ---")
		# « La mission doit IMPERATIVEMENT se derouler la journee. » Elle
		# s'ouvrait a 21h30 : le script le demandait, le retour le refuse, et
		# c'est le retour qui gagne.
		var h: float = _mission.call("heure_de_depart")
		_verifier(h >= 8.0 and h <= 19.0,
				"l'ouverture se joue en plein jour (%.1f h)" % h)

		# ON REMET LA MISSION AU DEBUT, ET CE N'EST PAS UNE PRECAUTION DE STYLE.
		#
		# Une suite lancee juste avant avait laisse une sauvegarde a l'etape 22 :
		# le monde reprend la partie au chargement — « REPRISE : partie chargee »
		# — et cette suite mesurait alors le guidage d'une etape qui n'en a pas.
		# Sept controles au rouge, aucun defaut dans le jeu. Ce que la suite
		# veut mesurer est l'OUVERTURE ; elle doit donc la poser elle-meme, et
		# le dire.
		_mission.call("recommencer")
		_verifier(str(_mission.call("cle_etape")) == "guide",
				"la mission est a son ouverture ('%s')"
						% str(_mission.call("cle_etape")))

		_le_guidage()
		_les_directions()
		_armer_la_relance()
		_attente = 0.0
		_etape = 1
		return false

	# ON NE BOUGE PAS, ET C'EST TOUT L'INTERET : c'est la situation du joueur
	# perdu. Une seconde de silence doit suffire a faire reparler Jesse.
	#
	# ON COMPTE DES SECONDES ET NON DES IMAGES. En headless la boucle tourne
	# aussi vite qu'elle peut : soixante images n'y valent pas une seconde, et
	# une attente comptee en images mesurerait la vitesse de la machine.
	if _etape == 1:
		if _attente < 1.0:
			return false
		_verifier(_relances > 0,
				"Jesse redit ou aller quand on n'avance pas (%d fois, la"
						% _relances + " derniere « %s »)" % _derniere_relance)

		# ET LA PHRASE ARRIVE JUSQU'A L'ECRAN. Le compteur ci-dessus s'abonne au
		# guidage : il verrait un signal partir dans le vide et se declarerait
		# content — c'est exactement le piege 32. Ce qu'on lit ici est le
		# bandeau du controleur, c'est-a-dire le bout de la chaine : guidage,
		# scenario, ecran.
		#
		# ON EXIGE UNE PHRASE DE RELANCE, PAS UNE PHRASE DE JESSE. Le premier
		# jet demandait qu'elle commence par « Jesse » : le fil coupe, le
		# bandeau portait encore « Par ici ! Par ici, Mr. White ! » — la phrase
		# d'entree de l'etape, qui dure trois secondes — et le controle restait
		# vert. Debrancher `redire` dans Scenario le rougit maintenant.
		var ctrl := _trouver(root, "Controleur")
		var lu := "" if ctrl == null else str(ctrl.call("bandeau"))
		var table: Dictionary = (_mission.call("etape") as Dictionary).get(
				"voix_relance", {})
		var connue := false
		for cle in table:
			for p in (table[cle] as Array):
				if str((p as Dictionary).get("texte", "")) == lu:
					connue = true
		_verifier(connue, "et elle s'affiche : bandeau « %s »" % lu)

		# LE PICTO ACCOMPAGNE LA REPLIQUE, et il s'eteint tout seul. Ce qui est
		# mesure ici est l'echo — le HUD ne fait que le lire. Un chevron dont
		# le compte a rebours ne repart pas a chaque phrase serait un repere
		# permanent des la premiere seconde, c'est-a-dire une boussole.
		var g2 := root.get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
		_verifier(g2 != null and g2.echo_restant() > 0.0,
				"le picto est allume avec elle (%.1f s restantes)"
						% (g2.echo_restant() if g2 != null else -1.0))

		# ET ON L'ENTEND SORTIR DE QUELQUE PART.
		#
		# Les deux controles du dessus se contentent de moins : l'un lit le
		# bandeau, l'autre un compte a rebours, et TOUS DEUX RESTERAIENT VERTS
		# si la ligne qui joue le son n'existait pas (piege 32). Celui-ci
		# regarde le lecteur : joue-t-il, et est-il POSE sur le jalon plutot
		# qu'a l'origine du monde — une voix non positionnee s'entendrait
		# pareil de partout, ce qui est exactement ce qu'on cherche a eviter.
		var hp := _trouver(root, "VoixDuGuidage") as AudioStreamPlayer3D
		_verifier(hp != null and hp.playing,
				"la voix de Jesse sort d'un lecteur (joue = %s)"
						% (hp != null and hp.playing))
		if hp != null and g2 != null:
			var ecart := hp.global_position.distance_to(g2.source_de_la_voix())
			_verifier(ecart < 0.5,
					"et elle sort du jalon : lecteur (%.0f, %.0f), source"
							% [hp.global_position.x, hp.global_position.z]
					+ " (%.0f, %.0f), ecart %.2f m"
							% [g2.source_de_la_voix().x,
							g2.source_de_la_voix().z, ecart])

		print("--- le masque ---")
		_verifier(_aller_a_l_etape("masque"), "l'etape 'masque' existe")
		_repere = _n
		_etape = 2
		return false

	# On laisse une poignee d'images au scenario pour poser l'entrave et au
	# filtre pour se monter : les deux se font sur le changement d'etape.
	if _etape == 2:
		if _n < _repere + 20:
			return false

		_verifier(bool(_joueur.get("entrave")),
				"Walter se traine tant qu'il porte le masque")

		# ET IL L'A VRAIMENT SUR LE VISAGE. « J'ai aussi depose un model 3d de
		# masque a gaz, a placer evidemment sur Walter tant qu'il le porte. »
		var eq := _trouver(root, "Equipement")
		_verifier(eq != null and bool(eq.call("porte", "masque")),
				"le masque a gaz est sur sa tete pendant l'etape qui le nomme")

		# ON CHERCHE LE CALQUE, PAS LE SYSTEME. Les deux se sont longtemps
		# appeles « FiltreEcran » : le premier controle ecrit ici trouvait le
		# systeme — qui ne disparait jamais — et se declarait content.
		_verifier(_trouver(root, "CalqueFiltre") != null,
				"le calque du masque est pose sur l ecran")

		# DE N'IMPORTE OU. « L'option retirer le masque n'est cliquable que
		# devant le RV. Elle devrait l'etre depuis n'importe ou. »
		#
		# On emmene Walter a deux cents metres et on demande au point s'il se
		# propose encore. C'est ce que ferait un joueur qui s'eloigne — et
		# c'est ce qui rougirait si quelqu'un retirait « partout ».
		var pt := _trouver(root, "PointMasque")
		var point: Point = null
		if pt != null:
			point = _trouver(pt, "Point") as Point
		_verifier(point != null, "le point du masque existe")
		if point != null:
			var j := _joueur as Node3D
			j.global_position = point.global_position + Vector3(200.0, 0.0, 0.0)
			_verifier(point.offert(j, _mission as Mission),
					"on peut retirer le masque a deux cents metres du point")

		print("--- une fois le masque retire ---")
		# « jesse_panique » et non « reveil » : l'etape qui envoyait regarder
		# les corps est sortie du deroule le 24/08/2026, et c'est celle-ci qui
		# suit maintenant le retrait du masque.
		_verifier(_aller_a_l_etape("jesse_panique"), "l'etape suivante existe")
		_repere = _n
		_etape = 3
		return false

	if _etape == 3:
		# Le filtre part sur un fondu de 0,3 s puis un queue_free : on laisse
		# largement le temps plutot que de mesurer au plus juste. Un test qui
		# court apres une animation finit par accuser le jeu de sa propre hate.
		if _n < _repere + 90:
			return false
		# ET L'ENTRAVE TOMBE. Un booleen qu'on pose sans jamais l'annuler
		# laisserait Walter se trainer pendant toute la mission, et personne
		# ne ferait le lien avec le masque une heure plus tard.
		_verifier(not bool(_joueur.get("entrave")),
				"il remarche normalement une fois le masque retire")

		# ET LE MASQUE A QUITTE SON VISAGE. C'est la moitie qu'on oublie : un
		# objet pose par une etape et jamais retire suit le joueur pendant les
		# vingt suivantes, et personne ne fait le lien avec l'ouverture une
		# heure plus tard. L'entrave « lent » a exactement ce defaut dans son
		# histoire, et c'est pour ca que ce controle existe.
		var eq2 := _trouver(root, "Equipement")
		_verifier(eq2 != null and not bool(eq2.call("porte", "masque")),
				"et le masque a gaz n'est plus sur sa tete")
		_verifier(_trouver(root, "CalqueFiltre") == null,
				"et le calque a disparu une fois le masque retire")
		_etape = 4
		return false

	print("")
	if _erreurs.is_empty():
		print("l'ouverture : tout est vert")
		quit(0)
	else:
		printerr("l'ouverture : %d echec(s)" % _erreurs.size())
		quit(1)
	return true
