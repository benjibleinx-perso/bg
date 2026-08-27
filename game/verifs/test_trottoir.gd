# Verifie que le personnage monte sur un trottoir au lieu de buter dessus.
#
#   godot --path game --script res://verifs/test_trottoir.gd
#
# CharacterBody3D ne franchit aucune marche par defaut : il glisse le long
# des obstacles verticaux quelle que soit leur hauteur. Une bordure de 18 cm
# bloquait donc net, ce qui est intenable dans une ville ou l'on monte et
# descend des trottoirs en permanence.
#
# LA VILLE DIT OU SONT SES TROTTOIRS, ON NE LES RECOPIE PLUS.
#
# Trois valeurs etaient ecrites en dur ici : « chaussee du couloir 0, x de 3 a
# 11, bordure a x = 11, trottoir a y = 0,18 ». C'etait vrai de la ville d'un
# soir. Le 27/08/2026, la mesure rendait x = 12,46 franchi mais y = 0,011, et le
# compteur du joueur disait ZERO franchissement : il n'y avait plus aucune
# bordure a cet endroit. La suite accusait le jeu de ne plus savoir monter sur
# un trottoir alors qu'elle visait un morceau de rue qui n'existait plus.
#
# Ce n'etait pas un defaut du jeu : `passants` mesure que les vingt-six pietons
# marchent tous sur un trottoir, et `bordure` (en voiture) est verte.
#
# Le generateur ecrit ce qu'il a fait dans ville_lampes.json — les voies
# pietonnes, avec leur hauteur, et la geometrie des rues. On lui demande. Meme
# lecon que la table des phases du menu de test (piege 65) : une liste qui peut
# se DEDUIRE de ce qu'elle decrit ne se recopie pas.
extends SceneTree

const POSE := 30
const MARCHE := 200
const VILLE := "res://assets/ville/ville_lampes.json"

var _depart := Vector3.ZERO
var _cible := Vector3.ZERO
var _y_trottoir := 0.18

var _j: CharacterBody3D
var _cam: Camera3D
var _erreurs: Array[String] = []


