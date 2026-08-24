# LES FLAMMES DU FOSSE : est-ce qu'elles genent, ou est-ce qu'elles bloquent ?
#
#     godot --headless --path game --script res://verifs/test_feu.gd
#
# CE QUE CA GARDE. Le retour du 23/08/2026 demande des flammes qui font DEUX
# choses : blesser, et compliquer le ramassage. Le mot exact est « en essayant
# de ne pas marcher dans les flammes » — donc gener, pas empecher.
#
# La difference entre les deux ne se voit pas en jouant une fois : on contourne
# sans y penser, et un foyer pose trois centimetres trop pres d'un objet ne se
# decouvre que le jour ou quelqu'un se demande pourquoi il perd de la vie a
# chaque ramassage. C'est mesurable, donc c'est mesure ici.
#
# LES CINQ FAITS :
#
#   1. les foyers existent et brulent ;
#   2. aucun ne couvre un objet a ramasser — sinon le prendre coute de la vie
#      sans qu'on ait rien fait de travers ;
#   3. aucun ne couvre les trois endroits obliges : la ou l'on se reveille, la
#      ou l'on remonte, et la ou Jesse se tient ;
#   4. dedans, on brule ;
#   5. ET ON NE PEUT PAS L'ETEINDRE. C'est le seul point du lot qui soit une
#      regle plutot qu'un reglage, et c'est celui qu'une refonte du point
#      d'interaction casserait sans bruit.
extends SceneTree

## Ce qui doit rester atteignable sans se bruler, et ce que chacun est.
##
## LES NOMS SONT CEUX DES NOEUDS DE crash.tscn. Un nom qui disparait fait
## echouer ce test, et c'est voulu : un objet renomme dont plus personne ne
## verifie l'acces est exactement ce qui se perd entre deux versions.
const A_PORTEE := {
	"SacMateriel": "un objet a ramasser",
	"BidonRenverse": "un objet a ramasser",
	"VerrerieCassee": "un objet a ramasser",
	"Pantalon": "l'objet facultatif",
	"DepartCrash": "la portiere : on s'y reveille, et on y remonte",
	"JesseCrash": "la ou Jesse se tient",
	"CorpsALArriere": "les deux corps",
}

## CE QU'ON NE MESURE PAS, ET POURQUOI.
##
## « PosteConduite » a figure dans la liste ci-dessus pendant une demi-heure, et
## il y a fait echouer un foyer parfaitement bien pose : c'est un point
## « au_volant », donc il ne s'atteint jamais a pied et sa portee ne s'applique
## pas. Il est en plus DANS l'habitacle, a un metre soixante du flanc — exiger
## deux metres quarante de sable autour de lui revenait a interdire tout foyer
## le long de la caisse, c'est-a-dire l'endroit meme ou un vehicule brule.
##
## Ce qui compte pour remonter, c'est la PORTIERE, et elle est deja dans la
## liste sous le nom de l'endroit ou Walter se reveille contre elle.
const _NON_MESURE := ["PosteConduite"]

