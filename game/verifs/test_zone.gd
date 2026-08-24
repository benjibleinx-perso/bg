# Peut-on partir faire sa vie au milieu d'une mission ?
#
#     godot --headless --path game --script res://verifs/test_zone.gd
#
# CE QUE CA GARDE. La zone de mission, demandee le 23/08/2026 : on est rappele
# quand on s'eloigne, puis un decompte de dix secondes se lance si l'on
# s'obstine, et il finit la partie.
#
# LES QUATRE FAITS, ET LE DERNIER EST CELUI QU'ON OUBLIE :
#
#   1. dans la zone, il ne se passe RIEN — une zone qui se declenche a
#      l'endroit ou l'on doit se tenir est pire que pas de zone ;
#   2. au-dela du rappel, quelqu'un le dit ;
#   3. au-dela de la limite, le decompte tourne ;
#   4. REVENIR L'ANNULE. C'est ce qui distingue un avertissement d'une
#      condamnation, et rien d'autre dans le jeu ne le verifie.
extends SceneTree

## L'etape ou la zone doit valoir. La mission demarre au masque ;
## « jesse_panique » est la premiere ou l'on tient debout, et c'est la que la
## zone commence.
##
## C'ETAIT « reveil », l'etape qui envoyait regarder les deux corps. Le retour
## du 23/08/2026 les sort du suivi de mission : elle n'existe plus, et ce test
## a crie tout de suite — c'est exactement ce qu'on lui demande.
const ETAPE := "jesse_panique"

## Et une etape ou elle NE doit PAS valoir : celle ou l'on part.
const ETAPE_LIBRE := "sortir_du_fosse"

var _erreurs := 0


func _initialize() -> void:
	var monde := (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(monde)
	await process_frame
	await process_frame

	var zone := _trouver(root, "ZoneMission")
	var mission := _trouver(root, "Mission") as Mission
	var joueur := _trouver(root, "Joueur") as Node3D
	var centre := _trouver(root, "SiteCrash") as Node3D
	if zone == null or mission == null or joueur == null or centre == null:
		printerr("ECHEC monde incomplet (ZoneMission, Mission, Joueur, SiteCrash)")
		quit(1)
		return

	mission.call("aller_a", _rang(mission, ETAPE))
	await process_frame
	await process_frame

	if not bool(zone.call("active")):
		printerr("ECHEC aucune zone active a l'etape '%s'" % ETAPE)
		quit(1)
		return
	print("")
	print("--- la zone est en place a l'etape '%s' ---" % ETAPE)

	# 1. AU CENTRE, IL NE SE PASSE RIEN.
	joueur.global_position = centre.global_position
	for _i in 20:
		await process_frame
	if float(zone.call("compte")) >= 0.0:
		_echec("le decompte tourne alors qu'on est au milieu de la zone")
	else:
		print("  ok   au centre, rien ne se declenche")

	# 3. AU-DELA DE LA LIMITE, LE DECOMPTE TOURNE.
	joueur.global_position = centre.global_position + Vector3(200.0, 0.0, 0.0)
	var lance := -1.0
	for _i in 30:
		await process_frame
		lance = float(zone.call("compte"))
		if lance >= 0.0:
			break
	if lance < 0.0:
		_echec("a deux cents metres, aucun decompte")
	else:
		print("  ok   au-dela de la limite, le decompte part (%.1f s)" % lance)

	# ... ET IL DESCEND. Un compteur arme qui ne bouge pas ne condamne rien.
	for _i in 30:
		await process_frame
	var descendu := float(zone.call("compte"))
	if not (descendu < lance):
		_echec("le decompte ne descend pas (%.1f puis %.1f)" % [lance, descendu])
	else:
		print("  ok   il descend (%.1f puis %.1f)" % [lance, descendu])

	# 4. REVENIR L'ANNULE.
	joueur.global_position = centre.global_position
	for _i in 20:
		await process_frame
	if float(zone.call("compte")) >= 0.0:
		_echec("revenir n'annule pas le decompte")
	else:
		print("  ok   revenir l'annule")

	# ET ELLE SE TAIT LA OU LA MISSION DEMANDE DE PARTIR.
	print("")
	print("--- a l'etape '%s', on a le droit de s'en aller ---" % ETAPE_LIBRE)
	mission.call("aller_a", _rang(mission, ETAPE_LIBRE))
	await process_frame
	await process_frame
	joueur.global_position = centre.global_position + Vector3(200.0, 0.0, 0.0)
	for _i in 30:
		await process_frame
	if bool(zone.call("active")) or float(zone.call("compte")) >= 0.0:
		_echec("la zone tient encore alors que l'etape consiste a partir")
	else:
		print("  ok   elle est levee")

	print("")
	if _erreurs > 0:
		printerr("TEST ZONE ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST ZONE OK")
	quit(0)


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC %s" % quoi)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


# Le rang d'une etape, par sa cle. On saute PAR CLE et pas par numero : une
# etape inseree au milieu decalerait tous les numeros, et le test irait
# mesurer autre chose sans rien dire.
func _rang(mission: Mission, cle: String) -> int:
	var etapes: Array = mission.etapes()
	for i in etapes.size():
		if str((etapes[i] as Dictionary).get("cle", "")) == cle:
			return i
	printerr("ECHEC aucune etape '%s' dans la mission" % cle)
	quit(1)
	return 0
