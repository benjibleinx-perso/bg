# REGLER LA PLAQUE : TENIR UNE CHALEUR QUI NE TIENT PAS TOUTE SEULE.
#
# Deuxieme des trois gestes de cuisine, battement B4. « Il faut creer des
# mecaniques de jeu DIFFERENTES pour chacune des etapes » — retour de Guillaume
# du 23/08/2026. Verser demande de viser ; celui-ci demande d'accompagner.
#
# CE QU'IL Y AVAIT : une invite « Regler la plaque », un dialogue, l'etape
# suivante.
#
# LE GESTE. On tient la touche pour avoir la main sur le robinet, et la MOLETTE
# monte ou baisse le gaz. Deux commandes differentes du versement, exprès : un
# mini-jeu qui se joue avec le meme geste que le precedent est le meme mini-jeu.
#
# CE QUI FAIT LA DIFFICULTE, ET CE N'EST PAS L'ADRESSE.
#
# Le liquide ne suit pas le gaz : il rattrape. On corrige donc TOUJOURS en
# retard, et pousser le gaz a fond pour aller plus vite fait deborder trente
# secondes plus tard. C'est la seule chose a comprendre, et elle s'apprend en
# la ratant une fois.
#
# ET LA CONSIGNE DESCEND. Un melange qui a commence a reagir demande moins de
# feu qu'au premier instant : la fenetre juste glisse vers le bas pendant toute
# la cuisson. Sans ca, on trouve le bon cran une fois et on regarde le temps
# passer — exactement le defaut que le retour reproche a toute la mission.
#
# AUCUN CHIFFRE, ET AUCUNE JAUGE. Trois choses se voient : la flamme, dont la
# hauteur EST le gaz ; les bulles, qui disent la chaleur reelle ; et la mousse,
# qui monte dans le col des qu'on est trop chaud. On cuisine entre deux
# symptomes. L'avancement, lui, se lit sur la COULEUR du produit — il vire
# lentement au bleu cristal, celui de la serie, et la fournee est prete quand
# il n'est plus ambre du tout.
class_name Chauffe
extends Node

## Meme groupe que la verseuse : c'est le groupe des gestes qui prennent la
## souris, et le controleur n'a qu'un seul endroit ou regarder.
const GROUPE := Verseuse.GROUPE

## CE QUE CE GESTE VAUT POUR LA MISSION. Le point n'annonce plus rien.
const EVENEMENT := "action:chauffer_bien"

## Emis quand la fournee est prete — le liquide est entierement bleu.
signal reussi

## Emis a chaque echec, avec ce qui a rate. « deborde » pour l'instant, et il
## y en aura d'autres le jour ou un labo apportera ses propres pannes.
signal rate(faute: String)

@export var point: NodePath
@export var interface: NodePath
@export var reglages: Reglages

## LA FENETRE JUSTE, en part de chaleur, au premier instant de la cuisson.
## Large : on doit pouvoir la trouver sans la chercher, la difficulte est de
## l'y garder pendant qu'elle descend.
const FENETRE_BAS := 0.52
const FENETRE_HAUT := 0.78

## De combien la fenetre descend entre le debut et la fin de la cuisson.
## C'est elle qui oblige a accompagner : a 0,30 il faut avoir baisse le gaz
## d'un bon tiers avant la fin, sans quoi on deborde.
const DERIVE := 0.30

## Ce que la molette ajoute au gaz par cran.
const CRAN := 0.07

## Geometrie du dessin, en points d'interface.
const LARGE := 250.0
const HAUTE := 130.0

var _hote: Control
var _panneau: Control
var _audio: Audio

var _arme := false
var _tient := false

## Ce qu'on demande a la plaque, et ce que le liquide en fait. Les deux ne se
## rejoignent jamais tout a fait : c'est tout le mini-jeu.
var _gaz := 0.0
var _chaleur := 0.0

## Ce qui est cuit, de 0 a 1. C'est la couleur du produit, pas un compteur.
var _cuit := 0.0

