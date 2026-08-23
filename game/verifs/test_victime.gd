# Quand c'est quelqu'un d'AUTRE qui meurt, est-ce lui qu'on voit ?
#
#     godot --path game --script res://verifs/test_victime.gd
#
# CE QUE CA ATTRAPE. « Quand un Game Over est provoqué par la mort de
# quelqu'un d'autre, c'est Walter qui meurt sur l'écran de game over. Il faut
# que ce soit un plan sur le personnage qui meurt, au ralenti, 1 seconde avant
# de lancer son animation de mort » — retour de Guillaume du 23/08/2026.
#
# Le defaut etait dans une seule ligne : `perdre()` appelait toujours
# `effondrer_le_joueur()`, quel que soit le mort. On lisait donc « Jesse est
# mort » sur le corps de Walter.
#
# LES QUATRE CHOSES QU'ON MESURE, et la troisieme est celle qui manquait :
#
#   1. la camera prend la VICTIME pour sujet ;
#   2. la victime tombe — et pas tout de suite : on a le temps de la voir ;
#   3. le JOUEUR, lui, reste debout ;
#   4. le carton finit par s'afficher, avec le titre de la scene.
extends SceneTree

## Qui l'on tue. Jesse est le seul PNJ present des le debut de la mission, et
## c'est l'exemple meme du retour : lui tirer dessus termine la partie.
const VICTIME := "jesse"

## Le titre que le scenario emploie pour lui. On le passe nous-memes : ce test
## verifie la mise en scene, pas la table des repliques.
const TITRE := "Jesse est mort"

## Le temps qu'on laisse a la sequence entiere, en images. Large : elle dure
## deux secondes reelles, et elle se joue au ralenti.
const DEROULE := 400

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var scenario := _trouver(root, "Scenario")
	var joueur := _trouver(root, "Joueur") as Node3D
	var camera := _trouver(root, "Camera3D") as Camera3D
	var fin := _trouver(root, "FinDePartie")
	var victime := _pnj(root, VICTIME)

	for paire in [["Scenario", scenario], ["Joueur", joueur],
			["Camera3D", camera], ["FinDePartie", fin],
			["le PNJ '%s'" % VICTIME, victime]]:
		if paire[1] == null:
			printerr("ECHEC %s introuvable" % paire[0])
			quit(1)
			return

	# La victime est loin du joueur : sans ca, « la camera regarde la victime »
	# et « la camera regarde le joueur » seraient la meme phrase.
	victime.global_position = joueur.global_position + Vector3(0.0, 0.0, -14.0)
	await process_frame

	var debout_joueur := joueur.rotation.x
	print("")
	print("--- on tire sur %s ---" % VICTIME)
	scenario.call("perdre", TITRE, victime)

	# 1. LA CAMERA CHANGE DE SUJET, et vite : c'est une seconde de plan.
	var vue := false
	for _i in 60:
		await process_frame
		var d_victime := camera.global_position.distance_to(victime.global_position)
		var d_joueur := camera.global_position.distance_to(joueur.global_position)
		if d_victime < d_joueur:
			vue = true
			break
	if not vue:
		_echec("la camera est restee sur le joueur")
	else:
		print("  ok   la camera prend la victime pour sujet")

	# 2. ELLE TOMBE, mais pas dans l'image qui suit le coup de feu.
	var tombee_tot := absf(victime.rotation.x) > 0.2
	if tombee_tot:
		_echec("elle tombe immediatement : on n'a pas le temps de la suivre")

	# ELLE TOMBE AVANT QUE LE CARTON S'ECRIVE, et c'est l'ordre qui compte.
	#
	# Le premier essai laissait 0,9 seconde entre la chute et l'ecran de fin —
	# sauf que la chute avance avec le temps DU JEU, donc au ralenti : une
	# demi-seconde de bascule en dure deux a la montre. « GAME OVER »
	# s'ecrivait par-dessus quelqu'un encore debout. Aucune mesure ne le
	# disait ; la capture, si.
	var tombee := false
	var carton_avant := false
	for _i in DEROULE:
		await process_frame
		if absf(victime.rotation.x) > 1.0:
			tombee = true
			break
		if bool(fin.call("actif")):
			carton_avant = true
			break
	if carton_avant:
		_echec("« GAME OVER » s'affiche alors qu'elle est encore debout")
	elif not tombee:
		_echec("elle n'est jamais tombee (inclinaison %.2f rad)" % victime.rotation.x)
	else:
		print("  ok   elle bascule, apres qu'on l'a vue debout, avant le carton")

	# 3. ET LE JOUEUR RESTE DEBOUT. C'est le defaut d'origine, et il ne se
	# voyait nulle part ailleurs : le carton disait bien « Jesse est mort ».
	if absf(joueur.rotation.x - debout_joueur) > 0.2:
		_echec("le joueur s'est effondre alors que c'est %s qui meurt" % VICTIME)
	else:
		print("  ok   le joueur, lui, ne s'effondre pas")

	# 4. LE CARTON ARRIVE.
	var affiche := false
	for _i in 200:
		await process_frame
		if bool(fin.call("actif")):
			affiche = true
			break
	if not affiche:
		_echec("l'ecran de fin ne s'est pas affiche")
	else:
		print("  ok   l'ecran de fin suit la chute")

	# On rend le temps a la vitesse normale : une suite qui laisse le moteur
	# au quart de sa vitesse fausse celle qui la suit.
	Engine.time_scale = 1.0

	print("")
	if _erreurs > 0:
		printerr("TEST VICTIME ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST VICTIME OK")
	quit(0)


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC %s" % quoi)


# Le PNJ portant cette cle. On cherche par CLE et pas par nom de noeud : la
# cle est ce qui relie un personnage a ses repliques, et c'est elle que le
# scenario emploie.
func _pnj(n: Node, cle: String) -> Node3D:
	if n is Pnj and (n as Pnj).cle == cle:
		return n as Node3D
	for e in n.get_children():
		var t := _pnj(e, cle)
		if t != null:
			return t
	return null


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
