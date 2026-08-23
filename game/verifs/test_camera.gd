# Les quatre touches vont-elles la ou l'ecran dit qu'elles vont ?
#
#   godot --path game --script res://verifs/test_camera.gd
#
# Les touches sont simulees et le jeu tourne normalement : c'est la boucle
# complete camera <-> personnage qui est mise a l'epreuve, pas des fonctions
# prises isolement.
#
# CE QUE CE TEST GARDE, ET POURQUOI. Le personnage se deplace RELATIVEMENT A
# LA CAMERA : avancer veut dire vers le haut de l'ecran, quelle que soit son
# orientation. C'est facile a casser sans s'en rendre compte, parce que les
# deux versions — relative et « commandes de char » — se ressemblent tant
# qu'on ne fait qu'avancer en ligne droite. Elles ne different que sur le
# cote, et c'est exactement la que le jeu se juge.
#
# La version precedente de ce fichier verifiait le CONTRAIRE : que gauche et
# droite pivotent sans deplacer, et que la camera finisse dans le dos du
# personnage. Les deux etaient les symptomes d'un defaut, pas un contrat.
#
# Ce qu'on mesure ici, dans l'ordre :
#   1. chaque touche deplace dans la bonne direction A L'ECRAN ;
#   2. le personnage se tourne vers la ou il va ;
#   3. la camera NE se replace PAS toute seule — c'est ce recentrage qui a
#      poursuivi le projet pendant trois versions ;
#   4. la souris tourne la vue dans le bon sens, horizontalement ET
#      verticalement. La verticale etait inversee depuis le debut.
extends SceneTree

const POSE := 40            # le temps que tout se pose
const STABILISATION := 120  # le temps de se tourner et de prendre son elan
const MESURE := 90          # fenetre d'observation
const ECART_MAX := 30.0     # degres tolerés entre direction voulue et reelle
const DERIVE_MAX := 20.0    # degres de rotation tolerés une fois lance

# Chaque cas dit la direction attendue DANS LE REPERE DE L'ECRAN : x vers la
# droite du cadre, y vers le haut du cadre. C'est la seule facon de formuler
# ce qu'on veut sans recopier le calcul qu'on teste.
const CAS := [
	{"nom": "avancer", "action": "gaz", "ecran": Vector2(0.0, 1.0)},
	{"nom": "reculer", "action": "frein", "ecran": Vector2(0.0, -1.0)},
	{"nom": "aller a gauche", "action": "gauche", "ecran": Vector2(-1.0, 0.0)},
	{"nom": "aller a droite", "action": "droite", "ecran": Vector2(1.0, 0.0)},
]

## Chaque cas repart du desert, hors de la ville : sol plat, aucun obstacle
## sur des dizaines de metres.
##
## Deux versions precedentes partaient de la chaussee et concluaient a tort
## que le personnage ne bougeait pas — il butait en realite contre la voiture,
## puis contre un immeuble apres avoir traverse un trottoir. Un test de
## stabilite ne doit rien avoir a heurter, sinon il mesure la collision.
const DEPART := Vector3(-60.0, 0.6, 60.0)

## Le cap impose a la camera pendant les quatre cas. Volontairement de biais :
## a zero, « relatif a la camera » et « relatif au personnage » donnent le
## meme resultat, et le test passerait sur les deux jeux.
const CAP_DE_BIAIS := 1.0

