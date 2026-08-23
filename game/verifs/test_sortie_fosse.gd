# EST-CE QU'ON PEUT VRAIMENT SORTIR DU FOSSE, EN CONDUISANT COMME UN JOUEUR ?
#
#     godot --headless --path game --script res://verifs/test_sortie_fosse.gd
#
# CE QUE LES AUTRES NE VOIENT PAS.
#
# `test -Suite roulage` appelle `Passage.rouler()` en direct : elle verifie le
# compteur, jamais le franchissement. Elle est verte depuis toujours, et elle
# n'aurait rien vu si la zone ne detectait pas le vehicule, si l'etape le
# refusait, ou si le camping-car ne montait pas assez vite. C'est le piege 19 —
# une verification qui se place elle-meme au bon endroit valide toujours.
#
# Celle-ci pose le camping-car AU FOND DU FOSSE, met les gaz, et regarde deux
# choses : la vitesse qu'il atteint reellement en remontant, et si la sortie
# finit par s'ouvrir.
#
# POURQUOI CETTE MESURE EXISTE : Guillaume, le 23/08/2026 a 23 h 24 — « j'arrive
# pas a declencher les pompiers, je vais sur la piste mais ca declenche rien ».
# La sortie demande de rouler trois secondes AU-DESSUS DE 8 KM/H, et le
# camping-car remonte la pente en peinant. Si sa vitesse passe sous le seuil, le
# compteur retombe a zero — et rien ne s'affiche, puisque de l'avis du code il
# n'y a rien a corriger.
extends SceneTree

const POSE := 60

## Combien de temps on pousse les gaz, en images.
const CONDUITE := 900

var _n := 0
var _etape := 0
var _monde: Node
var _mission: Node
var _vehicule: Node3D
var _zone: Node3D
var _erreurs: Array[String] = []

var _vitesse_max := 0.0
var _images_au_dessus := 0
var _ouverte := false
var _depart := 0


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
	root.add_child(_monde)


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


func _aller_a_l_etape(cle: String) -> bool:
	var etapes: Array = _mission.call("etapes")
	for k in etapes.size():
		if str((etapes[k] as Dictionary).get("cle", "")) == cle:
			_mission.call("aller_a", k)
			return true
	return false


