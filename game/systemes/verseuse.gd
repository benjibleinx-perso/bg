# VERSER, EN GESTE PLUTOT QU'EN DIALOGUE.
#
# « MAIS on ne fait que cliquer sans vraiment jouer. Il faut ABSOLUMENT que ces
# etapes de cuisine soient des mini jeux. [...] Par exemple pour verser, il faut
# baisser la souris vers le bas de sorte que le liquide d'une fiole coule dans
# un recipient. Pas assez baisse ou trop, le liquide tombe hors du recipient et
# c'est l'echec, et recommencer. » — retour de Guillaume du 23/08/2026.
#
# CE QU'IL Y AVAIT : un point d'interaction, une invite « Verser, lentement »,
# un evenement brut. Walter venait de dire « Non. Recommence. » et le joueur
# appuyait sur une touche. On lisait une lecon au lieu de la recevoir.
#
# CE QUI DECIDE, ET POURQUOI CE N'EST PAS UNE JAUGE.
#
# Le joueur ne lit rien : il regarde OU LE FILET TOMBE. Trop peu incline, le
# liquide coule le long de la paroi et tombe en deca du becher ; trop, le jet
# passe au-dela. Entre les deux, ca remplit. C'est exactement l'image que
# Guillaume decrit, et elle se comprend sans un mot d'explication — ce qui est
# la premiere regle du projet : aucun chiffre, jamais.
#
# ET LA FIOLE SE VIDE. Une fiole presque vide demande plus d'inclinaison pour
# porter au meme endroit. C'est ce qui empeche de bloquer la souris et
# d'attendre : le geste juste au debut devient trop court a la fin, et il faut
# accompagner. C'est physiquement vrai, donc personne n'a a l'apprendre.
#
# POURQUOI ON TIENT LA TOUCHE. Meme raison qu'au demarreur : tenir, c'est avoir
# la fiole en main. On lache, on la repose, rien n'est casse et on recommence.
# Sans ca, un mini-jeu de precision devient un piege dont on ne peut pas sortir.
class_name Verseuse
extends Node

## Tous les mini-jeux de cuisine sont dans ce groupe. Le controleur y cherche
## qui tient la souris : pendant qu'on verse, elle incline la fiole et ne
## tourne pas la camera.
const GROUPE := "cuisine_souris"

## CE QUE CE GESTE VAUT POUR LA MISSION — voir la meme constante sur le
## demarreur. Le point ne porte plus l'evenement, donc c'est ici qu'il s'ecrit.
const EVENEMENT := "action:verser_bien"

## Emis quand le becher est rempli au trait. C'est ce que la mission attend.
signal reussi

## Emis a chaque echec, avec ce qui a rate — « court », « long » ou « vide ».
## Le scenario s'en sert pour faire parler Walter, qui ne dit pas la meme
## chose selon la faute.
signal rate(faute: String)

## Le point d'interaction qui met la fiole en main. On ecoute son signal plutot
## que de modifier point.gd : un point est un point, et lui apprendre ce qu'est
## un filet de liquide compliquerait les douze autres.
@export var point: NodePath

## Ou dessiner. Le meme hote que le reste de l'interface, donc DANS le
## SubViewport : la scene doit avoir le grain du jeu, pas la nettete du bureau.
@export var interface: NodePath

## Les nombres de ressenti. Ils vivent dans reglages.tres, c'est la regle du
## projet — le demarreur y avait echappe et ses constantes sont restees en dur.
@export var reglages: Reglages

## INCLINAISON A PARTIR DE LAQUELLE LE LIQUIDE SORT.
##
## En dessous, la fiole penche et rien ne coule : c'est la zone ou l'on peut
## respirer, et celle ou l'on revient quand on a peur d'avoir trop verse.
const SEUIL := 0.30

## Inclinaison maximale, en radians, quand la souris est descendue a fond.
const ANGLE_MAX := 1.15

## Geometrie du dessin, en points d interface. LARGE doit contenir le jet le
## plus long — sinon l eclaboussure de l echec se dessine hors du cadre, ce qui
## a ete vu a la capture.
const LARGE := 250.0
const HAUTE := 130.0
const BECHER_DEMI := 26.0

