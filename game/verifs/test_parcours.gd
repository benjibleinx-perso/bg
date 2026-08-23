# La mission se joue-t-elle vraiment, du debut a la fin, SANS RIEN TRICHER ?
#
#     godot --headless --path game --script res://verifs/test_parcours.gd
#
# CE QUI A RENDU CE FICHIER NECESSAIRE. Le 16/08/2026, vingt-deux defauts ont
# ete corriges sur la mission 1. Dix-neuf ont ete trouves EN JOUANT, zero par une
# suite — et les trente-deux suites etaient vertes a chaque fois.
#
# Elles ne mentaient pas : elles mesurent qu'une chose EXISTE. Que le point
# existe, que l'evenement existe, que la conversation existe, que le niveau de
# sirene monte. Aucune ne mesure qu'on peut y ARRIVER, et c'est presque toujours
# la question :
#
#   « je vois les trois objets, deux sur trois ne repondent pas a F »
#   « je ne peux pas monter dans le camping-car, on ne me propose rien »
#   « y'a ecrit sortir par le chemin mais le point est meme pas sur le chemin »
#
# Les trois etaient au vert. Les trois bloquaient une partie.
#
# CE QUE CE TEST S'INTERDIT, et c'est tout son interet. Le piege 19 : « une
# verification qui se place elle-meme au bon endroit valide toujours ». Un test
# teleportait la voiture sur la sortie du desert avant de verifier qu'on pouvait
# repartir ; la sortie etait introuvable depuis une semaine, et il etait vert.
#
# Donc, ici :
#
#   - AUCUNE teleportation. Le joueur marche, le vehicule roule.
#   - AUCUN appel a Mission.aller_a. On franchit les etapes en les jouant.
#   - AUCUN declenchement direct d'un Point ou d'un Dialogue. On appuie sur E.
#
# CE QUI EST AUTORISE, et pourquoi : poser le CAP. Orienter le joueur vers sa
# cible est ce qu'un humain fait d'un geste de souris, en un dixieme de seconde,
# et ce n'est pas ce qu'on mesure. Poser sa POSITION serait exactement le piege
# 19. La frontiere est nette : on choisit ou REGARDER, jamais ou ETRE.
#
# ------------------------------------------------------------------------------
# ETAT AU 17/08/2026 : CETTE SUITE EST ROUGE, ET ON LA LAISSE ROUGE.
#
# Elle joue les dix premieres etapes — le masque, les corps, la panique de Jesse,
# les trois preuves, le pantalon, le retour a la portiere, le demarrage assis au
# volant — puis bute sur « moteur_lance » : assise au volant, a 5,2 m du point,
# soixante appuis sans rien franchir.
#
# JE N'AI PAS TRANCHE si c'est le jeu ou le pilote. En jeu, un humain franchit
# cette etape ; en tete, tous les criteres de point.gd sont remplis. Il manque
# une mesure, pas une hypothese — et il est deux heures du matin.
#
# ON NE LA MET PAS AU VERT POUR AUTANT. Un test qu'on neutralise pour qu'il se
# taise est un test qu'on ne relira jamais, et le projet en a deja paye le prix
# autrement : « une absence ne prouve rien tant que la recherche n'est pas
# complete ». Elle reste rouge, elle dit ou, et elle dit ce qu'elle voyait.
#
# CE QU'ELLE A DEJA RAPPORTE, avant meme d'aller au bout : « PorteCampingCar »
# existait dans trois scenes, et le marqueur du battement A6 designait celui de
# la mission de rodage, a neuf cents metres du fosse. Corrige le jour meme.
# ------------------------------------------------------------------------------
extends SceneTree

## Images accordees a une etape avant de la declarer bloquee. A soixante images
## par seconde, quarante secondes — largement de quoi traverser le fosse a pied
## et remonter la piste au volant.
const BUDGET := 2400

