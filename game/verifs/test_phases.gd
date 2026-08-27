# Peut-on sauter a chaque etape de la mission QU'ON JOUE, et en franchir une ?
#
#     godot --headless --path game --script res://verifs/test_phases.gd
#
# CE QUE CA ATTRAPE. Le menu de test propose la liste des etapes. Chacune peut
# echouer de deux facons, et AUCUNE des deux ne leve d'erreur :
#
#   1. le deroule se bloque avant elle — une etape sans emetteur, ou un
#      evenement que la mission refuse — et la ligne du menu ne fait rien ;
#   2. l'etape est atteinte mais son 'ou' designe un noeud absent : le joueur
#      reste ou il est, la mission avance quand meme, et on croit que le saut a
#      marche jusqu'a se demander pourquoi le decor n'est pas le bon.
#
# CE QUE LA VERSION D'AVANT NE POUVAIT PAS VOIR, et c'est la raison d'etre de
# celle-ci. Elle mesurait une table ecrite a la main dans dev.gd — dix phases de
# mission1.json — alors que le jeu charge « Deux corps, un camping-car » depuis
# des semaines. Elle s'en etait apercue et avait choisi de RECHARGER la mission
# de rodage pour se mettre d'accord avec la table :
#
#     « on mesure donc contre le fichier que les phases decrivent »
#
# C'est le piege 19 dans sa forme la plus pure — une verification qui se place
# elle-meme au bon endroit valide toujours. Elle etait verte pendant que l'outil
# etait inutilisable dans la seule mission jouable, et il a fallu qu'on soit
# bloque a la premiere etape, manette en main, pour l'apprendre.
#
# ON NE RECHARGE PLUS RIEN : on mesure la mission telle que le joueur la trouve.
extends SceneTree


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var dev := monde.find_child("Dev", true, false)
	if dev == null:
		print("ECHEC noeud Dev introuvable")
		quit(1)
		return
	var m := Mission.courante(dev)
	if m == null:
		print("ECHEC pas de mission")
		quit(1)
		return

	var rates := 0
	print("")
	print("--- « %s », telle qu'elle est chargee ---" % m.titre())

	# LA LISTE DU MENU EST-ELLE CELLE DE LA MISSION ? Les deux nombres sont
	# imprimes et non seulement compares : c'est ce qui distingue « la page est
	# vide » de « la page decrit autre chose ».
	var lignes: Array = dev.call("page_lignes", "etape")
	var etapes: Array = m.etapes()
	if lignes.size() != etapes.size():
		printerr("  ECHEC le menu propose %d ligne(s) pour %d etape(s)"
				% [lignes.size(), etapes.size()])
		rates += 1
	else:
		print("  ok   %d etape(s) proposees, autant que la mission en a"
				% lignes.size())

	# ---------------------------------------------------------------------
	# FRANCHIR L'ETAPE EN COURS : le geste de deblocage, et le seul qui compte
	# quand on est coince. On passe par `basculer`, c'est-a-dire par la meme
	# porte que le menu — appeler la fonction interne validerait un chemin que
	# personne n'emprunte, et ne dirait rien du branchement (piege 32).
	m.recommencer()
	var avant := m.index()
	var cle_avant := m.cle_etape()
	var echo := str(dev.call("basculer", "valider_etape"))
	if m.index() == avant + 1:
		print("  ok   « Valider l'etape en cours » franchit '%s' (%s)"
				% [cle_avant, echo])
	else:
		printerr("  ECHEC « Valider l'etape en cours » : index %d -> %d (%s)"
				% [avant, m.index(), echo])
		rates += 1

	# ---------------------------------------------------------------------
	# ET CHAQUE ETAPE EST ATTEIGNABLE. On rembobine et on avance par les MEMES
	# evenements que le jeu : un test qui poserait l'index validerait un chemin
	# que personne n'emprunte.
	print("")
	for i in etapes.size():
		var e: Dictionary = etapes[i]
		var cle := str(e.get("cle", ""))
		var nom := "%d. %s" % [i + 1, str(e.get("objectif", cle))]

		m.recommencer()
		var garde := 0
		while not m.finie() and m.index() < i and garde < 60:
			garde += 1
			var quoi := str(m.etape().get("valide_par", ""))
			if quoi == "" or not m.evenement(quoi):
				break

		if m.index() != i:
			printerr("  ECHEC %-34s bloque a '%s'" % [nom, m.cle_etape()])
			rates += 1
			continue

		# UNE ETAPE SANS LIEU N'EST PAS UN DEFAUT. « Suivre la voix » et
		# « rentrer » n'en ont pas : la premiere se joue la ou l'on se reveille,
		# la seconde se termine en roulant. Les exiger toutes reviendrait a
		# demander a la mission de ressembler a l'outil.
		var ou := m.ou()
		if ou == "":
			print("  ok   %-34s (aucun lieu, on reste sur place)" % nom)
			continue
		var n := monde.find_child(ou, true, false) as Node3D
		if n == null:
			printerr("  ECHEC %-34s '%s' introuvable dans la scene" % [nom, ou])
			rates += 1
			continue

		var pos := n.global_position
		print("  ok   %-34s %-18s %7.0f %7.0f" % [nom, ou, pos.x, pos.z])

	# LA LISTE DES LIEUX DOIT RESTER COURTE. Elle publiait quarante et un noms,
	# dont trente-sept parcelles du generateur ; le cadre en montre quatorze.
	# Si elle regrossit, c'est que les parcelles sont revenues.
	var lieux: Array = dev.call("lieux")
	print("")
	print("  %d lieu(x) proposes : %s" % [lieux.size(), ", ".join(lieux)])
	if lieux.size() > 14:
		printerr("  ECHEC la liste des lieux deborde du cadre (%d > 14)"
				% lieux.size())
		rates += 1

	# LE DEFILEMENT NE S'EMBALLE PLUS SOUS LA SOURIS.
	#
	# La liste des LIEUX tient dans le cadre — c'est le controle juste au-dessus
	# qui l'exige. Celle des ETAPES, non : la mission en a plus de vingt pour
	# quatorze lignes visibles, et c'est la page que l'on ouvre pour tester.
	#
	# La fenetre y etait recentree sur le choix a chaque image. Avec le survol
	# de la souris, un cran de deplacement faisait glisser la liste d'un cran
	# sous le curseur, qui choisissait la ligne suivante, qui la faisait glisser
	# encore : « ca defile/scroll trop vite » (Guillaume, 27/08/2026).
	#
	# CE QUE CE CONTROLE VERIFIE, ET QUI NE PEUT PAS ARRIVER AUTREMENT : viser
	# une ligne DEJA visible ne bouge pas la fenetre. Avec l'ancien calcul elle
	# reculait de quatre lignes sur ce meme geste.
	var pause := monde.find_child("Pause", true, false)
	if pause == null:
		printerr("  ECHEC noeud Pause introuvable")
		rates += 1
	else:
		var total := etapes.size() + 1
		var fen := 14
		var vise := total - 2
		pause.set("_choix", vise)
		var bas: int = pause.call("suivre_la_fenetre", total, fen)
		var attendu := maxi(0, vise - fen + 1)
		pause.set("_choix", bas + 3)
		var apres: int = pause.call("suivre_la_fenetre", total, fen)
		if bas != attendu:
			printerr("  ECHEC la fenetre n'avance pas au plus court : %d au lieu de %d"
					% [bas, attendu])
			rates += 1
		elif apres != bas:
			printerr("  ECHEC viser une ligne visible fait defiler : %d -> %d"
					% [bas, apres])
			rates += 1
		else:
			print("  ok   %-34s fenetre a %d, immobile sur une ligne visible"
					% ["defilement des etapes", bas])

	print("")
	if rates > 0:
		print("ECHEC %d etape(s) ou liste(s) en defaut" % rates)
		quit(1)
		return
	print("TEST PHASES OK  %d etape(s) atteignables" % etapes.size())
	quit()