## OU SE TIENT LE BEC DE LA FIOLE, depuis le coin bas gauche du dessin.
##
## Pas au bord : la fiole pivote AUTOUR de son bec, donc son corps balaie vers
## la gauche a mesure qu'on l'incline. Pose a six points du bord, elle sortait
## du cadre des qu'on versait fort — vu a la capture, le corps de la fiole se
## dessinait sur un bidon du decor.
const BEC := Vector2(50.0, -74.0)

## OU EST LE BECHER, mesure DEPUIS LE BEC — comme la chute du filet.
##
## Les deux se comparent en permanence : les rapporter au meme point evite la
## seule erreur possible ici, celle de comparer une distance parcourue par le
## liquide a une position mesuree depuis un bord.
const BECHER_X := 60.0

## COMBIEN LA FIOLE CONTIENT, en fois ce que le trait du becher demande.
##
## Pas un. A un, verser parfaitement des la premiere goutte remplit le becher
## a l'instant exact ou la fiole se vide : la moindre hesitation rend l'etape
## impossible, sans que rien ne le dise. A 1,6 on a droit a une erreur franche
## et a deux petites — au-dela, la contrainte de dose ne se sent plus.
const CONTENANCE := 1.6

var _hote: Control
var _panneau: Control
var _rng := RandomNumberGenerator.new()
var _audio: Audio

## Vrai une fois le point utilise : a partir de la, tenir la touche joue.
var _arme := false

## Vrai tant qu'on tient la fiole.
var _tient := false

var _incl := 0.0
var _reste := 1.0
var _recu := 0.0

## Secondes cumulees pendant lesquelles le filet tombe a cote. Un echec
## instantane serait injuste : on corrige toujours avec un peu de retard.
var _dehors := 0.0

## Ou le filet touche, en points DEPUIS LE BEC. Garde d une image
## a l'autre pour que le dessin et le verdict lisent la meme chose.
var _chute := 0.0

var _fin := 0.0
var _echoue := false
var _faute := ""


func _ready() -> void:
	add_to_group(GROUPE)
	_rng.randomize()
	set_process(false)
	var p := get_node_or_null(point)
	if p != null and p.has_signal("utilise"):
		p.connect("utilise", _sur_point)

	# L'hote se cherche si le chemin ne mene nulle part : la cuisine est une
	# scene instanciee, sa profondeur dans l'arbre depend de qui l'a chargee.
	_hote = get_node_or_null(interface) as Control
	if _hote == null:
		_hote = _chercher_l_interface(get_tree().root)


func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio


func _sur_point(_p: Variant) -> void:
	armer()


## Rend la fiole prenable. Publique pour le menu de test et les captures.
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


## La fiole est-elle en main ? Le controleur le demande avant de laisser la
## souris tourner la camera.
func capte_la_souris() -> bool:
	return _tient and _fin <= 0.0


## Pour les verifications, qui ne peuvent pas regarder l'ecran.
func arme() -> bool:
	return _arme


func inclinaison() -> float:
	return _incl


func recu() -> float:
	return _recu


## Le liquide sort-il ? En dessous du seuil la fiole penche sans couler, et
## « ou tombe le filet » n'a alors pas de reponse.
func coule() -> bool:
	return _tient and _incl > SEUIL and _fin <= 0.0


## Ou le filet touche, rapporte au becher : 0 dedans, negatif trop court,
## positif trop loin. C'est la seule mesure qui dit si le geste est juste.
func ecart() -> float:
	if _incl <= SEUIL:
		return 0.0
	var d := _chute - BECHER_X
	if absf(d) <= BECHER_DEMI:
		return 0.0
	return d - signf(d) * BECHER_DEMI


## Incline la fiole. Appelee par le controleur avec le mouvement de la souris,
## et par le pilote de la suite qui joue.
func incliner(dy: float) -> void:
	if not _tient or _fin > 0.0:
		return
	var sensibilite := 0.0042
	if reglages != null:
		sensibilite = reglages.cuisine_verser_sensibilite
	_incl = clampf(_incl + dy * sensibilite, 0.0, 1.0)


