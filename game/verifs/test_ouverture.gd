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
