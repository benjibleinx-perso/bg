# LA CINEMATIQUE SE JOUE-T-ELLE, ET EST-CE QU'ON LA VOIT ?
#
#     .\bg.ps1 test -Suite cinematique
#
# POURQUOI CE FICHIER EXISTE, ET C'EST UN RETOUR DE GUILLAUME DU 27/08/2026 :
#
#   « genre la cinematique, elle marche juste pas. Et il a aucun moyen de le
#     savoir. Il faut lui dire, comme s'il etait completement aveugle. »
#
# Il a raison, et c'etait mesurable : la seule chose que le projet verifiait des
# cinematiques etait la FORME de leurs donnees — les noms de noeuds existent,
# les champs sont bien ecrits. Une cinematique dont pas un plan ne s'affiche
# passait ce controle sans une remarque.
#
# CE QUE CELLE-CI MESURE, DANS L'ORDRE OU CA CASSE :
#
#   1. elle DEMARRE quand on la lance ;
#   2. sa camera est celle du SubViewport ou le 3D est rendu — c'est le piege
#      deja paye une fois : « l'ouverture se deroulait normalement, cartons,
#      fondu, plans qui defilent, sur un plan fixe de Walter vu de dos. Tout
#      marchait sauf ce qu'on voyait » ;
#   3. la camera BOUGE : deux plans qui rendent la meme image ne sont pas une
#      cinematique ;
#   4. elle se TERMINE toute seule ;
#   5. et elle rend la main — un joueur bloque apres l'ouverture ne peut plus
#      rien faire du jeu.
#
# CE QU'ELLE NE PEUT PAS DIRE : si c'est beau. Ca se juge sur une capture, et
# les vues existent — voir « ouverture_sable » et « crash_masque_tombe ».
extends SceneTree

## Ce qu'on laisse au monde pour se construire.
const POSE := 60

## Le temps qu'on accorde a une cinematique pour se finir, en images. Celle de
## l'ouverture dure une vingtaine de secondes ; on double, largement.
const BUDGET := 3000

## De combien la camera doit avoir bouge entre deux releves pour qu'on parle de
## mise en scene, en metres. Un plan fixe est legitime ; DEUX plans identiques
## d'affilee ne le sont pas, et c'est ce qu'on cherche.
const BOUGE_MINI := 0.5

var _monde: Node
var _cine: Node
var _n := 0
var _erreurs: Array[String] = []


