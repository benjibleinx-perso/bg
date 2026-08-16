# La premiere mission, jouee de bout en bout sans y jouer.
#
#   godot --path game --script res://verifs/test_mission.gd
#
# CE QUE CE TEST CHERCHE. Une mission de quinze etapes a une facon de casser
# qui lui est propre : elle ne plante pas, elle se BLOQUE. Un objectif dont
# l'evenement ne sera jamais emis, une etape franchie deux fois, un point
# d'interaction accroche a une etape qui n'existe plus — dans les trois cas le
# jeu tourne parfaitement et le joueur reste devant une porte pour toujours.
#
# On deroule donc la mission entiere en annoncant les evenements attendus, et
# on verifie qu'elle arrive au bout. Puis on verifie ce qui ne se voit
# qu'autrement : que chaque cle citee existe vraiment quelque part.
extends SceneTree

const POSE := 30

var _n := 0
var _erreurs: Array[String] = []
var _monde: Node


func _initialize() -> void:
	# ON PART D'UNE PARTIE NEUVE, ET IL FAUT LE DIRE AVANT DE CHARGER LA SCENE.
	#
	# Depuis que la sauvegarde restaure vraiment la position et l'inventaire —
	# elle n'en gardait que la moitie —, une partie qui traine sur la machine
	# replace le joueur ou il s'etait arrete. « La partie s'ouvre dans le salon »
	# devenait alors faux, pour une bonne raison : on reprend ou l'on etait.
	#
	# Le fichier se supprime ICI parce que Sauvegarde le relit dans son _ready,
	# donc avant la premiere ligne du scenario de test. Effacer plus tard
	# n'annulerait rien.
	if FileAccess.file_exists("user://partie.json"):
		DirAccess.remove_absolute("user://partie.json")
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
	root.add_child(_monde)


func _verifier(ok: bool, message: String) -> void:
	if ok:
		print("  ok   " + message)
	else:
		_erreurs.append(message)
		printerr("  ECHEC " + message)


func _process(_d: float) -> bool:
	_n += 1
	if _n != POSE:
		return false
	_scenario()
	return true


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


