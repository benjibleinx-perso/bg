# Les conversations.
#
# Le texte n'est nulle part dans le code : il vit dans donnees/dialogues.json,
# et Guillaume peut le reecrire sans ouvrir Godot. Ce script ne fait que
# derouler ce qu'il y trouve.
#
# Une seule conversation a la fois. Elle avance replique par replique sur la
# touche d'interaction, et se termine d'elle-meme a la derniere.
class_name Dialogue
extends Node

const FICHIER := "res://donnees/dialogues.json"
const VOIX := "res://assets/voix/%s_%s.wav"

## Les voix sortent sur le bus Interface : c'est du hors-champ, comme le
## reste de l'habillage, et ca les met sous le meme curseur de volume.
const BUS_VOIX := "Interface"

## Une voix qui traverse un appareil ne sort pas sur le meme bus.
##
## Le champ 'canal' d'une replique nomme l'appareil qu'elle traverse. Les bus
## correspondants vivent dans default_bus_layout.tres, ils renvoient tous sur
## Interface, et c'est la que se reglent les filtres — pas ici.
##
## SEUL LE CORRESPONDANT PORTE UN CANAL. Walter est le joueur : il est dans la
## piece, sa voix ne traverse rien, meme quand c'est lui qui tient le combine.
const BUS_PAR_CANAL := {
	"telephone": "Telephone",
	"interphone": "Interphone",
}

signal termine

## Emis quand la replique affichee porte un champ 'effet'.
##
## CE QUI SE PASSE DOIT SE PASSER SUR LA PHRASE QUI LE DIT. L'argent de Tuco
## arrivait a la FIN de la conversation, donc vingt repliques apres « compte-les
## si tu veux » — et la fouille du garde, de meme, avait deja eu lieu quand il
## annoncait la trouver. Une scene ou l'action et le texte ne coincident pas se
## lit comme deux scenes.
##
## Le dialogue ne sait pas ce qu'un effet veut dire, et c'est voulu : il porte
## un nom, le scenario decide. Ajouter un moment cle a une conversation est
## donc un mot de plus dans dialogues.json.
signal effet(nom: String)

@export var cadre: NodePath
@export var etiquette_nom: NodePath
@export var etiquette_texte: NodePath

var _donnees: Dictionary = {}
var _repliques: Array = []
var _index: int = 0
var _actif: bool = false

## LE CHOIX EN COURS, s'il y en a un.
##
## Une replique peut porter « choix » au lieu de « texte » : le jeu s'arrete
## alors sur elle et attend qu'on tranche. C'est le battement B5 du script de
## Guillaume — Jesse propose de sauter une etape — et c'etait jusqu'ici le seul
## endroit du jeu ou l'on decidait de quelque chose... sauf qu'on ne decidait
## rien : les deux repliques s'enchainaient, donc Walter refusait toujours.
##
## Ce que le choix ne fait PAS : bloquer, punir, ou s'annoncer. Les deux
## options reussissent la cuisine. Ce qui change est la teinte du cristal, et
## personne ne la commente — regle numero un du projet, aucun chiffre montre.
var _options: Array = []
var _option: int = 0

## Combien de fois on a deja parle a chacun. C'est ce compteur qui fait
## tourner les conversations : reparler a quelqu'un ne rejoue pas la meme
## scene, ce qui suffit a donner l'impression que le monde avance.
var _vus: Dictionary = {}

var _cadre: Control
var _nom: Label
var _texte: Label
var _lecteur: AudioStreamPlayer

## Personnages deja signales comme muets. Sans ce garde, une voix manquante
## remplit la console d'un avertissement par replique.
var _manquantes: Dictionary = {}


func _ready() -> void:
	_cadre = get_node_or_null(cadre) as Control
	_nom = get_node_or_null(etiquette_nom) as Label
	_texte = get_node_or_null(etiquette_texte) as Label
	if _cadre != null:
		_cadre.visible = false

	# Non positionne : une voix de dialogue ne doit pas baisser quand le
	# joueur tourne la tete. C'est du hors-champ, pas une source du monde.
	_lecteur = AudioStreamPlayer.new()
	_lecteur.name = "Voix"
	_lecteur.bus = BUS_VOIX
	add_child(_lecteur)

	_charger()


