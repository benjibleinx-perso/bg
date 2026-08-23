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

## OU L'ON GARDE LES TOUCHES CHOISIES PAR LE JOUEUR.
##
## A cote de la sauvegarde, pas dedans : des commandes ne sont pas une partie.
## Recommencer une mission ne doit pas rendre son clavier a quelqu'un qui l'a
## regle une fois pour toutes.
const FICHIER := "user://commandes.json"

## LES ACTIONS QU'ON LAISSE REGLER, dans l'ordre du menu : cle de l'action, et
## le nom qu'un joueur lui donne.
##
## Viser et tirer n'y sont pas : ce sont des boutons de souris, et un menu qui
## propose de les remapper au clavier promet ce qu'il ne tient pas.
const REMAPPABLES := [
	["gaz", "Avancer"],
	["frein", "Reculer"],
	["gauche", "Aller a gauche"],
	["droite", "Aller a droite"],
	["interagir", "Agir, parler, monter"],
	["sprint", "Courir"],
	["saut", "Sauter"],
	["accroupir", "S'accroupir"],
	["roue", "Roue des outils"],
	["telephone", "Telephone"],
	["phares", "Phares"],
	["klaxon", "Klaxon"],
	["frein_main", "Frein a main"],
]

## Les touches d'origine, relevees AVANT d'appliquer le fichier du joueur.
## C'est la seule facon de rendre « remettre par defaut » possible : une fois
## l'InputMap ecrase, project.godot n'est plus lisible depuis le jeu.
static var _defauts: Dictionary = {}
static var _charge: bool = false


## Applique les touches du joueur. Sans effet si elles le sont deja, donc on
## peut l'appeler d'ou l'on veut — c'est ce que fait nom(), pour qu'aucune
## invite ne puisse afficher une touche perimee.
static func charger() -> void:
	if _charge:
		return
	_charge = true
	for paire in REMAPPABLES:
		_defauts[paire[0]] = _code(str(paire[0]))
	if not FileAccess.file_exists(FICHIER):
		return
	var f := FileAccess.open(FICHIER, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return
	for action in (d as Dictionary):
		if InputMap.has_action(action):
			_poser_le_code(str(action), int((d as Dictionary)[action]))


static func enregistrer() -> void:
	var d := {}
	for paire in REMAPPABLES:
		var action := str(paire[0])
		var code := _code(action)
		# On n'ecrit QUE ce qui a change. Un fichier qui recopie les defauts
		# fige le jeu tel qu'il etait le jour ou on a ouvert le menu : une
		# touche modifiee plus tard dans project.godot ne parviendrait plus a
		# personne ayant ouvert les options une fois.
		if code != int(_defauts.get(action, 0)):
			d[action] = code
	var f := FileAccess.open(FICHIER, FileAccess.WRITE)
	if f == null:
		push_error("touches : impossible d'ecrire %s" % FICHIER)
		return
	f.store_string(JSON.stringify(d, " "))


## LES ACTIONS QUI ONT LE DROIT DE PARTAGER UNE TOUCHE.
##
## Espace saute a pied et sert de frein a main au volant : le personnage ne lit
## jamais 'frein_main', le vehicule ne lit jamais 'saut', et elles ne peuvent
## donc pas se gener. C'est ecrit dans project.godot depuis toujours, et le
## menu des commandes l'aurait defait des le premier reglage en criant au
## doublon sur une touche que le jeu livre lui-meme en double.
const COMPATIBLES := [["saut", "frein_main"]]


## Donne une touche a une action. Renvoie le nom de l'action qui la portait
## deja, ou "" si le changement est passe.
##
## ON REFUSE LE DOUBLON PLUTOT QUE DE LE RESOUDRE. Retirer la touche a l'autre
## action laisserait quelqu'un sans commande pour avancer sans qu'on le lui
## dise — et il ne le decouvrirait qu'en jeu, menu ferme.
static func poser(action: String, code: int) -> String:
	charger()
	for paire in REMAPPABLES:
		var autre := str(paire[0])
		if autre != action and _code(autre) == code \
				and not _compatibles(action, autre):
			return str(paire[1])
	_poser_le_code(action, code)
	enregistrer()
	return ""


## Remet toutes les commandes telles que le jeu les livre.
static func remettre_par_defaut() -> void:
	charger()
	for action in _defauts:
		_poser_le_code(str(action), int(_defauts[action]))
	enregistrer()


## La touche d'une action a-t-elle ete changee par le joueur ?
static func changee(action: String) -> bool:
	charger()
	return _code(action) != int(_defauts.get(action, 0))


static func _compatibles(une: String, autre: String) -> bool:
	for groupe in COMPATIBLES:
		if une in groupe and autre in groupe:
			return true
	return false


# Le code PHYSIQUE de la premiere touche d'une action, ou zero.
static func _code(action: String) -> int:
	if not InputMap.has_action(action):
		return 0
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return (e as InputEventKey).physical_keycode
	return 0


# On remplace la premiere touche CLAVIER et on laisse le reste : « avancer »
# porte W et la fleche du haut, et quelqu'un qui choisit une autre lettre ne
# demande pas qu'on lui retire ses fleches.
#
# LA NOUVELLE TOUCHE PASSE EN TETE, et la liste est reconstruite pour ca. Un
# simple ajout la mettait en dernier : « avancer » devenait [fleche, choix],
# _code() lisait la fleche, et le menu affichait « Haut » juste apres qu'on
# ait choisi K. Le reglage marchait ; c'est son affichage qui mentait.
static func _poser_le_code(action: String, code: int) -> void:
	if code == 0:
		return
	var gardes: Array = []
	var remplacee := false
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and not remplacee:
			remplacee = true
			continue
		gardes.append(e)
	InputMap.action_erase_events(action)
	var neuf := InputEventKey.new()
	neuf.physical_keycode = code
	InputMap.action_add_event(action, neuf)
	for e in gardes:
		InputMap.action_add_event(action, e)


## Le nom court de la premiere touche d'une action : « E », « Echap », « Tab ».
##
## On passe par le keycode PHYSIQUE traduit pour le clavier de la machine :
## le jeu lit des positions de touches, donc la touche marquee Z sur un
## clavier francais doit s'afficher « Z » et pas « W ».
static func nom(action: String) -> String:
	# Les touches du joueur s'appliquent ici aussi : une invite est le premier
	# endroit ou un reglage non charge se verrait, et le dernier ou l'on
	# penserait a le chercher.
	charger()
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


## Le nom d'un code physique, sans passer par une action. Sert au menu des
## commandes, qui doit nommer la touche qu'on vient d'enfoncer avant meme de
## decider si elle est acceptee.
static func nom_du_code(code: int) -> String:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return nom_du_clavier(e)


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
