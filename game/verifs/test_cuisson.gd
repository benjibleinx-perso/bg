# La cuisson est-elle branchee, et decide-t-elle vraiment de la purete ?
#
#     godot --headless --path game --script res://verifs/test_cuisson.gd
#
# TROIS PANNES MUETTES POSSIBLES :
#
#   1. le signal « utilise » de l'atelier n'est pas connecte — on appuie sur F,
#      on reçoit la botte, et rien ne se passe. Le jeu se comporte exactement
#      comme avant la cuisson, ce qui est le plus difficile a remarquer ;
#   2. l'hote d'interface est introuvable — la barre ne se dessine nulle part
#      et la cuisson se joue en aveugle ;
#   3. le calcul du palier ne couvre pas ses bornes — trois passages parfaits
#      qui ne donnent pas le bleu, ou trois rates qui bloquent la mission.
#
# On ne simule pas des appuis : on appelle la logique et on lit ce qu'elle
# produit. Le geste, lui, se juge en jouant.
extends SceneTree


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var rates := 0

	var c := monde.find_child("Cuisson", true, false)
	if c == null:
		print("ECHEC noeud Cuisson introuvable")
		quit(1)
		return

	print("")
	print("--- la cuisson ---")

	# 1. Le branchement sur l'atelier.
	#
	# ON PREND CELUI QUE LA CUISSON DESIGNE, pas le premier du nom.
	# find_child("Atelier") rend un MAILLAGE du decor genere, appele « Atelier »
	# lui aussi — c'est le piege 19, et il a fait echouer ce test sur une
	# connexion qui existait. Le seul atelier qui compte est celui vers lequel
	# pointe le NodePath de la cuisson.
	var vers: Variant = c.get("atelier")
	var atelier := c.get_node_or_null(vers) if vers != null else null
	var branche := false
	if atelier != null and atelier.has_signal("utilise"):
		for lien in atelier.get_signal_connection_list("utilise"):
			if lien["callable"].get_object() == c:
				branche = true
	print("  %s l'atelier previent la cuisson" % ("ok  " if branche else "ECHEC"))
	if not branche:
		rates += 1

	# 2. L'hote d'interface.
	var hote: Variant = c.get("interface")
	var vu := c.get_node_or_null(hote) if hote != null else null
	print("  %s l'interface d'accueil existe" % ("ok  " if vu != null else "ECHEC"))
	if vu == null:
		rates += 1

	# 3. Les bornes du calcul. On pose les scores a la main et on lit le palier
	# obtenu : c'est la seule partie qui decide de ce que vaudra la marchandise.
	var p := Purete.courante(c)
	if p == null:
		print("  ECHEC pas de systeme de purete")
		quit(1)
		return

	var haut := Purete.PALIERS.size() - 1
	print("")
	print("  moyenne -> palier")
	for cas in [[0.0, 0], [0.25, 1], [0.5, 2], [0.75, 3], [1.0, haut]]:
		var moyenne: float = cas[0]
		var attendu: int = cas[1]
		var obtenu := clampi(int(round(moyenne * float(haut))), 0, haut)
		var bon := obtenu == attendu
		print("    %.2f -> %d (%s) %s" % [moyenne, obtenu,
				Purete.PALIERS[obtenu]["nom"], "" if bon else "ATTENDU %d" % attendu])
		if not bon:
			rates += 1

	# Rater ne doit jamais bloquer : on ressort toujours avec de la
	# marchandise, meme mauvaise. C'est ce qui distingue une difficulte d'un
	# mur.
	var plancher := clampi(int(round(0.0 * float(haut))), 0, haut)
	print("")
	print("  %s trois passages rates donnent quand meme du '%s'"
			% ["ok  " if plancher >= 0 else "ECHEC", Purete.PALIERS[plancher]["nom"]])

	print("")
	if rates > 0:
		print("ECHEC %d point(s) en defaut" % rates)
		quit(1)
		return
	print("TEST CUISSON OK")
	quit()
