# TRAINER LES DEUX CORPS : est-ce que ca dure vraiment, et est-ce que ca finit ?
#
#     godot --headless --path game --script res://verifs/test_traction.gd
#
# CE QUE CA GARDE. Le retour du 23/08/2026 pose une exigence CHIFFREE, ce qui
# est rare : « la tractation complete doit bien prendre au moins 20 secondes ».
# Un chiffre demande se mesure, sinon il se perd au premier reglage — et celui-
# la tient tout seul le diagnostic central du document, « la mission est trop
# rapide ».
#
# LES SIX FAITS :
#
#   1. hors de son etape, la traction ne fait RIEN. Un mecanisme qui repond
#      partout est un mecanisme qui volera la touche ailleurs ;
#   2. maintenir pres d'un corps l'attrape, et il suit ;
#   3. lacher le repose LA OU IL EST — pas a sa place d'origine : lacher a
#      mi-chemin est un choix qu'on a le droit de faire ;
#   4. deux pauses par corps, et pendant une pause on ne peut pas reprendre ;
#   5. arrive a la portiere, le corps passe dedans sans qu'on appuie ;
#   6. les deux dedans, le signal part — et le trajet complet a coute plus de
#      vingt secondes.
#
# LE PILOTE NE TRICHE PAS SUR LA VITESSE. Il deplace Walter par pas de
# `traction_vitesse * delta`, exactement ce qu'un joueur qui tient la touche
# obtient. S'il avancait d'un metre par image, il mesurerait sa propre hate.
extends SceneTree

## Combien d'images de physique on simule par seconde. C'est le pas de temps
## FIXE du projet, et il faut le meme ici : une suite qui joue a pas variable
## rend deux verdicts sur le meme depot.
const PAS := 1.0 / 60.0

## Le budget d'images. Large : le trajet fait une douzaine de metres a moins
## d'un metre par seconde, plus deux pauses de trois secondes et demie.
const BUDGET := 60 * 90

var _erreurs := 0
var _monde: Node


