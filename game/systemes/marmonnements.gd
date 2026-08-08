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


func _process(delta: float) -> void:
	if _controleur == null or _phrases.is_empty():
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
	_attente = intervalle
	_marmonner()


func _marmonner() -> void:
	var cle := ""
	if _mission != null and not _mission.finie():
		cle = _mission.cle_etape()

	# L'etape d'abord, le fond de sac ensuite. Une pensee liee a ce qu'on est
	# en train de faire vaut dix pensees generales.
	var choix := _tirer(cle)
	if choix == "":
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