# TOUT SE JOUE ICI, ET PAS DANS _process.
#
# Le choix de la bordure a besoin de POSER le joueur et de le laisser tomber
# quelques images : c'est un `await`, donc une coroutine. Une coroutine appelee
# depuis `_process` ne rend pas le booleen que le SceneTree attend — il le lit
# comme « arrete la boucle » et le processus se termine au milieu de la mesure,
# avec un code de sortie 0. C'est le defaut que test_cinematique.gd raconte, et
# qui donne une suite annoncee verte sans avoir rien mesure.
func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())
	for i in POSE:
		await process_frame

	_j = _trouver(root, "Joueur") as CharacterBody3D
	_cam = _trouver(root, "Camera3D") as Camera3D
	if _j == null or _cam == null:
		printerr("ECHEC joueur ou camera introuvables")
		quit(1)
		return

	# ON EN ESSAIE PLUSIEURS, ET C'EST TOUT LE SUJET.
	#
	# Un seul emplacement ne distingue pas « le jeu ne sait pas franchir une
	# bordure » de « il y avait un lampadaire a cet endroit-la ». Trois rues
	# tirees du plan de la ville repondent a la question que la version d'avant
	# ne pouvait pas poser : est-ce systematique ?
	var essais := 0
	var montes := 0
	var rate: Array[String] = []
	for tentative in 3:
		if not await _choisir_la_bordure(tentative):
			break
		essais += 1
		if await _traverser():
			montes += 1
		else:
			rate.append("%s" % _cible)

	_verifier(essais > 0,
			"la ville declare des trottoirs a essayer (%d)" % essais)
	_verifier(montes == essais,
			"il monte sur la bordure a chaque fois (%d sur %d)"
					% [montes, essais])
	if montes < essais:
		printerr("        bordures non franchies : %s" % ", ".join(rate))

	print("")
	if _erreurs.is_empty():
		print("TEST TROTTOIR OK")
		quit(0)
	else:
		printerr("TEST TROTTOIR ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)


# UNE TRAVERSEE : on part de la chaussee, on marche vers le trottoir, et on
# regarde si l'on finit dessus. Rend vrai quand c'est le cas.
func _traverser() -> bool:
	print("       trottoir vise %s (y = %.2f), depart %s"
			% [_cible, _y_trottoir, _depart])

	_j.global_position = _depart
	_j.velocity = Vector3.ZERO

	# ET ON LUI RETIRE SON MASQUE.
	#
	# La partie commence dans le fosse, et sa premiere etape declare « lent » :
	# Walter se traine a 1,15 m/s. Il parcourait donc 3,8 m des sept qui le
	# separaient de la bordure, s'arretait en pleine chaussee, et la suite
	# concluait qu'il n'etait pas monte sur le trottoir — ce qui etait vrai, et
	# n'avait rien a voir avec le franchissement. Meme cause que dans
	# test_allures, trouvee le meme jour.
	if _j.get("entrave"):
		print("       Walter etait entrave (etape au masque) : on le libere")
		_j.set("entrave", false)

	# ON ORIENTE LA CAMERA VERS LA BORDURE, et le personnage avec.
	#
	# « Avancer » veut dire « vers le haut de l'ecran » : la direction se lit
	# sur le cap de la camera, qui designe le vecteur allant du sujet VERS elle.
	# L'avant de la vue en est l'oppose.
	#
	# Le personnage est tourne dans le meme sens pour partir droit : il se
	# tourne tout seul vers sa direction, mais pas instantanement, et un quart
	# de seconde de courbe suffirait a le faire aborder la bordure de biais.
	var vers := _cible - _depart
	vers.y = 0.0
	var cap := atan2(-vers.x, -vers.z)
	_j.rotation.y = cap
	_cam.call("poser_le_cap", cap)
	# Et on la force a s'y placer d'un coup, parce que ce qu'on mesure ensuite
	# est une distance parcourue : tant que la camera est en route, sa position
	# ne correspond a rien de ce qu'on a demande.
	_cam.set("_initialisee", false)

	Input.action_press("gaz")
	for i in MARCHE:
		await process_frame
	Input.action_release("gaz")
	await process_frame

	var p := _j.global_position
	print("       arrivee %s" % p)
	print("       franchissements %d, dernier refus : %s"
			% [_j.get("franchissements"), _j.call("raison_refus")])

	# ON MESURE LE RAPPROCHEMENT, PAS UNE COORDONNEE. Le trottoir n'est plus a
	# un x connu d'avance : il est la ou la ville l'a mis, et l'axe change d'une
	# rue a l'autre.
	var reste := Vector2(p.x - _cible.x, p.z - _cible.z).length()
	var au_depart := Vector2(_depart.x - _cible.x, _depart.z - _cible.z).length()
	var monte := p.y > _y_trottoir * 0.6
	print("       %.1f m -> %.1f m, y = %.3f (trottoir a %.2f) : %s"
			% [au_depart, reste, p.y, _y_trottoir,
			"monte" if monte else "reste en bas"])
	return monte


func _verifier(ok: bool, message: String) -> void:
	if ok:
		print("  ok   " + message)
	else:
		_erreurs.append(message)
		printerr("  ECHEC " + message)


# ON DEMANDE A LA VILLE OU ELLE A MIS UN TROTTOIR.
#
# Les voies pietonnes du generateur sont, par construction, DESSUS : c'est la
# que marchent les vingt-six passants. Chacune est un segment le long d'une rue,
# et sa hauteur est celle du trottoir.
#
# LA CHAUSSEE EST PERPENDICULAIRE, ET ON NE SAIT PAS DE QUEL COTE. Un trottoir a
# la rue d'un cote et des maisons de l'autre, et rien dans la donnee ne dit
# lequel. On essaie donc les deux et on garde CELUI QUI EST PLUS BAS : la
# chaussee est en contrebas du trottoir, c'est la seule chose dont on soit sur.
#
# LE JOUEUR EST NOTRE SONDE. On le pose, on laisse la gravite faire une poignee
# d'images, et on lit ou il s'est arrete — c'est exactement la surface sur
# laquelle il marchera. Un rayon dirait ce que la physique touche ; lui dit ou
# il TIENT, ce qui n'est pas la meme question.
func _choisir_la_bordure(depuis: int = 0) -> bool:
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(VILLE))
	if typeof(lu) != TYPE_DICTIONARY:
		return false
	var d: Dictionary = lu
	var voies: Array = d.get("pietons", [])
	var graphe: Dictionary = d.get("graphe", {})
	var ecart := float(graphe.get("ecart_trottoir", 7.0))
	if voies.is_empty():
		return false

	for i in range(depuis * 5, mini(voies.size(), depuis * 5 + 14)):
		var v: Dictionary = voies[i]
		var a := _en_vecteur(v.get("depart", null))
		var b := _en_vecteur(v.get("arrivee", null))
		if a == Vector3.INF or b == Vector3.INF:
			continue
		var le_long := b - a
		le_long.y = 0.0
		if le_long.length() < 6.0:
			continue
		# Le milieu du segment : loin des deux carrefours qui le bornent.
		var m := a.lerp(b, 0.5)
		var perp := Vector3(-le_long.z, 0.0, le_long.x).normalized()

		for sens in [1.0, -1.0]:
			# ON LE POSE BAS ET ON LUI LAISSE LE TEMPS DE TOMBER.
			#
			# Premier jet : lache de 1,50 m pendant dix images. A 9,81 m/s2, dix
			# images font treize centimetres de chute — la sonde n'avait jamais
			# touche le sol, elle rendait la hauteur ou on venait de la poser, et
			# la suite concluait que la ville n'a pas de trottoirs.
			_j.global_position = m + perp * sens * ecart + Vector3.UP * 0.6
			_j.velocity = Vector3.ZERO
			for k in 30:
				await process_frame
			var pose := _j.global_position
			if pose.y < a.y - 0.08:
				_depart = pose
				_cible = m
				_y_trottoir = a.y
				return true
	return false


func _en_vecteur(brut: Variant) -> Vector3:
	if typeof(brut) != TYPE_ARRAY or (brut as Array).size() != 3:
		return Vector3.INF
	var t: Array = brut
	return Vector3(float(t[0]), float(t[1]), float(t[2]))


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
