# LA CLAIRIERE DU FLASHBACK : est-ce que tout y touche le sol, et rien la pierre ?
#
#     godot --headless --path game --script res://verifs/test_clairiere.gd
#
# CE QUE CA GARDE. Trois defauts releves d'un coup par Guillaume le 23/08/2026,
# et ils ont la meme cause :
#
#   « Le RV est a cheval sur un caillou et flotte un peu dans le vide. Il faut
#     juste le mettre sur un sol plat. Mais garder l'idee du gros massif qui le
#     cache de la route. Jesse lui est carrement dans la pierre. Le deplacer
#     ailleurs. On peut traverser le RV. Il faut le rendre solide. »
#
# LA CAUSE COMMUNE : ce decor est pose A LA MAIN dans un terrain GENERE. Les
# rochers viennent de gen_desert.py, la mesa d'un fichier de lieux, et les
# coordonnees ecrites dans la scene ne savent rien de tout ca. Elles etaient
# justes le jour ou on les a posees ; elles ne le sont plus des que la graine
# du desert bouge — et rien ne le dit, parce qu'un personnage a mi-corps dans
# un caillou ne plante pas.
#
# C'est pour ca que ce controle mesure des RAYONS plutot que des positions :
# il reste vrai apres une regeneration.
extends SceneTree

## L'etape a laquelle la clairiere existe. Avant le flashback, elle est cachee.
const ETAPE := "flashback"

## Ce qui ne doit avoir NI pierre ni relief dans les jambes, et sur quelle
## hauteur on regarde. Un personnage debout mesure 1,78 m ; on verifie le bas
## du corps, la ou l'enfoncement se voit.
const DEBOUT := {
	"JesseClairiere": 1.2,
}

## Combien de centimetres de denivele on tolere sous le camping-car.
##
## Il fait neuf metres de long : sur du sable qui monte, ses quatre roues ne
## seront jamais a la meme altitude au centimetre pres. Trente centimetres,
## c'est une pente qu'on ne voit pas ; au-dela, une roue decolle et l'ombre se
## detache du pneu — ce que Guillaume appelle « flotte un peu dans le vide ».
const DENIVELE_TOLERE := 0.30

## Les quatre coins ou l'on mesure, dans le repere du camping-car. Il fait
## 9 m sur 3 : on prend les essieux, pas les pare-chocs.
const COINS := [
	Vector3(-1.3, 0.0, -3.2),
	Vector3(1.3, 0.0, -3.2),
	Vector3(-1.3, 0.0, 3.2),
	Vector3(1.3, 0.0, 3.2),
]

var _erreurs := 0
var _monde: Node


