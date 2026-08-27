# LE DEMARRAGE DU CAMPING-CAR, EN GESTE PLUTOT QU'EN TEXTE.
#
# « Le demarrage : ne PAS ecrire "le moteur tousse" par pitie, il faut le
# vivre, pas le lire. » — retour de Guillaume du 23/08/2026.
#
# CE QU'IL Y AVAIT : un point d'interaction avec un compteur d'essais. On
# appuyait deux ou trois fois, un bandeau annoncait que le moteur toussait, et
# ca partait. Le joueur n'y faisait rien — il assistait a un tirage au sort en
# lisant le resultat.
#
# CE QU'IL DEMANDE, mot pour mot : « Mettre par exemple un cercle epais avec
# une zone a cliquer, placee aleatoirement sur le cercle. Une aiguille tourne
# en vitesse constante, il faut maintenir la touche E pour laisser apparaitre
# ce cadrant de demarrage, et appuyer sur A quand l'aiguille est dans la zone
# de validation. Il faut valider 3 zones de suite (chacune de plus en plus
# petites). Quand une zone est validee, l'aiguille tourne dans l'autre sens.
# Si le joueur se trompe : Son de moteur qui se noie et le cadrant disparait. »
#
# POURQUOI TENIR UNE TOUCHE ET EN PRESSER UNE AUTRE. Ce n'est pas une
# complication : la premiere est le CONTACT, la seconde le geste. Lacher le
# contact ferme le cadran — on peut renoncer, regarder autour, et recommencer.
# C'est ce qui distingue ce mini-jeu d'une epreuve de reflexe.
class_name Demarreur
extends Node

## Tous les demarreurs sont dans ce groupe. Le scenario les y cherche : le
## decor du fosse est instancie a l'execution, donc aucun chemin ecrit a la
## main ne tient.
const GROUPE := "demarreur"

## CE QUE CE GESTE VAUT POUR LA MISSION.
##
## Le scenario emet l'evenement, pas ce fichier — mais c'est ici qu'il est
## ECRIT, et une seule fois. Sans cette declaration, le controle « chaque etape
## a quelqu'un pour la franchir » cherchait l'emetteur dans les points des
## scenes, n'y trouvait rien, et accusait l'etape « demarrer » d'etre orpheline
## alors qu'elle se joue tres bien. Un mini-jeu qui remplace un point doit dire
## ce qu'il remplace.
const EVENEMENT := "action:demarrer"

## Emis quand le moteur prend. C'est ce que la mission attend.
signal reussi

## Emis a chaque echec, avec le rang de la zone ratee. Le scenario s'en sert
## pour faire parler Jesse.
signal rate(zone: int)

## Le poste de conduite. On ecoute son signal plutot que de modifier point.gd :
## un point est un point, et lui apprendre ce qu'est un cadran compliquerait
## les douze autres qui n'en ont pas besoin.
@export var poste: NodePath

## Ou dessiner. Le meme hote que le reste de l'interface, donc DANS le
## SubViewport : le cadran doit avoir le grain du jeu.
@export var interface: NodePath

## COMBIEN DE ZONES A VALIDER, et de combien elles retrecissent.
##
## Trois, comme demande. La premiere est large — on comprend le geste en le
## faisant — et la troisieme fait moins de la moitie : c'est elle qui donne le
## sentiment d'avoir demarre le vehicule plutot que d'avoir eu de la chance.
const ZONES := 3
const LARGEUR_ZONE: Array[float] = [0.17, 0.12, 0.075]

## Tours par seconde de l'aiguille. Constante, comme demande — une aiguille
## qui accelere transforme l'adresse en loterie.
const VITESSE := 0.62

## Rayon du cadran et epaisseur de son anneau, en points d'interface.
const RAYON := 46.0
const EPAISSEUR := 9.0

var _hote: Control
var _cadran: Control
var _rng := RandomNumberGenerator.new()

## Vrai tant que le contact est mis, c'est-a-dire tant qu'on tient la touche.
var _contact := false

var _zone := 0
var _angle := 0.0
var _sens := 1.0
var _cible := 0.0