## En dessous de cette distance, on arrete d'avancer et on appuie. C'est la
## portee des points les plus courts (2,2 m) avec de la marge.
const ARRIVE := 1.6

## Ce qu'on considere comme « il ne se passe plus rien ». Si la distance a la
## cible ne baisse pas de dix centimetres en trois secondes, on est contre un
## mur, dans un trou, ou la cible est inatteignable.
const IMMOBILE := 180
const PROGRES := 0.1

## COMMENT ON CONTOURNE, et pourquoi ce n'est pas un detail.
##
## Sans contournement, le pilote fonce droit dans la tole du camping-car et
## declare la portiere « inatteignable a pied » — ce qui est faux : un joueur
## contourne sans y penser. Un test qui crie a tort cesse d'etre lu, et c'est
## pire qu'un test absent.
##
## On longe a quatre-vingts degres — presque perpendiculaire, donc on suit le
## mur au lieu d'y revenir — et on longe TANT QUE ca ne rapproche pas, sans
## duree fixe. Une duree fixe ramenait droit dans l'obstacle a chaque fois.
##
## On alterne les cotes : rien ne dit lequel est le bon. Six echecs de suite,
## alors seulement, valent un echec de parcours.
const DEVIATION := deg_to_rad(80.0)
const LONGER_MAX := 240
const ESSAIS_CONTOURNEMENT := 6

var _monde: Node
var _mission: Mission
var _controleur: Node

## La camera de poursuite. On la pilote comme un joueur pilote sa souris :
## depuis que les touches sont relatives a la vue, poser le cap du personnage
## ne le fait plus avancer dans cette direction — c'est la camera qui dit ou
## est « devant ».
var _camera: Node
var _joueur: Node3D
var _rates := 0
var _journal: Array[String] = []


