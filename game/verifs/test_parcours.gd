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
# ETAT AU 06/09/2026 : LA SORTIE DU FOSSE EST TOMBEE, ET LE TABLIER AVEC.
#
# « sortir_du_fosse » bloquait depuis le 17/08, et ce n'etait ni le vehicule
# ni le pilote : la zone de sortie faisait 26 m et exigeait trois secondes de
# roulage DEDANS. A 75 km/h on la traverse en 1,25 s — au-dessus de 31 km/h la
# condition etait inatteignable, quoi que fasse le joueur. Benjamin, manette en
# main, l'a dit avec d'autres mots : « je continue sur la route et ca declenche
# rien ». Le compte suit desormais le vehicule une fois entame.
#
# Derriere, « tablier » a cache trois choses d'un coup, et la trace de la
# partie les a nommees une par une : l'annonce du telephone prenait la touche
# trois secondes a chaque etape ; la « Sortie » de l'interieur de la mission de
# rodage, pose au meme endroit que la cuisine, se proposait a l'arrivee et
# renvoyait au desert ; et le pilote, remis au bord par le filet, y retournait
# droit. Le message d'echec imprime maintenant CE QUI PEUT PRENDRE LA TOUCHE —
# telephone, dialogue, geste, fondu, point vise — parce que « rien du tout »
# designait un coupable sans le nommer.
#
# Ce qui suit est l'etat d'avant, garde parce qu'il dit comment on cherchait.
# ------------------------------------------------------------------------------
# ETAT AU 23/08/2026 : ROUGE PLUS LOIN QU'AVANT, ET ON LA LAISSE ROUGE.
#
# Elle butait depuis le 17/08 sur « moteur_lance » : assise au volant, a 5,2 m
# du point, soixante appuis sans rien franchir. C'ETAIT LE JEU, pas le pilote —
# le demarrage etait un compteur d'essais cache derriere un bandeau, et il a ete
# remplace par un mini-jeu (systemes/demarreur.gd). Le pilote le JOUE
# maintenant : il lit ou est l'aiguille, ou est la zone, et presse quand elles
# se croisent. Deux etapes de plus sont tombees.
#
# ELLE BUTE MAINTENANT SUR « sortir_du_fosse » : au volant, a 28,4 m de la
# sortie, zero appui en quarante secondes. Le camping-car doit remonter la
# cuvette et rejoindre la piste — c'est le battement A8, celui que Guillaume
# veut refaire (« c'est assez confusant ici »).
#
# ET LA QUESTION EST TRANCHEE DEPUIS LE 27/08/2026 : C'EST LE PILOTE.
#
# Cette ligne disait « on ne sait pas encore si c'est le vehicule qui patine ou
# le pilote qui ne sait pas conduire jusque-la », et la reponse etait deja
# ecrite a cote : `test -Suite sortie` pose le camping-car au fond du fosse, met
# les gaz, et releve **74,2 km/h** — 857 images sur 901 au-dessus des 8 km/h que
# la sortie exige. Le vehicule sort largement. Un joueur n'est donc PAS bloque
# ici, et c'est ce qui compte.
#
# Ce qui reste a comprendre est plus etroit : pourquoi CE pilote, au volant, ne
# rejoint pas une zone de 30 x 26 m. La piste est en devers, il vise le centre
# de la zone et non son bord, et il ne recule jamais — trois pistes, aucune
# mesuree. Tant que ce n'est pas fait, l'echec reste rouge et il dit la verite :
# le parcours ne va pas plus loin. Il ne dit simplement pas ce qu'on a cru
# pendant deux jours.
#
# ON NE LA MET PAS AU VERT POUR AUTANT. Un test qu'on neutralise pour qu'il se
# taise est un test qu'on ne relira jamais. Elle reste rouge, elle dit ou, et
# elle dit ce qu'elle voyait.
#
# CE QU'ELLE A DEJA RAPPORTE : « PorteCampingCar » existait dans trois scenes,
# et le marqueur du battement A6 designait celui de la mission de rodage, a neuf
# cents metres du fosse. Corrige le jour meme.
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
	# ON RETIENT JUSQU'OU L'ON EST MONTE. Un parcours qui RECULE n'est pas un
	# parcours lent, c'est une partie qui a recommence — et il faut le dire.
	var plus_loin := 0
	while not _mission.finie() and garde < etapes.size() + 4:
		garde += 1
		var avant := _rates

		# LA MORT REMET LA MISSION A ZERO, ET LA BOUCLE NE LE VOYAIT PAS.
		#
		# Depuis qu'il y a du feu autour du camping-car, le pilote peut mourir :
		# il fonce droit sur sa cible la ou un joueur contourne. La partie
		# repart alors a la premiere etape, le pilote rejoue « masque »,
		# « jesse_panique », « preuve_1 »... et s'arrete sur la garde en
		# annoncant « 25 etapes jouees sans rien tricher ».
		#
		# Vingt-cinq etapes sur une mission qui en a vingt et une : le compte
		# etait la, sous les yeux, et il disait exactement ce qui se passait.
		if _mission.index() < plus_loin:
			_echouer(_mission.cle_etape(), _mission.objectif(),
					"la mission est revenue a l'etape %d apres etre montee a %d"
							% [_mission.index(), plus_loin]
					+ " : Walter est mort en chemin. Sa vie : %.0f"
							% _pv())
			break
		plus_loin = maxi(plus_loin, _mission.index())

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

	# UNE ETAPE GUIDEE N'A PAS DE LIEU NON PLUS, ET IL FAUT LA JOUER QUAND MEME.
	#
	# Elle passe AVANT le test du « ou » vide, et c'est tout le sujet. L'ouverture
	# au masque ne pose aucun marqueur — Guillaume veut qu'on suive une VOIX, pas
	# une fleche sur une minimap — donc son champ « ou » est vide, exactement
	# comme celui de la derniere etape de la mission.
	#
	# Le pilote l'a donc comptee « jouee, fin de mission » et est passe a la
	# suite. Quatorze fois de suite, et il a conclu par un TEST PARCOURS OK sur
	# vingt-cinq etapes alors que la mission en a vingt et une. Un vert obtenu en
	# ne jouant pas ce qu'on pretend jouer : c'est le piege 19, et il vient
	# d'etre repaye sur le premier ecran du jeu.
	if await _suivre_la_voix():
		_journal.append("  ok   %-18s %s  (guide a la voix, sans marqueur)"
				% [cle, objectif])
		return

	# UNE ETAPE SANS « ou » PEUT QUAND MEME AVOIR UN ENDROIT : une ZONE.
	#
	# « retour » se valide par le passage `retour_maison`, en voiture, et n'a
	# pas de marqueur — le joueur lit « ressortez, puis eloignez-vous ». Le
	# pilote la comptait « aucun lieu, fin de mission » et la rejouait cinq
	# fois, d'ou un vert a vingt-six etapes sur vingt-deux : piege 61, encore.
	# Quand l'etape se valide par une zone, la zone est le lieu.
	if _mission.ou().is_empty():
		cible = _passage_de_l_etape()
		if cible == null:
			# LA, il n'y a vraiment rien a atteindre : on la compte comme jouee
			# et on sort.
			_journal.append("  ok   %-18s %s  (aucun lieu, fin de mission)"
					% [cle, objectif])
			return

	# ON EST DEDANS, ET LE LIEU EST DEHORS : ON PASSE LA PORTE D'ABORD.
	#
	# Depuis la cuisine du camping-car, la zone du retour est a mille metres.
	# Marcher droit dessus, c'est marcher dans une paroi. Un joueur voit « E
	# Sortir du camping-car » et sort ; le pilote fait pareil, avant de viser.
	if cible != null and not _au_volant():
		await _sortir_s_il_le_faut(cible)

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
			# LE DEMARRAGE N'EST PLUS UN APPUI, C'EST UN GESTE.
			#
			# Depuis le 23/08/2026, mettre le contact ouvre un cadran : une
			# aiguille tourne, il faut presser quand elle traverse la zone, et
			# trois fois. Appuyer en boucle ne demarre plus rien.
			#
			# Le pilote le JOUE donc, et il le joue comme quelqu'un qui
			# regarde l'ecran : il lit ou est l'aiguille et ou est la zone —
			# les deux sont dessinees — et presse quand elles se croisent. Il
			# ne pose rien, ne saute rien, n'accelere rien.
			if await _jouer_le_demarreur():
				continue
			# ET CERTAINES SORTIES NE S'APPUIENT PAS : ELLES SE ROULENT.
			#
			# Depuis le 23/08/2026, la sortie du fosse s'ouvre apres trois
			# secondes de conduite sur la piste — il n'y a plus de ligne a
			# franchir ni de touche a presser. Le pilote arrivait dessus,
			# s'arretait, et appuyait soixante fois sur une zone qui attendait
			# justement qu'il ROULE.
			if await _rouler_pour_sortir():
				continue
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

		# ARRIVE — SAUF LA OU IL NE FAUT PAS S'ARRETER.
		#
		# La sortie du fosse s'ouvre apres trois secondes de conduite : le
		# pilote arrivait dessus, freinait, et appuyait soixante fois sur une
		# zone qui attendait justement qu'il roule. C'est exactement ce que le
		# joueur ferait s'il croyait qu'il faut appuyer — et c'est pour ca que
		# Guillaume ne veut plus de touche a cet endroit.
		if await _rouler_pour_sortir():
			continue

		# ET CERTAINES ETAPES NE S'APPUIENT PAS NON PLUS : ELLES SE TIENNENT.
		#
		# Depuis le 24/08/2026, l'etape des deux corps se joue en MAINTENANT la
		# touche et en reculant. Le pilote appuyait soixante fois pendant que le
		# jeu lui disait, en toutes lettres, « Maintenir pour attraper les
		# pieds » — le message qu'il imprime en echouant a servi a le reparer.
		if await _trainer_les_corps():
			continue

		# Sinon on relache tout et on appuie, comme un joueur qui s'arrete.
		_lacher()
		await _appuyer()
		geste += 1

		# ET SI L'APPUI A MIS QUELQUE CHOSE EN MAIN, ON LE JOUE.
		#
		# Les trois mini-jeux de la cuisine — verser, la plaque, la fournee —
		# s'ouvrent sur E au point, puis se jouent a la souris en tenant la
		# touche. Le pilote appuyait soixante fois sur « Verser, lentement »
		# pendant que la fiole attendait sa main. Piege 59, quatrieme fois.
		if await _cuisiner():
			continue

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


