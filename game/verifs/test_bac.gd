# LE BAC A SABLE TIENT-IL CE QU'IL PROMET ?
#
#   godot --path game --script res://verifs/test_bac.gd
#
# Un banc d'essai qu'on ne verifie pas rend un verdict sur son decor en croyant
# parler de son sujet — c'est le piege 33, paye trois fois. Cette suite mesure
# donc le bac lui-meme, avant qu'on mesure quoi que ce soit dessus :
#
#   - le sol PORTE : un rayon le touche, et a la hauteur que bac.gd annonce.
#     Une piste sans sol a deja fait passer une chute libre pour 282 km/h ;
#   - la cuvette a bien la profondeur du fosse, mesuree au rayon et non lue
#     dans la constante qui l'a creusee ;
#   - la piste est PLATE et LIBRE sur cent metres ;
#   - il est seul : rien du monde a moins de trois cents metres.
extends SceneTree

## On laisse le monde se poser avant de mesurer : le sol du bac est construit
## dans son _ready, et ses collisions le sont a l'image suivante.
const POSE := 40

## D'ou l'on tire vers le bas pour trouver le sol, et jusqu'ou.
const HAUT := 40.0
const PORTEE := 120.0

## Ce qu'on tolere entre la hauteur annoncee par bac.gd et celle que le rayon
## touche. Le maillage est en facettes de deux metres : entre deux sommets, un
## point est sur la corde et non sur la courbe.
const ECART_MAX := 0.35

## La piste : d'ou a ou on la veut plate, en local, et l'ecart tolere.
const PISTE_DE := Vector3(-40.0, 0.0, 40.0)
const PISTE_A := Vector3(60.0, 0.0, 40.0)
const PISTE_PLAT := 0.05

var _n := 0
var _erreurs: Array[String] = []
var _bac: Bac = null


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	root.add_child(ps.instantiate())


func _verifier(ok: bool, msg: String) -> void:
	if ok:
		print("  ok   " + msg)
	else:
		_erreurs.append(msg)
		printerr("  ECHEC " + msg)


func _process(_d: float) -> bool:
	_n += 1
	if _n != POSE:
		return false
	_mesurer()
	return false


## Ou le sol se trouve reellement sous ce point local, en hauteur locale, ou
## INF si le rayon ne touche rien. C'est LA mesure de cette suite : tout le
## reste en decoule.
func _sol_sous(local: Vector3) -> float:
	var depart := _bac.global_position + Vector3(local.x, HAUT, local.z)
	var arrivee := depart + Vector3.DOWN * PORTEE
	var espace := _bac.get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(depart, arrivee)
	var touche := espace.intersect_ray(params)
	if touche.is_empty():
		return INF
	return (touche["position"] as Vector3).y - _bac.global_position.y


func _mesurer() -> void:
	_bac = get_first_node_in_group(Bac.GROUPE) as Bac
	if _bac == null:
		printerr("  ECHEC aucun bac a sable dans la scene")
		printerr("TEST BAC ECHOUE : 1 probleme(s)")
		quit(1)
		return

	print("\n--- le sol porte, et a la hauteur annoncee ---")
	# Quatre points qui couvrent le plat, le creux et la pente. On les prend
	# dans le meme repere que bac.gd les publie.
	var points := {
		"la piste, au depart": Vector3(20.0, 0.0, 0.0),
		"le fond de la cuvette": Vector3(Bac.CUVETTE.x, 0.0, Bac.CUVETTE.y),
		"le flanc de la cuvette": Vector3(Bac.CUVETTE.x + 12.0, 0.0, Bac.CUVETTE.y),
		"le haut de la rampe": Vector3(Bac.RAMPE_X + Bac.RAMPE_LONGUEUR - 2.0, 0.0, 50.0),
	}
	for nom in points:
		var p: Vector3 = points[nom]
		var mesure := _sol_sous(p)
		var annonce := _bac.hauteur(p.x, p.z)
		if mesure == INF:
			_verifier(false, "%s : AUCUN SOL sous (%.0f, %.0f)" % [nom, p.x, p.z])
			continue
		print("       %-24s annonce %+.2f m, mesure %+.2f m" % [nom, annonce, mesure])
		_verifier(absf(mesure - annonce) <= ECART_MAX,
				"%s : le sol est la ou bac.gd le dit (%.2f m d'ecart)"
						% [nom, absf(mesure - annonce)])

	print("\n--- la cuvette a la profondeur du fosse ---")
	var fond := _sol_sous(Vector3(Bac.CUVETTE.x, 0.0, Bac.CUVETTE.y))
	var bord := _sol_sous(Vector3(Bac.CUVETTE.x + Bac.CUVETTE_RAYON + 4.0,
			0.0, Bac.CUVETTE.y))
	print("       fond a %+.2f m, bord a %+.2f m, soit %.2f m de creux"
			% [fond, bord, bord - fond])
	_verifier(absf((bord - fond) - absf(Bac.CUVETTE_FOND)) <= 0.4,
			"le creux mesure fait bien %.1f m" % absf(Bac.CUVETTE_FOND))

	print("\n--- la piste est plate sur cent metres ---")
	var plat := true
	var pire := 0.0
	var ou := 0.0
	for i in 21:
		var t := float(i) / 20.0
		var p: Vector3 = PISTE_DE.lerp(PISTE_A, t)
		var h := _sol_sous(p)
		if h == INF:
			plat = false
			ou = p.x
			break
		if absf(h) > pire:
			pire = absf(h)
			ou = p.x
	_verifier(plat and pire <= PISTE_PLAT,
			"cent metres de piste sans un creux (le pire : %.3f m en x=%.0f)"
					% [pire, ou])

	print("\n--- et il est seul ---")
	# On refait la mesure du degagement ici plutot que de croire le message
	# imprime au chargement : un controle qui relit un print ne verifie rien.
	var proche := INF
	var quoi := ""
	var comptes := 0
	var pile: Array[Node] = [root]
	while not pile.is_empty():
		var n: Node = pile.pop_back()
		if n == _bac:
			continue
		for e in n.get_children():
			pile.append(e)
		var mi := n as MeshInstance3D
		if mi == null:
			continue
		comptes += 1
		var d := mi.global_position.distance_to(_bac.global_position)
		if d < proche:
			proche = d
			quoi = str(mi.name)
	print("       %d maillage(s) mesures, le plus proche « %s » a %.0f m"
			% [comptes, quoi, proche])
	_verifier(comptes > 0, "la mesure a bien regarde quelque chose")
	_verifier(proche >= Bac.DEGAGEMENT,
			"rien du monde a moins de %.0f m" % Bac.DEGAGEMENT)

	print("")
	if _erreurs.is_empty():
		print("TEST BAC OK")
		quit(0)
	else:
		printerr("TEST BAC ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