func _initialize() -> void:
	# UNE PARTIE NEUVE, ET C'EST LA PREMIERE CHOSE A FAIRE.
	#
	# Sans cette ligne, le monde reprend la sauvegarde de la machine — donc,
	# sur la mienne, une mission DEJA TERMINEE. Le test s'est declare vert au
	# premier essai avec « 0 etape(s) jouees ». Il n'avait rien joue du tout.
	#
	# C'est exactement le piege que ce fichier existe pour attraper, et il l'a
	# tendu a son auteur avant d'attraper quoi que ce soit d'autre. Un test qui
	# depend de l'etat de la machine ne mesure pas le jeu, il mesure la machine.
	if FileAccess.file_exists("user://partie.json"):
		DirAccess.remove_absolute("user://partie.json")

	_monde = (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(_monde)
	await process_frame
	await process_frame

	_mission = Mission.courante(_monde)
	_controleur = _monde.find_child("Controleur", true, false)
	_camera = _monde.find_child("Camera3D", true, false)
	if _mission == null or _controleur == null:
		print("ECHEC monde incomplet : Mission ou Controleur introuvable")
		quit(1)
		return

	# Et on verifie qu'on a bien quelque chose a jouer, plutot que de conclure
	# « OK » sur une boucle qui ne tourne pas.
	if _mission.finie() or _mission.etapes().is_empty():
		printerr("ECHEC la mission est deja finie au chargement : rien a jouer")
		quit(1)
		return

	print("")
	print("--- on joue « %s » du debut a la fin ---" % _mission.titre())
	print("")

	_verifier_les_lieux()

	# ON S'ARRETE AU PREMIER BLOCAGE, ET C'EST UNE DECISION.
	#
	# Premiere version : on forcait l'etape suivante et on continuait. Resultat,
	# un rapport de treize echecs dont neuf etaient la meme cause — le joueur
	# restait au volant du camping-car pendant que la mission sautait a la
	# cuisine, donc « a 2 059 m de PaillasseCuisine » neuf fois de suite.
	#
	# Neuf lignes qui disent la meme chose noient la seule qui compte. Un
	# parcours s'arrete la ou un joueur serait bloque : c'est exactement
	# l'information qu'on cherche, et le reste ne se saura qu'apres correction.
	var etapes := _mission.etapes()
	var garde := 0
	var joues := 0
	while not _mission.finie() and garde < etapes.size() + 4:
		garde += 1
		var avant := _rates
		await _jouer_une_etape()
		if _rates > avant:
			var reste := etapes.size() - _mission.index()
			if reste > 0:
				_journal.append("")
				_journal.append("  %d etape(s) suivante(s) non jouees : on ne "
						% reste + "sait pas si elles tiennent tant que "
						+ "celle-ci bloque.")
			break
		joues += 1

	print("")
	for ligne in _journal:
		print(ligne)
	print("")
	if _rates > 0:
		printerr("TEST PARCOURS ECHEC  bloque apres %d etape(s) jouee(s)" % joues)
		quit(1)
		return
	print("TEST PARCOURS OK  %d etape(s) jouees sans rien tricher" % joues)
	quit(0)


# --------------------------------------------------- avant de jouer : les noms
#
# UN NOM DE LIEU QUI EXISTE DEUX FOIS DESIGNE LE MAUVAIS.
#
# Le champ « ou » d'une etape pose le marqueur de la minimap. Il se resout par
# find_child, qui rend le PREMIER noeud portant ce nom dans l'arbre — et l'arbre
# contient toutes les scenes du jeu en meme temps.
#
# « PorteCampingCar » existait trois fois le 17/08 : dans la clairiere de la
# sequence B, dans la mission de rodage a neuf cents metres, et l'etape A6 le
# demandait. Le marqueur envoyait donc traverser le desert en pleine montee de
# sirene. Rien n'etait bloque, et c'est ce qui rendait le defaut invisible : le
# declencheur reel etait ailleurs, a quatre metres, et on y retourne d'instinct.
#
# C'est le piege 39 sous un autre jour — un nom qui ne dit pas de quelle mission
# il vient. La verification tient en dix lignes et elle vaut pour toutes les
# missions a venir.


func _verifier_les_lieux() -> void:
	for e in _mission.etapes():
		var etape: Dictionary = e
		var ou := str(etape.get("ou", ""))
		if ou.is_empty():
			continue
		var vus := 0
		_compter(_monde, ou, func(): vus += 1)
		if vus > 1:
			_rates += 1
			var m := "  ECHEC %-16s le lieu « %s » existe %d fois dans le jeu"
			_journal.append(m % [str(etape.get("cle", "")), ou, vus])
			_journal.append("        le marqueur en designe UN, et jamais celui "
					+ "qu'on croit")
			printerr("  ECHEC lieu ambigu : « %s » existe %d fois" % [ou, vus])


func _compter(noeud: Node, nom: String, vu: Callable) -> void:
	if noeud.name == nom:
		vu.call()
	for enfant in noeud.get_children():
		_compter(enfant, nom, vu)


# ------------------------------------------------------------------ une etape


func _jouer_une_etape() -> void:
	var depart := _mission.index()
	var cle := _mission.cle_etape()
	var objectif := _mission.objectif()
	var cible := _cible()

	# UNE ETAPE SANS « ou » N'A PAS DE LIEU, ET C'EST LEGITIME : la derniere de
	# la mission n'en a pas, elle ne se termine jamais seule. On la compte comme
	# jouee et on sort — il n'y a rien a atteindre.
	if _mission.ou().is_empty():
		_journal.append("  ok   %-18s %s  (aucun lieu, fin de mission)"
				% [cle, objectif])
		return

	# EN REVANCHE, un « ou » qui designe un noeud absent est un vrai defaut :
	# le joueur voit un objectif et un marqueur qui ne pointe nulle part.
	if cible == null:
		_echouer(cle, objectif, "le lieu « %s » n'existe dans aucune scene"
				% _mission.ou())
		return

	# UN POSTE DE CONDUITE NE S'ATTEINT PAS A PIED.
	#
	# Le battement A7 s'appelle « poste de conduite » : le geste de demarrage se
	# fait ASSIS AU VOLANT, et point.gd le marque « au_volant ». Marcher jusqu'au
	# point ne propose donc rien, quelle que soit la distance — le pilote
	# tournait autour du camping-car pendant quarante secondes.
	#
	# On monte d'abord. C'est un detour, pas une triche : c'est exactement ce
	# que le joueur fait, et c'est meme le geste qui a bloque Benjamin le 16/08.
	if _demande_le_volant(cible) and not _au_volant():
		await _monter_dans_le_vehicule(cible)

	var images := 0
	var derniere := INF
	var stagne := 0
	var geste := 0
	var contournements := 0
	var longe := 0
	var cote := 1.0
	var d_bute := INF
	# ON S'APPROCHE AU PLUS PRES, TOUJOURS, et la portee ne sert que de filet.
	#
	# Version precedente : on s'arretait des qu'on entrait dans la portee
	# declaree du point. Ca semblait plus fidele et c'etait pire — a 2,4 m d'un
	# point qui porte a 3,0, le geste ne se proposait deja plus, et une etape
	# qui passait s'est mise a echouer. La portee declaree et la portee reelle
	# ne coincident pas, et c'est la seconde qui compte.
	#
	# Donc : on va au contact. La portee ne sert qu'a decider si l'on tente
	# d'appuyer quand meme, quand on est bloque par un obstacle en etant deja
	# assez pres — voir plus bas.
	var portee := _portee_de(cible)

	while _mission.index() == depart and images < BUDGET:
		images += 1
		var j := _sujet()
		var d := j.global_position.distance_to(cible.global_position)

		# Une conversation prend la main : c'est elle qui avance, et F suffit.
		#
		# ELLE NE COMPTE PAS DANS LE BUDGET DE GESTES. Premiere version : elle y
		# comptait, et le test accusait « CorpsALArriere » de ne pas repondre a
		# F alors que le point s'etait ouvert du premier coup et qu'on etait en
		# train de derouler ses trois repliques. Un compteur nomme UNE cause —
		# celui-la en agregeait deux, et il tranchait dans le mauvais sens.
		if _en_dialogue():
			await _appuyer()
			continue

		# ASSIS AU VOLANT, LE GESTE EST SUR SOI — on n'a plus a s'en approcher.
		#
		# Le poste de conduite est un point pose DANS le camping-car, a 3,3 m de
		# son origine. Le pilote mesurait cette distance depuis le vehicule et
		# essayait de la reduire en roulant : il promenait le camping-car dans
		# le desert en emportant le siege avec lui, sans jamais appuyer une fois.
		if _demande_le_volant(cible) and _au_volant():
			await _appuyer()
			geste += 1
			if geste > 60:
				var v := _sujet()
				var dv := v.global_position.distance_to(cible.global_position)
				_echouer(cle, objectif,
						"assis au volant, 60 appuis sans rien franchir. "
						+ "Le point est a %.1f m du vehicule " % dv
						+ "(le controleur ne propose au volant que ce qui est "
						+ "a moins de 12 m). Le jeu propose : %s" % _propose())
				return
			continue

		if d > ARRIVE:
			# On longe TANT QUE ca n'a pas rapproche de l'endroit ou l'on a
			# bute. Un joueur fait exactement ca : il glisse le long de la tole
			# jusqu'a ce que la portiere se rapproche, puis il repart droit.
			var biais := 0.0
			if longe > 0:
				longe -= 1
				biais = cote * DEVIATION
				# On ne repart droit que quand on a VRAIMENT gagne du terrain.
				# A 0,8 m de gain, le pilote revenait dans la tole avant
				# d'avoir depasse le camping-car, qui fait neuf metres de long.
				if d < d_bute - 3.0:
					longe = 0
					derniere = d
				# ET ON NE COMPTE PAS LA STAGNATION PENDANT QU'ON LONGE.
				#
				# C'etait le vrai defaut de cette boucle : longer eloigne de la
				# cible pendant les premieres secondes, donc la stagnation se
				# redeclenchait aussitot, donc on changeait de cote, donc on
				# oscillait sur place contre la meme tole — six fois de suite.
				# Le pilote se declarait bloque par le decor alors qu'il etait
				# bloque par lui-meme.
				_aller_vers(cible, j, biais)
				await process_frame
				continue
			_aller_vers(cible, j, biais)

			# Le progres se mesure sur la DISTANCE, pas sur le fait d'appuyer :
			# un joueur coince contre une tole appuie sur gaz tout autant.
			if d < derniere - PROGRES:
				derniere = d
				stagne = 0
			else:
				stagne += 1
				# BLOQUE MAIS DEJA A PORTEE : on tente le geste avant de
				# conclure. Un objet coince derriere une tole se ramasse quand
				# meme si le point porte assez loin, et un joueur essaie.
				if stagne > IMMOBILE and d <= portee:
					_lacher()
					await _appuyer()
					geste += 1
					stagne = 0
					continue
				if stagne > IMMOBILE:
					if contournements < ESSAIS_CONTOURNEMENT:
						contournements += 1
						cote = -cote
						longe = LONGER_MAX
						d_bute = d
						stagne = 0
						derniere = INF
						await process_frame
						continue
					var pj := j.global_position
					var pc := cible.global_position
					_echouer(cle, objectif,
							"immobile a %.1f m de « %s » apres %d contournement(s). "
							% [d, _mission.ou(), contournements]
							+ "Joueur (%.1f %.1f %.1f), cible (%.1f %.1f %.1f), "
							% [pj.x, pj.y, pj.z, pc.x, pc.y, pc.z]
							+ "denivele %.1f m. Le jeu propose : %s"
							% [pc.y - pj.y, _propose()])
					return
			await process_frame
			continue

		# ARRIVE. On relache tout et on appuie, comme un joueur qui s'arrete.
		_lacher()
		await _appuyer()
		geste += 1

		# Des appuis sans rien franchir : le geste n'est pas propose. C'est le
		# defaut le plus frequent et le moins visible — l'objet est la, on est
		# dessus, et F ne fait rien parce que l'etape n'est pas la bonne ou que
		# la geometrie est ailleurs que le point.
		#
		# ON RAPPORTE CE QUE LE JEU PROPOSE, et c'est toute la valeur du
		# message : « F Monter » dit que le camping-car a vole la touche,
		# « F Ramasser le bidon » dit qu'on est sur le mauvais objet, et un
		# bandeau VIDE dit que rien n'est a portee — trois causes, trois
		# corrections differentes.
		if geste > 60:
			_echouer(cle, objectif,
					"arrive a %.1f m de « %s », 60 appuis sans rien franchir. "
					% [d, _mission.ou()]
					+ "Le jeu propose : %s" % _propose())
			return

	if _mission.index() == depart:
		var j2 := _sujet()
		var d2 := j2.global_position.distance_to(cible.global_position)
		_echouer(cle, objectif,
				"rien en %d images. A %.1f m de « %s », %s, %d appui(s). "
				% [BUDGET, d2, _mission.ou(),
					"au volant" if _au_volant() else "a pied", geste]
				+ "Le jeu propose : %s" % _propose())
		return

	_journal.append("  ok   %-18s %s" % [cle, objectif])


# ------------------------------------------------------- se deplacer, en jouant


## Qui bouge : le joueur, ou le vehicule quand il est au volant. Le controleur
## le sait deja — c'est lui qui decide ce que la minimap suit.
func _sujet() -> Node3D:
	if _controleur.has_method("sujet"):
		var s: Node3D = _controleur.call("sujet")
		if s != null:
			return s
	return _joueur_courant()


func _joueur_courant() -> Node3D:
	if _joueur == null:
		_joueur = _monde.find_child("Joueur", true, false) as Node3D
	return _joueur


## ON LE DEMANDE AU CONTROLEUR, on ne le deduit pas.
##
## Premiere version : « le sujet de la minimap n'est pas le joueur, donc on
## conduit ». C'est faux — sujet() suit le vehicule des qu'il devient le sujet
## interessant, pas seulement quand on est assis dedans. Le pilote se croyait
## donc au volant en etant plante a cinq metres du camping-car : il appuyait
## sur E sans bouger, le jeu n'avait rien a lui proposer, et l'echec accusait
## le poste de conduite de ne pas repondre.
##
## Deux sources de verite finissent toujours par diverger — c'est ce que dit
## appel.gd, qui interroge la meme methode pour la meme raison.
func _au_volant() -> bool:
	if _controleur.has_method("au_volant"):
		return bool(_controleur.call("au_volant"))
	return _sujet() != _joueur_courant()


# ON POSE LE CAP DE LA VUE, ON N'AVANCE PAS A LA PLACE DU JOUEUR.
#
# A pied : on tourne la CAMERA, instantanement, comme un geste de souris. Le
# personnage s'oriente tout seul en marchant, exactement comme sous les mains
# de quelqu'un. Poser sa rotation a lui ne servirait plus a rien depuis que
# les touches sont relatives a la vue : il repartirait vers la camera.
#
# AU VOLANT, C'EST DIFFERENT ET C'EST VOLONTAIRE : on ne pose pas le cap d'un
# vehicule, on BRAQUE. Onze tonnes qui pivotent sur place masqueraient
# exactement ce qu'on cherche a savoir — est-ce que le camping-car remonte sa
# cuvette a 24 %, ou est-ce qu'il patine.
func _aller_vers(cible: Node3D, j: Node3D, biais: float = 0.0) -> void:
	var vers := cible.global_position - j.global_position
	vers.y = 0.0
	if vers.length() < 0.01:
		return
	var voulu := atan2(-vers.x, -vers.z) + biais

	if not _au_volant():
		if _camera != null and _camera.has_method("poser_le_cap"):
			_camera.call("poser_le_cap", voulu)
		else:
			j.rotation.y = voulu
		Input.action_release("gauche")
		Input.action_release("droite")
		Input.action_press("gaz")
		Input.action_press("sprint")
		return

	# Au volant : l'ecart de cap devient un braquage, et le gaz se dose.
	var ecart := wrapf(voulu - j.rotation.y, -PI, PI)
	Input.action_release("gauche")
	Input.action_release("droite")
	if ecart > 0.06:
		Input.action_press("gauche")
	elif ecart < -0.06:
		Input.action_press("droite")
	Input.action_release("sprint")
	Input.action_press("gaz")


func _lacher() -> void:
	for a in ["gaz", "frein", "gauche", "droite", "sprint"]:
		Input.action_release(a)


## Un appui sur E, avec son relachement : « just_pressed » ne se declenche que
## sur le front, et une touche laissee enfoncee ne franchit qu'une chose.
func _appuyer() -> void:
	Input.action_press("interagir")
	await process_frame
	Input.action_release("interagir")
	await process_frame
	await process_frame


## L'etape demande-t-elle d'etre assis au volant ?
func _demande_le_volant(cible: Node3D) -> bool:
	var p := cible as Point
	if p == null:
		p = cible.find_child("Point", false, false) as Point
	return p != null and p.au_volant


## Le vehicule le plus proche du point vise — pas du joueur. Le camping-car du
## fosse est a quatre metres du poste de conduite ; celui de la ville est a
## douze cents, et « le plus proche du joueur » l'a deja designe une fois.
func _vehicule_pres_de(cible: Node3D) -> Node3D:
	var meilleur: Node3D = null
	var d_min := INF
	for n in _monde.find_children("*", "VehicleBody3D", true, false):
		var v := n as Node3D
		var d := v.global_position.distance_to(cible.global_position)
		if d < d_min:
			d_min = d
			meilleur = v
	return meilleur


## On marche jusqu'a la portiere et on appuie, comme tout le monde. Si rien ne
## se propose, on n'insiste pas : c'est l'etape elle-meme qui echouera ensuite,
## avec son message et ce que le jeu affichait.
func _monter_dans_le_vehicule(cible: Node3D) -> void:
	var v := _vehicule_pres_de(cible)
	if v == null:
		return
	var images := 0
	var longe := 0
	var cote := 1.0
	var derniere := INF
	var stagne := 0
	while not _au_volant() and images < BUDGET:
		images += 1
		var j := _joueur_courant()
		var d := j.global_position.distance_to(v.global_position)
		if d > 3.2:
			var biais := 0.0
			if longe > 0:
				longe -= 1
				biais = cote * DEVIATION
			else:
				if d < derniere - PROGRES:
					derniere = d
					stagne = 0
				else:
					stagne += 1
					if stagne > IMMOBILE:
						cote = -cote
						longe = LONGER_MAX / 2
						stagne = 0
						derniere = INF
			_aller_vers(v, j, biais)
			await process_frame
			continue
		_lacher()
		await _appuyer()
	_lacher()


## A quelle distance on s'arrete pour appuyer. La portee du point que l'etape
## designe, s'il y en a un — sinon la marge par defaut. Un point porte a 2,2 m
## et parfois a 6 ; viser le noeud a 1,6 m dans les deux cas fait se cogner
## contre ce qui l'entoure pour rien.
func _portee_de(cible: Node3D) -> float:
	var p := cible as Point
	if p == null:
		p = cible.find_child("Point", false, false) as Point
	if p != null:
		return maxf(ARRIVE, p.portee - 0.4)
	return ARRIVE


## Ce que le joueur lit en bas de l'ecran a cet instant. C'est la seule chose qui
## distingue « rien n'est a portee » de « autre chose a pris la touche », et
## sans elle un echec de parcours demande une soiree pour etre compris.
##
## C'EST L'INVITE, PAS LE BANDEAU. Premiere version : bandeau(), qui rend le
## message de REFUS — vide dans l'immense majorite des cas, y compris quand tout
## va bien. Le diagnostic annoncait donc « le jeu propose : rien du tout » a
## chaque echec, quelle qu'en soit la cause, et il a fait chercher un appel
## telephonique fantome pendant vingt minutes.
##
## Un instrument se verifie avant de corriger ce qu'il denonce — piege 18, et je
## l'ai repaye.
func _propose() -> String:
	var chemin: NodePath = _controleur.get("invite")
	if chemin != null and not chemin.is_empty():
		var n := _controleur.get_node_or_null(chemin)
		if n != null and "text" in n:
			var t := str(n.get("text")).strip_edges()
			return "« %s »" % t if not t.is_empty() else "rien du tout"
	return "?"


func _en_dialogue() -> bool:
	var d := _monde.find_child("Dialogue", true, false)
	return d != null and d.has_method("actif") and d.call("actif")


## Le noeud que l'etape designe. C'est le meme champ que celui qui pose le
## marqueur de la minimap : si on ne le trouve pas ici, le joueur ne le trouve
## pas non plus.
func _cible() -> Node3D:
	var ou := _mission.ou()
	if ou.is_empty():
		return null
	return _monde.find_child(ou, true, false) as Node3D


func _echouer(cle: String, objectif: String, pourquoi: String) -> void:
	_rates += 1
	_journal.append("  ECHEC %-16s %s" % [cle, objectif])
	_journal.append("        %s" % pourquoi)
	printerr("  ECHEC etape '%s' : %s" % [cle, pourquoi])