var _j: Node3D
var _cam: Camera3D
var _n := 0
var _cas := 0
var _phase := 0
var _debut_angle := 0.0
var _debut_pos := Vector3.ZERO
var _erreurs: Array[String] = []


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	var monde := ps.instantiate()
	# SANS LE SCENARIO. La mission fait sonner le telephone cinq secondes apres
	# la sortie de chez Walter, et un appel entrant immobilise le personnage :
	# ce test mesure des deplacements, et il les a tous mesures a zero.
	var scenario := _trouver(monde, "Scenario")
	if scenario != null:
		scenario.free()
	root.add_child(monde)


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	if _j == null:
		_j = _trouver(root, "Joueur") as Node3D
		_cam = _trouver(root, "Camera3D") as Camera3D
		if _j == null or _cam == null:
			printerr("Joueur introuvable")
			quit(1)
			return true
		print("")
		print("--- les quatre touches, camera de biais (%.0f deg) ---"
				% rad_to_deg(CAP_DE_BIAIS))
		_lancer_cas()
		return false

	_phase += 1

	if _phase == STABILISATION:
		_debut_angle = _j.rotation.y
		_debut_pos = _j.global_position
	elif _phase >= STABILISATION + MESURE:
		_mesurer()
		Input.action_release(CAS[_cas]["action"])
		_cas += 1
		if _cas >= CAS.size():
			return _conclure()
		_lancer_cas()

	return false


func _mesurer() -> void:
	var nom: String = CAS[_cas]["nom"]
	var ecran: Vector2 = CAS[_cas]["ecran"]
	var parcouru := _j.global_position - _debut_pos
	parcouru.y = 0.0

	if parcouru.length() < 1.0:
		_erreurs.append(nom + " (immobile)")
		printerr("  ECHEC %-16s n'a pas bouge (%.2f m)" % [nom, parcouru.length()])
		return

	# La direction attendue, reconstruite depuis le cap de la CAMERA : c'est
	# la definition meme de « relatif a la camera ».
	var cap := _cap_camera()
	var devant := Vector3(-sin(cap), 0.0, -cos(cap))
	var cote := Vector3(cos(cap), 0.0, -sin(cap))
	var voulue := (devant * ecran.y + cote * ecran.x).normalized()
	var ecart := rad_to_deg(voulue.angle_to(parcouru.normalized()))

	# Et il regarde ou il va. Sans cette mesure, un personnage qui glisse de
	# cote en restant de face passerait le test.
	var avant := -_j.global_transform.basis.z
	avant.y = 0.0
	var oriente := rad_to_deg(avant.normalized().angle_to(parcouru.normalized()))

	var derive := rad_to_deg(absf(angle_difference(_debut_angle, _j.rotation.y)))

	# LA CAMERA N'A PAS BOUGE TOUTE SEULE. C'est ici qu'on le voit, et nulle
	# part ailleurs : le personnage vient de se retourner et de marcher deux
	# secondes, ce qui est exactement la situation ou l'ancien recentrage
	# ramenait le cap sur son dos.
	var glissement := rad_to_deg(absf(angle_difference(CAP_DE_BIAIS, _cap_camera())))
	if glissement > 1.0:
		_erreurs.append(nom + " (la camera se recentre)")
		printerr("  ECHEC %-16s la camera a tourne de %.1f deg sans la souris"
				% [nom, glissement])
		return

	if ecart > ECART_MAX:
		_erreurs.append(nom)
		printerr("  ECHEC %-16s part a %.0f deg de la direction demandee (%.2f m)"
				% [nom, ecart, parcouru.length()])
	elif oriente > ECART_MAX:
		_erreurs.append(nom + " (mal oriente)")
		printerr("  ECHEC %-16s ne regarde pas ou il va (%.0f deg)" % [nom, oriente])
	elif derive > DERIVE_MAX:
		_erreurs.append(nom + " (tourne sans fin)")
		printerr("  ECHEC %-16s tourne encore une fois lance (%.1f deg)"
				% [nom, derive])
	else:
		print("  ok   %-16s %.1f m a %.0f deg de l'axe demande, regarde a %.0f deg"
				% [nom, parcouru.length(), ecart, oriente])