## La mousse qui monte dans le col quand on chauffe trop. Elle redescend des
## qu'on revient dans la fenetre — deborder demande d'insister.
var _mousse := 0.0

var _fin := 0.0
var _echoue := false


func _ready() -> void:
	add_to_group(GROUPE)
	set_process(false)
	var p := get_node_or_null(point)
	if p != null and p.has_signal("utilise"):
		p.connect("utilise", _sur_point)
	_hote = get_node_or_null(interface) as Control
	if _hote == null:
		_hote = _chercher_l_interface(get_tree().root)


func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio


func _sur_point(_p: Variant) -> void:
	armer()


## Rend le robinet prenable. Publique pour le menu de test et les captures.
func armer() -> void:
	if _hote == null:
		return
	if _panneau == null:
		_panneau = Control.new()
		_panneau.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_panneau.set_anchors_preset(Control.PRESET_FULL_RECT)
		_panneau.draw.connect(_dessiner)
		_hote.add_child(_panneau)
	_panneau.visible = false
	_arme = true
	set_process(true)


## La main est-elle sur le robinet ? Le controleur le demande avant de laisser
## la molette zoomer la camera.
func capte_la_souris() -> bool:
	return _tient and _fin <= 0.0


## Un cran de molette. +1 monte le gaz, -1 le baisse.
func molette(sens: float) -> void:
	if not _tient or _fin > 0.0:
		return
	var cran := CRAN
	if reglages != null:
		cran = reglages.cuisine_plaque_cran
	_gaz = clampf(_gaz + sens * cran, 0.0, 1.0)


func arme() -> bool:
	return _arme


func gaz() -> float:
	return _gaz


func chaleur() -> float:
	return _chaleur


func cuit() -> float:
	return _cuit


## Le centre de la fenetre juste, maintenant. Elle descend avec la cuisson.
func fenetre() -> Vector2:
	var d := DERIVE * _cuit
	return Vector2(FENETRE_BAS - d, FENETRE_HAUT - d)


## Ou l'on est par rapport a la fenetre : 0 dedans, negatif trop froid,
## positif trop chaud. La seule mesure dont le joueur a besoin, et il la lit
## sur les bulles et la mousse, jamais en clair.
func ecart() -> float:
	var f := fenetre()
	if _chaleur < f.x:
		return _chaleur - f.x
	if _chaleur > f.y:
		return _chaleur - f.y
	return 0.0


func _process(delta: float) -> void:
	if _fin > 0.0:
		_fin -= delta
		if _fin <= 0.0:
			_panneau.visible = false
			if _echoue:
				_reprendre()
			else:
				# On lache le robinet — meme oubli que sur la verseuse, meme
				# consequence : la souris serait restee captee par un geste
				# termine.
				_tient = false
				_arme = false
				set_process(false)
				reussi.emit()
		_panneau.queue_redraw()
		return

	if not _arme:
		return

	var tenu := Input.is_action_pressed("interagir")
	if tenu and not _tient:
		_prendre()
	elif not tenu and _tient:
		_reposer()
	if not _tient:
		return

	_cuire(delta)
	_panneau.queue_redraw()


func _prendre() -> void:
	_tient = true
	_panneau.visible = true
	if _son() != null:
		_son().bruit("roue_ouvre")


# LACHER LE ROBINET N'ARRETE PAS LA PLAQUE, et c'est le contraire de la fiole.
#
# On repose une fiole ; on n'eteint pas un bec de gaz en retirant la main. La
# cuisson continue donc, hors du panneau, et revenir peut trouver un ballon qui
# a debordé. C'est ce qui fait qu'on reste, et c'est vrai.
func _reposer() -> void:
	_tient = false
	_panneau.visible = false


