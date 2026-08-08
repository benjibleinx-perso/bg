# Verifie que la voiture roule DROIT et prend ses tours.
#
#   godot --path game --script res://verifs/test_conduite.gd
#
# Ecrit apres un defaut signale au clavier : « en accelerant elle se dandine
# et fait des gauche-droite, ca la ralentit aussi ». Deux symptomes, une
# seule cause profonde — des reglages dans la mauvaise unite.
#
# wheel_friction_slip n'est PAS un coefficient entre 0 et 1 : sa valeur
# normale dans Godot est 10,5. A 0,85 on roule sur de la glace, l'arriere
# chasse, se rattrape, rechasse — c'est le dandinement — et les roues
# patinent au lieu d'entrainer, d'ou la reprise molle.
#
# On mesure donc l'ecart lateral a une trajectoire droite, la derive de cap,
# et la vitesse atteinte. Aucun de ces trois ne se juge a l'oeil sur une
# capture.
extends SceneTree

const POSE := 40
const ROULAGE := 1100

## Le temps qu'on laisse a la voiture pour se poser sur ses suspensions AVANT
## de compter quoi que ce soit.
##
## Sans lui, le test mesurait la chute. Deposee a 0,6 m du sol, elle tombe,
## rebondit et RECULE : releve du 09/08/2026, la distance au point de depart
## passait de 1,20 m a 0,86 m entre la deuxieme et la troisieme seconde. Deux
## secondes sur les sept du roulage partaient la-dedans, et la voiture finissait
## a 23 km/h sur un seuil de 45 — sans qu'aucune ligne de conduite soit en
## cause. Elle accelere de 3,3 km/h par seconde, ce qui est son allure normale.
const STABILISATION := 90

## Ce dont la voiture a besoin devant elle, en metres. A 3,3 km/h par seconde,
## atteindre 45 km/h demande une quinzaine de secondes et une centaine de
## metres ; le reste est la marge qui evite de refaire ce diagnostic.
const PISTE := 160.0
const DEMI_LARGEUR := 1.1

const ECART_MAX := 1.2      # metres de derive laterale toleres
const LACET_MAX := 6.0      # degres de derive de cap toleres
const VITESSE_MIN := 45.0   # km/h attendus apres l'acceleration

var _n := 0
var _c: Node
var _v: VehicleBody3D
var _depart := Vector3.ZERO
var _axe := Vector3.ZERO
var _cap_depart := 0.0
var _ecart_max := 0.0
var _lance := false
var _heurte := false
var _vitesse_avant := 0.0
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


## La hauteur du sol sous le point de depart, NAN s'il n'y en a pas.
##
## Cette verification manquait, et son absence a produit un test au vert sur une
## voiture en chute libre. Le desert a des bords.
func _sol_sous_la_voiture() -> float:
	var espace := _v.get_world_3d().direct_space_state
	var haut := _depart + Vector3.UP * 2.0
	var q := PhysicsRayQueryParameters3D.create(haut, _depart - Vector3.UP * 30.0)
	q.exclude = [_v.get_rid()]
	var r := espace.intersect_ray(q)
	if r.is_empty():
		printerr("       AUCUN SOL sous %s : la voiture va tomber."
				% str(_depart.round()))
		return NAN
	return float(r["position"].y)


