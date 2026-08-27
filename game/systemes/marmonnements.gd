# Ce que Walter se dit tout seul, entre deux scenes.
#
# POURQUOI. La mission enchaine des lieux et des dialogues, et entre les deux
# il y a des trajets — le desert est a neuf cents metres, le QG a l'autre bout
# de la ville. Pendant ces minutes, personne ne parle et il ne se passe rien.
# Un homme qui traverse sa ville en portant ce qu'il porte n'est pas silencieux
# dans sa tete.
#
# CE N'EST PAS UN DIALOGUE. Personne ne repond, aucun cadre ne s'ouvre, aucune
# etape n'avance. Ca passe par le bandeau du controleur, le meme canal que les
# refus et les tutos — donc ca disparait tout seul, et ca n'interrompt rien.
#
# TROIS SILENCES QU'ON RESPECTE, et ils comptent plus que les phrases :
#
#   - pendant un dialogue, on se tait. Deux textes en meme temps ne se lisent
#     ni l'un ni l'autre ;
#   - quand un bandeau est deja affiche, on attend. Un tuto qui se fait ecraser
#     par une pensee est un tuto perdu, et c'est lui qui aide vraiment ;
#   - juste apres le demarrage, on laisse respirer. Un personnage qui commence
#     a monologuer dans la premiere seconde a l'air d'un menu d'aide.
class_name Marmonnements
extends Node

const FICHIER := "res://donnees/marmonnements.json"

## Le controleur, qui porte le bandeau.
@export var controleur: NodePath

## Secondes entre deux pensees. Long, volontairement : une phrase toutes les
## quarante secondes se remarque, une toutes les dix devient du bavardage et on
## cesse de lire.
@export_range(10.0, 180.0, 5.0) var intervalle: float = 42.0

## Ce qu'on laisse passer au demarrage avant la premiere.
@export_range(0.0, 120.0, 1.0) var repos_initial: float = 25.0

var _phrases: Dictionary = {}
var _controleur: Node
var _mission: Mission
var _dialogue: Dialogue
var _attente: float = 0.0
var _rng := RandomNumberGenerator.new()

## Ce qui a deja ete dit. Une pensee entendue deux fois dans la meme partie
## casse l'illusion plus surement qu'un silence.
var _dites: Dictionary = {}


func _ready() -> void:
	_rng.randomize()
	_attente = repos_initial
	_controleur = get_node_or_null(controleur)
	_mission = Mission.courante(self)
	_dialogue = _trouver_dialogue(get_tree().root)
	_charger()


func _trouver_dialogue(n: Node) -> Dialogue:
	if n is Dialogue:
		return n as Dialogue
	for e in n.get_children():
		var t := _trouver_dialogue(e)
		if t != null:
			return t
	return null


func _charger() -> void:
	if not FileAccess.file_exists(FICHIER):
		push_warning("marmonnements : %s introuvable" % FICHIER)
		return
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(FICHIER))
	if typeof(lu) != TYPE_DICTIONARY:
		push_error("marmonnements : %s illisible. Verifier les virgules." % FICHIER)
		return
	_phrases = lu
	var total := 0
	for cle in _phrases:
		if typeof(_phrases[cle]) == TYPE_ARRAY:
			total += (_phrases[cle] as Array).size()
	print("MARMONNEMENTS : %d phrase(s)" % total)


## UNE MISSION PEUT SE PASSER DE PENSEES, et « Deux corps » le fait.
##
## Ces soixante-et-une phrases ont ete ecrites pour la mission de rodage : un
## professeur de chimie qui traverse sa ville en pensant a son diagnostic, a sa
## femme, a l'argent qui manque. Elles supposent un homme qui n'a encore rien
## fait.
##
## « Deux corps » commence apres. Walter se reveille masque dans un camping-car
## retourne avec deux cadavres a l'arriere, et une pensee sur les factures qui
## s'accumulent au-dessus de cette scene ne fait pas seulement tache — elle
## dement ce qu'on est en train de regarder.
##
## C'EST TEMPORAIRE ET CA SE VOIT ICI. Le silence n'est pas la bonne reponse
## definitive : cette mission a besoin de ses propres pensees, et il faudra les
## ecrire. En attendant, mieux vaut qu'il se taise que qu'il dise le contraire
## de ce qu'il vit. La mission le declare dans son JSON, ce fichier n'en sait
## rien de plus.
func _pensees_permises() -> bool:
	var m := Mission.courante(self)
	if m == null:
		return true
	return bool(m.donnees().get("pensees", true))