func _process(delta: float) -> bool:
	_n += 1

	if _etape == 0:
		if _n < POSE:
			return false
		_mission = _trouver(root, "Mission")
		_zone = _trouver(root, "SortieCrash") as Node3D
		_vehicule = _trouver(root, "CampingCar") as Node3D
		if _mission == null or _zone == null:
			printerr("ECHEC la mission ou la zone de sortie sont introuvables")
			quit(1)
			return true
		_verifier(_vehicule != null,
				"le camping-car existe dans le monde")
		if _vehicule == null:
			_etape = 9
			return false

		print("--- ou est la zone, et ou est le vehicule ---")
		var d := _vehicule.global_position.distance_to(_zone.global_position)
		print("    camping-car %s, zone %s"
				% [_vehicule.global_position, _zone.global_position])
		_verifier(d < 80.0,
				"la zone de sortie est a portee du camping-car (%.1f m)" % d)

		_verifier(_aller_a_l_etape("sortir_du_fosse"),
				"l'etape 'sortir_du_fosse' existe")

		# ET QUELQU'UN ECOUTE. La suite « roulage » verifie que le passage
		# EMET ses signaux ; elle resterait verte si personne ne les branchait,
		# et Jesse se tairait exactement comme avant. C'est ici qu'on regarde
		# le fil, parce qu'ici le monde entier est charge.
		_verifier(_zone.get_signal_connection_list("commence").size() > 0,
				"quelqu'un ecoute quand on commence a rouler")
		_verifier(_zone.get_signal_connection_list("interrompu").size() > 0,
				"et quand on s'arrete avant la fin")

		# ON DEGELE L'EPAVE PAR LE VRAI FIL.
		#
		# Le camping-car est un corps FIGE tant que le moteur n'a pas pris :
		# lache dans la pose du crash, il se redresserait tout seul. Le degel
		# se fait quand le demarreur reussit, et pas avant.
		#
		# Premiere version de ce controle : elle allait droit a l'etape et
		# poussait les gaz. Zero kilometre-heure en quinze secondes, et le
		# coupable etait le TEST — le vehicule etait gele, ce que le jeu ne
		# fait jamais a ce moment-la.
		#
		# On emet donc la reussite du demarreur, ce qui reveille l'epave par le
		# meme chemin que le jeu. Le mini-jeu lui-meme n'est pas rejoue ici :
		# c'est la suite « parcours » qui le joue a la main.
		var demarreurs := root.get_tree().get_nodes_in_group("demarreur")
		_verifier(not demarreurs.is_empty(),
				"le demarreur du camping-car est dans le monde")
		for dem in demarreurs:
			dem.emit_signal("reussi")
		_etape = 1
		return false

	# ------------------------------------------------ ON CONDUIT VERS LA SORTIE
	#
	# On ne teleporte PAS le vehicule sur la zone : ce serait exactement le
	# piege 19 une seconde fois. On le laisse ou le jeu l'a mis, et on pousse
	# les gaz vers la sortie, comme un joueur qui veut s'en aller.
	if _etape == 1:
		print("--- on met les gaz vers la piste ---")
		_depart = _n
		_etape = 2
		return false

	if _etape == 2:
		var v := _vehicule as VehicleBody3D
		if v == null:
			_verifier(false, "le camping-car n'est pas un vehicule conduisible")
			_etape = 9
			return false

		# Plein gaz, roues droites vers la zone.
		var vers := (_zone.global_position - v.global_position)
		vers.y = 0.0
		if vers.length() > 1.0:
			var avant := -v.global_transform.basis.z
			var angle := avant.signed_angle_to(vers.normalized(), Vector3.UP)
			v.steering = clampf(angle, -0.5, 0.5)
		v.engine_force = 4000.0
		v.brake = 0.0

		var kmh := v.linear_velocity.length() * 3.6
		_vitesse_max = maxf(_vitesse_max, kmh)
		if kmh >= 8.0:
			_images_au_dessus += 1
		if _zone.call("roule_assez"):
			_ouverte = true

		if _ouverte or _n > _depart + CONDUITE:
			print("    vitesse maximale atteinte : %.1f km/h" % _vitesse_max)
			print("    images au-dessus de 8 km/h : %d sur %d"
					% [_images_au_dessus, _n - _depart])
			print("    distance restante : %.1f m"
					% v.global_position.distance_to(_zone.global_position))
			_verifier(_vitesse_max >= 8.0,
					"le camping-car depasse les 8 km/h que la sortie exige"
					+ " (%.1f km/h)" % _vitesse_max)

			# CE QUE CE CONTROLE NE PEUT PAS DIRE, et il vaut mieux l'ecrire
			# que de laisser un rouge qu'on cesserait de lire.
			#
			# Le compteur de la sortie n'avance que pour le vehicule que LE
			# CONTROLEUR conduit — `rouler(contient(corps) and au_volant, ...)`.
			# Ici on pousse la caisse sans que Walter soit au volant : le
			# compteur reste donc a zero quoi qu'on fasse, et exiger
			# l'ouverture serait accuser le jeu de ce que le test ne fait pas.
			#
			# Mettre le joueur au volant demande de passer par le point du
			# volant, donc par le mini-jeu de demarrage. C'est ce que fait la
			# suite « parcours », et c'est LA qu'il faut regarder — elle bute
			# sur cette etape depuis le 17/08.
			print("    (l'ouverture elle-meme se joue dans la suite 'parcours' :")
			print("     le compteur n'avance que pour le vehicule CONDUIT)")
			_etape = 9
		return false

	print("")
	if _erreurs.is_empty():
		print("la sortie du fosse : tout est vert")
		quit(0)
	else:
		printerr("la sortie du fosse : %d echec(s)" % _erreurs.size())
		quit(1)
	return true