func _scenario() -> void:
	var mission := _trouver(_monde, "Mission") as Mission
	var bourse := _trouver(_monde, "Bourse") as Bourse
	var dialogue := _trouver(_monde, "Dialogue") as Dialogue
	var equipement := _trouver(_monde, "Equipement") as Equipement
	if mission == null or bourse == null or dialogue == null:
		printerr("  ECHEC systemes de mission introuvables")
		quit(1)
		return

	print("\n--- l'etat de depart ---")
	print("       %s en poche, %d objet(s)"
			% [Bourse.ecrire(bourse.montant()), equipement.nombre()])
	# ON MESURE CE QUE LA MISSION DECLARE, PAS UN CHIFFRE ECRIT ICI.
	#
	# Le montant etait compare a 100-200, les valeurs de la mission de rodage,
	# recopiees dans ce test. « Deux corps » ouvre le jeu a ZERO — c'est sa
	# fiche qui le dit, « argent ~0 », et c'est le sujet de la mission : Walter
	# n'a rien et tout ce qu'il aura, il ira le chercher.
	#
	# Le test accusait donc une mission conforme. Un seuil recopie d'un fichier
	# de donnees finit toujours par diverger de lui : on lit la source.
	var f := mission.fourchette_de_depart()
	_verifier(bourse.montant() >= f.x and bourse.montant() <= f.y,
			"on demarre avec %s, entre %d et %d comme annonce"
					% [Bourse.ecrire(bourse.montant()), f.x, f.y])
	_verifier(not equipement.possede("meth"), "sans la meth")
	_verifier(not equipement.possede("arme"), "et sans le revolver")

	# CE QUI VAUT POUR N'IMPORTE QUELLE MISSION.
	_les_passages_sont_surveilles()
	_ou_commence_la_partie(mission)
	_le_depart()
	_qui_dit_quoi(mission)
	_qui_emet_quoi(mission, dialogue)
	_les_missions_non_chargees(mission, dialogue)
	_le_deroule(mission)

	# CE QUI NE VAUT QUE POUR LA MISSION DE RODAGE.
	#
	# Ces six-la connaissent « Un client impatient » par coeur : la botte
	# secrete, la cachette sous la latte, la boite d'oeufs, l'appel de Tuco, le
	# puits de reputation. Ce sont de bons controles — ils ont attrape des
	# blocages reels — mais ils ne parlent que de CETTE mission.
	#
	# Tant qu'ils s'executaient sans condition, changer la mission chargee les
	# faisait tous crier sur des pieces saines, et le seul moyen de basculer
	# aurait ete de les supprimer. Ils sont donc poses sur la mission qu'ils
	# decrivent, et le test DIT ce qu'il ne mesure pas.
	#
	# « Deux corps » n'a pas encore les siens. Elle est couverte par les cinq
	# controles generiques ci-dessus, ce qui est deja plus que ce que la mission
	# de rodage a eu pendant ses six premiers mois.
	if mission.fichier.ends_with("mission1.json"):
		_les_cles(mission, dialogue, equipement)
		_la_cachette(mission, bourse)
		_les_courses(equipement, dialogue)
		_le_mot_de_la_fin(mission, dialogue)
		_l_appel(dialogue)
		_le_puits(equipement, bourse)
	else:
		print("\n--- les controles propres a la mission de rodage ---")
		print("       sautes : la mission chargee est '%s'" % mission.titre())
		print("       ils gardent la botte, la cachette, les oeufs, l'appel et")
		print("       le puits de reputation, qui n'existent que la-bas")

	print("")
	if _erreurs.is_empty():
		print("TEST MISSION OK")
		quit(0)
	else:
		printerr("TEST MISSION ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)


# LA PARTIE COMMENCE DANS LE SALON DE WALTER.
#
# C'est ce que demande le scenario, et ca n'est pas cosmetique : l'homme de
# Tuco appelle cinq secondes apres qu'on est SORTI de chez soi. En demarrant
# dehors, la condition « il est sorti » etait vraie des la premiere image et le
# telephone sonnait avant meme qu'on ait vu la rue.
#
# CE CONTROLE NE VAUT QUE SI LA MISSION NE DIT PAS OU ELLE COMMENCE. Depuis le
# 16/08/2026, une mission peut declarer son propre depart — « Deux corps » ouvre
# dans un fosse a neuf cents metres du salon. Le controle exigeait alors un
# joueur chez Walter et accusait une mission qui faisait exactement ce qu'elle
# annonce. Son propre depart est mesure juste au-dessus, par _ou_commence_la_partie.
func _le_depart() -> void:
	var m := Mission.courante(_monde)
	if m != null and m.depart_ou() != "":
		return
	print("\n--- on commence chez Walter ---")
	var controleur := _trouver(_monde, "Controleur")
	var joueur := _trouver(_monde, "Joueur") as Node3D
	if controleur == null or joueur == null:
		_erreurs.append("controleur ou joueur introuvable")
		printerr("  ECHEC controleur ou joueur introuvable")
		return
	var dedans: bool = controleur.call("dedans")
	print("       joueur en %s, dedans = %s"
			% [joueur.global_position.round(), dedans])
	_verifier(dedans, "la partie s'ouvre a l'interieur")
	# L'interieur de la maison de Walter est pose loin du centre-ville, vers
	# (-574, 583). Si le joueur est reste en ville, c'est que rien ne l'a
	# deplace et que le drapeau ment.
	_verifier(joueur.global_position.distance_to(Vector3(-574, 0, 583)) < 12.0,
			"et il est bien dans le salon, pas seulement declare dedans")


# Jesse chez lui doit tenir la conversation de la MISSION a l'etape ou l'on
# vient lui parler de la commande, et sa causette habituelle le reste du temps.
#
# C'est exactement ce qui a rate au premier essai en jeu : on recevait l'appel,
# on courait chez lui, et il repondait « Yo » comme si de rien n'etait. La
# mission ne pouvait plus avancer, et rien n'indiquait pourquoi — l'habitant
# porte une cle unique, il disait donc toujours la meme chose.
#
# CE CONTROLE EST CELUI DE LA MISSION DE RODAGE, malgre les apparences. Il
# nomme des etapes — « parler_jesse » — et des conversations qui n'existent que
# la-bas. Il etait range avec les controles generiques parce qu'il parle d'un
# MECANISME general ; ce qu'il mesure, lui, est particulier.
func _qui_dit_quoi(mission: Mission) -> void:
	if not mission.fichier.ends_with("mission1.json"):
		return
	print("\n--- Jesse dit ce que la mission attend ---")
	var scenario := _trouver(_monde, "Scenario") as Scenario
	if scenario == null:
		_erreurs.append("scenario introuvable")
		printerr("  ECHEC scenario introuvable")
		return
	mission.recommencer()
	_verifier(scenario.dialogue_pour("jesse") == "jesse",
			"avant l'appel, il tient sa conversation ordinaire")
	mission.evenement("dialogue:mission_tuco_appel")
	_verifier(mission.a_l_etape("parler_jesse"), "l'appel mene chez Jesse")
	_verifier(scenario.dialogue_pour("jesse") == "mission_jesse_maison",
			"et la, il parle de la commande")
	mission.evenement("dialogue:mission_jesse_maison")
	_verifier(scenario.dialogue_pour("jesse") == "jesse",
			"une fois l'etape passee, il redevient lui-meme")
	mission.recommencer()


# CHAQUE EVENEMENT ATTENDU DOIT AVOIR UN EMETTEUR.
#
# C'est le controle qui manquait, et son absence a coute une mission morte a sa
# troisieme etape : personne n'annoncait « volant ». L'objectif « trouver la
# voiture de Walt » ne pouvait donc jamais etre franchi, et tout ce qui suit —
# le desert, Jesse, le camping-car — restait hors d'atteinte. Le jeu tournait
# parfaitement.
#
# Le deroule ci-dessous ne voyait rien : il annonce les evenements DIRECTEMENT
# a la machine. Il prouve que la chaine des etapes est coherente, pas que le
# monde sait la faire avancer. Ici on cherche, pour chaque evenement, l'objet
# du jeu capable de l'emettre.
func _qui_emet_quoi(mission: Mission, dialogue: Dialogue) -> void:
	print("\n--- chaque etape a quelqu'un pour la franchir ---")
	var zones: Array[String] = []
	var actions: Array[String] = []
	for n in root.get_tree().get_nodes_in_group("point"):
		var p := n as Point
		if p.zone != "":
			zones.append(p.zone)
		if p.evenement != "":
			actions.append(p.evenement)
	for n in root.get_tree().get_nodes_in_group("passage"):
		var z: String = n.get("zone")
		if z != "":
			zones.append(z)
	# Deux zones ne viennent ni d'un point ni d'un passage : entrer dans une
	# maison, et le retour en ville apres l'explosion. Le controleur les
	# annonce lui-meme.
	zones.append_array(["maison_walter", "maison_jesse", "albuquerque"])

	# QUI SAIT DIRE QUOI. Une conversation peut exister dans les donnees et
	# n'etre a la portee de personne : le PNJ porte une cle unique, et si elle
	# ne correspond pas, il recite autre chose indefiniment.
	#
	# Deux fois de suite ca a bloque la mission — Jesse chez lui qui disait
	# « Yo », Jesse au camping-car qui repetait « je suis concentre ». Verifier
	# que la fiche EXISTE ne suffisait pas ; il faut verifier qu'un habitant du
	# monde peut la sortir.
	var dicibles: Array[String] = []
	for n in root.get_tree().get_nodes_in_group(Pnj.GROUPE):
		var p := n as Pnj
		if p.cle != "":
			dicibles.append(p.cle)
	for n in root.get_tree().get_nodes_in_group("point"):
		var pt := n as Point
		if pt.dialogue != "":
			dicibles.append(pt.dialogue)
	var scenario0 := _trouver(_monde, "Scenario") as Scenario
	if scenario0 != null:
		for source in Scenario.REMPLACEMENTS:
			for regle in Scenario.REMPLACEMENTS[source]:
				dicibles.append(str(regle[1]))
	# L'appel d'ouverture ne vient d'aucun personnage : le jeu compose.
	dicibles.append("mission_tuco_appel")

	var orphelins: Array[String] = []
	for e in mission.etapes():
		var attendu := str((e as Dictionary).get("valide_par", ""))
		var cle := str((e as Dictionary).get("cle", ""))
		# UNE ETAPE SANS 'valide_par' EST LEGITIME, et le format le dit :
		# « elle ne se termine jamais toute seule — c'est le cas de la
		# derniere ». Le controle l'accusait quand meme de n'avoir personne
		# pour l'emettre. Ca ne s'etait jamais vu parce que la derniere etape
		# de la mission de rodage en a un, « argent_cache » ; « Deux corps »
		# finit sur un retour au monde ouvert, qui ne se valide pas.
		if attendu == "":
			continue
		var trouve := false
		if attendu.begins_with("dialogue:"):
			var conv := attendu.substr(9)
			trouve = dialogue.connait(conv) and dicibles.has(conv)
			if dialogue.connait(conv) and not dicibles.has(conv):
				printerr("  ECHEC '%s' existe mais PERSONNE ne peut la dire"
						% conv)
		elif attendu.begins_with("zone:"):
			trouve = zones.has(attendu.substr(5))
		elif attendu.begins_with("objet:") or attendu.begins_with("action:"):
			trouve = actions.has(attendu)
		else:
			# Les evenements nus — « volant », « argent_cache ». On ne peut pas
			# les trouver dans la scene : ils sont emis par du code. On les
			# eprouve donc pour de vrai, plus bas.
			trouve = attendu in ["volant", "argent_cache"]
		if not trouve:
			orphelins.append("%s attend '%s'" % [cle, attendu])
	for o in orphelins:
		printerr("  ECHEC " + o + " — personne ne l'emet")
		_erreurs.append(o)
	_verifier(orphelins.is_empty(),
			"les %d etapes ont un emetteur" % mission.etapes().size())

	# « volant » EPROUVE POUR DE VRAI : on monte dans la voiture et on regarde
	# si la mission avance. C'est le seul controle qui aurait attrape le bug.
	#
	# Il vise l'etape « voiture », qui n'existe que dans la mission de rodage.
	# « Deux corps » n'envoie jamais chercher un vehicule : elle en fournit un,
	# accidente, et on le redemarre. Sans cette garde, la boucle ci-dessous ne
	# trouvait rien et le controle accusait un volant en parfait etat.
	if not mission.contient("voiture"):
		print("       pas d'etape 'voiture' dans cette mission : « volant » non "
				+ "eprouve")
		return
	mission.recommencer()
	while not mission.a_l_etape("voiture") and not mission.finie():
		if not mission.evenement(str(mission.etape().get("valide_par", ""))):
			break
	var controleur := _trouver(_monde, "Controleur")
	var scenario := _trouver(_monde, "Scenario") as Scenario
	if controleur != null and mission.a_l_etape("voiture"):
		controleur.call("_monter")
		_verifier(not mission.a_l_etape("voiture"),
				"monter dans la voiture franchit bien l'etape")

	# ET SI ON Y ETAIT DEJA ? C'est le cas courant : on prend la voiture pour
	# aller chez Jesse, on lui parle, et l'etape s'ouvre alors qu'on est assis
	# au volant. Plus aucun « monter » n'aura lieu — l'objectif resterait
	# affiche pour toujours. Signale en jouant, invisible au test precedent.
	mission.recommencer()
	while not mission.a_l_etape("voiture") and not mission.finie():
		if not mission.evenement(str(mission.etape().get("valide_par", ""))):
			break
	if scenario != null and controleur != null:
		_verifier(controleur.call("au_volant"), "on est toujours au volant")
		scenario.traiter(0.016)
		_verifier(not mission.a_l_etape("voiture"),
				"deja au volant, l'etape se franchit d'elle-meme")
		controleur.call("_descendre")
	mission.recommencer()


## UN PASSAGE QUE PERSONNE NE SCRUTE NE S'OUVRE JAMAIS.
##
## passage.gd ne teleporte rien lui-meme : « il constate qu'on est dedans, et le
## dit au controleur ». Et le controleur ne surveille QUE les passages de sa
## liste, donnee par l'inspecteur dans monde.tscn.
##
## Un passage peut donc exister, porter la bonne zone, la bonne destination, se
## declarer dans son groupe — et n'etre relie a personne. Il est alors un mur
## invisible : on marche dedans, il ne se passe rien, et absolument rien ne le
## signale.
##
## C'est arrive a SortieCrash, la sortie du fosse de « Deux corps ». Benjamin
## est reste plante sur le marqueur. Les suites etaient vertes : elles comptaient
## les passages du GROUPE, ou le noeud figurait bien.
func _les_passages_sont_surveilles() -> void:
	print("\n--- chaque passage est surveille par le controleur ---")
	var c := _trouver(_monde, "Controleur")
	if c == null:
		return
	var liste: Array = c.get("passages")
	var vus: Array[String] = []
	for np in liste:
		var n := c.get_node_or_null(np as NodePath)
		if n != null:
			vus.append(n.name)
	var orphelins: Array[String] = []
	for n in root.get_tree().get_nodes_in_group("passage"):
		if not vus.has(n.name):
			orphelins.append(n.name)
	for o in orphelins:
		printerr("  ECHEC le passage '%s' n'est dans la liste de personne" % o)
		_erreurs.append("passage %s orphelin" % o)
	_verifier(orphelins.is_empty(),
			"les %d passages du monde sont tous scrutes" % vus.size())


## OU LA PARTIE COMMENCE, ET SI LE JOUEUR Y EST VRAIMENT.
##
## AUCUNE SUITE NE MESURAIT CA. « Deux corps » a ete livree en 0.56.0 avec la
## bonne mission, les bons dialogues, les bons decors — et elle deposait le
## joueur devant la porte de Walter, a neuf cents metres du camping-car, avec
## « Retirer le masque » en objectif. Tout etait vert.
##
## C'est Benjamin qui l'a vu en lancant le jeu, en dix secondes. Aucun controle
## ne posait la question la plus simple : est-ce qu'on commence au bon endroit ?
func _ou_commence_la_partie(mission: Mission) -> void:
	var nom := mission.depart_ou()
	if nom == "":
		print("\n--- ou la partie commence ---")
		print("       la mission n'en declare pas : la scene decide")
		return
	print("\n--- ou la partie commence ---")
	var n := _trouver(_monde, nom) as Node3D
	_verifier(n != null, "le depart '%s' existe dans une scene" % nom)
	if n == null:
		return
	var j := _trouver(_monde, "Joueur") as Node3D
	if j == null:
		return
	var d := j.global_position.distance_to(n.global_position)
	# Deux metres : le controleur pose le joueur SUR le noeud, mais la physique
	# le fait retomber sur le sol dans l'image qui suit.
	_verifier(d < 2.0,
			"le joueur commence bien dessus (%.1f m de '%s')" % [d, nom])


## LES MISSIONS QUI NE SONT PAS CHARGEES SONT GARDEES AUSSI.
##
## Une mission qu'on ecrit avant de la brancher n'a aucun filet : ses etapes
## peuvent citer un dialogue qui n'existe pas, ou attendre un evenement que
## personne n'emet, et rien ne le dira jusqu'au jour ou on la branche — c'est-a-
## dire au pire moment, quand on croit avoir fini.
##
## « Deux corps » a ete ecrite comme ca, et ses decors vivent deja dans le monde
## en dormant. On peut donc la mesurer sans la jouer : les points sont dans
## l'arbre, seulement invisibles.
##
## On lit les fichiers plutot que d'instancier une seconde Mission : deux noeuds
## dans le groupe « mission » et Mission.courante() en designerait un au hasard.
func _les_missions_non_chargees(mission: Mission, dialogue: Dialogue) -> void:
	print("\n--- les missions ecrites mais pas encore branchees ---")
	var zones: Array[String] = []
	var actions: Array[String] = []
	var dicibles: Array[String] = []
	for n in root.get_tree().get_nodes_in_group("point"):
		var p := n as Point
		if p.zone != "":
			zones.append(p.zone)
		if p.evenement != "":
			actions.append(p.evenement)
		if p.dialogue != "":
			dicibles.append(p.dialogue)
	for n in root.get_tree().get_nodes_in_group("passage"):
		var z: String = n.get("zone")
		if z != "":
			zones.append(z)
	for n in root.get_tree().get_nodes_in_group(Pnj.GROUPE):
		var pn := n as Pnj
		if pn.cle != "":
			dicibles.append(pn.cle)
	for source in Scenario.REMPLACEMENTS:
		for regle in Scenario.REMPLACEMENTS[source]:
			dicibles.append(str(regle[1]))
	# LES MEMES EXCEPTIONS QUE LE CONTROLE DE LA MISSION CHARGEE, et pour les
	# memes raisons : l'appel d'ouverture ne sort d'aucun personnage, le jeu le
	# compose ; et trois zones sont annoncees par le controleur lui-meme plutot
	# que par un passage pose dans une scene.
	dicibles.append("mission_tuco_appel")
	zones.append_array(["maison_walter", "maison_jesse", "albuquerque"])

	var dossier := DirAccess.open("res://donnees")
	if dossier == null:
		return
	for nom in dossier.get_files():
		if not nom.begins_with("mission") or not nom.ends_with(".json"):
			continue
		if mission.fichier.ends_with(nom):
			continue
		var lu: Variant = JSON.parse_string(
				FileAccess.get_file_as_string("res://donnees/" + nom))
		if typeof(lu) != TYPE_DICTIONARY:
			_verifier(false, "%s est illisible" % nom)
			continue
		var orphelins: Array[String] = []
		var etapes: Array = (lu as Dictionary).get("etapes", [])
		for e in etapes:
			var attendu := str((e as Dictionary).get("valide_par", ""))
			if attendu == "":
				continue
			var cle := str((e as Dictionary).get("cle", ""))
			var trouve := false
			if attendu.begins_with("dialogue:"):
				var conv := attendu.substr(9)
				trouve = dialogue.connait(conv) and dicibles.has(conv)
				if dialogue.connait(conv) and not dicibles.has(conv):
					printerr("  ECHEC %s : '%s' existe mais PERSONNE ne peut la dire"
							% [nom, conv])
			elif attendu.begins_with("zone:"):
				trouve = zones.has(attendu.substr(5))
			elif attendu.begins_with("objet:") or attendu.begins_with("action:"):
				trouve = actions.has(attendu)
			else:
				trouve = attendu in ["volant", "argent_cache"]
			if not trouve:
				orphelins.append("%s : %s attend '%s'" % [nom, cle, attendu])
		for o in orphelins:
			printerr("  ECHEC " + o + " — personne ne l'emet")
			_erreurs.append(o)
		_verifier(orphelins.is_empty(),
				"%s : ses %d etapes ont un emetteur" % [nom, etapes.size()])


# On joue la mission en annoncant, etape apres etape, l'evenement qu'elle
# declare attendre. Si elle arrive au bout, c'est qu'aucune etape n'attend
# quelque chose que rien n'emettra jamais.
#
# La derniere etape n'a pas d'evenement dans la table — c'est « argent_cache »,
# emis par la cachette — donc on s'arrete quand la liste est epuisee.
func _le_deroule(mission: Mission) -> void:
	print("\n--- la mission se deroule en entier ---")
	var garde := 0
	while not mission.finie() and garde < 60:
		garde += 1
		var attendu := str(mission.etape().get("valide_par", ""))
		var cle := mission.cle_etape()
		# UN CUL-DE-SAC EN PLEIN MILIEU EST UN BUG ; A LA FIN, C'EST LE FORMAT.
		#
		# « Une etape sans 'valide_par' ne se termine jamais toute seule : c'est
		# le cas de la derniere. » Le controle ne faisait pas la difference et
		# accusait la derniere etape de « Deux corps », qui rend la main au monde
		# ouvert et n'a rien a attendre. Celle de la mission de rodage en a un,
		# « argent_cache », donc le cas ne s'etait jamais presente.
		if attendu == "" and mission.derniere():
			print("       %-18s <- (fin, aucun evenement attendu)" % cle)
			break
		if attendu == "":
			_erreurs.append("l'etape '%s' n'attend aucun evenement" % cle)
			printerr("  ECHEC l'etape '%s' est un cul-de-sac" % cle)
			return
		if not mission.evenement(attendu):
			_erreurs.append("'%s' n'a pas fait avancer '%s'" % [attendu, cle])
			printerr("  ECHEC '%s' ne franchit pas '%s'" % [attendu, cle])
			return
		print("       %-18s <- %s" % [cle, attendu])
	# ARRIVER AU BOUT, C'EST ETRE FINIE **OU** ETRE SUR LA DERNIERE.
	#
	# Une mission dont la derniere etape n'attend rien ne se declare jamais
	# « finie » : elle rend la main au monde ouvert et s'arrete la. C'est le cas
	# de « Deux corps », et le controle la declarait bloquee alors qu'elle avait
	# parcouru ses dix-huit etapes sans accroc.
	_verifier(mission.finie() or mission.derniere(),
			"les %d etapes s'enchainent" % garde)
	# Un evenement de trop ne doit rien faire. Sans ce controle, une mission
	# terminee continuerait d'avancer dans le vide et le telephone afficherait
	# une etape qui n'existe pas.
	#
	# On l'eprouve avec un evenement que la mission courante ne connait pas :
	# celui de la mission de rodage ferait avancer la sienne d'une etape.
	_verifier(not mission.evenement("dialogue:_evenement_qui_n_existe_pas"),
			"et plus rien ne bouge une fois finie")
	_les_etapes_facultatives(mission)


## UNE ETAPE FACULTATIVE SE SAUTE-T-ELLE VRAIMENT ?
##
## Le deroule ci-dessus emet l'evenement de CHAQUE etape, l'une apres l'autre :
## il franchit donc les facultatives comme les autres et ne prouve rien. Si le
## saut etait debranche, il resterait vert — et le joueur qui ne trouve pas
## l'objet resterait bloque pour toujours, ce qui est exactement ce qui a ete
## livre en 0.56.0.
##
## On rejoue donc la mission en IGNORANT l'objet facultatif, et on exige que la
## mission arrive au bout quand meme.
func _les_etapes_facultatives(mission: Mission) -> void:
	var facultatives: Array[String] = []
	for e in mission.etapes():
		if bool((e as Dictionary).get("facultative", false)):
			facultatives.append(str((e as Dictionary).get("cle", "")))
	if facultatives.is_empty():
		return

	print("\n--- on peut finir sans les etapes facultatives ---")
	mission.recommencer()
	var garde := 0
	var sautees := 0
	while not mission.finie() and not mission.derniere() and garde < 60:
		garde += 1
		var cle := mission.cle_etape()
		var attendu := str(mission.etape().get("valide_par", ""))
		# ON NE RAMASSE PAS : on annonce l'evenement de l'etape SUIVANTE, comme
		# un joueur qui passe devant sans voir.
		if facultatives.has(cle):
			var i := mission.index() + 1
			if i >= mission.etapes().size():
				break
			var apres := str((mission.etapes()[i] as Dictionary).get("valide_par", ""))
			if not mission.evenement(apres):
				printerr("  ECHEC '%s' est facultative mais ne se saute pas" % cle)
				_erreurs.append("facultative %s" % cle)
				return
			sautees += 1
			continue
		if not mission.evenement(attendu):
			break
	_verifier(sautees == facultatives.size() and (mission.finie() or mission.derniere()),
			"les %d etape(s) facultative(s) se sautent et la mission va au bout"
					% facultatives.size())
	mission.recommencer()


# Chaque cle citee par la mission doit exister QUELQUE PART.
#
# C'est le controle qui rattrape les fautes de frappe. Une conversation
# manquante ne fait rien planter : le personnage est simplement muet, la
# mission ne s'en apercoit jamais, et on cherche pendant vingt minutes
# pourquoi Jesse ne repond pas.
func _les_cles(mission: Mission, dialogue: Dialogue,
		equipement: Equipement) -> void:
	print("\n--- tout ce que la mission nomme existe ---")
	var manquants: Array[String] = []
	for e in mission.etapes():
		var attendu := str((e as Dictionary).get("valide_par", ""))
		if attendu.begins_with("dialogue:"):
			var cle := attendu.substr(9)
			if not dialogue.connait(cle):
				manquants.append("conversation '%s'" % cle)
		elif attendu.begins_with("objet:"):
			var obj := attendu.substr(6)
			# On demande a l'equipement de le DONNER : c'est la seule facon de
			# savoir qu'il est dans outils.json ET que son modele existe.
			if not equipement.donner(obj) and not equipement.possede(obj):
				manquants.append("objet '%s'" % obj)
	for m in manquants:
		printerr("  ECHEC %s introuvable" % m)
		_erreurs.append(m)
	_verifier(manquants.is_empty(),
			"les %d etapes citent des cles qui existent" % mission.etapes().size())

	# Les points d'interaction accroches a une etape : si l'etape n'existe pas,
	# le point ne s'affichera JAMAIS, sans que rien ne le dise.
	#
	# ON NE MESURE QUE LES POINTS VISIBLES. Depuis le 16/08/2026, les decors
	# d'une autre mission vivent dans le monde et s'y masquent — voir
	# mission_attendue dans ancrage.gd. Leurs points citent les etapes de LEUR
	# deroule, qui n'existent evidemment pas dans celui-ci, et le controle
	# accusait alors une scene parfaitement saine.
	#
	# Le critere qui les separe est deja la : point.gd refuse d'offrir un point
	# invisible, c'est son premier controle. Ce qui est masque n'est de toute
	# facon jamais propose au joueur.
	var etapes: Array[String] = []
	for e in mission.etapes():
		etapes.append(str((e as Dictionary).get("cle", "")))
	var orphelins := 0
	var dormants := 0
	var points := root.get_tree().get_nodes_in_group("point")
	for n in points:
		var p := n as Point
		if p.etape == "" or etapes.has(p.etape):
			continue
		if not p.is_visible_in_tree():
			dormants += 1
			continue
		printerr("  ECHEC le point '%s' attend l'etape '%s', qui n'existe pas"
				% [p.name, p.etape])
		_erreurs.append("point %s" % p.name)
		orphelins += 1
	print("       %d point(s) d'interaction dans le monde" % points.size())
	if dormants > 0:
		print("       dont %d dans un decor d'une autre mission, masque" % dormants)
	_verifier(points.size() >= 6, "les points de la mission sont poses")
	_verifier(orphelins == 0, "et aucun n'attend une etape inexistante")


# La regle de la derniere etape : on ne sort pas de chez soi avec plus de dix
# mille dollars. C'est le seul verrou du jeu qui porte sur un NOMBRE, et il
# est facile de le poser a l'envers.
func _la_cachette(mission: Mission, bourse: Bourse) -> void:
	print("\n--- la cachette ---")
	var plafond := mission.reste_maximum()
	bourse.poser(300000)
	var scenario := _trouver(_monde, "Scenario") as Scenario
	if scenario == null:
		printerr("  ECHEC scenario introuvable")
		_erreurs.append("scenario")
		return
	# On se remet a l'etape « cacher » : le refus n'existe qu'a ce moment-la,
	# sinon on ne pourrait plus jamais ressortir de chez soi de toute la partie.
	mission.recommencer()
	while not mission.a_l_etape("cacher") and not mission.finie():
		if not mission.evenement(str(mission.etape().get("valide_par", ""))):
			break
	_verifier(mission.a_l_etape("cacher"), "on atteint la derniere etape")
	_verifier(scenario.refus_de_sortie() != "",
			"avec %s en poche, la porte refuse" % Bourse.ecrire(300000))

	bourse.poser(plafond - 1)
	_verifier(scenario.refus_de_sortie() == "",
			"avec %s, elle s'ouvre" % Bourse.ecrire(plafond - 1))
	print("       plafond : %s" % Bourse.ecrire(plafond))


# LA MISSION NE S'ARRETE PAS, ELLE SE TERMINE.
#
# La replique « mission_fin » etait ecrite dans dialogues.json et doublee depuis
# des versions, et appelee de NULLE PART : la mission finissait sur un bandeau
# en capitales, c'est-a-dire sur du vocabulaire de jeu. Ce controle existe pour
# qu'elle ne se retrouve pas debranchee une seconde fois sans que rien ne le
# dise.
#
# On ne declenche PAS la conversation nous-memes : on finit la mission et on
# laisse le scenario tourner, exactement comme en jouant. Sans le branchement,
# le dialogue reste inactif et cette ligne passe au rouge — verifie en
# commentant l'appel.
func _le_mot_de_la_fin(mission: Mission, dialogue: Dialogue) -> void:
	print("\n--- le mot de la fin ---")
	var scenario := _trouver(_monde, "Scenario") as Scenario
	var controleur := _trouver(_monde, "Controleur")
	if scenario == null or controleur == null:
		_erreurs.append("scenario ou controleur introuvable")
		return

	mission.recommencer()
	while not mission.finie():
		if not mission.evenement(str(mission.etape().get("valide_par", ""))):
			break
	_verifier(mission.finie(), "la mission va jusqu'a son terme")

	# Le bandeau « MISSION ACCOMPLIE » tient neuf secondes et Walter attend qu'il
	# s'efface. On le vide plutot que d'attendre : c'est la seule chose que le
	# temps apporterait ici.
	controleur.call("annoncer", "")
	for i in 12:
		scenario.traiter(0.1)

	_verifier(dialogue.actif(), "Walter a le mot de la fin")
	_verifier(dialogue.cle_courante() == "mission_fin",
			"et c'est bien la replique de fin ('%s')" % dialogue.cle_courante())


func _point_nomme(nom: String) -> Point:
	for n in _monde.get_tree().get_nodes_in_group(Point.GROUPE):
		if n.name == nom:
			return n as Point
	return null


# LES COURSES : ACHETER N'EST PAS LA RECOMPENSE, RENTRER AVEC L'EST.
#
# L'epicerie donnait dix points de famille sur place, sans rien prelever et sans
# rien remettre : on pouvait appuyer en boucle devant le comptoir et monter la
# famille a cent sans bouger. Le compteur devenait une manivelle.
#
# Ce controle verrouille la dissociation — le magasin VEND, la cuisine COMPTE —
# et surtout la ligne qui casse tout si on la reecrit : tant que l'evenement de
# l'epicerie figure dans Famille.GAINS, Famille se rebranche dessus toute seule.
# C'est une mecanique generique, et c'est precisement ce qui la rend facile a
# reactiver sans le vouloir.
func _les_courses(equipement: Equipement, dialogue: Dialogue) -> void:
	print("\n--- les courses ---")
	var epicerie := _point_nomme("Courses")
	var plan := _point_nomme("PlanDeTravail")
	_verifier(epicerie != null, "l'epicerie a son point d'interaction")
	_verifier(plan != null, "la cuisine a son plan de travail")
	if epicerie == null or plan == null:
		return

	_verifier(epicerie.coute > 0,
			"faire les courses coute quelque chose ($%d)" % epicerie.coute)
	_verifier(epicerie.donne == "oeufs", "et rend une boite d'oeufs")
	_verifier(epicerie.son != "", "avec un son au comptoir ('%s')" % epicerie.son)
	_verifier(not Famille.GAINS.has(epicerie.evenement),
			"l'epicerie ne credite plus la famille ('%s')" % epicerie.evenement)

	var famille := _trouver(_monde, "Famille") as Famille
	var scenario := _trouver(_monde, "Scenario") as Scenario
	if famille == null or scenario == null:
		_verifier(false, "la famille et le scenario repondent")
		return

	# On pose l'inventaire et le compteur a la main : ce test mesure la
	# MECANIQUE, pas les deux cent quatre-vingts metres de trajet.
	equipement.donner("oeufs")
	famille.poser(50)
	_verifier(scenario.poser_les_courses(), "on pose la boite sur le plan de travail")
	_verifier(not equipement.possede("oeufs"), "elle quitte l'inventaire")
	_verifier(famille.points() > 50,
			"et la famille monte (50 -> %d)" % famille.points())

	# LES MAINS VIDES, ET DEUX FOIS DE SUITE. C'est le geste qu'on martelait a
	# l'epicerie : il ne doit rien produire, quel que soit le nombre d'appuis.
	var avant := famille.points()
	_verifier(not scenario.poser_les_courses(), "les mains vides, le geste ne prend pas")
	scenario.poser_les_courses()
	_verifier(famille.points() == avant,
			"et rien ne monte, meme repete (%d)" % famille.points())

	# ON NE PEUT PAS OUVRIR DE CONVERSATION ICI — voir poser_les_courses(). On
	# verifie donc que les deux reponses de Skyler EXISTENT ; laquelle se joue
	# est decide par point_utilise, juste au-dessus, en une ligne.
	_verifier(dialogue.connait("skyler_courses_oui"),
			"Skyler a une reponse quand on a pense a elle")
	_verifier(dialogue.connait("skyler_courses_non"),
			"et une autre quand on a oublie")


# CUISINER, LIVRER, ETRE PAYE, RECOMMENCER.
#
# Le puits economique hors mission. Ce qui se mesure : que le cycle EXISTE en
# entier — un atelier qui resserve apres la mission, un acheteur qui ne se
# propose que si l'on a de quoi vendre, et un prix qui suit la purete.
#
# LE PRIX EST LE POINT QUI COMPTE. Rien ne l'affiche au joueur : c'est en
# comparant deux livraisons qu'il doit sentir que la qualite se paie. Si les
# deux paliers rapportaient pareil, la purete deviendrait un chiffre decoratif
# et personne ne s'en apercevrait avant des semaines.
func _le_puits(equipement: Equipement, bourse: Bourse) -> void:
	print("\n--- cuisiner, livrer, recommencer ---")
	var atelier := _point_nomme("AtelierLibre")
	var contact := _point_nomme("Livrer")
	_verifier(atelier != null, "l'atelier resserre une fois la mission finie")
	_verifier(contact != null, "et il y a quelqu'un a qui vendre")
	if atelier == null or contact == null:
		return

	_verifier(atelier.donne == "meth", "l'atelier rend de la marchandise")
	_verifier(not atelier.une_fois, "et il ne s'epuise pas")
	_verifier(contact.exige == "meth",
			"l'acheteur ne se propose que si l'on porte de quoi vendre")

	var scenario := _trouver(_monde, "Scenario") as Scenario
	var purete := _trouver(_monde, "Purete") as Purete
	if scenario == null or purete == null:
		_verifier(false, "le scenario et la purete repondent")
		return

	# LES MAINS VIDES, ON NE VEND RIEN. Sans ce garde, appuyer sur un acheteur
	# sans marchandise creditait le prix de base : de l'argent gratuit.
	#
	# On retire explicitement : les controles precedents manipulent l'inventaire,
	# et un test qui suppose l'etat laisse par le test d'avant se met a dependre
	# de leur ordre.
	equipement.retirer("meth")
	bourse.poser(0)
	scenario.livrer_la_marchandise()
	_verifier(bourse.montant() == 0, "les mains vides, livrer ne rapporte rien")

	# Au palier 1, puis au palier 5 : le meme geste, deux prix.
	purete.poser(1)
	equipement.donner("meth")
	scenario.livrer_la_marchandise()
	var brun := bourse.montant()
	_verifier(brun > 0, "livrer du brun paie (%d $)" % brun)
	_verifier(not equipement.possede("meth"), "et la marchandise part")

	bourse.poser(0)
	purete.poser(5)
	equipement.donner("meth")
	scenario.livrer_la_marchandise()
	var bleu := bourse.montant()
	_verifier(bleu > brun,
			"et livrer du bleu paie davantage (%d contre %d)" % [bleu, brun])


# L'APPEL DE SKYLER, PENDANT QU'ON ROULE VERS LE DESERT.
#
# Ce qui se mesure ici : qu'il soit branche sur la bonne etape, que raccrocher
# coute, et surtout QUE LES VARIANTES DE DIALOGUE FASSENT AVANCER LA MISSION.
#
# Ce dernier point est le seul qui pouvait tout casser en silence.
# dialogue_fini() emet « dialogue:<cle> » : jouer la version de Jesse avec les
# oeufs emettait une cle inconnue de la mission, donc l'etape « jesse_dehors »
# ne passait plus. Prendre les courses aurait BLOQUE la mission 1, et le
# symptome serait apparu trois ecrans plus loin, sans rapport visible avec les
# oeufs.
#
# On ne DECLENCHE pas l'appel ici : decrocher ouvre une conversation, et une
# conversation ne s'ouvre pas dans cette suite — voir le piege 22.
func _l_appel(dialogue: Dialogue) -> void:
	print("\n--- l'appel de Skyler ---")
	var appel := _trouver(_monde, "AppelSkyler") as Appel
	_verifier(appel != null, "l'appel est pose dans la scene")
	if appel == null:
		return

	_verifier(appel.etape == "camping",
			"il tombe a l'etape '%s' — le trajet vers le desert" % appel.etape)
	_verifier(dialogue.connait(appel.conversation),
			"et sa conversation existe ('%s')" % appel.conversation)
	_verifier(appel.apres_secondes > 0.0,
			"il attend %.0f s de conduite" % appel.apres_secondes)

	var famille := _trouver(_monde, "Famille") as Famille
	if famille != null and appel.cout_ignore > 0:
		famille.poser(50)
		appel.sonner_maintenant()
		appel.raccrocher()
		_verifier(famille.points() == 50 - appel.cout_ignore,
				"raccrocher sans repondre coute %d (50 -> %d)"
						% [appel.cout_ignore, famille.points()])

	# LES DEUX FACONS DE VOIR LA BOITE D'OEUFS.
	_verifier(dialogue.connait("mission_jesse_camping_oeufs"),
			"Jesse a une version ou il voit les courses")
	_verifier(dialogue.connait("mission_tuco_vente_oeufs"),
			"Tuco aussi")
	_verifier(Scenario.VARIANTES.get("mission_jesse_camping_oeufs", "")
					== "mission_jesse_camping",
			"celle de Jesse fait avancer la mission comme l'originale")
	_verifier(Scenario.OUVERTURES.get("mission_tuco_vente_oeufs", "")
					== "mission_tuco_vente",
			"celle de Tuco enchaine sur la vraie vente au lieu de la remplacer")
	_verifier(Reputation.PERTES.has("retard"),
			"et arriver en retard a un prix (%d)" % int(Reputation.PERTES.get("retard", 0)))