## Ce qui reste a afficher apres un echec ou une reussite, en secondes. Couper
## le cadran a l'instant du dernier appui ne laisserait pas voir ce qui vient
## de se passer.
var _fin := 0.0
var _echoue := false

var _audio: Audio


func _ready() -> void:
	add_to_group(GROUPE)
	_rng.randomize()
	set_process(false)
	var p := get_node_or_null(poste)
	if p != null and p.has_signal("utilise"):
		p.connect("utilise", _sur_poste)

	# L'HOTE SE CHERCHE SI LE CHEMIN NE MENE NULLE PART.
	#
	# Le decor du fosse est instancie a l'execution par desert.gd, pas pose
	# dans le monde : sa profondeur dans l'arbre depend de qui l'a cree, et un
	# NodePath relatif ecrit a la main y devient faux au premier remaniement.
	# Le cadran ne s'afficherait alors nulle part, en silence.
	_hote = get_node_or_null(interface) as Control
	if _hote == null:
		_hote = _chercher_l_interface(get_tree().root)


## LE DEMARREUR QUI PATINE, EN BOUCLE, TANT QUE LE CONTACT EST MIS.
##
## Livre par Guillaume le 26/08/2026 sous le nom « RV essaye de demarrer
## (loop) » — et c'est exactement ce que ce mini-jeu montre : on tient la cle,
## le moteur tourne sans prendre, et on cherche le moment ou il accroche. Le
## son n'accompagne pas le geste, il EST le geste.
##
## UN CHEMIN EN CONSTANTE, ET PAS UNE ENTREE DE BANQUE. La banque joue des sons
## PONCTUELS ; celui-ci doit tourner en boucle et s'arreter au bon instant, ce
## qui demande un lecteur a soi. C'est la meme forme que systemes/
## filtre_ecran.gd pour la respiration du masque, et pour la meme raison.
const ESSAI := "res://assets/sons/vehicule/rv_demarreur.wav"

var _essai: AudioStreamPlayer


func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio


# ON LE FABRIQUE A LA PREMIERE MISE DE CONTACT et on le garde. Le charger dans
# _ready() ferait porter le cout a toutes les parties, y compris celles ou l'on
# ne monte jamais dans le camping-car.
func _essayer(en_marche: bool) -> void:
	if _essai == null:
		if not en_marche:
			return
		var flux := load(ESSAI) as AudioStream
		if flux == null:
			return
		# Sans marquage, un WAV se rejoue depuis le debut a chaque fin et le
		# raccord s'entend — sur un son qui tourne pendant qu'on vise, c'est le
		# rythme meme du mini-jeu qui se met a claquer.
		if flux is AudioStreamWAV:
			(flux as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		_essai = AudioStreamPlayer.new()
		_essai.name = "EssaiDemarrage"
		_essai.stream = flux
		_essai.bus = Audio.BUS_INTERFACE
		add_child(_essai)
	if en_marche:
		if not _essai.playing:
			_essai.play()
	else:
		_essai.stop()


func _sur_poste(_point: Variant) -> void:
	armer()


## Rend le demarreur disponible : a partir de la, tenir la touche ouvre le
## cadran. Publique pour le menu de test et les captures.
func armer() -> void:
	if _hote == null:
		return
	if _cadran == null:
		_cadran = Control.new()
		_cadran.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_cadran.set_anchors_preset(Control.PRESET_FULL_RECT)
		_cadran.draw.connect(_dessiner)
		_hote.add_child(_cadran)
	_cadran.visible = false
	_arme = true
	set_process(true)


var _arme := false


## Le demarreur attend-il qu'on tienne la touche ?
func arme() -> bool:
	return _arme


## Le cadran est-il ouvert ? Pour les verifications, qui ne peuvent pas
## regarder l'ecran.
func ouvert() -> bool:
	return _contact


## Combien de zones ont ete validees d'affilee.
func zone() -> int:
	return _zone


func _process(delta: float) -> void:
	if _fin > 0.0:
		_fin -= delta
		if _fin <= 0.0:
			_cadran.visible = false
			if not _echoue:
				_arme = false
				set_process(false)
				reussi.emit()
		_cadran.queue_redraw()
		return

	if not _arme:
		return

	# LE CONTACT : on tient, le cadran s'ouvre. On lache, il se ferme et tout
	# recommence a zero. Rien ne se perd — on n'a rien casse, on a juste
	# retire la main de la cle.
	var tenu := Input.is_action_pressed("interagir")
	if tenu and not _contact:
		_ouvrir()
	elif not tenu and _contact:
		_fermer()
	if not _contact:
		return

	_angle = wrapf(_angle + _sens * VITESSE * TAU * delta, 0.0, TAU)

	# LE GESTE. La touche est celle qui va a GAUCHE : c'est celle que
	# Guillaume nomme — « appuyer sur A » — et la lire dans l'InputMap fait
	# qu'un joueur qui l'a remappee garde la sienne.
	if Input.is_action_just_pressed("gauche"):
		_tenter()

	_cadran.queue_redraw()


func _ouvrir() -> void:
	_contact = true
	_zone = 0
	_sens = 1.0
	_angle = 0.0
	_nouvelle_cible()
	_cadran.visible = true
	if _son() != null:
		# LE COUP DE CLE, puis le demarreur qui patine dessous. Deux sons parce
		# que ce sont deux gestes : on met le contact, et ENSUITE ca peine.
		_son().bruit("contact_rv")
	_essayer(true)


func _fermer() -> void:
	_contact = false
	_cadran.visible = false
	_essayer(false)


# LA ZONE EST TIREE AU SORT, ET JAMAIS SOUS L'AIGUILLE.
#
# Une zone posee la ou l'aiguille se trouve deja se valide sans rien viser :
# le premier appui tomberait juste une fois sur trois, et le joueur ne saurait
# pas pourquoi. On la place donc a bonne distance de la position courante.
func _nouvelle_cible() -> void:
	var ecart := _rng.randf_range(PI * 0.45, PI * 1.55)
	_cible = wrapf(_angle + ecart * _sens, 0.0, TAU)


func _tenter() -> void:
	var demi := LARGEUR_ZONE[mini(_zone, LARGEUR_ZONE.size() - 1)] * TAU * 0.5
	var ecart := absf(wrapf(_angle - _cible, -PI, PI))
	if ecart > demi:
		_echec()
		return

	_zone += 1
	if _son() != null:
		_son().bruit("roue_cran")
	if _zone >= ZONES:
		_reussite()
		return
	# UNE ZONE VALIDEE INVERSE LE SENS, comme demande. C'est ce qui empeche
	# d'apprendre le rythme : on ne peut pas anticiper une aiguille dont on ne
	# sait pas de quel cote elle repartira.
	_sens = -_sens
	_nouvelle_cible()


func _echec() -> void:
	_echoue = true
	_fin = 0.8
	_zone = 0
	_essayer(false)
	if _son() != null:
		# IL A SON BRUITAGE, DEPUIS LE 26/08/2026. Cette ligne rejouait le son
		# de demarrage RALENTI a 0,62 — « ca s'entend comme un moteur qui se
		# noie » — faute de mieux, et le commentaire disait : « la banque n'a
		# pas de bruitage propre, Guillaume propose d'en fournir ». Il l'a
		# fourni : « Rv demarrage fail ». On joue donc le vrai son, a sa
		# hauteur, et le bricolage disparait.
		_son().bruit("demarreur_rate")
	rate.emit(_zone)


func _reussite() -> void:
	_echoue = false
	_fin = 0.55
	# ON SE TAIT ICI, ET C'EST VOULU. Le demarreur cesse de patiner, et c'est le
	# MOTEUR qui prend la parole : moteur_audio joue « start RV success » sur le
	# vehicule, en son positionne. Jouer un troisieme son par-dessus, sur le bus
	# de l'interface, ferait deux demarrages superposes au moment precis ou l'on
	# veut entendre la caisse repartir.
	_essayer(false)


# ------------------------------------------------------------------- dessin


func _dessiner() -> void:
	if _cadran == null or not _cadran.visible:
		return
	var centre := Vector2(_cadran.size.x * 0.5, _cadran.size.y * 0.62)

	# L'ANNEAU, epais, comme demande. Trente-deux segments : a ce rayon, on ne
	# distingue pas un cercle parfait d'un polygone, et draw_arc coute trois
	# fois plus cher pour le meme resultat.
	_anneau(centre, RAYON, EPAISSEUR, Color(0.14, 0.15, 0.17, 0.92))
	_anneau(centre, RAYON, EPAISSEUR - 4.0, Color(0.28, 0.29, 0.31, 0.6))

	# La zone a viser, dans le jaune de la charte. Elle retrecit a chaque
	# passage, et c'est visible : c'est la seule facon de dire « ca devient
	# difficile » sans l'ecrire.
	var demi := LARGEUR_ZONE[mini(_zone, LARGEUR_ZONE.size() - 1)] * TAU * 0.5
	_arc(centre, RAYON, EPAISSEUR, _cible - demi, _cible + demi,
			Color(0.96, 0.77, 0.19, 0.95 if _fin <= 0.0 else 0.4))

	# L'aiguille. Rouge quand on vient de rater, claire sinon.
	var teinte := Color(0.949, 0.925, 0.867)
	if _fin > 0.0:
		teinte = Color(0.78, 0.22, 0.18) if _echoue else Color(0.60, 0.82, 0.44)
	var bout := centre + Vector2(sin(_angle), -cos(_angle)) * (RAYON + 4.0)
	_cadran.draw_line(centre + Vector2(sin(_angle), -cos(_angle)) * 12.0,
			bout, teinte, 2.0)
	_cadran.draw_circle(centre, 3.0, teinte)

	# LES TROIS TEMOINS, sous le cadran : combien de zones sont acquises. Le
	# joueur doit savoir ou il en est sans compter dans sa tete.
	for i in ZONES:
		var p := centre + Vector2((float(i) - 1.0) * 12.0, RAYON + 16.0)
		var pris := i < _zone
		_cadran.draw_rect(Rect2(p - Vector2(4.0, 3.0), Vector2(8.0, 6.0)),
				Color(0.96, 0.77, 0.19) if pris else Color(0.30, 0.30, 0.32))

	# La consigne, une seule fois et en petit. Les deux touches y sont nommees
	# telles qu'elles sont reglees.
	var police := _cadran.get_theme_default_font()
	if police == null:
		return
	var aide := "%s   contact        %s   allumage" % [
			Touches.nom("interagir"), Touches.nom("gauche")]
	var largeur := police.get_string_size(aide, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 10).x
	police.draw_string(_cadran.get_canvas_item(),
			Vector2(centre.x - largeur * 0.5, centre.y + RAYON + 34.0), aide,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.72, 0.70, 0.64))


