# LA SIRENE QUI SE RAPPROCHE, PUIS QUI N'EN EST PAS UNE.
#
# C'est le compte a rebours de la sequence A, et il ne s'affiche nulle part.
# Guillaume l'ecrit en trois temps :
#
#   A4  « Sirene au loin — un son continu, faible, qui va monter en intensite
#         REELLE au fil des battements suivants (pas un minuteur affiche). »
#   A6  « Le volume de la sirene a nettement monte depuis A4. »
#   A9  « Ce n'est plus une sirene de police, c'est un camion de pompiers, qui
#         passe au loin sans s'arreter. »
#
# Sans elle, on ramasse trois objets tranquillement et on s'en va. Toute la
# tension de l'ouverture tient a ce son, et tout son sens tient au fait qu'il se
# revele faux : « on a couru pour des pompiers ».
#
# C'EST L'ETAPE QUI PORTE SON NIVEAU, comme le filtre du masque porte le sien.
#
# La tentation etait d'ecrire « a partir de l'etape jesse_panique, monter ».
# C'est le piege 39, paye trois fois : un nom d'etape n'appartient a personne, et
# le jour ou une autre mission s'appelle pareil, elle herite d'une sirene. Le
# JSON dit « sirene »: 0.18, ce fichier ne sait rien d'autre.
#
# La montee se lit donc en relisant le JSON de la mission, cote a cote avec le
# script — et se regle sans toucher a une ligne de code.
extends Node

## Les deux sons. Deux fichiers et non un seul module par pitch : Guillaume note
## que le retournement ne fonctionne QUE si les timbres sont franchement
## differents, sinon il ne reste que le sous-titre de Jesse pour l'annoncer.
const POLICE := "res://assets/sons/mission/sirene_police.ogg"
const POMPIERS := "res://assets/sons/mission/sirene_pompiers.ogg"

## Le volume atteint quand l'etape demande 1.0, en decibels. La sirene est
## LOINTAINE meme au plus fort : elle doit inquieter, pas couvrir les voix.
const PLEIN := -9.0

## Silence, en decibels. Godot coupe en dessous de -60.
const MUET := -60.0

## Combien de temps le volume met a rejoindre sa cible, en decibels par seconde.
## Lent, et c'est le reglage le plus important du fichier : le script dit « qui
## va monter au fil des battements », pas « qui monte d'un cran ». Une marche
## d'escalier a chaque etape s'entendrait comme un curseur qu'on pousse.
const VITESSE := 3.5

var _joueur: AudioStreamPlayer
var _niveau: float = 0.0
var _en_pompiers: bool = false


func _ready() -> void:
	add_to_group("sirene")
	_joueur = AudioStreamPlayer.new()
	_joueur.bus = Audio.BUS_AMBIANCE
	_joueur.volume_db = MUET
	add_child(_joueur)


static func courante(depuis: Node) -> Node:
	if depuis == null or not depuis.is_inside_tree():
		return null
	return depuis.get_tree().get_first_node_in_group("sirene")


func _process(delta: float) -> void:
	var vise := _voulu()
	_niveau = move_toward(_niveau, vise, VITESSE * delta / abs(MUET - PLEIN))
	if _niveau <= 0.001:
		if _joueur.playing and not _en_pompiers:
			_joueur.stop()
		return
	if not _joueur.playing and not _en_pompiers:
		_joueur.stream = load(POLICE)
		_joueur.play()
	_joueur.volume_db = lerpf(MUET, PLEIN, _niveau)


# Ce que l'etape en cours reclame, de 0 a 1. Le retournement passe, lui, par
# basculer() : ce n'est pas un niveau, c'est un evenement.
func _voulu() -> float:
	if _en_pompiers:
		return 0.0
	var m := Mission.courante(self)
	if m == null or m.finie():
		return 0.0
	return clampf(float(m.etape().get("sirene", 0.0)), 0.0, 1.0)


## LE RETOURNEMENT. Appele par le scenario sur la replique qui le dit.
##
## On coupe la police NET plutot que de la fondre : le script demande « un
## battement de silence » avant que Jesse parle, et c'est ce silence qui fait
## comprendre que quelque chose a change. Un fondu enchaine les deux sirenes et
## le joueur n'entend qu'un son qui se deforme.
func basculer() -> void:
	if _en_pompiers:
		return
	_en_pompiers = true
	_niveau = 0.0
	_joueur.stop()
	_joueur.stream = load(POMPIERS)
	# Plus fort que la police ne l'a jamais ete : il PASSE, il ne s'approche
	# plus. Le fichier decroit tout seul sur ses six dernieres secondes.
	_joueur.volume_db = PLEIN + 3.0
	_joueur.play()


## Tout remettre a zero — recommencer une partie, ou changer de mission.
func reinitialiser() -> void:
	_en_pompiers = false
	_niveau = 0.0
	if _joueur != null:
		_joueur.stop()
		_joueur.volume_db = MUET
