# Les invites affichent-elles la touche qu'il faut vraiment presser ?
#
#     godot --headless --path game --script res://verifs/test_commandes.gd
#
# CE QUE CA ATTRAPE. Les invites du jeu ont ete ecrites en dur pendant six
# mois — « F   Descendre ». Rien ne les relie a l'InputMap : le jour ou la
# touche d'action change, elles restent affichables, lisibles, et fausses.
# Une invite fausse ne plante pas, ne rougit aucun test, et se decouvre en
# jouant, devant une portiere qui ne s'ouvre pas.
#
# Le test verifie donc les deux bouts de la chaine : la touche declaree dans
# project.godot, et le TEXTE que le joueur lit.
extends SceneTree

# Ce que le jeu attend aujourd'hui. Un changement volontaire se declare ici,
# ce qui laisse une trace ; un changement accidentel rougit.
const ATTENDU := {
	"interagir": KEY_E,
	"gaz": KEY_W,
	"frein": KEY_S,
	"gauche": KEY_A,
	"droite": KEY_D,
}

var _erreurs := 0


func _initialize() -> void:
	print("")
	print("--- les touches declarees ---")
	for action in ATTENDU:
		var voulu: int = ATTENDU[action]
		if not InputMap.has_action(action):
			_echec("l'action '%s' n'existe pas" % action)
			continue
		var trouve := 0
		for e in InputMap.action_get_events(action):
			if e is InputEventKey and (e as InputEventKey).physical_keycode == voulu:
				trouve = voulu
				break
		if trouve == 0:
			_echec("'%s' n'est pas sur %s" % [action, OS.get_keycode_string(voulu)])
		else:
			print("  ok   %-10s %s" % [action, OS.get_keycode_string(voulu)])

	print("")
	print("--- ce que le joueur lit ---")
	# La touche d'action est celle qui s'affiche le plus souvent : elle porte
	# toutes les invites du monde ouvert et toutes celles des menus.
	var nom := Touches.nom("interagir")
	if nom == "?" or nom.is_empty():
		_echec("Touches.nom('interagir') ne rend aucun nom")
	else:
		print("  ok   invite d'action : « %s »" % Touches.invite("interagir", "Descendre"))

	# Une action absente doit se voir, pas se taire : une invite vide devant
	# une portiere ressemble a une portiere qui ne s'ouvre pas.
	if Touches.nom("action_qui_n_existe_pas") != "?":
		_echec("une action inconnue devrait rendre '?'")

	for action in ["interagir", "saut", "sprint", "accroupir", "roue", "telephone"]:
		var lisible := Touches.nom(action)
		if lisible == "?" or lisible.is_empty():
			_echec("'%s' n'a pas de nom affichable" % action)
		else:
			print("  ok   %-10s s'affiche « %s »" % [action, lisible])

	print("")
	if _erreurs > 0:
		printerr("TEST COMMANDES ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST COMMANDES OK")
	quit(0)


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC %s" % quoi)