## Combien de metres de ligne droite la voiture a devant elle.
##
## TROIS RAYONS, PAS UN. Un rayon est infiniment fin : il passe entre deux
## cactus par lesquels la voiture, elle, ne passe pas. On sonde donc la largeur
## du vehicule.
func _piste_libre() -> float:
	var espace := _v.get_world_3d().direct_space_state
	var cote := _axe.cross(Vector3.UP).normalized()
	var mini := PISTE
	for k: float in [-1.0, 0.0, 1.0]:
		var depuis: Vector3 = _depart + Vector3.UP * 0.5 + cote * (k * DEMI_LARGEUR)
		var q := PhysicsRayQueryParameters3D.create(depuis, depuis + _axe * PISTE)
		q.collide_with_areas = false
		q.exclude = [_v.get_rid()]
		var r := espace.intersect_ray(q)
		if not r.is_empty():
			var n := r["collider"] as Node
			printerr("       DEVANT : %s a %.0f m"
					% [n.name, depuis.distance_to(r["position"])])
			mini = minf(mini, depuis.distance_to(r["position"]))
	return mini


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	if _c == null:
		_c = _trouver(root, "Controleur")
		_v = _trouver(root, "Vehicule") as VehicleBody3D
		if _c == null or _v == null:
			printerr("noeuds introuvables")
			quit(1)
			return true
		_c.call("_monter")
		# En plein desert : aucun trottoir, aucun mobilier, rien a heurter.
		# Un test de trajectoire qui percute quelque chose mesure la collision.
		# LE CIRCUIT EST HORS DE TOUT, ET IL DOIT LE RESTER.
		#
		# Il roulait a soixante metres du coin de la ville. Le 31/07/2026 la
		# bande de cactus semee autour de la ville est passee de 75 a 165 m :
		# le circuit s'est retrouve dedans, la voiture a tape un saguaro au
		# bout de dix-sept metres, et le test a annonce « 0 km/h » sans qu'une
		# seule ligne de conduite ait change.
		#
		# LA MEME CHOSE S'EST REPRODUITE LE 09/08/2026, ET LE TEST NE LE DISAIT
		# TOUJOURS PAS. Les cretes de montagne sont passees de 300 et 420 m a
		# 230 et 360 m des bords nord et ouest. Le circuit etait a x = -260,
		# c'est-a-dire DERRIERE la crete ouest : la voiture accelerait
		# normalement jusqu'a 37 km/h puis percutait `montagne_col` a 27,8 m, et
		# le releve annoncait « 0 km/h, seuil 45 » — un symptome de panne moteur
		# pour un mur de roche.
		#
		# Deux choses ont change ici, et la seconde compte plus que la premiere.
		# La position, mesuree libre sur 160 m dans les quatre directions,
		# largeur de voiture comprise ; et surtout LE TEST VERIFIE MAINTENANT SA
		# PROPRE PISTE avant de rouler. Un circuit qui se retrouve dans le decor
		# une troisieme fois le dira lui-meme.
		#
		# ET IL FAUT UN SOL, pas seulement de la place. Le desert ne s'etend pas
		# a l'infini : a (260, -700) l'horizontale est degagee sur 160 m dans
		# les quatre directions ET IL N'Y A RIEN DESSOUS. La voiture tombait ;
		# vitesse_kmh() etant la norme du vecteur, chute comprise, le releve
		# annoncait 282 km/h et le test passait au vert. Un seuil de 45 km/h
		# franchi par une chute libre ne mesure rien.
		#
		# La position retenue est entre la ville et la crete ouest : sol a
		# -0,05 m, 160 m libres dans les quatre directions, largeur de voiture
		# comprise.
		_v.global_position = Vector3(-120.0, 0.6, 60.0)
		# ON NE TOUCHE PAS A SON CAP. Une premiere version le forcait a zero
		# pour rendre la piste previsible : la voiture s'est retrouvee a
		# contresens de sa poussee, a accelere en marche arriere sans jamais
		# rencontrer le plafond de vitesse — 257 km/h pour un maximum regle a
		# 130 — et la derive de cap a fini a 179,9 deg. Le cap de repos est
		# celui du jeu ; la verification de piste ci-dessous mesure la direction
		# reelle, elle n'a pas besoin qu'on la lui impose.
		_v.linear_velocity = Vector3.ZERO
		_v.angular_velocity = Vector3.ZERO
		return false

	# ON LA LAISSE SE POSER AVANT DE COMPTER. Le point de depart et le cap se
	# prennent ICI, une fois les suspensions au repos : les prendre en l'air
	# faisait mesurer la chute comme si c'etait de la conduite.
	if _n < POSE + STABILISATION:
		return false

	if not _lance:
		_lance = true
		_depart = _v.global_position
		_axe = -_v.global_transform.basis.z
		_axe.y = 0.0
		_axe = _axe.normalized()
		_cap_depart = _v.rotation.y
		var sol := _sol_sous_la_voiture()
		_verifier(not is_nan(sol), "il y a un sol sous le circuit")
		var libre := _piste_libre()
		print("       piste libre sur      %.0f m (besoin %.0f)" % [libre, PISTE])
		_verifier(libre >= PISTE, "le circuit est degage (%.0f m devant)" % libre)
		print("--- plein gaz, tout droit, aucune commande de direction ---")
		return false

	# On pousse comme une touche maintenue, sans jamais braquer.
	_v.call("_propulser", 1.0, _v.call("vitesse_kmh"))

	# LA COURBE, PAS LE POINT D'ARRIVEE. Une vitesse finale trop basse ne dit
	# pas si la voiture n'accelere pas ou si elle a simplement demarre tard —
	# et les deux ne se corrigent pas au meme endroit.
	if _n % 60 == 0:
		print("       t+%4.1f s   %5.1f km/h   %6.2f m"
				% [(_n - POSE - STABILISATION) / 60.0, _v.call("vitesse_kmh"),
				_depart.distance_to(_v.global_position)])

	# ELLE S'EST ARRETEE NET : ON DIT CONTRE QUOI.
	#
	# Le circuit est cense etre en plein desert, hors de tout ce que le
	# generateur seme. Quand il ne l'est plus, le symptome est une vitesse
	# finale basse — « 0 km/h, seuil 45 » — qui ressemble a une panne de
	# conduite et n'en est pas. C'est deja arrive le 31/07/2026 avec un cactus,
	# et le releve ne le disait pas : il a fallu le deviner.
	# On compare au MAXIMUM atteint, pas a l'image precedente : un choc met
	# quelques images a stopper la voiture, et de proche en proche l'ecart entre
	# deux images ne franchit jamais le seuil. Premiere version ratee pour ca.
	var kmh_ici: float = _v.call("vitesse_kmh")
	_vitesse_avant = maxf(_vitesse_avant, kmh_ici)
	if not _heurte and _vitesse_avant > 20.0 and kmh_ici < 3.0:
		_heurte = true
		var nez := _v.global_position + Vector3.UP * 0.4
		var espace := _v.get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(nez, nez + _axe * 4.0)
		q.exclude = [_v.get_rid()]
		var r := espace.intersect_ray(q)
		var quoi := "rien devant (elle s'est arretee toute seule)"
		if not r.is_empty():
			var n := r["collider"] as Node
			quoi = "%s/%s a %.1f m du depart" % [
					n.get_parent().name if n.get_parent() != null else "?",
					n.name, _depart.distance_to(_v.global_position)]
		printerr("       ELLE A HEURTE : %s" % quoi)


	if _n > POSE + STABILISATION + 40:
		var vers: Vector3 = _v.global_position - _depart
		vers.y = 0.0
		# Distance a la droite ideale : la composante perpendiculaire a l'axe
		# de depart. C'est la mesure du dandinement.
		var lateral := (vers - _axe * vers.dot(_axe)).length()
		_ecart_max = maxf(_ecart_max, lateral)

	if _n < POSE + STABILISATION + ROULAGE:
		return false

	var kmh: float = _v.call("vitesse_kmh")
	var parcouru: float = _depart.distance_to(_v.global_position)
	var lacet := rad_to_deg(absf(angle_difference(_cap_depart, _v.rotation.y)))

	print("       distance parcourue   %.1f m" % parcouru)
	print("       vitesse atteinte     %.1f km/h" % kmh)
	print("       ecart lateral max    %.2f m" % _ecart_max)
	print("       derive de cap        %.1f deg" % lacet)

	_verifier(parcouru > 10.0, "elle avance (%.1f m)" % parcouru)
	_verifier(_ecart_max < ECART_MAX,
			"elle roule droit (%.2f m d'ecart, seuil %.1f)" % [_ecart_max, ECART_MAX])
	_verifier(lacet < LACET_MAX,
			"elle ne se dandine pas (%.1f deg, seuil %.0f)" % [lacet, LACET_MAX])
	_verifier(kmh > VITESSE_MIN,
			"elle prend ses tours (%.0f km/h, seuil %.0f)" % [kmh, VITESSE_MIN])

	print("")
	if _erreurs.is_empty():
		print("TEST CONDUITE OK")
		quit(0)
	else:
		printerr("TEST CONDUITE ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true