# CE QU'IL LUI RESTE DE VIE. Uniquement pour le message d'echec : savoir que
# Walter est mort ne dit pas de quoi, et « sa vie : 0 » apres un trajet qui
# longe cinq foyers designe le coupable sans qu'on ait a chercher.
func _pv() -> float:
	var j := _joueur_courant()
	return float(j.get("pv")) if j != null else -1.0


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
	# UN PASSAGE QUI EXIGE LA VOITURE demande le volant aussi : le retour de la
	# clairiere refuse les pietons — « votre voiture est garee un peu plus
	# loin » — et le pilote y arrivait a pied.
	if cible is Passage:
		return (cible as Passage).exige_vehicule
	var p := cible as Point
	if p == null:
		p = cible.find_child("Point", false, false) as Point
	return p != null and p.au_volant


## LE PASSAGE QUI VALIDE L'ETAPE COURANTE, quand elle n'a pas de lieu. On lit
## « zone:nom » dans son `valide_par` et on cherche le passage qui porte cette
## zone — comme le jeu le fait pour la franchir.
func _passage_de_l_etape() -> Node3D:
	var v := str(_mission.etape().get("valide_par", ""))
	if not v.begins_with("zone:"):
		return null
	var nom := v.trim_prefix("zone:")
	for n in get_nodes_in_group(Passage.GROUPE):
		var p := n as Passage
		if p != null and p.zone == nom:
			return p
	return null


