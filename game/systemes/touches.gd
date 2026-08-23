# Le nom d'une touche, lu dans l'InputMap.
#
# Les invites du jeu etaient ecrites en dur — « F   Descendre », onze fois
# dans cinq fichiers. Le jour ou la touche d'action est passee de F a E, il a
# fallu les retrouver une par une, et rien n'aurait signale celle qu'on
# oubliait : le texte reste juste, il ment simplement au joueur.
#
# Depuis que les commandes se remappent dans le menu pause, ce n'est plus une
# commodite mais la seule facon d'etre exact — une invite figee redevient
# fausse au premier reglage.
class_name Touches


## Le nom court de la premiere touche d'une action : « E », « Echap », « Tab ».
##
## On passe par le keycode PHYSIQUE traduit pour le clavier de la machine :
## le jeu lit des positions de touches, donc la touche marquee Z sur un
## clavier francais doit s'afficher « Z » et pas « W ».
static func nom(action: String) -> String:
	if not InputMap.has_action(action):
		return "?"
	for evenement in InputMap.action_get_events(action):
		if evenement is InputEventKey:
			return nom_du_clavier(evenement as InputEventKey)
		if evenement is InputEventMouseButton:
			match (evenement as InputEventMouseButton).button_index:
				MOUSE_BUTTON_LEFT: return "Clic gauche"
				MOUSE_BUTTON_RIGHT: return "Clic droit"
				MOUSE_BUTTON_MIDDLE: return "Clic milieu"
				_: return "Souris"
	return "?"


## Le nom d'un evenement clavier, seul. Sert au menu des commandes, qui
## affiche des touches qu'il n'a pas encore posees dans l'InputMap.
static func nom_du_clavier(touche: InputEventKey) -> String:
	var code := touche.keycode
	if touche.physical_keycode != 0:
		# La traduction depend de la disposition installee. En headless elle
		# peut rendre zero : on retombe alors sur le code physique, qui donne
		# le nom QWERTY plutot que rien du tout.
		code = DisplayServer.keyboard_get_keycode_from_physical(
				touche.physical_keycode)
		if code == 0:
			code = touche.physical_keycode
	if code == 0:
		return "?"
	return _lisible(OS.get_keycode_string(code))


## « E   Descendre ». Trois espaces, comme partout ailleurs a l'ecran.
static func invite(action: String, verbe: String) -> String:
	return "%s   %s" % [nom(action), verbe]


# Godot rend des noms anglais, et quelques-uns sont trop longs pour une
# invite. On ne traduit que ce qui apparait vraiment sur les commandes du jeu.
static func _lisible(brut: String) -> String:
	match brut:
		"Escape": return "Echap"
		"Space": return "Espace"
		"Shift": return "Maj"
		"Ctrl": return "Ctrl"
		"Enter": return "Entree"
		"Backspace": return "Retour"
		"Left": return "Gauche"
		"Right": return "Droite"
		"Up": return "Haut"
		"Down": return "Bas"
		_: return brut
