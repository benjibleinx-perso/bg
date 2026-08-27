# Verifie que les passants marchent vraiment.
#
#   godot --headless --path game --script res://verifs/test_foule.gd
#
# Un passant coince contre une poubelle a l'air parfaitement normal sur une
# capture : il est debout, au bon endroit, correctement texture. Il ne bouge
# simplement jamais. La seule facon de le voir est de mesurer un deplacement
# entre deux instants.
extends SceneTree

# ON NE SUPPOSE PLUS LA TRAME, ON LIT LA HAUTEUR DU SOL.
#
# Ce test declarait PAS = 54 et ROUTE = 8 « devant correspondre a
# gen_ville.py », qui disait 57 et 11 depuis des semaines. Pire : depuis la
# trame irreguliere du 31/07/2026, des ilots de 30 a 64 m, AUCUN pas fixe ne
# peut decrire la ville. Le compteur « au milieu d'un carrefour » calculait
# donc un modulo sur une grille qui n'existe pas.
#
# La hauteur, elle, ne se suppose pas : un passant repose sur ce qu'il y a
# sous lui. Trottoir a 0,18 m, chaussee a 0,01 m, sable du desert a -0,05 m.
# Un seul nombre, vrai quelle que soit la trame.
const H_TROTTOIR := 0.18
const MARGE := 0.05

## En dessous, ce n'est plus « pas sur le trottoir », c'est reellement passe au
## travers du decor. Les deux ne se corrigent pas au meme endroit, donc ils ne
## se comptent pas ensemble — c'est ce melange qui a fait lire « 12 passants
## sous la carte » alors qu'aucun n'etait tombe.
const SOUS_LA_CARTE := -0.5

const POSE := 30
const MARCHE := 110          # environ deux secondes
const ECOUTE := 40           # de quoi laisser un pas sortir sur le bus
const RENCONTRE := 150       # deux tours de detection, qui passe a 1 Hz

var _n := 0
var _etape := 0
var _foule: Node
var _avant: Array[Vector3] = []
var _erreurs: Array[String] = []
var _audio: Node
var _avant_lecteurs := 0
var _saluts_avant := 0


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


func _maillages(n: Node) -> Array[MeshInstance3D]:
	var trouves: Array[MeshInstance3D] = []
	if n is MeshInstance3D:
		trouves.append(n as MeshInstance3D)
	for e in n.get_children():
		trouves.append_array(_maillages(e))
	return trouves


func _sur_le_trottoir(y: float) -> bool:
	return absf(y - H_TROTTOIR) <= MARGE