## SORTIR PAR LA PORTE QU'ON NOUS PROPOSE, si la cible est loin. Une porte est
## un point offert qui emmene ailleurs ; on y va, on appuie, et on attend
## d'avoir change d'endroit. Rien n'est place : c'est le fondu du jeu qui nous
## deplace, exactement comme pour le joueur.
func _sortir_s_il_le_faut(cible: Node3D) -> void:
	var j := _joueur_courant()
	if j == null or j.global_position.distance_to(cible.global_position) < 60.0:
		return
	var porte: Point = null
	for n in get_nodes_in_group("point"):
		var p := n as Point
		if p == null or not p.disponible(_mission):
			continue
		if p.emmene_vers == "" and p.emmene_a == Vector3.ZERO:
			continue
		if p.global_position.distance_to(j.global_position) > 12.0:
			continue
		porte = p
		break
	if porte == null:
		return
	var origine := j.global_position
	var images := 0
	while images < BUDGET and j.global_position.distance_to(origine) < 30.0:
		images += 1
		var d := j.global_position.distance_to(porte.global_position)
		if d > _portee_de(porte):
			_aller_vers(porte, j)
			await process_frame
			continue
		_lacher()
		await _appuyer()
		# Le fondu de porte prend quelques images : on lui laisse le temps
		# avant de conclure qu'on n'a pas bouge.
		for _i in 40:
			await process_frame
	_lacher()
	_journal.append("       (sorti par « %s » pour rejoindre « %s »)"
			% [porte.name, cible.name])


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
	# ON VISE LA PORTIERE, PAS LE CENTRE DE LA CAISSE.
	#
	# Le pilote visait `v.global_position` — le milieu du camping-car — donc il
	# s approchait par le plus court chemin, qui peut etre n importe quel cote.
	# Depuis qu il y a du feu autour, ce cote-la est parfois en flammes : il
	# mourait a l etape du demarrage, la partie recommencait, et le journal
	# rejouait la mission depuis le debut.
	#
	# Un joueur ne fait jamais ca. Il est SORTI par la portiere, il y revient —
	# et ce cote-la est degage, la suite « feu » l exige a quatre metres pres.
	#
	# `SortieConducteur` est le noeud dont le controleur se sert deja pour
	# reposer Walter quand il descend : c est la meme porte, vue de l autre sens.
	var porte: Node3D = v.get_node_or_null("SortieConducteur") as Node3D
	if porte == null:
		porte = v
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
			_aller_vers(porte, j, biais)
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
	_journal.append("        etat : %s" % _etat_du_jeu())
	printerr("  ECHEC etape '%s' : %s" % [cle, pourquoi])
	printerr("        etat : %s" % _etat_du_jeu())