func _cuire(delta: float) -> void:
	var reaction := 0.55
	var vitesse := 0.10
	var patience := 2.2
	if reglages != null:
		reaction = reglages.cuisine_plaque_inertie
		vitesse = reglages.cuisine_plaque_vitesse
		patience = reglages.cuisine_plaque_patience

	# L'INERTIE. Le liquide rattrape le gaz, il ne le suit pas.
	_chaleur += (_gaz - _chaleur) * reaction * delta

	var e := ecart()
	if e == 0.0:
		_cuit = minf(1.0, _cuit + vitesse * delta)
		_mousse = maxf(0.0, _mousse - delta)
		if _cuit >= 1.0:
			_reussite()
		return

	if e > 0.0:
		# Trop chaud : la mousse monte d'autant plus vite qu'on depasse.
		_mousse += e * delta * 3.0
		if _mousse >= patience:
			_echec("deborde")
		return

	# Trop froid : rien ne brule, rien n'avance. La cuisson STAGNE, elle ne
	# recule pas — punir deux fois la meme hesitation rendrait le geste
	# desagreable sans le rendre plus interessant.
	_mousse = maxf(0.0, _mousse - delta)


func _echec(faute: String) -> void:
	_echoue = true
	_fin = 1.1
	if _son() != null:
		_son().bruit("choc_leger", Audio.BUS_INTERFACE, 0.7)
	rate.emit(faute)


func _reussite() -> void:
	_echoue = false
	_fin = 1.2
	if _son() != null:
		_son().bruit("roue_cran")


# ON REPART D'UN BALLON PROPRE, mais PAS d'une cuisson a zero : ce qui etait
# cuit avant de deborder l'est encore. Repartir de rien apres trente secondes
# de reglage juste ferait de l'echec une punition, alors qu'il doit etre une
# lecon — c'est ce que Guillaume demande en disant que l'echec se rattrape.
func _reprendre() -> void:
	_echoue = false
	_tient = false
	_mousse = 0.0
	_gaz = 0.0
	_chaleur = 0.0
	_cuit = maxf(0.0, _cuit - 0.2)


func reinitialiser() -> void:
	_arme = false
	_fin = 0.0
	_cuit = 0.0
	_reprendre()
	if _panneau != null:
		_panneau.visible = false
	set_process(false)


# ------------------------------------------------------------------- dessin


func _dessiner() -> void:
	if _panneau == null or not _panneau.visible:
		return
	# Meme coin que la verseuse, et c'est voulu : deux gestes du meme plan de
	# travail qui s'afficheraient a deux endroits differents donneraient
	# l'impression de deux interfaces au lieu d'une cuisine.
	var base := Vector2(_panneau.size.x * 0.09, _panneau.size.y * 0.80)

	_panneau.draw_rect(Rect2(base - Vector2(12.0, HAUTE + 10.0),
			Vector2(LARGE + 24.0, HAUTE + 44.0)),
			Color(0.03, 0.03, 0.04, 0.85))
	_panneau.draw_line(base, base + Vector2(LARGE, 0.0),
			Color(0.62, 0.60, 0.56), 2.0)

	_dessiner_flamme(base)
	_dessiner_ballon(base)
	_dessiner_consigne(base)


# LA FLAMME EST LE GAZ, litteralement : sa hauteur est la commande. C'est le
# seul retour immediat du mini-jeu — tout le reste arrive en retard, et c'est
# pour ca qu'il en faut un.
func _dessiner_flamme(base: Vector2) -> void:
	var x := base.x + 96.0
	var h := 6.0 + _gaz * 26.0
	# Le bruleur.
	_panneau.draw_line(Vector2(x - 22.0, base.y - 2.0),
			Vector2(x + 22.0, base.y - 2.0), Color(0.45, 0.44, 0.42), 3.0)
	if _gaz <= 0.0:
		return
	# Trois langues, la plus haute au centre. Le bleu du gaz vire a l'orange
	# quand on pousse : une flamme qui force ne fait pas la meme couleur.
	var chaud := Color(0.35, 0.68, 0.98).lerp(Color(0.91, 0.45, 0.05), _gaz)
	for i in 3:
		var dx := (float(i) - 1.0) * 10.0
		var ph := h * (1.0 if i == 1 else 0.62)
		_panneau.draw_line(Vector2(x + dx, base.y - 3.0),
				Vector2(x + dx, base.y - 3.0 - ph), chaud, 5.0)


