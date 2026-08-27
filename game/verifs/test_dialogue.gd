# Verifie les habitants et le deroulement d'une conversation.
#
#   godot --headless --path game --script res://verifs/test_dialogue.gd
#
# Le dialogue lit un fichier JSON. Une virgule en trop et tout le monde
# devient muet, sans qu'aucune autre partie du jeu ne signale quoi que ce
# soit — la maison s'ouvre, le personnage est la, il n'a simplement rien a
# dire. Ce test regarde le contenu reellement charge.
extends SceneTree

const POSE := 45

var _n := 0
var _c: Node
var _d: Node
var _j: CharacterBody3D
var _maisons: Array = []
var _erreurs: Array[String] = []


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


func _verifier(ok: bool, msg: String) -> void:
	if ok:
		print("  ok   " + msg)
	else:
		_erreurs.append(msg)
		printerr("  ECHEC " + msg)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


## LE SEUL VRAI CHOIX DU JEU, ET CE QU'IL FAUT LUI DEMANDER.
##
## Il a existe pendant des semaines sous une forme qui n'en etait pas une : les
## deux repliques s'enchainaient, Walter refusait toujours, et rien ne le
## signalait — le fichier de dialogue avait l'air complet, la scene se jouait,
## l'etape avancait. C'est le genre de defaut qu'aucune verification de PRESENCE
## n'attrape, puisque tout etait bien present.
##
## On mesure donc le COMPORTEMENT, et surtout la chose qui distingue un choix
## d'un texte : DEUX OPTIONS MENENT A DEUX RESULTATS DIFFERENTS. Un menu qui
## s'affiche joliment et retombe sur le meme etat n'est pas un choix, c'est une
## decoration — et c'est exactement l'etat d'avant, avec une interface en plus.
func _le_micro_choix() -> void:
	print("\n--- le micro-choix de la cuisine ---")
	var purete := _trouver(root, "Purete")
	if purete == null:
		_verifier(false, "la purete est introuvable")
		return

	var vus: Array[int] = []
	for option in 2:
		purete.call("poser", 1)
		_verifier(_d.call("demarrer", "cuisine_raccourci"),
				"la conversation du raccourci s'ouvre (option %d)" % option)
		# Jesse propose, puis on tombe sur le choix.
		var tours := 0
		while _d.call("actif") and not _d.call("en_choix") and tours < 20:
			_d.call("avancer")
			tours += 1
		_verifier(_d.call("en_choix"),
				"le jeu s'arrete et attend une reponse (option %d)" % option)
		_verifier((_d.call("invite") as String).contains("Repondre"),
				"l'invite dit comment repondre (option %d)" % option)

		# On descend jusqu'a l'option voulue, puis on tranche.
		for _i in option:
			_d.call("descendre_dans_le_choix")
		_d.call("avancer")
		_verifier(not _d.call("en_choix"),
				"repondre referme le choix (option %d)" % option)
		var borne := 0
		while _d.call("actif") and borne < 20:
			_d.call("avancer")
			borne += 1
		vus.append(int(purete.call("palier")))

	_verifier(vus.size() == 2 and vus[0] != vus[1],
			"les deux reponses ne donnent pas la meme fournee (paliers %s)" % str(vus))


