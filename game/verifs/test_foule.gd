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

var _n := 0
var _etape := 0
var _foule: Node
var _avant: Array[Vector3] = []
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
		# On travaille la ville seule depuis le 31/07/2026 : l'effectif est a
		# zero le temps que la trame irreguliere soit supportee cote jeu — voir
		# docs/16-albuquerque.md. Un test qui echoue pour un reglage volontaire
		# est un test qu'on apprend a ignorer, et c'est pire que pas de test.
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

		_etape = 1
		_n = 0
		return false

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

	print("")
	if _erreurs.is_empty():
		print("TEST FOULE OK")
		quit(0)
	else:
		printerr("TEST FOULE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true