func _charger() -> void:
	if not FileAccess.file_exists(FICHIER):
		push_error("dialogue : %s introuvable" % FICHIER)
		return
	var brut := FileAccess.get_file_as_string(FICHIER)
	var lu: Variant = JSON.parse_string(brut)
	if typeof(lu) != TYPE_DICTIONARY:
		# Une virgule en trop dans le JSON et tout le monde devient muet, sans
		# la moindre erreur ailleurs. On le dit fort.
		push_error("dialogue : %s illisible. Verifier les virgules." % FICHIER)
		return
	_donnees = lu
	var gens := 0
	for cle in _donnees:
		if typeof(_donnees[cle]) == TYPE_DICTIONARY:
			gens += 1
	print("DIALOGUE : %d personnage(s) charges" % gens)


func actif() -> bool:
	return _actif


## Qui vient de parler. Le signal `termine` ne porte pas cette information, et
## la lui ajouter aurait casse tous ceux qui l'ecoutent deja ; une lecture
## apres coup fait le meme travail. C'est par elle que la mission sait quelle
## conversation vient de se finir.
func cle_courante() -> String:
	return _cle

var _cle: String = ""


## Ouvre la conversation suivante de ce personnage. Renvoie faux s'il n'a
## rien a dire — l'appelant ne doit alors pas proposer de lui parler.
func demarrer(cle: String) -> bool:
	if _actif or not _donnees.has(cle):
		return false
	var fiche: Dictionary = _donnees[cle]
	var conversations: Array = fiche.get("conversations", [])
	if conversations.is_empty():
		return false

	var tour := int(_vus.get(cle, 0))
	_repliques = conversations[tour % conversations.size()]
	_vus[cle] = tour + 1
	_index = 0
	_actif = true
	_cle = cle
	if _cadre != null:
		_cadre.visible = true
	_montrer()
	return true


## Y a-t-il un choix a trancher a l'ecran ?
func en_choix() -> bool:
	return _actif and not _options.is_empty()


## CE QUE LE CONTROLEUR DOIT AFFICHER. Il ecrivait « F Suite » en dur a quatre
## endroits ; passer par ici evite d'avoir a se souvenir des quatre le jour ou
## une conversation demande autre chose que d'appuyer pour continuer.
func invite() -> String:
	# Les touches par leur NOM PHYSIQUE. « Haut/Bas » ne dit pas si ce sont les
	# fleches ou les lettres, et le joueur essaie les deux ; ici les deux
	# marchent, et l'invite nomme celles qu'on a deja sous les doigts.
	if en_choix():
		return "W/S   Choisir      F   Repondre"
	return "F   Suite"


# LA NAVIGATION VIT ICI, PAS DANS LE CONTROLEUR.
#
# Le controleur ne connait qu'« avancer » ; lui apprendre a monter et descendre
# dans une liste l'aurait rendu responsable de l'etat d'un menu qu'il n'affiche
# pas. Le dialogue tient son curseur, le controleur continue de ne relayer
# qu'une touche.
# LES MEMES TOUCHES QUE PARTOUT AILLEURS.
#
# Ce menu utilisait ui_up / ui_down, qui ne sont mappees nulle part dans ce jeu :
# le menu pause, l'ecran-titre et la roue des outils naviguent tous les trois
# avec « gaz » et « frein ». Le joueur ne pouvait donc pas changer d'option, et
# rien ne le lui disait — le chevron restait sur la premiere ligne.
#
# Une quatrieme convention pour un quatrieme menu, c'est un menu qu'on
# n'apprend pas. Il n'y en a plus qu'une : monter, descendre, valider avec F.
func _process(_delta: float) -> void:
	if not en_choix():
		return
	if Input.is_action_just_pressed("frein"):
		descendre_dans_le_choix()
	elif Input.is_action_just_pressed("gaz"):
		monter_dans_le_choix()