func _process(_delta: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	_c = _trouver(root, "Controleur")
	_d = _trouver(root, "Dialogue")
	_j = _trouver(root, "Joueur") as CharacterBody3D
	var racine := _trouver(root, "Maisons")
	if _c == null or _d == null or _j == null or racine == null:
		printerr("noeuds introuvables")
		quit(1)
		return true
	_maisons = racine.get_children()

	print("--- habitants ---")
	for m in _maisons:
		var p = m.habitant()
		_verifier(p != null, "%s a un habitant" % m.nom_affiche)
		if p == null:
			continue
		var nom: String = _d.call("nom_de", p.cle)
		print("       %-8s habitant '%s' (%s)" % [m.nom_affiche, p.cle, nom])
		# Un habitant plante a l'origine de la maison au lieu du repere, c'est
		# le signe que le repere Habitant est perdu, comme l'a ete le Seuil.
		var d: float = p.global_position.distance_to(m.place_habitant())
		_verifier(d < 0.5, "%s : il est bien sur son repere" % m.nom_affiche)
		# Une cle absente du JSON ne se voit qu'en essayant de parler.
		_verifier(_d.call("connait", p.cle),
				"%s : sa cle existe dans dialogues.json" % m.nom_affiche)

	print("--- une conversation ---")
	var pnj = _maisons[0].habitant()
	_verifier(not _d.call("actif"), "aucune conversation au repos")
	_verifier(_d.call("demarrer", pnj.cle), "la conversation s'ouvre")
	_verifier(_d.call("actif"), "elle est marquee active")

	var cadre := _trouver(root, "CadreDialogue") as Control
	_verifier(cadre != null and cadre.visible, "le cadre est affiche")
	var texte := _trouver(root, "Texte") as Label
	_verifier(texte != null and texte.text.length() > 0,
			"une replique est affichee : \"%s\"" % (texte.text if texte else ""))

	# On deroule jusqu'au bout. La borne evite la boucle infinie si avancer()
	# cesse un jour de terminer.
	var tours := 0
	while _d.call("actif") and tours < 40:
		_d.call("avancer")
		tours += 1
	_verifier(tours < 40, "elle se termine (%d repliques)" % tours)
	_verifier(cadre != null and not cadre.visible, "le cadre se referme")

	# Reparler doit donner autre chose : sinon les PNJ radotent, et c'est ce
	# qui fait le plus vite sentir qu'un monde est vide.
	var premiere := texte.text
	_d.call("demarrer", pnj.cle)
	var deuxieme := texte.text
	while _d.call("actif"):
		_d.call("avancer")
	_verifier(premiere != deuxieme,
			"la deuxieme visite dit autre chose (\"%s\")" % deuxieme)

	_le_micro_choix()
	_jesse_ne_radote_pas()

	print("")
	if _erreurs.is_empty():
		print("TEST DIALOGUE OK")
		quit(0)
	else:
		printerr("TEST DIALOGUE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true

# JESSE NE REDIT PAS « BIENVENUE DANS LE BUREAU » PENDANT TOUTE LA CUISINE.
#
#   « Bug : en parlant plusieurs fois a Jesse dans le RV ca fini par lancer le
#     dialogue d'avant "this is your office..." » — retour du 23/08/2026.
#
# Son noeud porte UNE cle, « cuisine_arrivee », et c'est la table
# REMPLACEMENTS de systemes/scenario.gd qui la remplace selon l'etape. Deux
# etapes sur neuf y figuraient : entre les deux, il rejouait son accueil.
#
# CE CONTROLE PART DE LA MISSION VERS LA TABLE, et pas l'inverse. C'est le sens
# qui trouve les manques : une regle en trop se voit tout de suite en jouant,
# une etape oubliee ne se voit qu'en parlant a Jesse au bon moment, ce que
# personne ne fait deux fois. Piege 56.
#
# Les etapes visees sont celles qui portent « clos » — le champ qui dit qu'on
# les joue A L'INTERIEUR du camping-car. C'est exactement la definition de
# « pendant la cuisine », et elle vient du fichier de mission plutot que d'une
# liste recopiee ici qui perimerait a la premiere etape ajoutee.
func _jesse_ne_radote_pas() -> void:
	print("\n--- Jesse repond selon l'etape, pendant toute la cuisine ---")

	var brut := FileAccess.get_file_as_string("res://donnees/mission_deux_corps.json")
	var lu: Variant = JSON.parse_string(brut)
	if typeof(lu) != TYPE_DICTIONARY:
		_verifier(false, "mission_deux_corps.json illisible")
		return
	var etapes: Array = (lu as Dictionary).get("etapes", [])
	_verifier(not etapes.is_empty(), "la mission a des etapes")

	var regles: Array = Scenario.REMPLACEMENTS.get("cuisine_arrivee", [])
	var couvertes := {}
	for regle in regles:
		couvertes[str((regle as Array)[0])] = str((regle as Array)[1])

	var oubliees: Array[String] = []
	var sans_fiche: Array[String] = []
	var closes := 0
	for e in etapes:
		var etape := e as Dictionary
		if not bool(etape.get("clos", false)):
			continue
		closes += 1
		var cle := str(etape.get("cle", ""))
		if not couvertes.has(cle):
			oubliees.append(cle)
			continue
		# Une regle qui vise une fiche inexistante est pire qu'une regle
		# absente : demarrer() rend faux, et le controleur n'affiche meme plus
		# « Parler a Jesse ». Le personnage devient MUET au lieu de radoter.
		if not _d.call("connait", couvertes[cle]):
			sans_fiche.append("%s -> %s" % [cle, couvertes[cle]])

	_verifier(closes > 0, "%d etape(s) se jouent dans le camping-car" % closes)
	_verifier(oubliees.is_empty(),
			"chacune dit a Jesse quoi repondre (oubliees : %s)"
			% ("aucune" if oubliees.is_empty() else ", ".join(oubliees)))
	_verifier(sans_fiche.is_empty(),
			"et chaque reponse existe dans dialogues.json (%s)"
			% ("toutes" if sans_fiche.is_empty() else ", ".join(sans_fiche)))
