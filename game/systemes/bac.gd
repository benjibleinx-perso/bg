# LE BAC A SABLE : un terrain de mesure, AU LARGE DU MONDE.
#
# POURQUOI IL EXISTE. Trois fois, un banc d'essai pose dans le monde a ete
# rattrape par lui : la bande de cactus a grandi, les cretes se sont
# rapprochees, et la suite « conduite » a rendu « 0 km/h, seuil 45 » pour une
# voiture qui percutait un saguaro a dix-sept metres. Le piege 33 conclut qu'un
# banc pose dans le decor sera rattrape un jour ou l'autre — et le remede tenu
# jusqu'ici, deplacer le banc, a produit la fois d'apres une piste sans sol ou
# une chute libre passait pour 282 km/h.
#
# ICI, LE DECOR NE PEUT PAS ARRIVER : le bac est a deux kilometres de la ville
# et du desert, il est plat par construction, et il DIT son etendue au
# demarrage. Ce qu'on y mesure ne decrit que ce qu'on est venu mesurer.
#
# CE N'EST PAS UN SECOND JEU. Meme scene, meme controleur, meme joueur, meme
# vehicule, meme HUD : on y arrive par `.\bg.ps1 jouer -Ou bac` ou par le menu
# de developpement, exactement comme on va au desert. Un second projet Godot
# aurait duplique trente-huit mille lignes qui auraient diverge en une semaine.
#
# CE QU'IL PORTE, ET RIEN D'AUTRE :
#   - une piste plate et degagee de 200 m, pour lancer un vehicule ;
#   - une cuvette au profil du fosse, pour rejouer la sortie sans jouer la
#     mission ;
#   - une rampe, pour les montees ;
#   - une toise graduee tous les 50 cm, pour juger l'echelle d'un modele.
#
# ET IL VALIDE SON TERRAIN AVANT QU'ON MESURE DESSUS. C'est la lecon du piege
# 33 : un banc qui ne verifie pas ce qu'il y a sous et devant lui rend un
# verdict sur son decor en croyant parler de son sujet.
class_name Bac
extends Node3D

## Le groupe par lequel on le retrouve sans connaitre son chemin dans l'arbre,
## comme Desert.courant() et Mission.courante().
const GROUPE := "bac"

## Cote du terrain, en metres. Deux cents suffisent a lancer un vehicule
## jusqu'a son plafond : 130 km/h en ligne droite se prennent en 90 m.
const COTE := 200.0

## Le pas de la grille du sol, en metres. Une case de dix metres se compte a
## l'oeil sur une capture, et donne l'echelle sans qu'aucun chiffre s'affiche.
const CASE := 10.0

## La cuvette : son centre, son rayon et sa profondeur. Le profil est celui du
## fosse du desert — trois metres sur une vingtaine de rayon — parce que c'est
## la pente qu'on vient rejouer.
const CUVETTE := Vector2(-45.0, -50.0)
const CUVETTE_RAYON := 18.0
const CUVETTE_FOND := -3.0

## La rampe : la pente, en degres, et son emprise. Quinze degres est la limite
## haute de ce qu'une piste de desert presente.
const RAMPE_PENTE := 15.0
const RAMPE_X := 45.0
const RAMPE_LARGEUR := 20.0
const RAMPE_LONGUEUR := 40.0

## La resolution du maillage du sol. Deux metres par maille : assez fin pour
## que la cuvette soit ronde, assez grossier pour rester un terrain PS2.
const MAILLE := 2.0

## Ce qui doit etre libre autour du bac pour qu'on puisse s'y fier, en metres.
## Mesure au demarrage contre tout ce que la scene contient.
const DEGAGEMENT := 300.0

## La toise : jusqu'ou elle monte et tous les combien elle se marque.
const TOISE_HAUT := 3.0
const TOISE_PAS := 0.5


func _ready() -> void:
	add_to_group(GROUPE)
	_poser_le_sol()
	_poser_la_toise()
	# Apres le sol : la verification se fait sur ce qui est en place, jamais
	# sur ce qu'on a l'intention de poser.
	call_deferred("_verifier_le_degagement")


## Ou deposer quelqu'un qui arrive, en coordonnees du monde. Sur la piste
## plate, face a la cuvette. On ne l'ecrit pas ailleurs : le jour ou le bac
## bouge, ce point le suit.
func depart() -> Vector3:
	return global_position + Vector3(20.0, 0.4, 0.0)


## La hauteur du sol du bac a cet endroit, en coordonnees LOCALES. C'est la
## seule definition du terrain : le maillage et la collision en descendent, et
## une mesure qui veut savoir ou est le sol la relit plutot que de deviner.
func hauteur(x: float, z: float) -> float:
	var h := 0.0

	# La cuvette, en cosinus pour que ses bords se raccordent au plat sans
	# arete : une pente franche se franchirait comme une marche.
	var d := Vector2(x, z).distance_to(CUVETTE)
	if d < CUVETTE_RAYON:
		h += CUVETTE_FOND * pow(cos(PI * 0.5 * d / CUVETTE_RAYON), 2.0)

	# La rampe, plein est, montant vers +X.
	if x > RAMPE_X and absf(z - 50.0) < RAMPE_LARGEUR * 0.5:
		var avance: float = minf(x - RAMPE_X, RAMPE_LONGUEUR)
		h += avance * tan(deg_to_rad(RAMPE_PENTE))

	return h