func _lancer_cas() -> void:
	_phase = 0
	_j.global_position = DEPART
	# Le personnage part TOURNE AILLEURS que la camera. Si sa direction se
	# lisait sur son propre corps, les quatre cas partiraient de travers.
	_j.rotation.y = CAP_DE_BIAIS + PI * 0.5
	if _j is CharacterBody3D:
		(_j as CharacterBody3D).velocity = Vector3.ZERO
	if _cam.has_method("poser_le_cap"):
		_cam.call("poser_le_cap", CAP_DE_BIAIS)
	Input.action_press(CAS[_cas]["action"])


func _cap_camera() -> float:
	if _cam.has_method("cap"):
		return _cam.call("cap")
	return 0.0


func _conclure() -> bool:
	_verifier_la_souris()
	print("")
	if _erreurs.is_empty():
		print("TEST CAMERA OK")
		quit(0)
	else:
		printerr("TEST CAMERA ECHOUE : %s" % ", ".join(_erreurs))
		quit(1)
	return true


# LA CAMERA OBEIT A LA SOURIS, ET A RIEN D'AUTRE.
#
# Ces trois mesures regardent le SENS, pas le fait qu'une valeur bouge. Le
# test d'avant affirmait que l'horizontale etait bonne alors qu'elle avait
# ete ecrite a l'envers : il verifiait que le cap changeait.
func _verifier_la_souris() -> void:
	print("")
	print("--- la souris ---")
	if not _cam.has_method("tourner") or not _cam.has_method("cap"):
		_erreurs.append("la camera n'expose ni tourner() ni cap()")
		return

	# (Qu'elle ne se replace pas toute seule se mesure plus haut, pendant les
	# quatre cas : c'est la, apres un demi-tour et deux secondes de marche,
	# que l'ancien recentrage se voyait.)

	# 1. Souris a DROITE, la vue tourne a droite. Le cap va du sujet VERS la
	# camera : la vue tourne a droite quand ce cap DIMINUE. C'est la
	# convention de camera_poursuite.gd, et le seul endroit ou ce test doit la
	# connaitre.
	var depart_cap: float = _cam.call("cap")
	_cam.call("tourner", Vector2(60.0, 0.0))
	var vire := angle_difference(depart_cap, _cam.call("cap"))
	if vire >= 0.0:
		_erreurs.append("souris a droite, la vue va a gauche")
		printerr("  ECHEC souris a droite : le cap a bouge de %+.1f deg"
				% rad_to_deg(vire))
	else:
		print("  ok   souris a droite, la vue tourne a droite")

	# 2. Souris vers le HAUT, on regarde vers le haut — donc la camera DESCEND
	# autour du personnage. C'etait inverse depuis le debut, comme un
	# simulateur de vol, et personne ne l'avait mesure. On lit le tangage a
	# travers l'ancrage voulu, pas la position lissee : la camera met une
	# seconde a rejoindre sa place et ce test ne dure pas une seconde.
	var repos := _hauteur_visee()
	_cam.call("tourner", Vector2(0.0, -200.0))
	var haut := _hauteur_visee()
	_cam.call("tourner", Vector2(0.0, 400.0))
	var bas := _hauteur_visee()
	if not (haut < repos and repos < bas):
		_erreurs.append("la verticale de la souris est inversee")
		printerr("  ECHEC souris en haut : %.2f m, au repos : %.2f m, en bas : %.2f m"
				% [haut, repos, bas])
	else:
		print("  ok   souris vers le haut, la camera descend (%.2f m contre %.2f m)"
				% [haut, bas])


# La hauteur ou la camera VEUT etre, au-dessus du personnage. On la recalcule
# depuis le tangage plutot que de lire la position du noeud : celle-ci est
# lissee sur plusieurs images et repondrait a la question « ou etait-elle ».
func _hauteur_visee() -> float:
	var tangage: float = _cam.get("_tangage")
	var reglages: Object = _cam.get("reglages")
	var recul: float = reglages.get("pieton_recul")
	var hauteur: float = reglages.get("pieton_hauteur")
	return hauteur + sin(tangage) * recul


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
