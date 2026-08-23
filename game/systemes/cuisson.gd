# Cuisiner devient un geste, et ce geste decide de la qualite.
#
# AVANT : on appuyait sur F devant l'atelier, on recevait la botte, et la
# purete du produit ne dependait de rien. Les cinq paliers de purete existaient
# depuis longtemps — avec leurs couleurs, leur effet sur le prix, leur place
# dans la sauvegarde — et RIEN dans le jeu ne permettait de les faire bouger
# autrement qu'avec le menu de test.
#
# MAINTENANT : trois passages, trois appuis, une couleur a la sortie.
#
# CE QUI A ETE REFUSE, ET POURQUOI.
#
# Un mini-jeu de dosage avec temperature, pression et trois curseurs aurait ete
# plus riche et faux : le jeu est lent, sale et provincial, et Walter cuisine
# dans un camping-car avec ce qu'il a. Trois gestes justes valent mieux qu'un
# tableau de bord.
#
# AUCUN CHIFFRE, jamais — c'est la premiere regle du projet. Pas de score, pas
# de pourcentage, pas de « 87 % de purete ». Le curseur se voit, la zone se
# voit, et le resultat se lit sur la COULEUR du cristal qu'on emporte. Un
# joueur qui rate comprend qu'il a rate parce que son produit est brun, pas
# parce qu'un nombre est rouge.
class_name Cuisson
extends Node

## Emis quand la cuisson se termine, avec le palier obtenu (0 a 4).
signal finie(palier: int)

## L'atelier. On ecoute son signal plutot que de modifier point.gd : un point
## est un point, et lui ajouter la notion d'epreuve compliquerait les douze
## autres qui n'en ont pas besoin.
@export var atelier: NodePath

## Ou dessiner. Le meme hote que le reste de l'interface, donc dans le
## SubViewport : la barre doit avoir le grain du jeu, pas la nettete du bureau.
@export var interface: NodePath

## Combien de passages. Trois : un seul serait un pile ou face, cinq
## lasseraient. Trois laissent le temps de comprendre et de se rattraper.
const PASSAGES := 3

## Largeur de la zone a viser, en fraction de la barre. 0,16 demande de
## regarder sans demander des reflexes : c'est une cuisine, pas un duel.
const ZONE := 0.16

## Secondes pour un aller simple du curseur. Il rebondit aux deux bouts.
const TRAVERSEE := 1.15

var _hote: Control
var _barre: Control
var _joue := false
var _passage := 0
var _t := 0.0
var _sens := 1.0
var _scores: Array[float] = []
var _cible := 0.5
var _rng := RandomNumberGenerator.new()
var _dernier := -1.0
var _fin_a := 0.0


func _ready() -> void:
	_rng.randomize()
	set_process(false)
	var p := get_node_or_null(atelier)
	if p != null and p.has_signal("utilise"):
		p.connect("utilise", _sur_atelier)
	_hote = get_node_or_null(interface) as Control


func _sur_atelier(_point: Variant) -> void:
	demarrer()


## Lance la cuisson. Publique pour que le menu de test puisse l'appeler sans
## avoir a se rendre dans le camping-car.
func demarrer() -> void:
	if _joue or _hote == null:
		return
	_joue = true
	_passage = 0
	_scores.clear()
	_t = 0.0
	_sens = 1.0
	_dernier = -1.0
	_nouvelle_cible()
	if _barre == null:
		_barre = Control.new()
		_barre.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_barre.set_anchors_preset(Control.PRESET_FULL_RECT)
		_barre.draw.connect(_dessiner)
		_hote.add_child(_barre)
	_barre.visible = true
	set_process(true)


# LA ZONE SE DEPLACE A CHAQUE PASSAGE, et ce n'est pas pour embeter.
#
# Fixe au centre, on apprend le rythme en deux essais et on ne regarde plus
# l'ecran — le geste devient une horloge interieure. En la deplaçant, il faut
# VOIR ou elle est, ce qui est exactement ce qu'on veut d'un joueur qui cuisine.
# Elle reste loin des bords : y coller la zone rendrait le passage injouable
# puisque le curseur y ralentit et rebondit.
func _nouvelle_cible() -> void:
	_cible = _rng.randf_range(0.22, 0.78)


func _process(delta: float) -> void:
	if not _joue:
		return

	# La fin laisse une seconde de lecture : couper l'affichage a l'instant du
	# troisieme appui ne laisserait pas voir le dernier resultat.
	if _fin_a > 0.0:
		_fin_a -= delta
		if _fin_a <= 0.0:
			_terminer()
		_barre.queue_redraw()
		return

	_t += _sens * delta / TRAVERSEE
	if _t >= 1.0:
		_t = 1.0
		_sens = -1.0
	elif _t <= 0.0:
		_t = 0.0
		_sens = 1.0

	if Input.is_action_just_pressed("interagir") or Input.is_action_just_pressed("ui_accept"):
		_valider()

	_barre.queue_redraw()