func _anneau(centre: Vector2, rayon: float, epaisseur: float,
		couleur: Color) -> void:
	_arc(centre, rayon, epaisseur, 0.0, TAU, couleur)


# Un arc epais, dessine en segments. On part du HAUT et on tourne dans le sens
# des aiguilles — c'est le sens d'un cadran, et l'aiguille suit la meme
# convention (sin, -cos).
func _arc(centre: Vector2, rayon: float, epaisseur: float, debut: float,
		fin: float, couleur: Color) -> void:
	var pas := 0.09
	var a := debut
	while a < fin:
		var b := minf(a + pas, fin)
		var p1 := centre + Vector2(sin(a), -cos(a)) * rayon
		var p2 := centre + Vector2(sin(b), -cos(b)) * rayon
		_cadran.draw_line(p1, p2, couleur, epaisseur)
		a = b


## Remet tout a zero. Recommencer une partie doit redonner un moteur a
## demarrer, pas un moteur deja lance.
func reinitialiser() -> void:
	_arme = false
	_contact = false
	_zone = 0
	_fin = 0.0
	_echoue = false
	if _cadran != null:
		_cadran.visible = false
	set_process(false)


# Le Control qui porte l'interface du jeu, retrouve par son nom. C'est le meme
# que celui de la cuisson et du telephone : « Echelle », sous Interface.
func _chercher_l_interface(n: Node) -> Control:
	if n.name == "Echelle" and n is Control:
		return n as Control
	for e in n.get_children():
		var t := _chercher_l_interface(e)
		if t != null:
			return t
	return null