func _process(delta: float) -> void:
	if _controleur == null or _phrases.is_empty():
		return
	if not _pensees_permises():
		return
	if _dialogue != null and _dialogue.actif():
		# On ne decompte meme pas pendant un dialogue : sinon la pensee tombe
		# a la seconde ou la conversation se ferme, comme une reponse.
		return
	if _controleur.has_method("bandeau") and str(_controleur.call("bandeau")) != "":
		return

	_attente -= delta
	if _attente > 0.0:
		return
	_attente = _intervalle_voulu()
	_marmonner()


## L'ECART ENTRE DEUX PHRASES, ET LA MISSION PEUT LE RACCOURCIR.
##
## Quarante-deux secondes conviennent a un homme seul au volant qui rumine
## entre deux quartiers. Elles sont absurdes au fond d'un fosse, avec une
## sirene qui approche et quelqu'un qui panique a cote de soi : « Deux corps »
## demande treize secondes, et c'est un rythme de scene, pas de trajet.
##
## C'est une DONNEE de mission, comme son heure ou son filtre — pas un reglage
## de ce fichier, qui vaudrait alors pour toutes les missions a la fois.
func _intervalle_voulu() -> float:
	var m := Mission.courante(self)
	if m == null:
		return intervalle
	return float(m.donnees().get("pensees_intervalle", intervalle))


func _marmonner() -> void:
	var cle := ""
	if _mission != null and not _mission.finie():
		cle = _mission.cle_etape()

	# L'etape d'abord, le fond de sac ensuite. Une pensee liee a ce qu'on est
	# en train de faire vaut dix pensees generales.
	var choix := _tirer(cle)

	# LE FOND DE SAC NE SE TIRE PLUS PENDANT UNE MISSION (28/08/2026).
	#
	# « Les phrases qui defilent de temps en temps sont assez mal placees et
	# n'ont pas vraiment de sens a ce stade du jeu. Le mieux serait de les
	# retirer pour l'instant. On verra pour les remettre (...) dans les parties
	# monde ouvert quand aucune mission n'est en cours. » — Guillaume, 27/08.
	#
	# CE N'EST PAS TOUTES LES PENSEES QU'IL VISE, et c'est le piege de cette
	# demande : les phrases d'ETAPE sont celles de Jesse, et le meme retour dit
	# « les phrases ecrites de Jesse sont bien ! ». Ce qui tombe a cote, c'est
	# le fond de sac — quatre pensees de professeur malade ecrites pour la
	# mission de rodage, qui sortent des que l'etape courante n'a plus rien a
	# dire. « Cinquante ans, et voila ou j'en suis » au-dessus d'un cadavre
	# qu'on traine dementait ce qu'on regarde.
	#
	# Hors mission il n'y a pas d'etape, donc pas de phrase d'etape : c'est
	# exactement la ou le fond de sac reprend son emploi, sans rien a rallumer.
	if choix == "" and (_mission == null or _mission.finie()):
		choix = _tirer("_partout")
	if choix == "":
		return
	_dites[choix] = true
	_controleur.call("annoncer", choix)


# Rend une phrase pas encore dite pour cette cle, ou "" s'il n'en reste aucune.
# On ne recycle pas : quand tout a ete dit sur une etape, on se tait plutot que
# de repeter, et le fond de sac prend le relais.
func _tirer(cle: String) -> String:
	if cle == "" or not _phrases.has(cle):
		return ""
	var liste: Array = _phrases[cle]
	var reste: Array = []
	for p in liste:
		if not _dites.has(str(p)):
			reste.append(str(p))
	if reste.is_empty():
		return ""
	return str(reste[_rng.randi() % reste.size()])