func _process(delta: float) -> void:
	if _fin > 0.0:
		_fin -= delta
		if _fin <= 0.0:
			_panneau.visible = false
			if _echoue:
				_reprendre()
			else:
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

	_couler(delta)
	_panneau.queue_redraw()


func _prendre() -> void:
	_tient = true
	_incl = 0.0
	_dehors = 0.0
	_panneau.visible = true
	if _son() != null:
		_son().bruit("roue_ouvre")


# REPOSER N'EFFACE PAS CE QU'ON A DEJA VERSE.
#
# Le becher garde son contenu et la fiole ce qui lui reste : on a le droit de
# souffler au milieu du geste, pas de recommencer a neuf pour effacer une
# erreur de dosage. C'est ce qui distingue une pause d'un retour en arriere.
func _reposer() -> void:
	_tient = false
	_incl = 0.0
	_panneau.visible = false


func _couler(delta: float) -> void:
	if _incl <= SEUIL:
		_dehors = maxf(0.0, _dehors - delta * 2.0)
		return

	# Le debit suit l'inclinaison au-dela du seuil. La portee, elle, depend
	# AUSSI de ce qui reste : c'est tout le geste.
	var au_dela := (_incl - SEUIL) / (1.0 - SEUIL)
	var debit := au_dela
	var portee := 1.0
	var vidange := 0.55
	if reglages != null:
		portee = reglages.cuisine_verser_portee
		vidange = reglages.cuisine_verser_vidange
	_chute = au_dela * portee * (0.55 + 0.45 * _reste)

	_reste = maxf(0.0, _reste - debit * vidange * delta)

	if absf(_chute - BECHER_X) <= BECHER_DEMI:
		_dehors = maxf(0.0, _dehors - delta)
		_recu = minf(1.0, _recu + debit * vidange * CONTENANCE * delta)
		if _recu >= 1.0:
			_reussite()
			return
	else:
		var tolerance := 0.35
		if reglages != null:
			tolerance = reglages.cuisine_verser_tolerance
		_dehors += delta
		if _dehors >= tolerance:
			_echec("long" if _chute > BECHER_X else "court")
			return

	# LA FIOLE VIDE AVANT LE TRAIT est un echec de dose, pas de precision, et
	# Walter ne le dit pas de la meme facon. Sans ce cas, verser n'importe
	# comment finissait par marcher : il suffisait d'y passer du temps.
	if _reste <= 0.0 and _recu < 1.0:
		_echec("vide")


func _echec(faute: String) -> void:
	_echoue = true
	_faute = faute
	_fin = 1.1
	if _son() != null:
		_son().bruit("choc_leger", Audio.BUS_INTERFACE, 0.7)
	rate.emit(faute)


func _reussite() -> void:
	_echoue = false
	_faute = ""
	_fin = 0.9
	if _son() != null:
		_son().bruit("roue_cran")


# On rate, on reprend : fiole pleine, becher vide, et la main toujours dessus.
# Guillaume demande que l'echec se rattrape — pas qu'il renvoie chercher une
# invite a l'autre bout de la piece.
func _reprendre() -> void:
	_echoue = false
	_tient = false
	_incl = 0.0
	_reste = 1.0
	_recu = 0.0
	_dehors = 0.0
	_chute = 0.0


## Remet tout a zero. Recommencer une partie doit redonner un geste a faire.
func reinitialiser() -> void:
	_arme = false
	_fin = 0.0
	_reprendre()
	if _panneau != null:
		_panneau.visible = false
	set_process(false)


# ------------------------------------------------------------------- dessin
#
# On dessine a la main, comme le reste de l'interface : a 960x720 un theme
# Control ne tombe pas sur la grille de pixels et bave.