## CE QUI PEUT PRENDRE LA TOUCHE A LA PLACE DU POINT, imprime au moment de
## l'echec. « Le jeu propose : rien du tout » designait un coupable sans le
## nommer : un telephone reste sorti, un geste en cours, un dialogue qui
## attend, un fondu jamais fini — chacun efface l'invite pour une raison
## differente, et on cherchait au mauvais endroit.
func _etat_du_jeu() -> String:
	var morceaux: Array[String] = []
	var tel := _monde.find_child("Telephone", true, false)
	if tel != null and tel.has_method("sorti"):
		morceaux.append("telephone sorti=%s" % tel.call("sorti"))
	morceaux.append("dialogue actif=%s" % _en_dialogue())
	var j := _joueur_courant()
	if j != null:
		morceaux.append("joueur bloque=%s geste='%s'"
				% [j.get("bloque"), j.call("geste_en_cours") if j.has_method("geste_en_cours") else "?"])
	if _controleur != null:
		morceaux.append("transition=%s au_volant=%s dedans=%s"
				% [_controleur.call("en_transition") if _controleur.has_method("en_transition") else "?",
				_au_volant(), _controleur.call("dedans")])
		var vise: Node = _controleur.call("point_vise")
		morceaux.append("point_vise=%s" % (vise.name if vise != null else "aucun"))
		morceaux.append("bandeau='%s'" % _controleur.call("bandeau"))
	return "  ".join(morceaux)


