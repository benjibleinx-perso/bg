# Une replique coupee s'enchaine-t-elle sans le joueur ?
#
#     godot --headless --path game --script res://verifs/test_coupure.gd
#
# CE QUE CA GARDE. « Si dans le dialogue, un personnage se fait couper la
# parole, le jeu ne laisse pas au joueur le temps d'appuyer sur suivant, la
# phrase d'apres s'enchaine toute seule » — retour de Guillaume du 23/08/2026.
#
# Une replique de dialogues.json peut donc porter « coupe ». Ici, c'est Jesse
# qui s'emballe — « C'est bon, c'est bon— » — et Walter qui lui passe dessus.
# Le comedien l'a joue ainsi, la donnee le dit depuis toujours dans son champ
# `jeu` : « cutting in, firm ». Il ne manquait que le jeu pour l'entendre.
#
# LE TEST A DEUX MOITIES, ET LA SECONDE COMPTE AUTANT QUE LA PREMIERE :
#
#   1. la replique marquee avance TOUTE SEULE, sans qu'on presse rien ;
#   2. une replique ordinaire, elle, ATTEND. Sans ce contre-test, un dialogue
#      qui avancerait tout seul du debut a la fin passerait pour un succes.
extends SceneTree

## La conversation qui porte la coupure, et le rang de la replique coupee.
const CONVERSATION := "cuisine_verser"

## Le temps qu'on laisse a la coupure pour se declencher. Large : la replique
## de Jesse est courte, et le compte a rebours suit la duree de sa voix.
const ATTENTE := 300

## Ce qu'on attend sur une replique ordinaire : qu'il ne se passe RIEN.
const PATIENCE := 180

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var d := _trouver(root, "Dialogue")
	if d == null:
		printerr("ECHEC Dialogue introuvable")
		quit(1)
		return

	print("")
	print("--- on avance jusqu'a la replique coupee ---")
	if not d.call("demarrer", CONVERSATION):
		printerr("ECHEC la conversation '%s' ne s'ouvre pas" % CONVERSATION)
		quit(1)
		return

	# On avance A LA MAIN jusqu'a tomber sur une replique sans invite : c'est
	# la signature d'une coupure, et la chercher plutot que de compter les
	# repliques evite un test qui casse des qu'on ajoute une phrase.
	var tours := 0
	while tours < 20 and str(d.call("invite")) != "":
		d.call("avancer")
		await process_frame
		tours += 1

	if str(d.call("invite")) != "":
		printerr("ECHEC aucune replique coupee trouvee dans '%s'" % CONVERSATION)
		_erreurs += 1
	else:
		print("  ok   l'invite disparait : rien a presser (replique %d)" % tours)

	# ON NE PRESSE RIEN. C'est tout le sujet.
	var avant := tours
	var bouge := false
	for _i in ATTENTE:
		await process_frame
		if str(d.call("invite")) != "":
			bouge = true
			break

	if not bouge:
		printerr("ECHEC la replique coupee attend le joueur")
		_erreurs += 1
	else:
		print("  ok   la suivante est partie toute seule, sans appui")

	print("")
	print("--- et une replique ordinaire attend ---")
	# La conversation a avance : on est sur une replique normale. Elle ne doit
	# PAS bouger tant qu'on ne presse rien.
	var invite_avant := str(d.call("invite"))
	var index_avant := _texte_courant(d)
	for _i in PATIENCE:
		await process_frame
	var apres := _texte_courant(d)

	if invite_avant == "":
		print("       (la conversation s'est fermee, rien a mesurer ici)")
	elif apres != index_avant:
		printerr("ECHEC une replique ordinaire a avance toute seule")
		_erreurs += 1
	else:
		print("  ok   elle attend l'appui, comme avant (%d images)" % PATIENCE)

	print("")
	if _erreurs > 0:
		printerr("TEST COUPURE ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST COUPURE OK")
	quit(0)


# Le texte affiche, lu sur l'etiquette du dialogue. On compare des TEXTES et
# pas un numero de replique : le numero est interne, le texte est ce que le
# joueur voit.
func _texte_courant(d: Node) -> String:
	var e := d.get_node_or_null(d.get("etiquette_texte")) as Label
	return e.text if e != null else ""


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
