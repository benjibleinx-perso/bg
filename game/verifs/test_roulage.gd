# Trois secondes de conduite ouvrent-elles la sortie du fosse ?
#
#     godot --headless --path game --script res://verifs/test_roulage.gd
#
# CE QUE CA REMPLACE. « On ne devrait pas sortir pour declencher la suite, on
# ne comprend pas. Le mieux serait de declencher une cinematique des qu'on se
# trouve les 4 roues sur la route et qu'on roule pendant au moins 3 secondes. »
# — retour du 23/08/2026.
#
# Il fallait franchir une bande de trois metres posee en travers de la piste :
# une ligne invisible, que rien n'annonce et qu'on peut manquer.
#
# ON MESURE LE MECANISME, PAS LA TRAVERSEE. Conduire le camping-car hors du
# fosse est l'affaire de `test -Suite parcours`, qui le joue. Ici on verifie
# les trois regles qui decident : le temps compte, l'arret le remet a zero, et
# sortir de la zone aussi.
extends SceneTree


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var p := _trouver(root, "SortieCrash") as Passage
	if p == null:
		printerr("ECHEC SortieCrash introuvable")
		quit(1)
		return

	var erreurs := 0
	print("")
	print("--- ce que la sortie demande ---")
	if p.roule_depuis <= 0.0:
		printerr("  ECHEC elle ne demande pas de rouler : c'est encore une ligne a franchir")
		quit(1)
		return
	print("  ok   %.1f s de conduite, au moins %.0f km/h"
			% [p.roule_depuis, p.vitesse_minimale])

	# 1. LE TEMPS COMPTE, ET SEULEMENT DEDANS.
	p.cesser_de_rouler()
	var ouvert := false
	for _i in 10:
		ouvert = p.rouler(true, 30.0, 0.5)
	if not ouvert:
		printerr("  ECHEC cinq secondes de conduite dedans n'ouvrent pas la sortie")
		erreurs += 1
	else:
		print("  ok   en roulant dedans, elle s'ouvre (%.1f s)"
				% p.temps_de_roulage())

	# 2. S'ARRETER REMET LE COMPTE A ZERO. Sans ca, on pourrait s'arreter sur
	# la piste et repartir deux minutes plus tard : le compte serait deja fait,
	# et la scene partirait sans qu'on roule.
	p.cesser_de_rouler()
	for _i in 4:
		p.rouler(true, 30.0, 0.5)
	var avant := p.temps_de_roulage()
	p.rouler(true, 0.0, 0.5)
	if p.temps_de_roulage() >= avant:
		printerr("  ECHEC s'arreter ne remet pas le compte a zero (%.1f s)"
				% p.temps_de_roulage())
		erreurs += 1
	else:
		print("  ok   s'arreter le remet a zero")

	# 3. SORTIR DE LA ZONE N'ARRETE PLUS LE COMPTE — c'est le contrat du
	#    04/09/2026, et l'inverse exact de ce que ce controle exigeait avant.
	#
	# L'ancien disait « sortir de la zone remet a zero », ce qui etait vrai et
	# rendait la sortie du fosse INFRANCHISSABLE au-dessus de 31 km/h : trois
	# secondes ne tiennent pas dans 26 m a la vitesse ou l'on roule. La zone
	# dit maintenant quand on COMMENCE a compter, et rien de plus.
	p.cesser_de_rouler()
	for _i in 4:
		p.rouler(true, 30.0, 0.5)
	p.rouler(false, 30.0, 0.5)
	if p.temps_de_roulage() <= 0.0:
		printerr("  ECHEC sortir de la zone remet le compte a zero : le verrou est revenu")
		erreurs += 1
	else:
		print("  ok   sortir de la zone n'arrete pas le compte (%.1f s)"
				% p.temps_de_roulage())

	# 3 bis. MAIS ROULER AILLEURS SANS ETRE PASSE PAR LA ZONE NE COMPTE PAS.
	#
	# C'est ce que la zone decide encore, et c'est tout ce qu'elle decide. Sans
	# ce controle, la reparation ci-dessus ouvrirait la sortie a quiconque roule
	# dans le desert.
	p.cesser_de_rouler()
	for _i in 10:
		p.rouler(false, 60.0, 0.5)
	if p.roule_assez() or p.roule_ouvert():
		printerr("  ECHEC rouler hors de la zone suffit a l'ouvrir")
		erreurs += 1
	else:
		print("  ok   rouler ailleurs ne l'ouvre pas")

	# 4. QUELQU'UN REAGIT, PARCE QUE LES TROIS SECONDES NE S'AFFICHENT NULLE PART.
	#
	# C'est voulu — Guillaume veut MOINS de texte de mission — donc le seul
	# retour que le joueur ait est Jesse. S'il se tait, on retombe exactement
	# sur ce qui l'a bloque le 23/08/2026 a 23 h 24 : un compteur invisible qui
	# repart a zero sans que rien ne le dise, et un joueur qui conclut que
	# « ca declenche rien ».
	var dits: Array[String] = []
	p.commence.connect(func() -> void: dits.append("commence"))
	p.interrompu.connect(func() -> void: dits.append("interrompu"))

	p.cesser_de_rouler()
	p.rouler(true, 30.0, 0.5)
	if not dits.has("commence"):
		printerr("  ECHEC personne ne reagit quand on commence a rouler dedans")
		erreurs += 1
	else:
		print("  ok   quelqu'un reagit des qu'on commence a rouler")

	p.rouler(true, 30.0, 0.5)
	if dits.count("commence") != 1:
		printerr("  ECHEC la reaction se repete a chaque image (%d fois)"
				% dits.count("commence"))
		erreurs += 1
	else:
		print("  ok   et elle ne se repete pas a chaque image")

	p.rouler(true, 0.0, 0.5)
	if not dits.has("interrompu"):
		printerr("  ECHEC personne ne reagit quand on s'arrete avant la fin")
		erreurs += 1
	else:
		print("  ok   quelqu'un reagit aussi quand on s'arrete avant la fin")

	# 5. ET ELLE S'OUVRE A LA VITESSE OU L'ON ROULE VRAIMENT.
	#
	# CE CONTROLE EXISTAIT ET REGARDAIT LE MAUVAIS BOUT. Il divisait la
	# longueur de la zone par la vitesse MINIMALE — 26 m a 8 km/h font 11,7 s,
	# donc trois secondes tenaient largement, donc il etait vert. A la vitesse
	# ou la piste se prend, 75 km/h, la meme zone se traverse en 1,25 s et la
	# condition devenait impossible. Le cas facile etait mesure, le cas reel ne
	# l'etait pas.
	#
	# On simule donc la traversee A PLEINE VITESSE — dedans le temps qu'elle
	# dure, dehors ensuite — et on exige que la sortie finisse par s'ouvrir.
	# C'est le seul controle de ce fichier qui aurait attrape le bug.
	var forme := p.find_child("Forme", true, false) as CollisionShape3D
	if forme == null or not (forme.shape is BoxShape3D):
		printerr("  ECHEC pas de forme de zone lisible")
		erreurs += 1
	else:
		var profondeur: float = (forme.shape as BoxShape3D).size.z
		var vite := 75.0
		var cc := _trouver(root, "CampingCar") as Node3D
		if cc != null and cc.get("vitesse_max_propre_kmh") != null:
			vite = maxf(vite, float(cc.get("vitesse_max_propre_kmh")))
		var pas := 1.0 / 60.0
		var traversee := profondeur / maxf(1.0, vite / 3.6)
		p.cesser_de_rouler()
		var dedans := 0.0
		while dedans < traversee:
			p.rouler(true, vite, pas)
			dedans += pas
		var dehors := 0.0
		while dehors < p.roule_depuis and not p.roule_ouvert():
			p.rouler(false, vite, pas)
			dehors += pas
		if not p.roule_ouvert():
			printerr("  ECHEC a %.0f km/h elle ne s'ouvre jamais :"
					% vite
					+ " %.0f m se traversent en %.2f s pour %.1f s demandees"
					% [profondeur, traversee, p.roule_depuis])
			erreurs += 1
		else:
			print("  ok   a %.0f km/h elle s'ouvre : %.0f m traverses en %.2f s,"
					% [vite, profondeur, traversee]
					+ " le compte finit %.1f s plus loin" % dehors)

	print("")
	if erreurs > 0:
		printerr("TEST ROULAGE ECHOUE : %d probleme(s)" % erreurs)
		quit(1)
		return
	print("TEST ROULAGE OK")
	quit(0)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