func _poser_le_sol() -> void:
	var pas := int(COTE / MAILLE)
	var demi := COTE * 0.5
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in pas:
		for j in pas:
			var x0 := -demi + i * MAILLE
			var z0 := -demi + j * MAILLE
			var x1 := x0 + MAILLE
			var z1 := z0 + MAILLE
			var a := Vector3(x0, hauteur(x0, z0), z0)
			var b := Vector3(x1, hauteur(x1, z0), z0)
			var c := Vector3(x1, hauteur(x1, z1), z1)
			var e := Vector3(x0, hauteur(x0, z1), z1)
			# UNE CASE SUR DEUX EST PLUS CLAIRE, et la case fait dix metres.
			# C'est la grille : elle donne l'echelle sur une capture sans
			# qu'un seul chiffre s'affiche, ce que la premiere regle du jeu
			# demande partout ailleurs.
			var pair := (int(floor((x0 + demi) / CASE))
					+ int(floor((z0 + demi) / CASE))) % 2 == 0
			var teinte := Color(0.22, 0.21, 0.19) if pair else Color(0.09, 0.09, 0.08)
			for sommet in [a, b, c, a, c, e]:
				st.set_color(teinte)
				st.add_vertex(sommet)

	st.generate_normals()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	st.set_material(mat)

	var sol := MeshInstance3D.new()
	sol.name = "SolDuBac"
	sol.mesh = st.commit()
	add_child(sol)
	sol.create_trimesh_collision()


# LA TOISE : quatre plots de tailles connues, alignes au bord de la piste.
#
# Un modele livre arrive a l'echelle de son auteur, et « il a l'air un peu
# grand » n a jamais regle personne. Pose a cote d'un plot de 1,75 m, un
# personnage se juge en une capture.
func _poser_la_toise() -> void:
	var parent := Node3D.new()
	parent.name = "Toise"
	parent.position = Vector3(0.0, 0.0, 12.0)
	add_child(parent)

	var n := int(TOISE_HAUT / TOISE_PAS)
	for i in n:
		var haut := TOISE_PAS * (i + 1)
		var plot := MeshInstance3D.new()
		plot.name = "Plot%d" % int(haut * 100.0)
		var boite := BoxMesh.new()
		boite.size = Vector3(0.4, haut, 0.4)
		plot.mesh = boite
		var mat := StandardMaterial3D.new()
		# Un plot sur deux plus sombre : on compte les barreaux d'un coup
		# d'oeil, comme sur une mire.
		var clair := i % 2 == 0
		mat.albedo_color = Color(0.80, 0.30, 0.22) if clair else Color(0.92, 0.90, 0.85)
		mat.roughness = 1.0
		plot.material_override = mat
		plot.position = Vector3(i * 1.2, haut * 0.5, 0.0)
		parent.add_child(plot)


# CE QUI L'ENTOURE, MESURE ET IMPRIME.
#
# Le piege 33 en trois lignes : un banc d'essai qui ne regarde pas son terrain
# rend un verdict sur le decor en croyant parler de son sujet. On ne verifie
# donc pas que le bac est loin de la ville « par construction » — on mesure ce
# qui est effectivement pose autour de lui, et on le dit.
func _verifier_le_degagement() -> void:
	# ON PARCOURT CE QUI EST POSE, PAS UN GROUPE. Ni la ville ni le desert
	# n'inscrivent leur decor dans un groupe : s'y fier reviendrait a mesurer
	# une liste vide et a la prendre pour un terrain degage.
	var trouve := _plus_proche(get_tree().get_root())
	var d := float(trouve.get("distance", INF))
	var quoi := str(trouve.get("nom", ""))
	var comptes := int(trouve.get("comptes", 0))

	if d < DEGAGEMENT:
		push_warning("BAC : « %s » est a %.0f m du centre — le bac n'est plus seul"
				% [quoi, d])
	print("BAC : %.0f x %.0f m, cuvette de %.1f m, rampe a %.0f deg ; %d maillage(s) autour, le plus proche « %s » a %.0f m"
			% [COTE, COTE, -CUVETTE_FOND, RAMPE_PENTE, comptes, quoi, d])


## Le maillage le plus proche du centre du bac, hors bac lui-meme. Rend son
## nom, sa distance et combien on en a mesure : un compte de zero dirait que
## la mesure n'a rien regarde, ce qui ne se distingue pas d'un terrain vide.
func _plus_proche(depuis: Node) -> Dictionary:
	var meilleur := {"distance": INF, "nom": "", "comptes": 0}
	var pile: Array[Node] = [depuis]
	while not pile.is_empty():
		var n: Node = pile.pop_back()
		if n == self:
			continue
		for enfant in n.get_children():
			pile.append(enfant)
		var mi := n as MeshInstance3D
		if mi == null:
			continue
		meilleur["comptes"] = int(meilleur["comptes"]) + 1
		var d := mi.global_position.distance_to(global_position)
		if d < float(meilleur["distance"]):
			meilleur["distance"] = d
			meilleur["nom"] = str(mi.name)
	return meilleur
