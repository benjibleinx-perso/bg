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
# CE QUE LES OS NE DISENT PAS, ET CE QU'ON VERIFIE A LA PLACE.
#
# Le 23/08/2026, les os annoncaient 1,72 m debout et 1,72 m couche pendant que
# le corps remplissait le cadre a six metres. Le defaut ne vivait pas dans les
# poses : l'armature du .glb portait une echelle de 0,0102, et le moteur
# physique la normalise des que le ragdoll demarre.
#
# D'ou la PREMIERE verification de ce fichier, qui est la plus importante :
# aucune armature ne porte d'echelle. C'est elle qui rougirait si un reimport
# la ramenait, et aucune mesure de pose ne le ferait a sa place.
#
# La preuve visuelle, elle, se rejoue :
#
#     .\bg.ps1 capture -Scenario corps_effondre
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

	var erreurs := 0

	# AUCUN PERSONNAGE RIGGE NE PORTE D'ECHELLE SUR SON ARMATURE.
	#
	# C'est LE garde-fou de ce fichier, et il vaut plus que tout ce qui suit :
	# une echelle sur l'armature ne se voit nulle part tant que personne ne
	# meurt, puis elle disperse le ragdoll sur vingt metres. Walter l'a portee
	# pendant des semaines. Un reimport fait sans appliquer l'echelle aux
	# donnees la ramenerait en silence — ici, il rougit.
	print("")
	print("--- l'echelle des armatures ---")
	erreurs += _verifier_les_echelles()

	print("")
	print("--- debout ---")
	var debout := _envergure(squelette)
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


# Chaque personnage riggé du dossier, et l'echelle de son armature. On les
# ouvre tous plutot que de nommer Walter, Jesse et Tuco : le jour ou un
# quatrieme arrive, il est verifie sans que personne y pense.
func _verifier_les_echelles() -> int:
	var d := DirAccess.open("res://assets/personnages")
	if d == null:
		printerr("  ECHEC dossier des personnages introuvable")
		return 1
	var noms: Array[String] = []
	for f in d.get_files():
		if f.ends_with(".glb"):
			noms.append(f)
	noms.sort()

	var fautifs := 0
	var riggees := 0
	var restants: Array[String] = []
	for n in noms:
		var ps := ResourceLoader.load("res://assets/personnages/" + n) as PackedScene
		if ps == null:
			continue
		var inst := ps.instantiate()
		var sq := inst.find_child("Skeleton3D", true, false) as Skeleton3D
		if sq == null:
			# Pas de squelette : pas de ragdoll possible, rien a verifier.
			inst.free()
			continue
		root.add_child(inst)
		riggees += 1
		var e: float = sq.global_transform.basis.get_scale().y
		if absf(e - 1.0) > 0.01:
			# ROUGE POUR CELUI QUI PEUT MOURIR, SIGNALE POUR LES AUTRES.
			#
			# Seul le joueur a un ragdoll aujourd'hui : c'est le seul chez qui
			# l'echelle se paie a l'ecran, et le seul dont ce test doit
			# empecher la regression. Jesse et Tuco la portent encore — leur
			# recette d'import n'est ecrite nulle part et la retrouver est un
			# chantier a part, suivi dans son ticket.
			#
			# On les NOMME quand meme, a chaque passage. Un defaut connu qui
			# ne s'imprime plus est un defaut oublie.
			if n == "walt.glb":
				fautifs += 1
				printerr("  ECHEC %-30s armature a l'echelle %.4f" % [n, e])
			else:
				restants.append("%s (%.4f)" % [n, e])
		root.remove_child(inst)
		inst.free()

	if fautifs == 0:
		print("  ok   le squelette du joueur est a l'echelle 1 (%d riggés lus)"
				% riggees)
	if not restants.is_empty():
		print("       reste a reimporter : %s" % ", ".join(restants))
	return fautifs


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