func _initialize() -> void:
	if FileAccess.file_exists("user://partie.json"):
		DirAccess.remove_absolute("user://partie.json")
	_monde = (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(_monde)
	await process_frame
	await process_frame

	var mission := _trouver(root, "Mission") as Mission
	if mission == null:
		printerr("ECHEC aucune mission")
		quit(1)
		return

	# LA CLAIRIERE N'EXISTE QU'AU FLASHBACK, et son ancrage la cache avant.
	mission.call("aller_a", _rang(mission, ETAPE))
	for _i in 12:
		await process_frame

	var rv := _trouver(root, "CampingCarClairiere") as Node3D
	if rv == null:
		printerr("ECHEC le camping-car de la clairiere est introuvable")
		quit(1)
		return

	# 1. LE SOL SOUS LE CAMPING-CAR EST-IL PLAT ?
	print("")
	print("--- le camping-car repose sur quelque chose de plat ---")
	var hauts: Array[float] = []
	for coin in COINS:
		var monde: Vector3 = rv.to_global(coin)
		var h := _sol_sous(monde, _corps_de(rv))
		if h == null_hauteur():
			_echec("aucun sol trouve sous le coin %s" % _plat(monde))
			continue
		hauts.append(h)
	if hauts.size() == COINS.size():
		var bas: float = hauts.min()
		var haut: float = hauts.max()
		var ecart := haut - bas
		print("       sol sous les quatre roues : %.2f a %.2f m"
				% [bas, haut])
		_verifier(ecart <= DENIVELE_TOLERE,
				"le denivele sous le vehicule est de %.2f m (max %.2f)"
						% [ecart, DENIVELE_TOLERE])
		if ecart > DENIVELE_TOLERE:
			_ou_est_le_plat(rv)
		# ET IL REPOSE DESSUS, il ne plane pas au-dessus. On compare le bas de
		# la caisse au plus HAUT des quatre sols : c'est celui-la qui porte.
		var sous_la_caisse := rv.global_position.y
		_verifier(absf(sous_la_caisse - haut) <= DENIVELE_TOLERE * 2.0,
				"il pose dessus : caisse a %.2f m, sol le plus haut a %.2f m"
						% [sous_la_caisse, haut])

	# 2. LE CAMPING-CAR EST-IL SOLIDE ?
	#
	# « On peut traverser le RV. Il faut le rendre solide. » Un .glb ne
	# transporte aucun corps physique : sans un StaticBody3D pose a la main, on
	# marche au travers, et c'est exactement ce que Guillaume a fait.
	print("")
	print("--- et on ne le traverse pas ---")
	_verifier(_a_un_corps(rv),
			"il porte un corps de collision")

	# 3. PERSONNE N'EST DANS LA PIERRE.
	print("")
	print("--- personne n'a les jambes dans un rocher ---")
	for nom in DEBOUT:
		var qui := _trouver(root, str(nom)) as Node3D
		if qui == null:
			_echec("« %s » introuvable" % nom)
			continue
		var dedans := _obstrue(qui.global_position, float(DEBOUT[nom]))
		_verifier(not dedans,
				"%s se tient sur le sable, pas dedans (%s)"
						% [nom, _plat(qui.global_position)])

	print("")
	if _erreurs > 0:
		printerr("TEST CLAIRIERE ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST CLAIRIERE OK")
	quit(0)


## Une valeur qui ne peut pas etre une altitude de ce desert. Sert de « rien
## trouve » — GDScript n'a pas de float nul, et rendre 0.0 confondrait un rayon
## perdu avec un sol au niveau de la mer.
func null_hauteur() -> float:
	return -9999.0


# L'ALTITUDE DU SOL SOUS CE POINT, ou null_hauteur().
#
# On part de dix metres au-dessus et on descend : c'est ce que fait pose_au_sol,
# et pour la meme raison — le terrain est genere, on le lui demande plutot que
# de le deviner.
# QUAND CA NE POSE PAS, ON DIT OU CA POSERAIT.
#
# Un « le denivele est de 1,40 m » envoie deplacer le vehicule sans dire DE
# COMBIEN ni DANS QUEL SENS. Le desert est genere : ses rochers ne se lisent
# dans aucun fichier, et un deplacement a vue de cinq metres a fait passer le
# denivele de 1,40 m a 1,73 — pire, en croyant mieux faire.
#
# On balaie donc une grille, on mesure sous les quatre roues a chaque nœud, et
# on imprime les meilleurs. Il ne tourne QUE sur echec : balayer six cents
# points a chaque lancement couterait des milliers de rayons pour rien.
#
# TOUT SORT PAR printerr, ET C'EST DELIBERE. `print` ecrit sur la sortie
# standard, dont le tampon n'est pas vide au moment du quit() : ce diagnostic a
# disparu deux fois avant qu'on remarque son absence. Voir le piege 62.
func _ou_est_le_plat(rv: Node3D) -> void:
	var depart := rv.global_position
	var base: Transform3D = rv.global_transform
	var sauf := _corps_de(rv)
	var trouves: Array = []
	for ix in range(-7, 8):
		for iz in range(-7, 8):
			var essai := depart + Vector3(ix * 2.0, 0.0, iz * 2.0)
			var bas := INF
			var haut := -INF
			var complet := true
			for coin in COINS:
				var decale: Vector3 = coin
				var h := _sol_sous(essai + base.basis * decale, sauf)
				if h == null_hauteur():
					complet = false
					break
				bas = minf(bas, h)
				haut = maxf(haut, h)
			if complet:
				trouves.append([haut - bas, ix * 2.0, iz * 2.0, haut])
	trouves.sort_custom(func(a, b): return a[0] < b[0])
	printerr("       ou ca poserait a plat, en decalage MONDE :")
	for i in mini(5, trouves.size()):
		var t: Array = trouves[i]
		printerr("         (%+.1f, %+.1f) -> denivele %.2f m, sol a %.2f"
				% [t[1], t[2], t[0], t[3]])


## ON EXCLUT LE VEHICULE LUI-MEME, ET C'EST UN PIEGE DEJA PAYE AILLEURS.
##
## Le rayon part de dix metres au-dessus et descend : il touche donc d'abord le
## TOIT du camping-car, qui fait trois metres de haut. Le controle annoncait
## « sol a 2,90 m, caisse a 0,00 m » — un vehicule enterre de trois metres dans
## un sol parfaitement plat. Les deux chiffres etaient exacts, et le second
## mesurait le premier.
##
## C'est mot pour mot ce que pose_au_sol a appris sur le semis de debris du
## fosse — « tout le semis se posait sur son TOIT » — et c'est reapparu ici a la
## seconde ou l'on a rendu la coque solide, c'est-a-dire dans le meme commit.
func _sol_sous(ou: Vector3, sauf: Array = []) -> float:
	# ON DEMANDE L'ESPACE A LA FENETRE, PAS AU MONDE.
	#
	# `_monde` est la racine de monde.tscn, un Node ordinaire : il n'a pas de
	# `get_world_3d()`. C'est le viewport qui porte le monde 3D, et root en est
	# un — c'est le meme chemin quelle que soit la scene chargee.
	var espace: PhysicsDirectSpaceState3D = root.world_3d.direct_space_state
	var haut := ou + Vector3.UP * 10.0
	var bas := ou + Vector3.DOWN * 10.0
	var q := PhysicsRayQueryParameters3D.create(haut, bas)
	q.collide_with_areas = false
	q.exclude = sauf
	var t := espace.intersect_ray(q)
	if t.is_empty():
		return null_hauteur()
	return float((t["position"] as Vector3).y)


# LES IDENTIFIANTS PHYSIQUES D'UN NOEUD ET DE SES ENFANTS, pour les exclure
# d'un rayon. Un seul suffit aujourd'hui — la coque — mais un vehicule qui
# gagnerait des roues solides en aurait cinq, et un rayon qui en oublie un
# mesure le pneu au lieu du sable.
func _corps_de(n: Node) -> Array:
	var rids: Array = []
	if n is CollisionObject3D:
		rids.append((n as CollisionObject3D).get_rid())
	for e in n.get_children():
		rids.append_array(_corps_de(e))
	return rids


# Y A-T-IL QUELQUE CHOSE DANS LES JAMBES DE QUELQU'UN QUI SE TIENT LA ?
#
# On tire un rayon HORIZONTAL a mi-hauteur, sur un metre, dans quatre
# directions. Un personnage plante dans un rocher en touche au moins une ; un
# personnage debout a cote n'en touche aucune.
#
# Pas un rayon vertical : le sol est sous tout le monde, et il repondrait oui
# partout.
func _obstrue(pieds: Vector3, hauteur: float) -> bool:
	# ON DEMANDE L'ESPACE A LA FENETRE, PAS AU MONDE.
	#
	# `_monde` est la racine de monde.tscn, un Node ordinaire : il n'a pas de
	# `get_world_3d()`. C'est le viewport qui porte le monde 3D, et root en est
	# un — c'est le meme chemin quelle que soit la scene chargee.
	var espace: PhysicsDirectSpaceState3D = root.world_3d.direct_space_state
	var centre := pieds + Vector3.UP * (hauteur * 0.5)
	for d in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
		var q := PhysicsRayQueryParameters3D.create(centre, centre + d * 0.9)
		q.collide_with_areas = false
		if not espace.intersect_ray(q).is_empty():
			return true
	return false


func _a_un_corps(n: Node) -> bool:
	if n is CollisionObject3D:
		return true
	for e in n.get_children():
		if _a_un_corps(e):
			return true
	return false


func _plat(v: Vector3) -> String:
	return "(%.1f, %.1f)" % [v.x, v.z]


func _rang(mission: Mission, cle: String) -> int:
	var etapes: Array = mission.etapes()
	for i in etapes.size():
		if str((etapes[i] as Dictionary).get("cle", "")) == cle:
			return i
	printerr("  ECHEC aucune etape '%s'" % cle)
	_erreurs += 1
	return 0


func _verifier(ok: bool, quoi: String) -> void:
	if ok:
		print("  ok   " + quoi)
	else:
		_erreurs += 1
		printerr("  ECHEC " + quoi)


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC " + quoi)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null
