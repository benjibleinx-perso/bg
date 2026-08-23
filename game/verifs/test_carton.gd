# Le saut de trois semaines se dit-il sur du noir, et le jeu en sort-il ?
#
#     godot --headless --path game --script res://verifs/test_carton.gd
#
# CE QUE CA GARDE. « Le titre "3 semaines plus tôt" doit apparaitre a la fin de
# la cinematique. Sur un fond noir pendant quelques secondes et non en jeu.
# C'est une vraie pause. On ouvre sur un fondu du noir vers le jeu. » — retour
# du 23/08/2026.
#
# ET SURTOUT : QU'ON EN SORTE. Un carton qui s'installe et ne se leve pas
# laisse un ecran noir dont plus rien ne fait sortir — la pire panne possible,
# parce qu'elle ressemble a un jeu qui a plante alors que tout tourne. C'est
# la moitie du test.
extends SceneTree

## Ce qu'on laisse au carton pour se dérouler, en images. Il dure quatre
## secondes et demie de temps reel ; on prend large.
const PATIENCE := 900

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var carton := _trouver(root, "Carton")
	if carton == null:
		printerr("ECHEC aucun noeud Carton dans le monde")
		quit(1)
		return

	print("")
	print("--- au repos ---")
	if bool(carton.call("actif")) or carton.get("visible"):
		_echec("le carton est affiche alors que rien ne l'a demande")
	else:
		print("  ok   il ne se montre pas tout seul")

	print("")
	print("--- on montre le saut de temps ---")
	carton.call("montrer", "Trois semaines plus tot")
	await process_frame
	if not bool(carton.call("actif")):
		_echec("il ne s'est pas declenche")
	elif not bool(carton.get("visible")):
		_echec("il est declenche mais invisible")
	else:
		print("  ok   il s'installe")

	# ON ATTEND SANS RIEN PRESSER : le carton doit se lever tout seul.
	var leve := false
	var images := 0
	for i in PATIENCE:
		await process_frame
		images = i
		if not bool(carton.call("actif")):
			leve = true
			break
	if not leve:
		_echec("il ne se leve jamais : l'ecran reste noir")
	else:
		print("  ok   il se leve seul (%d images)" % images)
		if bool(carton.get("visible")):
			_echec("il est fini mais reste affiche")
		else:
			print("  ok   et il rend l'ecran")

	# UN CARTON VIDE NE FAIT RIEN. Un passage sans carton passe la chaine
	# vide ; s'il declenchait un noir de quatre secondes, tous les passages du
	# jeu s'arreteraient sur un ecran muet.
	print("")
	print("--- un carton vide ---")
	carton.call("montrer", "")
	await process_frame
	if bool(carton.call("actif")):
		_echec("une chaine vide declenche quand meme un noir")
	else:
		print("  ok   il ne se passe rien")

	print("")
	if _erreurs > 0:
		printerr("TEST CARTON ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST CARTON OK")
	quit(0)


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
