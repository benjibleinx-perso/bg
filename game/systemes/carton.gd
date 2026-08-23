# UN CARTON PLEIN ECRAN : du noir, une phrase, et le jeu reprend.
#
# « Le titre "3 semaines plus tôt" doit apparaitre a la fin de la
# cinematique. Sur un fond noir pendant quelques secondes et non en jeu. C'est
# une vraie pause. On ouvre sur un fondu du noir vers le jeu. » — retour du
# 23/08/2026.
#
# CE QU'IL REMPLACE, ET POURQUOI CE N'ETAIT PAS LA MEME CHOSE. « Trois
# semaines plus tot » etait un TUTO : un bandeau, en haut a gauche, par-dessus
# le decor, de la meme forme que « E pour interagir ». Un saut de trois
# semaines annonce comme une consigne de touche ne se lit pas comme un saut de
# trois semaines.
#
# TROIS TEMPS, ET LE PREMIER EST LE PLUS IMPORTANT : le noir s'installe, la
# phrase s'y pose, puis le noir se leve sur le jeu. Sans le premier, le carton
# apparait sur le decor qu'il est cense faire oublier.
class_name Carton
extends Control

## Emis quand le carton est fini et que le noir est completement leve.
signal fini

## Combien de temps le noir met a s'installer, combien il reste, et combien il
## met a se lever. En secondes REELLES.
##
## Le milieu est long : c'est « une vraie pause », et une pause qui dure moins
## de deux secondes n'en est pas une — on la lit comme un raté d'affichage.
const ENTREE := 0.7
const TENUE := 2.6
const SORTIE := 1.2

enum Phase { REPOS, ENTREE_, TENUE_, SORTIE_ }

var _phase: int = Phase.REPOS
var _temps: float = 0.0
var _texte: String = ""
var _audio: Audio


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Il doit vivre meme quand le jeu est suspendu : un carton qui se fige a
	# mi-fondu laisse un ecran noir dont on ne sort plus.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)


## Affiche cette phrase sur du noir. Un carton deja en cours est remplace :
## deux cartons qui se superposent ne se lisent ni l'un ni l'autre.
func montrer(texte: String) -> void:
	if texte == "":
		return
	_texte = texte
	_phase = Phase.ENTREE_
	_temps = 0.0
	visible = true
	queue_redraw()
	# UN SON A L'APPARITION, comme demande — « rajouter un petit effet sonore
	# a l'apparition de ce titre ». On emprunte celui de la roue qui s'ouvre :
	# une note sourde, deja dans la banque, qui ne ressemble a aucune alerte.
	if _son() != null:
		_son().bruit("roue_ouvre")


func actif() -> bool:
	return _phase != Phase.REPOS


func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio


func _process(delta: float) -> void:
	if _phase == Phase.REPOS:
		return
	# Le temps REEL : un carton pose pendant un ralenti — l'ecran de fin en
	# met un — durerait quatre fois trop longtemps.
	_temps += delta / maxf(0.05, Engine.time_scale)
	match _phase:
		Phase.ENTREE_:
			if _temps >= ENTREE:
				_phase = Phase.TENUE_
				_temps = 0.0
		Phase.TENUE_:
			if _temps >= TENUE:
				_phase = Phase.SORTIE_
				_temps = 0.0
		Phase.SORTIE_:
			if _temps >= SORTIE:
				_phase = Phase.REPOS
				visible = false
				fini.emit()
	queue_redraw()


func _draw() -> void:
	if _phase == Phase.REPOS:
		return
	var police := get_theme_default_font()
	if police == null:
		return

	# L'opacite du noir suit la phase. Il est PLEIN pendant la tenue : c'est
	# ce qui fait la coupure, un voile a quatre-vingts pour cent laisse voir
	# le decor et le saut de trois semaines n'a plus lieu.
	var noir := 1.0
	if _phase == Phase.ENTREE_:
		noir = clampf(_temps / ENTREE, 0.0, 1.0)
	elif _phase == Phase.SORTIE_:
		noir = 1.0 - clampf(_temps / SORTIE, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.03, noir))

	# La phrase n'apparait qu'une fois le noir installe, et s'efface AVANT
	# lui : elle ne doit jamais se lire par-dessus le decor.
	var texte := 0.0
	if _phase == Phase.TENUE_:
		texte = clampf(_temps / 0.4, 0.0, 1.0)
		texte *= clampf((TENUE - _temps) / 0.5, 0.0, 1.0)
	if texte <= 0.0:
		return

	var couleur := Color(0.949, 0.925, 0.867, texte)
	var largeur := police.get_string_size(_texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 22).x
	var p := Vector2((size.x - largeur) / 2.0, size.y * 0.5)
	police.draw_string(get_canvas_item(), p, _texte,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, couleur)

	# Un filet sous la phrase, dans l'ambre du desert : sans lui, une ligne de
	# texte blanche au milieu du noir ressemble a un message d'erreur.
	draw_rect(Rect2(p.x, p.y + 9.0, largeur, 1.0),
			Color(0.78, 0.60, 0.25, texte * 0.8))
