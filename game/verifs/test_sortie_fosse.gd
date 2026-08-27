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

## L ecart de la fumee et des phares au vehicule, releve avant de rouler.
var _ecart_depart: Dictionary = {}
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


# Cette cle est-elle une etape d'une AUTRE mission du jeu ?
#
# marmonnements.json est partage : ses cles couvrent la mission de rodage comme
# celle du fosse. Sans cette question, tout ce qui appartient a l'autre deroule
# serait denonce comme orphelin, et le controle crierait a chaque lancement
# jusqu'a ce qu'on cesse de le lire.
#
# ON LIT LE FICHIER, on ne recopie pas la liste : une liste de cles recopiee
# dans un test est exactement ce qui vient de diverger.
const AUTRES_MISSIONS := ["res://donnees/mission1.json"]


func _cle_d_une_autre_mission(cle: String) -> bool:
	for chemin in AUTRES_MISSIONS:
		var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(chemin))
		if typeof(lu) != TYPE_DICTIONARY:
			continue
		for e in (lu as Dictionary).get("etapes", []):
			if str((e as Dictionary).get("cle", "")) == cle:
				return true
	return false


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

		# JESSE PARLE PENDANT LA SCENE, et il se taisait completement.
		#
		# « Il faut que Jesse fasse davantage de dialogues (qui ne figent ni le
		# jeu, ni le joueur) juste des dialogues de Jesse stresse et paniqué. »
		# La mission portait « pensees »: false — donc le systeme tournait a
		# vide, et aucune phrase ne pouvait sortir quoi qu'on ecrive.
		var d0: Dictionary = _mission.call("donnees")
		_verifier(bool(d0.get("pensees", true)),
				"les phrases de scene sont actives dans cette mission")
		var ecart := float(d0.get("pensees_intervalle", 42.0))
		_verifier(ecart <= 20.0,
				"elles s'enchainent a un rythme de scene, pas de trajet"
				+ " (%.0f s)" % ecart)

		# Et il a vraiment de quoi dire, sur les etapes de CETTE mission.
		var lu: Variant = JSON.parse_string(
				FileAccess.get_file_as_string("res://donnees/marmonnements.json"))
		var muettes: Array[String] = []
		for cle in ["jesse_panique", "preuve_1", "preuve_3", "demarrer"]:
			if typeof(lu) != TYPE_DICTIONARY or not (lu as Dictionary).has(cle):
				muettes.append(cle)
		_verifier(muettes.is_empty(),
				"chaque temps fort a ses phrases (muets : %s)"
				% ("aucun" if muettes.is_empty() else ", ".join(muettes)))

		# ET DANS L'AUTRE SENS : AUCUNE PHRASE NE PARLE A UN FANTOME.
		#
		# Celui-la manquait, et il a coute une soiree. Les phrases sont rangees
		# PAR CLE D'ETAPE ; quand une etape disparait du deroule, les siennes ne
		# cassent rien et ne s'affichent plus jamais. Trois d'un coup se sont
		# tues ainsi le 24/08/2026 — 'reveil' et 'pantalon', dont les etapes
		# sortaient du suivi de mission, puis 'remonter', fusionnee avec la
		# suivante — et le controle ci-dessus etait vert : il regarde ce qui
		# existe, jamais ce qui pointe dans le vide.
		#
		# On ne lit QUE les cles de cette mission-la : le fichier sert aussi la
		# mission de rodage, dont les etapes ne sont pas ici.
		var orphelines: Array[String] = []
		if typeof(lu) == TYPE_DICTIONARY:
			for cle in (lu as Dictionary).keys():
				var nom := str(cle)
				if nom.begins_with("_"):
					continue
				if _mission.call("contient", nom):
					continue
				# Une cle inconnue de CETTE mission peut appartenir a une autre.
				# On ne la denonce que si le fichier de la mission de rodage ne
				# la connait pas non plus.
				if _cle_d_une_autre_mission(nom):
					continue
				orphelines.append(nom)
		_verifier(orphelines.is_empty(),
				"aucune phrase ne vise une etape disparue (%s)"
				% ("aucune" if orphelines.is_empty() else ", ".join(orphelines)))

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
		# On note ce que la caisse emporte AVANT de rouler : c'est l'ecart au
		# vehicule, pas la position, qui doit survivre au trajet.
		for quoi in ["Fumee", "Phares"]:
			var n := _trouver(root, quoi) as Node3D
			if n != null and _vehicule != null:
				_ecart_depart[quoi] = n.global_position.distance_to(
						_vehicule.global_position)
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

			# ET CE QUI EST DESSUS PART AVEC LUI.
			#
			# « La fumee suit le camping-car au lieu de rester au sol a
			# l'endroit du crash » — retour du 23/08/2026. Elle etait bien
			# accrochee a la caisse, mais POSEE UNE FOIS, a la construction de
			# la scene : tant que l'epave restait gelee dans son fosse, on ne
			# pouvait pas le voir. Le jour ou elle repart, la fumee et les
			# phares restaient plantes dans le sable derriere.
			#
			# On mesure l'ECART AU VEHICULE avant et apres avoir roule : c'est
			# lui qui doit rester constant, pas la position. Le comparer a
			# l'endroit du depart dirait le contraire de ce qu'on veut.
			for quoi in ["Fumee", "Phares"]:
				var n := _trouver(root, quoi) as Node3D
				if n == null:
					_verifier(false, "« %s » existe dans la scene" % quoi)
					continue
				var ecart := n.global_position.distance_to(v.global_position)
				print("    %s : %.2f m du vehicule (au depart %.2f)"
						% [quoi, ecart, _ecart_depart.get(quoi, -1.0)])
				_verifier(absf(ecart - float(_ecart_depart.get(quoi, 0.0))) < 0.5,
						"« %s » est partie avec la caisse" % quoi)

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
