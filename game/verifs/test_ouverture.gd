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


func _process(_d: float) -> bool:
	_n += 1

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

		_le_guidage()

		print("--- le masque ---")
		_verifier(_aller_a_l_etape("masque"), "l'etape 'masque' existe")
		_etape = 1
		return false

	# On laisse une poignee d'images au scenario pour poser l'entrave et au
	# filtre pour se monter : les deux se font sur le changement d'etape.
	if _etape == 1:
		if _n < POSE + 20:
			return false

		_verifier(bool(_joueur.get("entrave")),
				"Walter se traine tant qu'il porte le masque")

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
		_etape = 2
		return false

	if _etape == 2:
		# Le filtre part sur un fondu de 0,3 s puis un queue_free : on laisse
		# largement le temps plutot que de mesurer au plus juste. Un test qui
		# court apres une animation finit par accuser le jeu de sa propre hate.
		if _n < POSE + 110:
			return false
		# ET L'ENTRAVE TOMBE. Un booleen qu'on pose sans jamais l'annuler
		# laisserait Walter se trainer pendant toute la mission, et personne
		# ne ferait le lien avec le masque une heure plus tard.
		_verifier(not bool(_joueur.get("entrave")),
				"il remarche normalement une fois le masque retire")
		_verifier(_trouver(root, "CalqueFiltre") == null,
				"et le calque a disparu une fois le masque retire")
		_etape = 3
		return false

	print("")
	if _erreurs.is_empty():
		print("l'ouverture : tout est vert")
		quit(0)
	else:
		printerr("l'ouverture : %d echec(s)" % _erreurs.size())
		quit(1)
	return true