# ON CUISINE, quand un point vient de mettre un mini-jeu en main.
#
# Renvoie vrai si un mini-jeu de souris etait arme et qu'on l'a joue jusqu'a
# ce que l'etape passe, ou qu'il se soit ferme — l'appelant reprend alors sa
# boucle au lieu de compter un appui de plus.
#
# CE QUE LE PILOTE S'AUTORISE, ET CE QU'IL REFUSE. Il tient E, comme le jeu
# le demande, et il LIT ce qui est dessine : ou tombe le filet, les bulles et
# la mousse, quel flacon le ballon reclame. Il repond avec de vrais evenements
# de souris — un mouvement pour la fiole, la molette pour le robinet et les
# flacons, un clic pour verser. Il ne pose aucune inclinaison, aucun gaz,
# aucun flacon, et il ne saute aucun ajout. C'est exactement ce que fait
# test_cuisine.gd, qui mesure les mecanismes ; ici on mesure qu'on y ARRIVE
# depuis le pas de la porte.
#
# Rater fait partie du jeu : la fiole se repose, la main revient une seconde
# plus tard, et le joueur la reprend. Le pilote fait pareil — il relache E et
# le reprend quand la main n'est plus sur l'objet.
func _cuisiner() -> bool:
	var jeu: Node = null
	for n in get_nodes_in_group(Verseuse.GROUPE):
		if n.has_method("arme") and bool(n.call("arme")):
			jeu = n
			break
	if jeu == null:
		return false

	var depart := _mission.index()
	Input.action_press("interagir")
	var images := 0
	var sans_main := 0
	while images < 60 * 60 and _mission.index() == depart \
			and bool(jeu.call("arme")):
		images += 1
		await process_frame
		if not bool(jeu.call("capte_la_souris")):
			# La main n'est pas dessus : pas encore prise, ou reposee apres un
			# rate. On laisse passer la seconde de lecture, puis on reprend.
			sans_main += 1
			if sans_main > 90:
				Input.action_release("interagir")
				await process_frame
				Input.action_press("interagir")
				sans_main = 0
			continue
		sans_main = 0

		if jeu.has_method("incliner"):
			# LA FIOLE : on penche jusqu'a ce que ca coule, puis on corrige
			# selon ou le filet tombe — trop court, on penche ; trop loin, on
			# redresse.
			var dy := GESTE_SOURIS
			if bool(jeu.call("coule")):
				var ecart: float = jeu.call("ecart")
				dy = GESTE_SOURIS if ecart < 0.0 else (-GESTE_SOURIS if ecart > 0.0 else 0.0)
			if dy != 0.0:
				_souris(dy)
		elif jeu.has_method("chaleur"):
			# LA PLAQUE : un cran dans le sens de l'ecart, et rien quand c'est
			# juste — la fenetre descend toute seule, on la suit.
			var e: float = jeu.call("ecart")
			if e < 0.0:
				_molette(1.0)
			elif e > 0.0:
				_molette(-1.0)
		elif jeu.has_method("demande"):
			# LA FOURNEE : on lit ce que le ballon reclame, on tourne jusqu'au
			# bon flacon, on verse. Rien tant qu'il ne reclame rien.
			var veut: int = jeu.call("demande")
			if veut >= 0:
				var a: int = jeu.call("choisi")
				if a < veut:
					_molette(1.0)
				elif a > veut:
					_molette(-1.0)
				else:
					Input.action_press("gauche")
					Input.action_release("gauche")
	Input.action_release("interagir")
	await process_frame
	return true


## Un mouvement de souris vers le bas, en points d'ecran, par image.
const GESTE_SOURIS := 7.0


func _souris(dy: float) -> void:
	var e := InputEventMouseMotion.new()
	e.relative = Vector2(0.0, dy)
	e.screen_relative = e.relative
	Input.parse_input_event(e)


func _molette(sens: float) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_WHEEL_UP if sens > 0.0 else MOUSE_BUTTON_WHEEL_DOWN
	e.pressed = true
	Input.parse_input_event(e)


# ON JOUE LE CADRAN DE DEMARRAGE, comme quelqu'un qui le regarde.
#
# Renvoie vrai si un cadran etait la et qu'on s'en est occupe — l'appelant
# passe alors son tour plutot que d'appuyer dans le vide.
#
# CE QUE CE PILOTE S'AUTORISE, ET CE QU'IL REFUSE. Il LIT l'angle de
# l'aiguille et celui de la zone : c'est ce que le joueur voit dessine a
# l'ecran. Il ne les MODIFIE pas, n'allonge pas la zone, ne ralentit pas
# l'aiguille et ne saute pas les trois passages. La suite `demarreur`, elle,
# pose l'aiguille — mais elle mesure le mecanisme, pas la traversee.
func _jouer_le_demarreur() -> bool:
	var d := _monde.find_child("Demarreur", true, false)
	if d == null or not bool(d.call("arme")):
		return false

	# Le contact, tenu : c'est lui qui ouvre le cadran.
	Input.action_press("interagir")
	var images := 0
	while images < 900:
		await process_frame
		images += 1
		if not bool(d.call("arme")):
			break                      # le moteur a pris
		if not bool(d.call("ouvert")):
			continue
		var angle := float(d.get("_angle"))
		var cible := float(d.get("_cible"))
		var zone := int(d.call("zone"))
		var demi: float = Demarreur.LARGEUR_ZONE[
				mini(zone, Demarreur.LARGEUR_ZONE.size() - 1)] * TAU * 0.5
		# On presse a l'entree de la zone plutot qu'en son centre : c'est ce
		# qu'un joueur reussit, et ca ne demande pas de prevoir l'avenir.
		if absf(wrapf(angle - cible, -PI, PI)) < demi * 0.8:
			Input.action_press("gauche")
			await process_frame
			Input.action_release("gauche")
			await process_frame
	Input.action_release("interagir")
	await process_frame
	return true