func _process(_d: float) -> bool:
	_n += 1

	if _etape == 0:
		if _n < POSE:
			return false
		_foule = _trouver(root, "Foule")
		if _foule == null:
			printerr("noeud Foule introuvable")
			quit(1)
			return true

		var n := _foule.get_child_count()
		print("--- les passants ---")
		# LA FOULE PEUT ETRE DESACTIVEE, et ce n'est pas une panne.
		#
		# Elle est a 26 dans monde.tscn depuis le 08/08/2026, mais le defaut de
		# foule.gd reste ZERO : la ville se travaille seule, et les outils qui
		# isolent son cout appellent repeupler(0). Un test qui echoue pour un
		# reglage volontaire est un test qu'on apprend a ignorer, et c'est pire
		# que pas de test.
		if n == 0:
			print("  --   foule desactivee (combien = 0), rien a verifier")
			print("")
			print("TEST FOULE OK")
			quit(0)
			return true
		_verifier(n > 0, "%d passant(s) crees" % n)

		# LE CORPS ET LA DEMARCHE, SANS RIEN SUPPOSER DU MODELE.
		#
		# Ce test cherchait un noeud nomme « Bassin » et un autre nomme « Tete ».
		# C'etait juste tant que les passants etaient des boites assemblees ;
		# depuis qu'ils sont les figurants du pack, ce sont des maillages a
		# squelette et ces noms n'existent plus. Le test tombait au rouge alors
		# que la rue etait plus belle qu'avant.
		#
		# On verifie donc ce qui compte vraiment et qui vaut pour les deux : il y
		# a quelque chose a voir, et il y a de quoi l'animer.
		var modeles := {}
		var sans_demarche := 0
		for p in _foule.get_children():
			_avant.append((p as Node3D).global_position)
			var maillages := _maillages(p)
			_verifier(not maillages.is_empty(), "%s a bien un corps" % p.name)
			# Un squelette avec ses clips, ou des segments animes par le code.
			# Sans l'un des deux, le passant traverse la rue en glissant.
			var anime: bool = p.find_child("AnimationPlayer", true, false) != null 					or p.find_child("Bassin", true, false) != null
			if not anime:
				sans_demarche += 1
			for mi in maillages:
				if mi.mesh != null:
					modeles[mi.mesh.get_rid()] = true
		_verifier(sans_demarche == 0,
				"tous savent marcher (%d sans demarche)" % sans_demarche)
		_verifier(modeles.size() >= 2,
				"%d maillage(s) different(s) dans la rue" % modeles.size())

		# ON SE MET A PORTEE AVANT DE LES ECOUTER MARCHER.
		#
		# La foule se recycle autour du joueur, et selon l'endroit ou la scene
		# le depose — la mission 1 s'ouvre dans le salon — aucun passant n'est
		# forcement a portee d'oreille. On amene donc le joueur dans la rue.
		# Le geste reproduit est « je marche a cote de quelqu'un », pas « je
		# peux l'atteindre » : cette seconde question est celle du placement,
		# verifiee plus bas et independamment.
		var joueur := _trouver(root, "Joueur") as Node3D
		var p0 := _foule.get_child(0) as Node3D
		if joueur != null:
			joueur.global_position = p0.global_position + Vector3(2.0, 0.0, 0.0)
		_audio = root.get_tree().get_first_node_in_group("audio")
		_verifier(_audio != null, "noeud Audio present")
		_avant_lecteurs = _lecteurs(_audio)

		_etape = 1
		_n = 0
		return false

	if _etape == 3:
		# Deux tours de detection : elle ne passe qu'une fois par seconde.
		if _n < RENCONTRE:
			return false
		var faits := int(_foule.get("saluts")) - _saluts_avant
		print("       rencontres detectees : %d" % faits)
		_verifier(faits > 0, "deux passants qui se croisent s'arretent")
		if faits > 0:
			var a := _foule.get_child(0) as Node3D
			var b := _foule.get_child(1) as Node3D
			# Ils doivent se REGARDER, pas seulement s'immobiliser. L'avant d'un
			# noeud Godot est -Z, d'ou la negation.
			var vers_b := (b.global_position - a.global_position)
			vers_b.y = 0.0
			var regarde := (-a.global_transform.basis.z)
			regarde.y = 0.0
			var angle := rad_to_deg(regarde.normalized().angle_to(vers_b.normalized()))
			print("       il regarde a %.0f deg de l'autre" % angle)
			_verifier(angle < 35.0, "et il se tourne vers celui qu'il croise")
		return _conclure()

	if _n < MARCHE:
		return false

	print("--- deux secondes plus tard ---")
	var immobiles := 0
	var hors_trottoir := 0
	var tombes := 0
	var parcours := 0.0

	for i in _foule.get_child_count():
		var p := _foule.get_child(i) as Node3D
		# ON MESURE CE QUI A ETE MARCHE, PAS L'ECART ENTRE DEUX POSITIONS.
		#
		# La foule se recycle autour du joueur depuis le 30/07/2026 : un passant
		# trop loin est repose sur une rue proche. Comparer deux positions
		# compterait ce saut comme cent metres de marche, et un passant coince
		# contre une poubelle juste apres avoir ete replace passerait pour le
		# plus actif de la rue.
		var d: float = (p as Pieton).parcouru if p is Pieton \
				else _avant[i].distance_to(p.global_position)
		parcours += d
		if d < 0.4:
			immobiles += 1
			printerr("       %s n'a pas bouge (%s)" % [p.name, str(p.global_position.round())])
		var y := p.global_position.y
		if y < SOUS_LA_CARTE:
			tombes += 1
		elif not _sur_le_trottoir(y):
			hors_trottoir += 1
			printerr("       %s marche a %.2f m, pas sur un trottoir (%s)"
					% [p.name, y, str(p.global_position.round())])

	print("       distance moyenne parcourue : %.2f m"
			% (parcours / maxf(1.0, _foule.get_child_count())))
	_verifier(immobiles == 0, "aucun passant coince (%d)" % immobiles)
	_verifier(tombes == 0, "aucun n'est passe sous la carte (%d)" % tombes)
	_verifier(hors_trottoir == 0,
			"tous marchent sur un trottoir (%d ailleurs)" % hors_trottoir)

	# LE SON DES PAS : ON COMPTE LES LECTEURS NES PENDANT LA MARCHE.
	#
	# Deux versions de cette mesure ont valide alors que le signal etait
	# DEBRANCHE, et chacune pour sa propre raison. Verifie les deux fois en
	# commentant la connexion, le 08/08/2026 :
	#
	#   1. La crete du bus « Effets » : il est partage, il portait -14,3 dB
	#      d'autre chose. Le seuil de -60 dB ne pouvait pas ne pas passer.
	#   2. Appeler `_poser_le_pied()` a la main : ca court-circuite justement le
	#      signal dont on veut savoir s'il est connecte. On testait la methode,
	#      pas le branchement.
	#
	# Ici, personne n'appelle rien : les passants marchent, et on regarde si
	# `Audio` a fabrique des lecteurs. Sans connexion, il n'en nait aucun.
	if _audio != null:
		var apparus := _lecteurs(_audio) - _avant_lecteurs
		_verifier(apparus > 0,
				"on entend marcher les passants (%d pas joue(s) en 2 s)" % apparus)
		# Le volume attendu se CALCULE, il ne se recopie pas : le gain du
		# mecanisme vient de sons.json, la discretion du passant de
		# reglages.tres. Les deux se reglent a l'oreille, et un test qui repete
		# leur valeur devient faux au premier reglage.
		if apparus > 0:
			var regl: Reglages = (_foule.get_child(0) as Pieton).reglages
			var attendu: float = float(_audio.call("gain_de", "pas_exterieur")) \
					+ regl.pas_passant_gain
			var joue := _dernier_volume(_audio)
			print("       volume d'un pas : %.1f dB (attendu %.1f)" % [joue, attendu])
			_verifier(absf(joue - attendu) < 0.01,
					"ils marchent au volume declare, pas a celui du joueur")

	# ON CONSTRUIT LA RENCONTRE, ET ON LAISSE LA FOULE LA TROUVER SEULE.
	#
	# Une rencontre est rare par construction — un croisement sur cinq — et la
	# detection ne tourne qu'une fois par seconde. L'attendre au hasard donnerait
	# un test qui echoue un jour sur trois, c'est-a-dire un test qu'on apprend a
	# ignorer.
	#
	# On met donc deux passants face a face et on monte la probabilite a 1. Ce
	# qu'on N'appelle PAS, c'est `_rencontres()` : c'est justement la chaine
	# qu'on veut voir fonctionner, du `_process` de la foule jusqu'a l'arret du
	# passant. Sans elle, le compteur reste a zero. Piege 32.
	print("--- deux passants se croisent ---")
	var regl: Reglages = (_foule.get_child(0) as Pieton).reglages
	regl.salut_proba = 1.0
	# ON ELARGIT LA PORTEE DU SALUT LE TEMPS DE LA MESURE, et c'est ce qui
	# manquait : la detection ne tourne qu'UNE FOIS PAR SECONDE, et les deux
	# passants etaient poses a 1,76 m l'un de l'autre — a 1,2 m/s chacun, ils
	# se croisaient et se depassaient en sept dixiemes de seconde. Le tick
	# tombait apres, sur deux passants qui s'eloignaient deja, et le compteur
	# restait a zero.
	#
	# La suite accusait donc le jeu de ne plus faire se saluer personne. Elle
	# mesurait en realite un rendez-vous manque de trois dixiemes de seconde.
	#
	# Elargir la portee est du meme ordre que forcer la probabilite a 1 : on
	# rend l'evenement CERTAIN, on n'appelle toujours pas `_rencontres()` —
	# c'est la chaine qu'on veut voir fonctionner (piege 32).
	regl.salut_distance = 8.0
	var a := _foule.get_child(0) as Pieton
	var b := _foule.get_child(1) as Pieton
	var base := a.global_position
	b.global_position = base + Vector3(5.0, 0.0, 0.0)
	# ILS SE DEPASSENT AU LIEU DE S'ARRETER L'UN SUR L'AUTRE : chacun vise
	# cinq metres DERRIERE l'autre. Un passant arrive a destination a une
	# vitesse nulle, et la detection exige que les deux soient en mouvement.
	a.arrivee = base + Vector3(10.0, 0.0, 0.0)
	b.arrivee = base - Vector3(5.0, 0.0, 0.0)
	a.set("_vers_arrivee", true)
	b.set("_vers_arrivee", true)
	_saluts_avant = int(_foule.get("saluts"))
	_etape = 3
	_n = 0
	return false


func _lecteurs(audio: Node) -> int:
	var n := 0
	for e in audio.get_children():
		if e is AudioStreamPlayer3D:
			n += 1
	return n


func _dernier_volume(audio: Node) -> float:
	for i in range(audio.get_child_count() - 1, -1, -1):
		var e := audio.get_child(i)
		if e is AudioStreamPlayer3D:
			return (e as AudioStreamPlayer3D).volume_db
	return NAN


func _conclure() -> bool:
	print("")
	if _erreurs.is_empty():
		print("TEST FOULE OK")
		quit(0)
	else:
		printerr("TEST FOULE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true