func _valider() -> void:
	# 1 au centre de la zone, 0 au bord. Au-dela, zero : un passage rate ne
	# rapporte rien, mais il ne retire rien non plus — on cuisine mal, on ne
	# se punit pas.
	var ecart := absf(_t - _cible)
	var score := clampf(1.0 - ecart / ZONE, 0.0, 1.0)
	_scores.append(score)
	_dernier = score
	_passage += 1
	if _passage >= PASSAGES:
		_fin_a = 1.1
		return
	_nouvelle_cible()
	# On repart du bord oppose : enchainer depuis la position courante donnerait
	# au troisieme passage un depart plus facile qu'au premier.
	_t = 0.0 if _sens > 0.0 else 1.0


## CE QUE VAUT UNE MOYENNE, en palier de purete de 1 a 5.
##
## Publique et statique pour une raison precise : le controle qui accompagne ce
## fichier RECOPIAIT cette formule au lieu de l'appeler. Il imprimait donc une
## belle echelle de cinq paliers, tous justes, pendant que le jeu en posait un
## autre — et il ne pouvait pas voir le bug qu'il y avait ici.
##
## LE BUG, justement : on passait a « poser » un index de 0 a 4 alors qu'elle
## attend un palier de 1 a 5. Tout etait decale d'un cran vers le bas, et le
## bleu du dernier palier n'est JAMAIS sorti de ce mini-jeu. Piege 42 dans les
## deux sens : mesurer ce qui SORT de la traduction, et ne jamais recopier la
## traduction dans ce qui la verifie.
static func palier_pour(moyenne: float) -> int:
	var haut := Purete.PALIERS.size()
	return clampi(1 + int(round(moyenne * float(haut - 1))), 1, haut)


func _terminer() -> void:
	_joue = false
	set_process(false)
	if _barre != null:
		_barre.visible = false

	var moyenne := 0.0
	for s in _scores:
		moyenne += s
	moyenne /= maxf(1.0, float(_scores.size()))

	# La moyenne devient un palier. Le premier est le plancher : on ressort
	# toujours avec quelque chose, meme rate — c'est du brun, et le brun se
	# vend mal. Rater ne bloque pas la mission, ça la paie moins.
	var palier := palier_pour(moyenne)

	var p := Purete.courante(self)
	if p != null:
		p.poser(palier)
	print("CUISSON : %d passage(s), moyenne %.2f -> palier %d (%s)"
			% [_scores.size(), moyenne, palier,
			p.nom() if p != null else "?"])
	finie.emit(palier)


# On dessine a la main, comme le reste de l'interface : a 960x720 un theme
# Control ne tombe pas sur la grille de pixels et bave.
func _dessiner() -> void:
	if _barre == null:
		return
	var taille := _barre.size
	var large := taille.x * 0.44
	var haute := 14.0
	var x := (taille.x - large) * 0.5
	var y := taille.y * 0.74

	# Le fond, puis la zone a viser, puis le curseur. Dans cet ordre : le
	# curseur doit rester lisible AU-DESSUS de la zone quand il est dedans.
	_barre.draw_rect(Rect2(x - 2, y - 2, large + 4, haute + 4),
			Color(0.02, 0.02, 0.03, 0.85))
	_barre.draw_rect(Rect2(x, y, large, haute), Color(0.16, 0.14, 0.12, 0.9))

	var zx := x + (_cible - ZONE * 0.5) * large
	_barre.draw_rect(Rect2(zx, y, ZONE * large, haute),
			Color(0.32, 0.62, 0.28, 0.75))

	var cx := x + _t * large
	_barre.draw_rect(Rect2(cx - 2.0, y - 4, 4.0, haute + 8),
			Color(0.95, 0.93, 0.87, 1.0))

	# Les passages deja faits, en pastilles. C'est le seul retour d'avancement,
	# et il ne chiffre rien : trois points, remplis ou vides.
	for i in PASSAGES:
		var px := x + large + 12.0 + float(i) * 10.0
		var plein := i < _scores.size()
		var teinte := Color(0.95, 0.93, 0.87, 1.0) if plein else Color(0.4, 0.4, 0.4, 0.6)
		if plein and _scores[i] < 0.34:
			teinte = Color(0.44, 0.28, 0.15, 1.0)
		_barre.draw_rect(Rect2(px, y + 3.0, 6.0, 6.0), teinte)