func _dessiner_ballon(base: Vector2) -> void:
	var centre := Vector2(base.x + 96.0, base.y - 62.0)
	var r := 28.0

	# LE PRODUIT. Ambre au depart, bleu cristal a la fin — la teinte de la
	# charte, celle que la serie a choisie pour qu'on reconnaisse le produit a
	# l'ecran. C'est le seul avancement affiche, et ce n'est pas un nombre.
	#
	# LA TEINTE TOURNE, ELLE NE SE MELANGE PAS. Un fondu direct entre les deux
	# couleurs passe par un kaki terne au milieu du parcours : vu a la capture,
	# la mi-cuisson ne se distinguait ni du depart ni de l'arrivee, et c'est le
	# SEUL avancement que le joueur ait. En tournant la teinte on passe par le
	# jaune puis le vert — la couleur bouge tout le temps, donc on voit que ca
	# avance meme sans savoir combien il reste.
	var produit := Color.from_hsv(lerpf(0.09, 0.52, _cuit), 0.62, 0.86, 0.78)
	_panneau.draw_circle(centre, r - 3.0, produit)

	# LES BULLES disent la chaleur REELLE, celle qui compte. Aucune quand c'est
	# froid, regulieres quand c'est juste, serrees quand ca s'emballe.
	var combien := int(_chaleur * 9.0)
	for i in combien:
		var a := float(i) * 1.9
		var p := centre + Vector2(sin(a) * r * 0.55, cos(a * 1.7) * r * 0.45)
		_panneau.draw_circle(p, 1.6, Color(1.0, 1.0, 1.0, 0.55))

	# LE COL, et la mousse qui y monte quand on chauffe trop. Elle est LE
	# signal d'alarme, et elle arrive avant l'echec : on a le temps de baisser.
	var col_bas := centre + Vector2(0.0, -r + 2.0)
	var col_haut := col_bas + Vector2(0.0, -26.0)
	var verre := Color(0.72, 0.76, 0.78, 0.8)
	_panneau.draw_line(col_bas + Vector2(-7.0, 0.0),
			col_haut + Vector2(-7.0, 0.0), verre, 2.0)
	_panneau.draw_line(col_bas + Vector2(7.0, 0.0),
			col_haut + Vector2(7.0, 0.0), verre, 2.0)

	var patience := 2.2
	if reglages != null:
		patience = reglages.cuisine_plaque_patience
	if _mousse > 0.0:
		var m := clampf(_mousse / patience, 0.0, 1.0) * 26.0
		_panneau.draw_rect(Rect2(col_bas.x - 6.0, col_bas.y - m, 12.0, m),
				Color(0.92, 0.86, 0.72, 0.85))

	# La panse, par-dessus le contenu.
	_cercle(centre, r, verre)


func _dessiner_consigne(base: Vector2) -> void:
	var police := _panneau.get_theme_default_font()
	if police == null:
		return
	var texte := "%s   molette : le gaz" % Touches.nom("interagir")
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 10).x
	police.draw_string(_panneau.get_canvas_item(),
			Vector2(base.x + LARGE * 0.5 - largeur * 0.5, base.y + 24.0),
			texte, HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
			Color(0.72, 0.70, 0.64))


func _cercle(centre: Vector2, rayon: float, couleur: Color) -> void:
	var pas := 0.34
	var a := 0.0
	while a < TAU:
		var b := minf(a + pas, TAU)
		_panneau.draw_line(centre + Vector2(sin(a), -cos(a)) * rayon,
				centre + Vector2(sin(b), -cos(b)) * rayon, couleur, 2.0)
		a = b


func _chercher_l_interface(n: Node) -> Control:
	if n.name == "Echelle" and n is Control:
		return n as Control
	for e in n.get_children():
		var t := _chercher_l_interface(e)
		if t != null:
			return t
	return null