func _dessiner() -> void:
	if _panneau == null or not _panneau.visible:
		return
	# OU LE GESTE SE DESSINE, ET POURQUOI PAS AU CENTRE.
	#
	# Le cadran du demarrage est centre et le personnage le traverse : ca passe
	# parce qu'il est un contour fin sur un corps sombre. Ici le dessin est
	# large et plein — le premier essai posait un rectangle noir en plein sur
	# Walter, qui masquait la moitie de la piece et se faisait masquer par lui.
	#
	# Il descend donc dans le bas GAUCHE, le seul coin que le jeu n'utilise
	# pas : le tuto tient le haut gauche, le telephone et la minimap le bas
	# droit. Rien n'est cache, et on voit toujours la paillasse derriere.
	var base := Vector2(_panneau.size.x * 0.09, _panneau.size.y * 0.80)

	# ET IL A UN FOND SOMBRE, contrairement au cadran du demarrage.
	#
	# Celui-la se dessine en contour clair sur une rue de nuit et se lit tres
	# bien. Le meme trait sur les parois beiges du camping-car, en plein jour,
	# disparaissait : mesure faite a la capture, le becher se confondait avec
	# un bidon derriere lui. Un demi-voile n'a fait qu'ajouter une tache grise.
	#
	# Le fond est donc franc, et cadre le geste comme le telephone cadre le
	# sien : ce qui compte est de pouvoir lire OU TOMBE LE FILET, pas de
	# preserver la vue sur une piece de trois metres.
	_panneau.draw_rect(Rect2(base - Vector2(12.0, HAUTE + 10.0),
			Vector2(LARGE + 24.0, HAUTE + 44.0)),
			Color(0.03, 0.03, 0.04, 0.85))

	# LA PAILLASSE, une simple ligne : elle donne le sol du dessin, sans quoi
	# le becher et le filet flottent.
	_panneau.draw_line(base, base + Vector2(LARGE, 0.0),
			Color(0.62, 0.60, 0.56), 2.0)

	_dessiner_becher(base)
	_dessiner_fiole(base)
	_dessiner_filet(base)
	_dessiner_consigne(base)


func _dessiner_becher(base: Vector2) -> void:
	var x := base.x + BEC.x + BECHER_X
	var haut := 42.0
	var g := x - BECHER_DEMI
	var d := x + BECHER_DEMI

	# Le contenu d'abord, les parois par-dessus : un liquide qui deborde du
	# verre se verrait, et c'est le genre de detail qui trahit un dessin.
	var h := _recu * (haut - 6.0)
	if h > 0.0:
		_panneau.draw_rect(Rect2(g + 2.0, base.y - h, BECHER_DEMI * 2.0 - 4.0, h),
				Color(0.85, 0.66, 0.28, 0.85))

	var paroi := Color(0.72, 0.76, 0.78, 0.75)
	_panneau.draw_line(Vector2(g, base.y - haut), Vector2(g, base.y), paroi, 2.0)
	_panneau.draw_line(Vector2(d, base.y - haut), Vector2(d, base.y), paroi, 2.0)
	_panneau.draw_line(Vector2(g, base.y), Vector2(d, base.y), paroi, 2.0)

	# LE TRAIT A ATTEINDRE. C'est le seul objectif affiche du mini-jeu, et il
	# est dessine, pas ecrit : on remplit jusqu'au trait, comme dans la vraie
	# verrerie graduee.
	var t := base.y - (haut - 6.0)
	_panneau.draw_line(Vector2(g + 3.0, t), Vector2(d - 3.0, t),
			Color(0.949, 0.925, 0.867, 0.9), 1.0)


func _dessiner_fiole(base: Vector2) -> void:
	# La fiole pivote autour de son BEC, pas de son pied : c'est le point qui
	# ne bouge pas quand on incline un recipient qu'on tient par le corps.
	var bec := base + BEC
	var a := _incl * ANGLE_MAX
	var ca := cos(a)
	var sa := sin(a)

	# Corps de la fiole, decrit dans son repere a elle puis tourne. Quatre
	# points suffisent : a cette taille, un col dessine se lit comme du bruit.
	var coins: Array[Vector2] = [
		Vector2(-11.0, 0.0), Vector2(11.0, 0.0),
		Vector2(11.0, 46.0), Vector2(-11.0, 46.0)]
	var forme := PackedVector2Array()
	for c in coins:
		forme.append(bec + Vector2(c.x * ca - c.y * sa, c.x * sa + c.y * ca))
	_panneau.draw_polyline(forme + PackedVector2Array([forme[0]]),
			Color(0.72, 0.76, 0.78, 0.8), 2.0)

	# Le liquide qui reste, dessine comme une hauteur dans la fiole. Il ne
	# s'horizontalise pas : a cette echelle, personne ne le verrait, et ca
	# couterait un polygone de plus par image.
	if _reste > 0.0:
		var h := 42.0 * _reste
		var bas := 46.0
		var hb: Array[Vector2] = [
			Vector2(-9.0, bas - h), Vector2(9.0, bas - h),
			Vector2(9.0, bas), Vector2(-9.0, bas)]
		var liq := PackedVector2Array()
		for c in hb:
			liq.append(bec + Vector2(c.x * ca - c.y * sa, c.x * sa + c.y * ca))
		_panneau.draw_colored_polygon(liq, Color(0.85, 0.66, 0.28, 0.75))


