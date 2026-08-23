# Le camping-car se démarre-t-il en le jouant ?
#
#     godot --headless --path game --script res://verifs/test_demarreur.gd
#
# CE QUE CA REMPLACE. « Le demarrage : ne PAS ecrire "le moteur tousse" par
# pitie, il faut le vivre, pas le lire. » Il y avait un compteur d'essais : on
# appuyait deux ou trois fois et un bandeau annoncait le resultat. Le joueur
# n'y faisait rien.
#
# CE QU'ON MESURE, ET POURQUOI CHAQUE POINT COMPTE :
#
#   1. le cadran ne s'ouvre QUE si l'on tient le contact — sinon il traine a
#      l'ecran pendant qu'on conduit ;
#   2. viser juste avance d'une zone, et il en faut trois ;
#   3. viser a cote RATE, et surtout : ca ne bloque rien. Un mini-jeu dont on
#      ne peut pas sortir est pire que pas de mini-jeu du tout — c'est la fin
#      de la partie pour qui n'a pas le geste ;
#   4. le sens de l'aiguille S'INVERSE a chaque zone. C'est demande, et c'est
#      ce qui empeche d'apprendre le rythme par coeur.
extends SceneTree

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var d := _trouver(root, "Demarreur")
	if d == null:
		printerr("ECHEC aucun Demarreur dans le monde")
		quit(1)
		return

	print("")
	print("--- avant qu'on ait mis le contact ---")
	if bool(d.call("arme")):
		_echec("il est arme sans qu'on ait touche au poste de conduite")
	else:
		print("  ok   il attend")

	d.call("armer")
	await process_frame
	if bool(d.call("ouvert")):
		_echec("le cadran est ouvert alors qu'on ne tient rien")
	else:
		print("  ok   arme, mais le cadran reste ferme tant qu'on ne tient pas")

	# ON TIENT LE CONTACT. Input.action_press simule la touche tenue, ce qui
	# est exactement ce que le mini-jeu attend.
	print("")
	print("--- on tient le contact ---")
	Input.action_press("interagir")
	for _i in 5:
		await process_frame
	if not bool(d.call("ouvert")):
		_echec("le cadran ne s'ouvre pas quand on tient la touche")
		quit(1)
		return
	print("  ok   le cadran s'ouvre")

	# 2 ET 4 : ON VISE JUSTE, TROIS FOIS, EN TRICHANT SUR L'AIGUILLE.
	#
	# On ne peut pas presser une touche au bon millieme de seconde depuis une
	# suite : on POSE l'aiguille sur la cible, puis on presse. Ce qu'on mesure
	# reste le mecanisme — la zone reconnait le bon angle, le compte avance,
	# le sens s'inverse — et pas l'adresse de la machine.
	print("")
	print("--- trois zones visees juste ---")
	var sens_avant := float(d.get("_sens"))
	var inversions := 0
	for zone in 3:
		d.set("_angle", float(d.get("_cible")))
		await _presser(d, "gauche")
		var atteint := int(d.call("zone"))
		if zone < 2:
			if atteint != zone + 1:
				_echec("zone %d visee juste, mais le compte est a %d"
						% [zone + 1, atteint])
				break
			var sens := float(d.get("_sens"))
			if sens != sens_avant:
				inversions += 1
			sens_avant = sens
			print("  ok   zone %d validee, l'aiguille repart dans l'autre sens"
					% [zone + 1])
		else:
			print("  ok   la troisieme lance le moteur")

	if inversions < 2:
		_echec("le sens ne s'est inverse que %d fois sur 2" % inversions)

	# Le moteur prend apres le petit temps d'affichage.
	var lance := false
	for _i in 90:
		await process_frame
		if not bool(d.call("arme")):
			lance = true
			break
	if not lance:
		_echec("les trois zones sont passees et le moteur n'a pas pris")
	else:
		print("  ok   le moteur a pris")

	# 3 : RATER NE BLOQUE RIEN.
	print("")
	print("--- et quand on vise a cote ---")
	d.call("reinitialiser")
	d.call("armer")
	for _i in 5:
		await process_frame
	# On pose l'aiguille A L'OPPOSE de la cible : impossible d'etre dans la
	# zone, quelle que soit sa largeur.
	d.set("_angle", wrapf(float(d.get("_cible")) + PI, 0.0, TAU))
	await _presser(d, "gauche")
	if int(d.call("zone")) != 0:
		_echec("un tir a l'oppose de la zone a ete accepte")
	else:
		print("  ok   c'est rate, et le compte repart de zero")

	# ET ON PEUT RECOMMENCER : c'est le point le plus important du test.
	for _i in 90:
		await process_frame
	if not bool(d.call("arme")):
		_echec("un echec desarme le demarreur : on ne peut plus demarrer")
	else:
		print("  ok   on peut recommencer")

	Input.action_release("interagir")
	print("")
	if _erreurs > 0:
		printerr("TEST DEMARREUR ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST DEMARREUR OK")
	quit(0)


# Un appui complet, avec son relachement : « just_pressed » ne se declenche
# que sur le front.
func _presser(d: Node, action: String) -> void:
	Input.action_press(action)
	await process_frame
	await process_frame
	Input.action_release(action)
	await process_frame


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC %s" % quoi)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