## Combien de sable libre on exige AUTOUR de chacun, en metres.
##
## Ce n'est pas « le foyer ne touche pas l'objet » : il faut aussi la place de
## s'en approcher et d'appuyer. La portee d'un ramassage est de 2,2 m, donc un
## foyer qui mord dedans oblige a bruler pour tendre le bras.
const DEGAGEMENT := 2.4

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var joueur := _trouver(root, "Joueur") as Node3D
	var mission := _trouver(root, "Mission") as Mission
	if joueur == null or mission == null:
		printerr("ECHEC monde incomplet (Joueur, Mission)")
		quit(1)
		return

	# LE DECOR DU FOSSE EST INSTANCIE A L'EXECUTION par desert.gd : le groupe
	# est vide a la premiere image, et un test qui conclurait ici annoncerait
	# « aucun foyer » sur un jeu qui en a cinq. On laisse la scene se poser.
	for _i in 10:
		await process_frame

	var foyers: Array[Feu] = []
	for n in root.get_tree().get_nodes_in_group(Feu.GROUPE):
		var f := n as Feu
		if f != null:
			foyers.append(f)

	print("")
	print("--- les foyers du fosse ---")
	if foyers.is_empty():
		printerr("  ECHEC aucun foyer dans la scene")
		quit(1)
		return
	print("  ok   %d foyer(s)" % foyers.size())

	# 2 ET 3. CE QUI DOIT RESTER ACCESSIBLE.
	#
	# On imprime la distance de CHAQUE couple, et pas seulement le verdict : un
	# diagnostic chiffre inspire une confiance qu'un « ok » n'obtient jamais, et
	# c'est le nombre qui dira de combien deplacer un foyer le jour ou l'un
	# d'eux se rapproche.
	print("")
	print("--- ce qu'on doit pouvoir atteindre sans bruler ---")
	for nom in A_PORTEE:
		var cible := _trouver(root, str(nom)) as Node3D
		if cible == null:
			_echec("« %s » introuvable dans la scene" % nom)
			continue
		var pire := INF
		var coupable := ""
		for f in foyers:
			var d := _a_plat(cible.global_position, f.global_position) - f.rayon
			if d < pire:
				pire = d
				coupable = str(f.get_parent().name)
		if pire < DEGAGEMENT:
			_echec("%s (%s) est a %.1f m du bord de %s : moins que les %.1f m"
					% [nom, A_PORTEE[nom], pire, coupable, DEGAGEMENT]
					+ " qu'il faut pour s'en approcher")
		else:
			print("  ok   %-16s %.1f m de sable libre (le plus proche : %s)"
					% [nom, pire, coupable])

	# 4. DEDANS, ON BRULE.
	print("")
	print("--- le feu blesse ---")
	var foyer := foyers[0]
	var avant := float(joueur.get("pv"))
	joueur.global_position = foyer.global_position
	for _i in 30:
		await process_frame
	var apres := float(joueur.get("pv"))
	if apres >= avant:
		_echec("une demi-seconde dans les flammes ne coute rien"
				+ " (%.0f pv avant, %.0f apres)" % [avant, apres])
	else:
		print("  ok   une demi-seconde coute %.0f pv (%.0f -> %.0f)"
				% [avant - apres, avant, apres])

	# ET DEHORS, ON NE BRULE PLUS. Sans ce controle, un foyer dont la zone
	# couvrirait tout le fosse passerait le precedent haut la main.
	joueur.global_position = foyer.global_position + Vector3(0.0, 0.0, 40.0)
	for _i in 5:
		await process_frame
	var repos := float(joueur.get("pv"))
	for _i in 30:
		await process_frame
	if float(joueur.get("pv")) < repos:
		_echec("on brule encore a quarante metres du foyer")
	else:
		print("  ok   a quarante metres, plus rien")

	# 5. ON NE L'ETEINT PAS.
	#
	# « Le jeu ne dira jamais au joueur qu'il est impossible d'eteindre les
	# flammes. » On verifie donc les deux moities de la promesse : le geste se
	# PROPOSE, et il ne fait rien au feu.
	print("")
	print("--- et on ne l'eteint pas ---")
	var eteindre := _point_d_extinction(foyer)
	if eteindre == null:
		_echec("aucun point « Eteindre » sur un foyer")
	else:
		print("  ok   le geste se propose (« %s »)" % eteindre.invite)
		# UN POINT QUI SE CONSOMME AURAIT L'AIR D'AVOIR MARCHE. C'est le piege
		# exact de ce lot : « une fois » est le defaut de point.gd, et un joueur
		# dont l'invite disparait apres un appui en conclut qu'il a reussi.
		if eteindre.une_fois:
			_echec("le geste se consomme apres un essai : le joueur en"
					+ " conclura qu'il a eteint quelque chose")
		else:
			print("  ok   on peut le retenter autant qu'on veut")
		for _i in 3:
			eteindre.declencher()
			await process_frame
		if not _brule_encore(foyer):
			_echec("le foyer s'est eteint : trois essais l'ont eu")
		else:
			print("  ok   trois essais plus tard, il brule pareil")

	print("")
	if _erreurs > 0:
		printerr("TEST FEU ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST FEU OK")
	quit(0)


# Le foyer brule-t-il toujours ? On regarde ce qui FAIT le feu — ses particules
# et sa zone — et pas un booleen qu'on aurait pose soi-meme : un drapeau
# « allume » repondrait oui a une question qu'on ne lui a pas posee.
func _brule_encore(f: Feu) -> bool:
	var p := f.get_node_or_null("Flammes") as GPUParticles3D
	if p == null or not p.emitting:
		return false
	return f.contient(f.global_position)


func _point_d_extinction(f: Feu) -> Point:
	for e in f.get_children():
		var p := e as Point
		if p != null and p.evenement == "action:eteindre":
			return p
	return null


# LA DISTANCE SE MESURE A PLAT, comme dans feu.gd.
#
# Un foyer est une colonne : sa hauteur ne doit pas entrer dans le calcul. Et
# le fosse creuse deux metres trente, donc un objet pose au fond et un foyer
# pose sur la pente ne sont PAS a la meme altitude — mesurer en trois
# dimensions rendrait des distances plus grandes que celles qu'on marche, et le
# test serait vert sur un feu qu'on traverse.
func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


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
