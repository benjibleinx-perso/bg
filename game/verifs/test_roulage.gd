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

	# 3. SORTIR DE LA ZONE AUSSI.
	p.cesser_de_rouler()
	for _i in 4:
		p.rouler(true, 30.0, 0.5)
	p.rouler(false, 30.0, 0.5)
	if p.roule_assez() or p.temps_de_roulage() > 0.0:
		printerr("  ECHEC sortir de la zone ne remet pas le compte a zero")
		erreurs += 1
	else:
		print("  ok   sortir de la zone le remet a zero")

	# 4. ET LA ZONE EST ASSEZ LARGE POUR QU'ON Y ROULE.
	#
	# Une bande de trois metres traversee a trente km/h dure un tiers de
	# seconde : trois secondes de conduite dedans y seraient impossibles, et
	# la sortie ne s'ouvrirait JAMAIS. C'est le genre de contradiction qu'on
	# ne voit pas en lisant deux fichiers separement.
	var forme := p.find_child("Forme", true, false) as CollisionShape3D
	if forme == null or not (forme.shape is BoxShape3D):
		printerr("  ECHEC pas de forme de zone lisible")
		erreurs += 1
	else:
		var profondeur: float = (forme.shape as BoxShape3D).size.z
		# A la vitesse minimale, combien de temps met-on a la traverser ?
		var traversee := profondeur / maxf(1.0, p.vitesse_minimale / 3.6)
		if traversee < p.roule_depuis:
			printerr("  ECHEC la zone se traverse en %.1f s, et elle demande %.1f s"
					% [traversee, p.roule_depuis])
			erreurs += 1
		else:
			print("  ok   elle fait %.0f m : %.1f s de traversee pour %.1f s demandees"
					% [profondeur, traversee, p.roule_depuis])

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
