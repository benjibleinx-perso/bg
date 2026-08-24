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
	"DepartCrash": "la portiere laterale : on s'y reveille",
	# LE COTE CONDUCTEUR EST UN ENDROIT OBLIGE, ET IL MANQUAIT ICI.
	#
	# Le jeu ne force aucune porte : l'invite « Monter » apparait des qu'on est
	# assez pres du CENTRE du vehicule, donc on monte par le cote d'ou l'on
	# vient. Quand on revient des deux corps, ce cote est celui-la.
	#
	# Un foyer s'y tenait a quatre-vingts centimetres de la tole. Walter mourait
	# en longeant la caisse pour aller demarrer, la partie recommencait, et la
	# mesure autour de la portiere laterale — a l'oppose — etait verte a quatre
	# metres.
	"SortieConducteur": "l'autre cote de la caisse, par ou l'on revient",
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

## LES TRAJETS QU'ON FAIT SANS POUVOIR S'ECARTER, et qu'aucun foyer ne doit
## croiser. Deux bouts par ligne.
##
## Celui des corps est le seul aujourd'hui, et c'est le pire qui soit : on le
## parcourt a 0,55 m/s, en marche arriere, sans pouvoir courir, et on ne peut
## pas lacher sans reposer le cadavre.
const TRAJETS := [
	["CorpsALArriere", "DepartCrash"],
]

## Combien de sable libre on exige DE PART ET D'AUTRE d'un tel trajet.
##
## Moins que le degagement autour d'un point : on suit une ligne, on ne tourne
## pas autour. Mais assez pour qu'un ecart de trajectoire ne coute pas la
## partie — un metre et demi, c'est trois fois la largeur de Walter.
const LARGEUR_DU_COULOIR := 1.5

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

	# 3 BIS. ET LE CHEMIN ENTRE DEUX, PAS SEULEMENT LES DEUX BOUTS.
	#
	# CE CONTROLE MANQUAIT, ET SON ABSENCE A COUTE UNE PARTIE QUI RECOMMENCAIT
	# TOUTE SEULE. Les mesures ci-dessus regardent le degagement AUTOUR de
	# chaque endroit important — et elles etaient toutes vertes pendant qu'un
	# foyer se tenait a trente-six centimetres de la ligne droite qui relie les
	# corps a la portiere.
	#
	# Walter la parcourt a 0,55 m/s en trainant un cadavre : il traversait trois
	# metres de feu en cinq secondes, soit quatre-vingt-quatorze points de degats
	# sur cent. Il mourait, la partie repartait au debut, et la seule trace etait
	# une suite « parcours » qui rejouait les memes etapes sans le dire.
	#
	# UN DEGAGEMENT AUTOUR DE DEUX POINTS NE DIT RIEN DE CE QU'IL Y A ENTRE EUX.
	# C'est evident ecrit comme ca, et ca ne l'etait pas au moment de poser les
	# foyers — d'autant que le commentaire de la scene interdisait deja ce foyer
	# a cet endroit.
	print("")
	print("--- et les chemins qu'on emprunte en portant quelque chose ---")
	for trajet in TRAJETS:
		var depuis := _trouver(root, str(trajet[0])) as Node3D
		var vers := _trouver(root, str(trajet[1])) as Node3D
		if depuis == null or vers == null:
			_echec("le trajet « %s → %s » : un bout manque" % [trajet[0], trajet[1]])
			continue
		var pire := INF
		var coupable := ""
		for f in foyers:
			var d := _distance_au_segment(f.global_position,
					depuis.global_position, vers.global_position) - f.rayon
			if d < pire:
				pire = d
				coupable = str(f.get_parent().name)
		if pire < LARGEUR_DU_COULOIR:
			# ON IMPRIME LES TROIS POSITIONS, pas seulement l'ecart.
			#
			# Un « il passe a 0,4 m » dit qu'il faut bouger le foyer et ne dit
			# pas DE QUEL COTE — et les positions du fichier de scene ne
			# suffisent pas a le deviner : elles sont relatives au fond du
			# fosse, la portiere suit le camping-car, et « pose_au_sol » deplace
			# tout le monde a la verticale. Deux calculs de tete se sont deja
			# trompes ici.
			# LES TROIS POSITIONS VONT DANS LE MESSAGE, pas dans un print a
			# cote. Un `print` place juste apres un `printerr` n'est pas ressorti
			# du tout ici — les deux flux ont leur propre tampon et celui de la
			# sortie standard n'etait pas vide au moment du quit(). Le
			# diagnostic le plus utile de la soiree a ainsi disparu deux fois
			# avant qu'on remarque son absence. Voir le piege 62.
			var f := _foyer_nomme(foyers, coupable)
			_echec("le trajet « %s → %s » passe a %.1f m du bord de %s :"
					% [trajet[0], trajet[1], pire, coupable]
					+ " on le fait en tirant un corps, sans pouvoir courir."
					+ " Depuis %s vers %s ; %s est en %s, rayon %.1f"
							% [_plat(depuis.global_position),
								_plat(vers.global_position), coupable,
								_plat(f.global_position) if f != null else "?",
								f.rayon if f != null else -1.0])
		else:
			print("  ok   %-14s -> %-14s %.1f m de marge (le plus proche : %s)"
					% [trajet[0], trajet[1], pire, coupable])

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
func _foyer_nomme(foyers: Array[Feu], nom: String) -> Feu:
	for f in foyers:
		if str(f.get_parent().name) == nom:
			return f
	return null


# Une position lisible, a plat : la hauteur n'entre dans aucun de ces calculs et
# la lire ferait chercher un probleme de relief qui n'existe pas.
func _plat(v: Vector3) -> String:
	return "(%.1f, %.1f)" % [v.x, v.z]


func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


# La distance d'un point au SEGMENT [a, b], a plat.
#
# Au segment et non a la droite qui le porte : un foyer place bien au-dela de la
# portiere, dans le prolongement du trajet, n'est pas sur le chemin — et une
# distance a la droite infinie le denoncerait a tort.
func _distance_au_segment(p: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := b - a
	var ap := p - a
	ab.y = 0.0
	ap.y = 0.0
	var l2 := ab.length_squared()
	if l2 < 0.0001:
		return ap.length()
	var t := clampf(ap.dot(ab) / l2, 0.0, 1.0)
	return (ap - ab * t).length()


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