func _initialize() -> void:
	if FileAccess.file_exists("user://partie.json"):
		DirAccess.remove_absolute("user://partie.json")
	_monde = (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(_monde)
	await process_frame
	await process_frame

	var mission := _trouver(root, "Mission") as Mission
	var joueur := _trouver(root, "Joueur") as Node3D
	if mission == null or joueur == null:
		printerr("ECHEC monde incomplet (Mission, Joueur)")
		quit(1)
		return

	# Le decor du fosse est instancie a l'execution par desert.gd : le groupe
	# est vide a la premiere image, et conclure ici annoncerait « aucune
	# traction » sur une scene qui en a une.
	for _i in 12:
		await process_frame

	var t := root.get_tree().get_first_node_in_group(Traction.GROUPE) as Traction
	if t == null:
		printerr("ECHEC aucune traction dans la scene")
		quit(1)
		return

	# 1. HORS DE SON ETAPE, ELLE SE TAIT.
	print("")
	print("--- hors de son etape ---")
	mission.call("aller_a", _rang(mission, "preuve_1"))
	await process_frame
	_verifier(not t.active(), "elle ne s'active pas a l'etape du ramassage")
	_verifier(t.invite() == "", "et elle ne propose rien (« %s »)" % t.invite())

	# ON SE PLACE A L'ETAPE QUI LA DEMANDE.
	print("")
	print("--- a l'etape des corps ---")
	mission.call("aller_a", _rang(mission, "corps"))
	await process_frame
	await process_frame
	_verifier(t.active(), "elle s'active")
	# UN SEUL POUR WALTER, ET C'EST TOUT LE SUJET DU LOT.
	#
	# « Jesse part devant et tracte sont cadavre lui-meme. » Il s'en reserve un
	# des la premiere image ou l'etape commence, et ce corps-la sort du compte
	# de ce qui reste a porter : deux personnes qui tirent le meme cadavre
	# chacune de son cote le feraient vibrer entre les deux.
	_verifier(t.restants() == 1,
			"un corps pour Walter, l'autre pour Jesse (%d restant)"
					% t.restants())

	var porte := _trouver(root, "DepartCrash") as Node3D
	if porte == null:
		printerr("ECHEC la portiere « DepartCrash » est introuvable")
		quit(1)
		return

	# LE TRAJET, MESURE AVANT DE LE FAIRE. C'est lui qui dit si les vingt
	# secondes sont atteignables, et c'est un nombre du DECOR : les corps et la
	# portiere bougent avec le camping-car.
	var corps_un := _un_corps(t)
	if corps_un == null:
		printerr("ECHEC aucun corps designe par la traction")
		quit(1)
		return
	var trajet := _a_plat(corps_un.global_position, porte.global_position)
	print("       le premier corps est a %.1f m de la portiere" % trajet)

	var secondes := 0.0
	# LES COMPTEURS SONT DES MEMBRES, ET CE N'EST PAS UN DETAIL DE STYLE.
	#
	# Ils ont d'abord ete des variables locales, incrementees depuis deux
	# lambdas branchees sur les signaux. En GDScript, une lambda capture par
	# VALEUR : les deux compteurs restaient a zero pour l'eternite, et le test
	# annoncait « les deux corps ne sont pas a bord » sur un mecanisme qui les
	# avait embarques tous les deux. C'est le diagnostic imprime juste en
	# dessous qui l'a dit — « il reste : aucun » et « 0 depose » dans la meme
	# ligne, ce qui ne peut pas etre vrai en meme temps.
	t.charges.connect(_sur_charges)
	t.souffle.connect(_sur_souffle)

	# 2. ON L'ATTRAPE.
	joueur.global_position = corps_un.global_position + Vector3(1.2, 0.0, 0.0)
	await process_frame
	t.tenir(true)
	await process_frame
	_verifier(t.porte_un_corps(), "maintenir pres d'un corps l'attrape")

	# 3. LACHER LE REPOSE LA OU IL EST.
	var ou := corps_un.global_position
	t.tenir(false)
	await process_frame
	_verifier(not t.porte_un_corps(), "lacher le repose")
	_verifier(_a_plat(corps_un.global_position, ou) < 1.5,
			"et il reste ou il etait, pas a sa place d'origine")

	# 4, 5 ET 6. ON LES EMMENE, EN MARCHANT.
	print("")
	print("--- on les traine jusqu'a la portiere ---")
	var vitesse := (joueur.get("reglages") as Reglages).traction_vitesse
	var images := 0
	while not _deposes and images < BUDGET:
		images += 1
		secondes += PAS
		t.tenir(true)
		# PENDANT UNE PAUSE, LA TOUCHE NE REND RIEN. On continue de la tenir —
		# c'est ce qu'un joueur fait — et on verifie qu'elle ne reprend pas.
		if t.au_repos():
			_repos_vu = true
			if t.porte_un_corps():
				_verifier(false, "on reprend le corps pendant la pause")
				break
			await process_frame
			continue
		if not t.porte_un_corps():
			# Il a lache — pause finie, ou corps depose. On va chercher le
			# suivant, exactement comme le joueur : on marche jusqu'a lui.
			var suivant := _un_corps(t)
			if suivant == null:
				await process_frame
				continue
			joueur.global_position = _vers(joueur.global_position,
					suivant.global_position, vitesse * PAS)
			await process_frame
			continue
		# On tire vers la portiere.
		joueur.global_position = _vers(joueur.global_position,
				porte.global_position, vitesse * PAS)
		await process_frame

	# ON IMPRIME L'ETAT AVANT DE JUGER. Un « les deux corps sont a bord :
	# ECHEC » ne dit pas si l'on n'a jamais attrape, jamais avance, ou jamais
	# depose — et les trois se corrigent a des endroits differents.
	var reste := _un_corps(t)
	print("       %d image(s), %.1f s simulees, %d depose(s), %d pause(s)"
			% [images, secondes, 2 if _deposes else 0, _pauses])
	print("       en main : %s | il reste : %s"
			% [t.porte_un_corps(), "aucun" if reste == null else reste.name])
	if reste != null:
		print("       ce qui reste est a %.1f m de la portiere, Walter a %.1f m"
				% [_a_plat(reste.global_position, porte.global_position),
					_a_plat(joueur.global_position, porte.global_position)])
	_verifier(_deposes, "les deux corps sont a bord")
	_verifier(_repos_vu, "Walter s'est arrete pour souffler")
	_verifier(_pauses >= 2,
			"il a souffle %d fois pour son corps (le retour en demande 2)" % _pauses)
	_verifier(secondes >= 20.0,
			"le trajet complet a coute %.1f s, et le retour en exige 20"
					% secondes)

	# 7. ET JESSE MONTE AVEC NOUS.
	#
	#   « Quand on monte dans le RV pour la premiere fois, il FAUT que Jesse
	#     monte aussi. Il peut se deplacer jusqu'au RV pour eviter une
	#     teleportation trop lointaine. » — retour du 23/08/2026.
	#
	# Il restait ou la traction l'avait laisse, pendant que le dialogue du
	# demarrage le disait « assis a cote ».
	#
	# CE CONTROLE A DEMANDE UNE MESURE POUR TROUVER SA FORME.
	#
	# Il exigeait d'abord que Jesse PARCOURE au moins un metre avant de
	# disparaitre — la moitie « il se deplace » de la phrase. Il est sorti
	# rouge sur « 0,0 m parcourus », et le chiffre d'a cote disait pourquoi :
	# Jesse etait a SOIXANTE CENTIMETRES de la portiere quand l'etape commence.
	#
	# C'est la traction qui l'y a amene. « Jesse part devant et tracte son
	# cadavre lui-meme » : quand vient le demarrage, il a deja fait le trajet a
	# pied, un corps au bout des bras. La distance que le retour redoutait
	# n'existe pas a ce moment-la du deroule.
	#
	# CE QU'IL FAUT DONC MESURER N'EST PAS LE CHEMIN, C'EST L'ARRIVEE : au
	# moment ou il s'efface, il est A LA PORTIERE. Un code qui le ferait
	# disparaitre de loin serait la teleportation que le retour refuse, et ce
	# seuil l'attrape — alors qu'un seuil sur la distance parcourue serait rouge
	# pour la bonne raison un jour, et rouge sans raison tous les autres.
	print("")
	print("--- Jesse monte dans le camping-car ---")
	var jesse := _trouver(root, "JesseCrash") as Node3D
	if jesse == null:
		_verifier(false, "Jesse est introuvable dans le fosse")
	else:
		_verifier(jesse.visible, "il est encore dehors avant l'etape")

		mission.call("aller_a", _rang(mission, "demarrer"))
		await process_frame
		await process_frame

		var tours_jesse := 0
		var ou_il_disparait := jesse.global_position
		while jesse.visible and tours_jesse < 60 * 30:
			ou_il_disparait = jesse.global_position
			await process_frame
			tours_jesse += 1
		var ecart_portiere := ou_il_disparait.distance_to(porte.global_position)
		_verifier(not jesse.visible,
				"il est monte (%.1f s)" % (float(tours_jesse) * PAS))
		_verifier(ecart_portiere <= 3.0,
				"et il s'efface A la portiere, pas de loin (%.1f m)" % ecart_portiere)

	print("")
	if _erreurs > 0:
		printerr("TEST TRACTION ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST TRACTION OK")
	quit(0)


var _repos_vu := false
var _deposes := false
var _pauses := 0


func _sur_charges() -> void:
	_deposes = true


func _sur_souffle(_reste: int) -> void:
	_pauses += 1


# Un pas vers la cible, sans jamais la depasser. C'est ce que fait le joueur qui
# tient une direction : il avance de `pas` metres, et il s'arrete en arrivant.
func _vers(depuis: Vector3, cible: Vector3, pas: float) -> Vector3:
	var d := cible - depuis
	d.y = 0.0
	if d.length() <= pas:
		return Vector3(cible.x, depuis.y, cible.z)
	return depuis + d.normalized() * pas


func _un_corps(t: Traction) -> Node3D:
	for chemin in t.corps:
		var c := t.get_node_or_null(chemin) as Node3D
		if c != null and c.visible:
			return c
	return null


func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


# Le rang d'une etape par sa CLE, jamais par un numero : une etape inseree au
# milieu decalerait tous les numeros, et le test irait mesurer autre chose sans
# rien dire. Le lot E vient justement d'en inserer deux.
func _rang(mission: Mission, cle: String) -> int:
	var etapes: Array = mission.etapes()
	for i in etapes.size():
		if str((etapes[i] as Dictionary).get("cle", "")) == cle:
			return i
	printerr("  ECHEC aucune etape '%s' dans la mission" % cle)
	_erreurs += 1
	return 0


func _verifier(ok: bool, quoi: String) -> void:
	if ok:
		print("  ok   " + quoi)
	else:
		_erreurs += 1
		printerr("  ECHEC " + quoi)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
