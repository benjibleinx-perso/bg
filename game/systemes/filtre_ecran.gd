# CE QUE LE JOUEUR REGARDE A TRAVERS.
#
# Un calque plein ecran, pose tant que l'etape de mission en cours en demande
# un, retire des qu'elle est franchie. Le premier — et pour l'instant le seul —
# est le masque a gaz du reveil dans le fosse, que le script de Guillaume decrit
# en A2 : « Vision legerement filtree tant que le masque est porte. »
#
# C'EST L'ETAPE QUI NOMME SON FILTRE, PAS CE SYSTEME QUI DEVINE.
#
# La tentation etait d'ecrire « si l'etape s'appelle masque, pose le masque ».
# C'est exactement le piege 39, paye trois fois la semaine du 16/08/2026 : le
# scenario reconnaissait des etapes a leur NOM, les noms se sont mis a exister
# dans deux missions, et les tueurs de Tuco sont venus abattre Walter au fond du
# fosse. Un nom d'etape n'appartient a personne.
#
# Le JSON de la mission porte donc « filtre »: « masque_a_gaz », et ce fichier
# ne connait qu'une table de noms vers des shaders. Une mission qui voudrait un
# masque a une autre etape n'a rien a coder ; une mission qui reutiliserait le
# nom « masque » pour autre chose ne declenche rien.
extends Node

## L'interface du jeu — le meme Control que la cinematique, et pour la meme
## raison : le calque doit vivre DANS le viewport 960x720, sinon il se dessine a
## la resolution de la fenetre et le degrade devient plus fin que tout le reste
## de l'image.
@export var interface: NodePath

## Le temps que met le filtre a se poser et a se lever. Court : le retrait du
## masque est un geste, pas une transition.
const FONDU := 0.3

## Les filtres connus. Un nom de la mission -> un shader de res://rendu.
const SHADERS := {
	"masque_a_gaz": "res://rendu/masque_a_gaz.gdshader",
}

## CE QU'ON ENTEND EN MEME TEMPS.
##
## A2 demande « vision legerement filtree (teinte, RESPIRATION AMPLIFIEE DANS LE
## SON) tant que le masque est porte ». La moitie visuelle a ete faite d'abord,
## et le mot « amplifiee » explique pourquoi la seconde compte autant : ce n'est
## pas un bruit d'ambiance, c'est ce qu'on entend quand sa propre respiration
## revient par un filtre a dix centimetres de l'oreille. C'est ca qui rend le
## masque etouffant, pas la teinte.
##
## Un filtre sans entree ici est simplement muet.
const SONS := {
	"masque_a_gaz": "res://assets/sons/mission/respiration_masque.ogg",
}

## Le volume de la respiration. Presente sans couvrir : la premiere replique de
## la mission se dit sous le masque, et elle doit rester comprehensible.
const VOLUME := -5.0

var _calque: ColorRect
var _pose: String = ""
var _fondu: Tween
var _souffle: AudioStreamPlayer


func _process(_delta: float) -> void:
	var voulu := _filtre_demande()
	if voulu == _pose:
		return
	if voulu == "":
		_lever()
	else:
		_poser(voulu)
	_pose = voulu


## Ce que l'etape en cours reclame, ou rien. On passe par la mission plutot que
## par le controleur : c'est une propriete du SCENARIO, pas de l'affichage.
func _filtre_demande() -> String:
	var m := Mission.courante(self)
	if m == null or m.finie():
		return ""
	var nom := str(m.etape().get("filtre", ""))
	if nom != "" and not SHADERS.has(nom):
		# Un nom inconnu est une faute de frappe dans le JSON, et se taire la
		# dessus ferait chercher le bug du cote du shader pendant une heure.
		push_warning("filtre d'ecran inconnu : '%s'" % nom)
		return ""
	return nom


func _poser(nom: String) -> void:
	var hote := get_node_or_null(interface) as Control
	if hote == null:
		return
	_lever_tout_de_suite()
	var shader := load(SHADERS[nom]) as Shader
	if shader == null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	_calque = ColorRect.new()
	_calque.name = "FiltreEcran"
	_calque.material = mat
	_calque.color = Color(1, 1, 1, 1)
	_calque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_calque.set_anchors_preset(Control.PRESET_FULL_RECT)
	_calque.modulate.a = 0.0
	hote.add_child(_calque)
	# DERRIERE LE RESTE DE L'INTERFACE. Le masque filtre le monde, pas le HUD :
	# l'argent et les objectifs restent lisibles, sinon on croit a un bug
	# d'affichage au moment ou l'on comprend le moins ce qui se passe.
	hote.move_child(_calque, 0)
	_fondu = create_tween()
	_fondu.tween_property(_calque, "modulate:a", 1.0, FONDU)
	_souffler(nom)


# LA RESPIRATION SE COUPE AVEC L'IMAGE, jamais separement : le masque se retire
# d'un geste, et un souffle qui continuerait une seconde apres que l'ecran s'est
# eclairci ferait croire a quelqu'un d'autre dans la piece.
func _souffler(nom: String) -> void:
	var chemin := str(SONS.get(nom, ""))
	if chemin == "":
		return
	var flux := load(chemin) as AudioStream
	if flux == null:
		return
	if _souffle == null:
		_souffle = AudioStreamPlayer.new()
		_souffle.bus = Audio.BUS_AMBIANCE
		add_child(_souffle)
	_souffle.stream = flux
	_souffle.volume_db = VOLUME
	_souffle.play()


func _taire() -> void:
	if _souffle != null:
		_souffle.stop()


func _lever() -> void:
	_taire()
	if _calque == null:
		return
	var partant := _calque
	_calque = null
	if _fondu != null and _fondu.is_valid():
		_fondu.kill()
	_fondu = create_tween()
	_fondu.tween_property(partant, "modulate:a", 0.0, FONDU)
	_fondu.tween_callback(partant.queue_free)


# Sans attendre, quand on remplace un filtre par un autre : deux calques qui se
# croisent en fondu additionneraient leurs bordures et fermeraient l'image.
func _lever_tout_de_suite() -> void:
	_taire()
	if _fondu != null and _fondu.is_valid():
		_fondu.kill()
	if _calque != null:
		_calque.queue_free()
		_calque = null


## Pour les verifications : le nom du filtre actuellement pose, ou rien.
func filtre_pose() -> String:
	return _pose if _calque != null else ""