## Deplacer le curseur. Publiques parce qu'une VERIFICATION ne peut pas presser
## une touche : Input ne se simule pas depuis une suite, et un test qui se
## contenterait de lire le premier choix ne mesurerait jamais le second — donc
## jamais le seul fait qui compte, que les deux menent ailleurs.
func descendre_dans_le_choix() -> void:
	if not en_choix():
		return
	_option = (_option + 1) % _options.size()
	_ecrire_les_options()


func monter_dans_le_choix() -> void:
	if not en_choix():
		return
	_option = (_option - 1 + _options.size()) % _options.size()
	_ecrire_les_options()


## Passe a la replique suivante, ou ferme si c'etait la derniere.
func avancer() -> void:
	if not _actif:
		return
	if en_choix():
		_trancher()
		return
	_index += 1
	if _index >= _repliques.size():
		_fermer()
		return
	_montrer()


# ON REPOND. L'option choisie insere ses repliques a la suite, et son effet part
# MAINTENANT — sur la phrase qui le dit, comme tous les autres effets.
func _trancher() -> void:
	var choisi: Dictionary = _options[_option]
	_options = []
	var e := str(choisi.get("effet", ""))
	if e != "":
		effet.emit(e)
	# Les repliques de la branche prennent la place de la ligne de choix. Une
	# option qui n'en porte aucune passe directement a la suite commune : c'est
	# le cas de « ceder », ou Walter hausse les epaules et ne dit rien.
	var suite: Array = choisi.get("repliques", [])
	if not suite.is_empty():
		var reste := _repliques.slice(_index + 1)
		_repliques = suite.duplicate()
		_repliques.append_array(reste)
		_index = 0
		_montrer()
		return
	_index += 1
	if _index >= _repliques.size():
		_fermer()
		return
	_montrer()


func _montrer() -> void:
	var r: Dictionary = _repliques[_index]
	if _nom != null:
		_nom.text = str(r.get("qui", ""))

	# UNE LIGNE DE CHOIX N'EST PAS UNE REPLIQUE. Elle ne se prononce pas — il n'y
	# a rien a enregistrer, personne ne parle encore — et elle n'emet pas son
	# effet : c'est l'option retenue qui portera le sien.
	var options: Array = r.get("choix", [])
	if not options.is_empty():
		_options = options
		_option = 0
		_ecrire_les_options()
		return

	_options = []
	if _texte != null:
		_texte.text = str(r.get("texte", ""))
	_dire(str(r.get("qui", "")), _prononce(r), str(r.get("canal", "")))
	var e := str(r.get("effet", ""))
	if e != "":
		effet.emit(e)


# Le curseur est un chevron, comme partout ailleurs dans le jeu — objectifs,
# menu des outils. Un surlignage demanderait un theme et une seconde etiquette
# pour deux lignes de texte.
func _ecrire_les_options() -> void:
	if _texte == null:
		return
	var lignes: PackedStringArray = []
	for i in _options.size():
		var t := str((_options[i] as Dictionary).get("texte", ""))
		lignes.append(("> %s" if i == _option else "   %s") % t)
	_texte.text = "\n".join(lignes)


## CE QUI EST PRONONCE, qui n'est plus ce qui est affiche.
##
## Depuis le 08/08/2026 le jeu se joue en VO anglaise sous-titree francais :
## 'vo' est la phrase dite, 'texte' le sous-titre. L'empreinte qui nomme le
## fichier son doit donc porter sur 'vo' — c'est la regle d'origine appliquee
## telle quelle, pas une exception. Elle dit : le nom suit ce qui est ENREGISTRE.
## Reecrire la VO change le fichier ; retoucher une virgule du sous-titre ne
## jette pas une prise qui reste juste.
##
## 'jeu' EST LA DIRECTION D'ACTEUR, et elle compte dans l'empreinte.
##
## Le champ porte une intention — « furious », « exasperated », « quiet, tense »
## — que le moteur de synthese interprete sans la prononcer. Elle fait donc
## partie de ce qui est ENREGISTRE, au meme titre que les mots : la meme phrase
## dite calmement ou en hurlant sont deux prises differentes, et elles ne
## peuvent pas partager un nom de fichier.
##
## Consequence voulue : changer l'intention d'une replique la fait regenerer
## toute seule, et laisser 'jeu' vide rend exactement l'empreinte d'avant. Les
## repliques deja doublees ne bougent donc pas tant qu'on ne les dirige pas.
##
## Une replique sans 'vo' retombe sur 'texte' : c'est le cas des repliques pas
## encore traduites, et elles gardent leur voix francaise en attendant.
static func _prononce(replique: Dictionary) -> String:
	var vo := str(replique.get("vo", ""))
	if vo == "":
		return str(replique.get("texte", ""))
	var jeu := str(replique.get("jeu", ""))
	if jeu == "":
		return vo
	return "[%s] %s" % [jeu, vo]