# TOUT SE JOUE DANS _initialize, ET PAS DANS _process.
#
# Un `_process` qui contient un `await` n'est plus une fonction : c'est une
# coroutine, et elle ne rend donc pas le booleen que le SceneTree attend. Godot
# lit ce retour comme « true », c'est-a-dire « arrete la boucle », et le
# processus se termine proprement AU MILIEU de la premiere mesure — avec un
# code de sortie 0, donc une suite annoncee verte.
#
# Le symptome exact : le rapport s'arretait sur « elle se lance » et bg.ps1
# affichait « 1 suite(s) OK ». C'est le meme genre de faux vert que ce fichier
# existe pour attraper, et il l'a tendu a son auteur avant d'attraper quoi que
# ce soit. Les suites qui jouent — parcours, foule — font toutes leur travail
# ici, pour cette raison.
func _initialize() -> void:
	# UNE PARTIE NEUVE. Le monde reprend la sauvegarde s'il en trouve une, et
	# l'ouverture ne se joue QUE quand il n'y en a pas : la suite mesurerait
	# alors une cinematique qui a raison de ne pas demarrer.
	if FileAccess.file_exists("user://partie.json"):
		DirAccess.remove_absolute("user://partie.json")
	_monde = (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(_monde)
	for i in POSE:
		await process_frame

	_cine = _monde.find_child("Cinematique", true, false)
	if _cine == null:
		printerr("  ECHEC aucun noeud « Cinematique » dans le monde")
		quit(1)
		return

	await _jouer_chacune()

	print("")
	if _erreurs.is_empty():
		print("TEST CINEMATIQUE OK")
		quit(0)
	else:
		printerr("TEST CINEMATIQUE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)


func _verifier(ok: bool, message: String) -> void:
	if ok:
		print("  ok   " + message)
	else:
		_erreurs.append(message)
		printerr("  ECHEC " + message)




# ON LES JOUE TOUTES, ET ON LES TROUVE TOUTES SEULES.
#
# Le dossier des donnees est la liste : une cinematique ajoutee demain est
# mesuree sans qu'on touche a ce fichier. C'est la lecon du piege 65 — une
# liste ecrite a la main perime en silence.
func _jouer_chacune() -> void:
	var dossier := DirAccess.open("res://donnees")
	if dossier == null:
		_verifier(false, "le dossier des donnees s'ouvre")
		return
	var fichiers: Array[String] = []
	for nom in dossier.get_files():
		if nom.begins_with("cinematique") and nom.ends_with(".json"):
			fichiers.append(nom)
	fichiers.sort()
	_verifier(not fichiers.is_empty(),
			"%d cinematique(s) trouvee(s) : %s"
					% [fichiers.size(), ", ".join(fichiers)])

	for nom in fichiers:
		await _jouer(nom)


func _jouer(nom: String) -> void:
	print("\n--- %s ---" % nom)
	var chemin := "res://donnees/" + nom
	var plans: int = _combien_de_plans(chemin)
	print("       %d plan(s) declares" % plans)

	var lance: bool = _cine.call("jouer_fichier", chemin)
	_verifier(lance, "elle se lance")
	if not lance:
		return

	# LA CAMERA EST-ELLE CELLE QU'ON REGARDE ?
	#
	# Le piege est ecrit dans cinematique.gd : le noeud vit sous Monde, pas sous
	# Rendu, donc get_viewport() y rend la FENETRE et non le SubViewport ou le
	# 3D est dessine. Une camera rendue courante pour un viewport que personne
	# ne regarde laisse voir la scene normale pendant que la cinematique se
	# deroule — cartons compris.
	await process_frame
	await process_frame
	var cam := _monde.find_child("CameraOuverture", true, false) as Camera3D
	_verifier(cam != null, "elle cree sa camera")
	if cam == null:
		return
	var vp := cam.get_viewport()
	var vue: Camera3D = vp.get_camera_3d() if vp != null else null
	_verifier(vue == cam,
			"et c'est ELLE qu'on voit (camera active : %s)"
					% ("aucune" if vue == null else vue.name))

	# LA CAMERA BOUGE-T-ELLE ? On releve sa position tout du long et on garde
	# le plus grand ecart. Une cinematique entiere jouee au meme endroit est le
	# symptome que Guillaume decrit : « elle marche juste pas ».
	var depart := cam.global_position
	var ecart_max := 0.0
	var images := 0
	var finie := false
	while images < BUDGET:
		images += 1
		await process_frame
		if not is_instance_valid(cam):
			finie = true
			break
		ecart_max = maxf(ecart_max, cam.global_position.distance_to(depart))
		if not bool(_cine.call("active")):
			finie = true
			break

	# ON COMPARE CE QUE LA DONNEE ANNONCE A CE QUE LA CAMERA A FAIT.
	#
	# Le premier jet exigeait du mouvement des qu'il y avait plus d'un plan, et
	# il avait tort : l'ouverture de « Deux corps » tient DELIBEREMENT le meme
	# cadre sur ses deux plans — « le meme cadre, tenu, puis le noir. Un plan ne
	# peut pas ouvrir et fermer a la fois. » Un controle qui accuse une intention
	# est un controle qu'on apprend a ignorer.
	#
	# Ce qui se mesure ici est donc l'ECART entre l'intention et le rendu : si
	# les plans declarent des positions differentes et que la camera n'a pas
	# bouge, la mise en scene ecrite n'est pas celle qu'on voit. C'est
	# exactement le defaut que ce fichier cherche.
	var voulu := _amplitude_declaree(chemin)
	print("       %.1f s, la camera s'est deplacee de %.1f m (la donnee en"
			% [float(images) / 60.0, ecart_max] + " annonce %.1f)" % voulu)
	_verifier(finie, "elle se termine toute seule (%d images)" % images)
	if voulu > BOUGE_MINI:
		_verifier(ecart_max > BOUGE_MINI,
				"la camera fait le trajet que ses plans decrivent"
						+ " (%.2f m parcourus pour %.2f m ecrits)"
						% [ecart_max, voulu])
	elif plans > 1:
		print("       (cadre tenu d'un plan a l'autre : c'est ce qui est ecrit)")

	# ET LA MAIN EST RENDUE. Une cinematique qui laisse le joueur bloque est
	# pire qu'une cinematique absente : le jeu repond, mais plus a personne.
	var j := _monde.find_child("Joueur", true, false)
	_verifier(j != null and not bool(j.get("bloque")),
			"le joueur peut rejouer apres (bloque = %s)"
					% ("?" if j == null else str(j.get("bloque"))))


func _combien_de_plans(chemin: String) -> int:
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(chemin))
	if typeof(lu) != TYPE_DICTIONARY:
		return 0
	return (lu as Dictionary).get("plans", []).size()


# DE COMBIEN LA CAMERA EST CENSEE SE DEPLACER, d'apres les plans eux-memes.
#
# On lit « camera » et « camera_fin » de chaque plan et on garde le plus grand
# ecart entre deux positions ecrites. Un plan peut viser un NOM DE NOEUD plutot
# que des coordonnees — on ne sait pas ou il est sans resoudre la scene, donc on
# l'ignore : mieux vaut ne rien exiger que d'exiger a partir d'une valeur qu'on
# n'a pas.
func _amplitude_declaree(chemin: String) -> float:
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(chemin))
	if typeof(lu) != TYPE_DICTIONARY:
		return 0.0
	var points: Array[Vector3] = []
	for p in (lu as Dictionary).get("plans", []):
		for champ in ["camera", "camera_fin"]:
			var v := _en_vecteur((p as Dictionary).get(champ, null))
			if v != Vector3.INF:
				points.append(v)
	var maxi := 0.0
	for i in points.size():
		for j in range(i + 1, points.size()):
			maxi = maxf(maxi, points[i].distance_to(points[j]))
	return maxi


func _en_vecteur(brut: Variant) -> Vector3:
	if typeof(brut) != TYPE_ARRAY or (brut as Array).size() != 3:
		return Vector3.INF
	var a: Array = brut
	for x in a:
		if typeof(x) != TYPE_FLOAT and typeof(x) != TYPE_INT:
			return Vector3.INF
	return Vector3(float(a[0]), float(a[1]), float(a[2]))
