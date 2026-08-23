# Le corps garde-t-il sa taille en s'effondrant ?
#
#     godot --headless --path game --script res://verifs/test_mort.gd
#
# CE QUE CA ATTRAPE. « Quand le personnage meurt, on voit son corps s'effondrer
# mais il est absolument enorme » — retour de Guillaume du 23/08/2026. Rien ne
# le signalait : le ragdoll fonctionne, le corps tombe, la partie se termine.
# Seule sa TAILLE est fausse, et aucune verification ne la regardait.
#
# ON MESURE SUR LES OS, en global, avant et apres. C'est la seule mesure qui
# ne peut pas mentir : la boite englobante d'un maillage decrit la geometrie
# AVANT deformation par l'armature — elle annoncerait la meme valeur quoi que
# fasse la simulation. Le projet a deja paye cette lecon deux fois.
#
# CE QUE CE TEST NE VOIT PAS, ET IL FAUT LE SAVOIR AVANT DE S'Y FIER.
#
# Les os restent justes pendant que le MAILLAGE, lui, s'affiche cent fois trop
# grand. Mesure faite le 23/08/2026 : envergure des os 1,72 m debout, 1,72 m
# couche — et a l'ecran, un corps qui remplit le cadre a six metres. Le defaut
# vit entre le squelette et son rendu, pas dans les poses.
#
# Ce test garde donc UNE chose : que les poses d'os ne partent pas en vrille.
# Pour la taille VUE, la preuve est une image :
#
#     .\bg.ps1 capture -Scenario corps_effondre
#
# La cause est ecrite dans docs/11-pieges.md — l'armature du .glb porte une
# echelle de 0,01, et la simulation physique ne la respecte pas.
extends SceneTree

## Ce qu'on tolere entre le personnage debout et son cadavre, en proportion.
## Un corps qui tombe s'etale : sa plus grande dimension reste sa taille, a
## quelques centimetres pres.
const ECART_MAX := 1.15

## Le temps qu'on laisse au corps pour tomber, en images.
const CHUTE := 90


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var joueur := _trouver(root, "Joueur") as Node3D
	var controleur := _trouver(root, "Controleur")
	if joueur == null or controleur == null:
		printerr("ECHEC monde incomplet")
		quit(1)
		return

	var squelette := joueur.find_child("Skeleton3D", true, false) as Skeleton3D
	if squelette == null:
		printerr("ECHEC pas de squelette")
		quit(1)
		return

	print("")
	print("--- debout ---")
	var debout := _envergure(squelette)
	var echelle := squelette.global_transform.basis.get_scale()
	print("       echelle du squelette  (%.3f, %.3f, %.3f)"
			% [echelle.x, echelle.y, echelle.z])
	print("       envergure des os      %.2f m" % debout)
	var erreurs := 0
	if debout < 1.5 or debout > 2.1:
		printerr("  ECHEC debout, il mesure %.2f m au lieu de 1,78" % debout)
		erreurs += 1
	else:
		print("  ok   debout, il mesure %.2f m" % debout)

	# ON LE TUE PAR LE CHEMIN DU JEU. Appeler lacher() directement sauterait
	# tout ce qui se passe entre les deux — le blocage, l'arret de la physique
	# du personnage, l'ecran de fin — et c'est justement la ou un defaut peut
	# se loger.
	print("")
	print("--- il s'effondre ---")
	joueur.call("blesser", 1000.0)
	for _i in CHUTE:
		await process_frame

	var apres := _envergure(squelette)
	var rapport := apres / maxf(0.01, debout)
	print("       envergure des os      %.2f m  (x %.2f)" % [apres, rapport])
	if rapport > ECART_MAX:
		printerr("  ECHEC le corps a grandi de %.0f %% en tombant (%.2f m)"
				% [(rapport - 1.0) * 100.0, apres])
		erreurs += 1
	else:
		print("  ok   il garde sa taille en tombant (%.2f m)" % apres)

	print("")
	if erreurs > 0:
		printerr("TEST MORT ECHOUE : %d probleme(s)" % erreurs)
		quit(1)
		return
	print("TEST MORT OK")
	quit(0)


# La plus grande distance entre deux os, en metres du MONDE.
#
# C'est la taille du personnage tant qu'il est debout — de la tete au pied —
# et la longueur de son corps une fois couche. Dans les deux cas c'est le
# meme nombre, et c'est precisement ce qui rend la comparaison lisible.
func _envergure(squelette: Skeleton3D) -> float:
	var points: Array[Vector3] = []
	for i in squelette.get_bone_count():
		points.append(squelette.global_transform
				* squelette.get_bone_global_pose(i).origin)
	var maxi := 0.0
	for a in points:
		for b in points:
			maxi = maxf(maxi, a.distance_to(b))
	return maxi


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