# Joue l'enregistrement de cette replique, s'il existe.
#
# Le nom du fichier est deduit de CE QUI EST DIT, pas d'un index : l'empreinte
# MD5 des dix premiers caracteres suffit. Reecrire une replique change son
# empreinte, donc son fichier — impossible d'entendre l'ancienne version sur le
# nouveau texte, ce qu'un index numerique aurait permis sans rien signaler.
func _dire(qui: String, texte: String, canal: String = "") -> void:
	if _lecteur == null:
		return
	_lecteur.stop()

	# Le bus se choisit AVANT de jouer : en changer pendant la lecture ne
	# reprend pas le son deja envoye au melangeur, et la premiere syllabe
	# sortirait sur le bus precedent.
	#
	# Un canal inconnu retombe sur la voix normale plutot que de rester muet :
	# une faute de frappe dans dialogues.json doit s'entendre comme une voix
	# non filtree, pas comme un personnage qui a perdu la parole.
	var bus: String = BUS_PAR_CANAL.get(canal, BUS_VOIX)
	if AudioServer.get_bus_index(bus) < 0:
		push_warning("dialogue : bus '%s' introuvable, voix en direct" % bus)
		bus = BUS_VOIX
	_lecteur.bus = bus

	var chemin := VOIX % [_simplifier(qui), texte.md5_text().substr(0, 10)]
	if not ResourceLoader.exists(chemin):
		if not _manquantes.has(qui):
			_manquantes[qui] = true
			push_warning("dialogue : aucune voix pour %s. Generer : .\\bg.ps1 voix"
					% qui)
		return
	_lecteur.stream = ResourceLoader.load(chemin) as AudioStream
	_lecteur.play()


# Doit produire exactement le meme nom que outils/gen_voix.ps1. Les deux
# cotes se rejoignent sur un nom de fichier et rien d'autre : s'ils divergent,
# le jeu cherche un fichier qui n'existe pas et reste muet sans erreur.
static func _simplifier(nom: String) -> String:
	var sortie := ""
	for c in nom.to_lower():
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			sortie += c
	return sortie


## Interrompt la conversation en cours. Raccrocher au milieu d'un appel doit
## couper la voix : sinon le correspondant continue de parler dans le vide,
## combine range.
func couper() -> void:
	if not _actif:
		return
	if _lecteur != null:
		_lecteur.stop()
	_fermer()


func _fermer() -> void:
	_actif = false
	_repliques = []
	# Un choix laisse en plan — conversation coupee, mission relancee — rendrait
	# « en_choix » vrai sur la conversation SUIVANTE, qui afficherait alors les
	# options de la precedente.
	_options = []
	_option = 0
	if _cadre != null:
		_cadre.visible = false
	termine.emit()


## Ce personnage a-t-il une fiche ? Une cle mal orthographiee ne se voit
## autrement qu'en allant lui parler et en le trouvant muet.
func connait(cle: String) -> bool:
	return _donnees.has(cle) and typeof(_donnees[cle]) == TYPE_DICTIONARY


## Nom affichable d'un personnage, pour l'invite « Parler a ... ».
func nom_de(cle: String) -> String:
	if not _donnees.has(cle):
		return cle.capitalize()
	return str((_donnees[cle] as Dictionary).get("nom", cle.capitalize()))