func _dessiner_filet(base: Vector2) -> void:
	if _incl <= SEUIL and _fin <= 0.0:
		return
	var bec := base + BEC
	var arrivee := Vector2(base.x + BEC.x + _chute, base.y)

	# Le filet est ROUGE quand il tombe a cote, et il l'est avant l'echec :
	# le joueur doit voir qu'il est en train de rater pendant qu'il peut
	# encore corriger, pas l'apprendre une fois que c'est fini.
	var juste := absf(_chute - BECHER_X) <= BECHER_DEMI
	var teinte := Color(0.85, 0.66, 0.28, 0.9)
	if not juste:
		teinte = Color(0.70, 0.23, 0.18, 0.9)
	if _fin > 0.0 and _echoue:
		teinte = Color(0.70, 0.23, 0.18, 0.9)

	# Deux segments plutot qu'un : un filet qui part du bec et s'incurve se
	# lit comme un ecoulement, une droite se lit comme un trait.
	var milieu := bec.lerp(arrivee, 0.55) + Vector2(0.0, 14.0)
	_panneau.draw_line(bec, milieu, teinte, 2.0)
	_panneau.draw_line(milieu, arrivee, teinte, 2.0)

	if not juste:
		# L'eclaboussure, au sol, la ou ca tombe. Elle grandit avec le temps
		# passe a cote : c'est le compte a rebours de l'echec, montre plutot
		# qu'affiche.
		var large := 6.0 + _dehors * 26.0
		_panneau.draw_line(arrivee - Vector2(large, 0.0),
				arrivee + Vector2(large, 0.0), teinte, 2.0)


func _dessiner_consigne(base: Vector2) -> void:
	var police := _panneau.get_theme_default_font()
	if police == null:
		return

	# LA CONSIGNE EST UN GESTE, PAS UNE PHRASE. Une fleche vers le bas et le
	# nom de la touche tenue : Guillaume demande « une petite indication de la
	# mecanique a faire », pas un mode d'emploi.
	var texte := "%s   souris vers le bas" % Touches.nom("interagir")
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 10).x
	var p := Vector2(base.x + LARGE * 0.5 - largeur * 0.5, base.y + 24.0)
	police.draw_string(_panneau.get_canvas_item(), p, texte,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.72, 0.70, 0.64))

	var f := Vector2(p.x - 12.0, p.y - 4.0)
	_panneau.draw_line(f - Vector2(0.0, 5.0), f + Vector2(0.0, 3.0),
			Color(0.96, 0.77, 0.19), 2.0)
	_panneau.draw_line(f + Vector2(-3.0, 0.0), f + Vector2(0.0, 3.0),
			Color(0.96, 0.77, 0.19), 2.0)
	_panneau.draw_line(f + Vector2(3.0, 0.0), f + Vector2(0.0, 3.0),
			Color(0.96, 0.77, 0.19), 2.0)


# Le Control qui porte l'interface du jeu, retrouve par son nom. C'est le meme
# que celui de la cuisson, du telephone et du demarreur : « Echelle ».
func _chercher_l_interface(n: Node) -> Control:
	if n.name == "Echelle" and n is Control:
		return n as Control
	for e in n.get_children():
		var t := _chercher_l_interface(e)
		if t != null:
			return t
	return null
