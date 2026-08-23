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

	_regler_une_commande()

	print("")
	if _erreurs > 0:
		printerr("TEST COMMANDES ECHOUE : %d probleme(s)" % _erreurs)
		quit(1)
		return
	print("TEST COMMANDES OK")
	quit(0)


# ON REGLE UNE COMMANDE POUR DE VRAI, et on regarde ce que le JEU en fait.
#
# Ce qu'un test naif verifierait : que le fichier de commandes contient la
# nouvelle touche. Ca ne prouve rien — ce qui compte est qu'appuyer sur cette
# touche declenche l'action, et que l'invite affiche la bonne lettre. Les deux
# passent par des chemins differents, et le second a deja menti : la touche
# ajoutee arrivait en FIN de liste, donc l'affichage restait celui de
# l'ancienne alors que le reglage, lui, avait bien pris.
func _regler_une_commande() -> void:
	print("")
	print("--- on change une touche ---")
	var avant := Touches.nom("interagir")

	var prise := Touches.poser("interagir", KEY_K)
	if prise != "":
		_echec("K etait libre, et pourtant refusee (%s)" % prise)
		return
	if Touches.nom("interagir") != "K":
		_echec("l'invite affiche « %s » alors qu'on a pose K"
				% Touches.nom("interagir"))
	else:
		print("  ok   l'invite suit : « %s » au lieu de « %s »"
				% [Touches.invite("interagir", "Descendre"), avant])

	# La touche appuyee declenche-t-elle l'action ? C'est la seule question
	# qui compte, et elle se pose au moteur, pas au fichier.
	var e := InputEventKey.new()
	e.physical_keycode = KEY_K
	if not InputMap.event_is_action(e, "interagir"):
		_echec("appuyer sur K ne declenche pas 'interagir'")
	else:
		print("  ok   appuyer sur K declenche bien l'action")

	if not Touches.changee("interagir"):
		_echec("le jeu ne voit pas que la touche a change")

	# LE DOUBLON SE REFUSE. Le reprendre a l'autre action laisserait quelqu'un
	# sans commande pour avancer sans que rien ne le lui dise.
	var conflit := Touches.poser("saut", KEY_K)
	if conflit == "":
		_echec("K a ete acceptee deux fois")
	else:
		print("  ok   la meme touche deux fois est refusee (« %s »)" % conflit)

	# ... SAUF LES DEUX QUI PARTAGENT ESPACE DEPUIS TOUJOURS. Le jeu les livre
	# en double parce qu'elles ne se croisent jamais — l'une a pied, l'autre au
	# volant — et un garde-fou trop zele aurait interdit de remettre en place
	# ce que project.godot declare.
	var duo := Touches.poser("frein_main", Touches._code("saut"))
	if duo != "":
		_echec("le frein a main ne peut plus partager la touche du saut (%s)"
				% duo)
	else:
		print("  ok   saut et frein a main partagent toujours leur touche")

	Touches.remettre_par_defaut()
	if Touches.nom("interagir") != avant:
		_echec("« remettre par defaut » n'a pas rendu %s" % avant)
	else:
		print("  ok   « tout remettre par defaut » rend « %s »" % avant)
	# On ne laisse pas de fichier de commandes derriere soi : la partie
	# suivante lancee sur cette machine hériterait du clavier d'un test.
	if FileAccess.file_exists(Touches.FICHIER):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(
				Touches.FICHIER))


func _echec(quoi: String) -> void:
	_erreurs += 1
	printerr("  ECHEC %s" % quoi)