# ON SUIT LA VOIX, quand l'etape se joue a l'aveugle.
#
# Renvoie vrai si un guidage nous attendait — l'appelant compte alors l'etape
# comme jouee et passe a la suivante.
#
# CE QUE LE PILOTE S'AUTORISE : marcher vers le jalon courant. C'est ce qu'un
# joueur fait en entendant « par ici » — il va dans la direction de la voix. Il
# ne se teleporte pas, ne saute aucun jalon, ne force aucune etape, et si le
# trajet ne se termine pas, il ne se termine pas.
#
# IL LIT `rang()`, CE QUE LE JOUEUR NE PEUT PAS FAIRE, et c'est la limite
# assumee de ce controle : un joueur entend une direction, le pilote lit une
# position. Ce qu'on mesure ici n'est donc pas « les consignes sont
# comprehensibles » — aucun test ne sait faire ca — mais « le trajet se termine,
# et il mene la ou il doit ». Les consignes elles-memes sont mesurees par la
# suite « ouverture », qui verifie que « a droite » est vraiment a droite.
func _suivre_la_voix() -> bool:
	var g := get_first_node_in_group(Guidage.GROUPE) as Guidage
	if g == null or not g.active():
		return false
	# ON PASSE PAR L'ACCESSEUR, PAS PAR LE CHAMP.
	#
	# `_joueur` est resolu paresseusement, la premiere fois qu'on en a besoin —
	# et ce guidage est la TOUTE PREMIERE etape du jeu, donc personne ne l'a
	# encore demande. Lire le champ directement rendait null, la fonction
	# renvoyait false, et l'etape retombait dans la branche « aucun lieu, fin de
	# mission » : le pilote annoncait vingt-cinq etapes jouees sur une mission
	# qui en a vingt et une, et se declarait vert.
	var j := _joueur_courant()
	if j == null:
		return false

	# SOIXANTE-DIX SECONDES, ET LE PREMIER CHIFFRE ETAIT TROP JUSTE.
	#
	# Le trajet fait vingt-sept metres et Walter se traine a 1,15 m/s sous son
	# masque : vingt-quatre secondes en ligne droite. Quarante-cinq semblaient
	# donc confortables — sauf qu'il y a un camping-car et cinq foyers entre les
	# jalons, et que contourner coute plus cher au pilote qu'a un joueur.
	#
	# CE QUE CE MAUVAIS CHIFFRE A COUTE : une demi-heure a chercher un bug qui
	# n'existait pas. Le test echouait, le jeu passait l'etape trois secondes
	# plus tard, et les deux messages arrivaient dans le desordre a l'ecran —
	# `print` sort sur la sortie standard, `printerr` sur celle des erreurs, et
	# rien ne garantit leur ordre. On lisait donc « guidage fini » AVANT
	# « ECHEC : le trajet ne s'est pas termine », ce qui est impossible.
	var images := 0
	var depart := _mission.index()
	while images < 60 * 70 and _mission.index() == depart:
		images += 1
		var jalon := g.get_node_or_null(g.jalons[mini(
				g.rang(), g.jalons.size() - 1)]) as Node3D
		if jalon == null:
			break
		_aller_vers(jalon, j)
		# PAS DE SPRINT SOUS LE MASQUE : l'etape pose « lent », et le joueur se
		# traine. Tenir Maj ne changerait rien au jeu, mais le pilote doit faire
		# ce que le joueur fait, pas ce qu'il pourrait faire.
		Input.action_release("sprint")
		await process_frame
	_lacher()
	await process_frame

	# ET ON DIT SI ON N'Y EST PAS ARRIVE, plutot que de rendre la main en
	# silence. Sans ca, l'appelant compte l'etape « jouee » quoi qu'il arrive —
	# ce qui est exactement le faux vert qu'on vient de corriger, deplace d'un
	# cran.
	if _mission.index() == depart:
		_echouer(_mission.cle_etape(), _mission.objectif(),
				"le trajet guide ne s'est pas termine en 70 s. Jalon %d sur %d,"
						% [g.rang() + 1, g.total()]
				+ " a %.1f m. Le jeu propose : %s" % [g.reste(), _propose()])
	return true


# ON TIENT LA TOUCHE ET ON RECULE, quand l'etape demande de porter les corps.
#
# Renvoie vrai si une traction nous attendait — l'appelant passe alors son tour
# au lieu d'appuyer dans le vide.
#
# CE PILOTE APPUYAIT SOIXANTE FOIS SUR UN GESTE QUI SE MAINTIENT, et il le
# disait tres bien : « le jeu propose "Maintenir pour attraper les pieds" ».
# C'est le troisieme geste du jeu qu'il a fallu lui apprendre, apres le cadran
# du demarreur et les trois secondes de roulage — et c'est le meme motif a
# chaque fois : un mecanisme nouveau ressemble a un blocage tant que personne ne
# sait le jouer.
#
# CE QU'IL S'AUTORISE : tenir E, et marcher vers la portiere. Il ne se
# teleporte pas, ne pose aucun corps a la main, ne raccourcit aucune pause. Si
# la traction ne finit pas, elle ne finit pas.
func _trainer_les_corps() -> bool:
	var t := get_first_node_in_group(Traction.GROUPE) as Traction
	if t == null or not t.active():
		return false
	var j := _joueur as Node3D
	var porte := _monde.find_child("DepartCrash", true, false) as Node3D
	if j == null or porte == null:
		return false

	Input.action_press("interagir")
	var images := 0
	var depart := _mission.index()
	while images < 60 * 120 and _mission.index() == depart:
		images += 1
		# On va chercher ce qu'on n'a pas encore : le corps tant qu'on ne le
		# tient pas, la portiere une fois qu'on l'a. Rien d'autre a decider.
		var but := porte if t.porte_un_corps() else _corps_libre(t)
		if but == null:
			# Plus rien a prendre et rien en main : Jesse finit le sien, on
			# attend que l'etape se ferme.
			_lacher()
			await process_frame
			continue
		_aller_vers(but, j)
		# PAS DE SPRINT AVEC UN CADAVRE. _aller_vers le pose systematiquement ;
		# ici il ne change rien — l'allure est bornee par la traction — mais un
		# pilote qui court en tirant un mort donnerait une mesure de duree qui
		# ne veut rien dire le jour ou cette borne bougera.
		Input.action_release("sprint")
		await process_frame
	_lacher()
	Input.action_release("interagir")
	await process_frame
	return true


# Un corps qu'on peut encore prendre. Celui que Jesse s'est reserve n'en est
# pas un : la traction le retire de son propre compte, on lit donc le meme.
func _corps_libre(t: Traction) -> Node3D:
	for chemin in t.corps:
		var c := t.get_node_or_null(chemin) as Node3D
		if c != null and c.visible:
			return c
	return null


# ON ROULE POUR SORTIR, quand la sortie le demande.
#
# Renvoie vrai si une sortie de ce genre nous attendait — l'appelant passe
# alors son tour au lieu d'appuyer dans le vide.
#
# CE N'EST PAS UNE TRICHE : le pilote garde le pied dessus, exactement comme
# un joueur qui monte sur la piste et continue. Il ne se teleporte pas, ne
# force aucune etape, et si la sortie ne s'ouvre pas, elle ne s'ouvre pas.
func _rouler_pour_sortir() -> bool:
	var sujet := _sujet()
	var attend: Passage = null
	# Ce script EST le SceneTree : les groupes se lisent directement.
	for n in get_nodes_in_group(Passage.GROUPE):
		var p := n as Passage
		if p != null and p.roule_depuis > 0.0 and p.contient(sujet):
			attend = p
			break
	if attend == null:
		return false

	# On roule DROIT DEVANT. Viser la cible ferait tourner en rond autour
	# d'elle une fois dessus ; ce qu'on veut est de continuer sa route.
	Input.action_release("gauche")
	Input.action_release("droite")
	Input.action_press("gaz")
	var images := 0
	var depart := _mission.index()
	while images < 600 and _mission.index() == depart:
		await process_frame
		images += 1
	Input.action_release("gaz")
	await process_frame
	return true
