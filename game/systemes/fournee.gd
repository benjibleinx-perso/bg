# LA FOURNEE : LE BON FLACON, AU BON MOMENT.
#
# Troisieme et dernier geste de cuisine, battement B6. Le script d'origine
# n'y demandait rien — « observation, pas d'input actif requis au-dela de
# regarder ». Guillaume autorise explicitement a en changer : « Tu as la
# possibilite de changer les etapes de cuisine en soi si tu penses a une idee
# plus visuelle et jouable », et il nomme les axes : « precision, choix/ordre
# des ingredients, de dose, ou de timing ».
#
# Verser tenait la precision, la plaque tenait la duree. Celui-ci tient
# l'ORDRE et le MOMENT, les deux axes qui restaient.
#
# LE GESTE, et il ne demande aucune touche nouvelle : c'est la recombinaison
# des deux precedents. On tient le plan de travail, la MOLETTE choisit le
# flacon — le geste de la plaque — et la touche qui va a gauche le verse — le
# geste du demarreur. Un joueur qui a fait les deux premiers sait deja jouer
# celui-la sans qu'on lui explique.
#
# CE QUE LE BALLON DEMANDE. Il ne se dit pas, il se voit : quand la reaction
# est prete a recevoir quelque chose, une aureole de la couleur du flacon
# attendu apparait autour de lui et PALIT. Ce qui palit est le temps qui
# reste, et c'est la seule horloge du mini-jeu.
#
# ET ON PEUT RATER SANS BLOQUER LA MISSION. C'est la difference avec les deux
# autres, et elle est voulue : rater ici ne recommence rien, ca fait un
# produit plus BRUN. Trois ajouts, trois chances, et la couleur du cristal
# qu'on emporte dit ce qu'on valait — exactement ce que la cuisson au curseur
# faisait deja, mais en se jouant.
class_name Fournee
extends Node

## Meme groupe que les deux autres gestes : le controleur n'a qu'un endroit
## ou regarder pour savoir qui tient la souris.
const GROUPE := Verseuse.GROUPE

## CE QUE CE GESTE VAUT POUR LA MISSION.
const EVENEMENT := "action:fournee"

## Emis a la fin, avec le nombre d'ajouts reussis sur trois.
signal finie(reussis: int)

## Emis a chaque ajout, juste ou non. Le scenario s'en sert pour faire parler
## Jesse, qui ne commente pas un bon geste comme un mauvais.
signal ajoute(juste: bool, raison: String)

@export var point: NodePath
@export var interface: NodePath
@export var reglages: Reglages

## LES TROIS FLACONS, dans les couleurs de la charte : rouge sourd (Jesse),
## bleu ardoise (Skyler), jaune securite (le business). Elles n'ont pas de
## sens narratif ici — ce sont trois teintes que la palette du jeu contient
## deja et qu'on ne confond pas, ce qui est la seule exigence.
const FLACONS: Array[Color] = [
	Color(0.70, 0.23, 0.18),
	Color(0.29, 0.44, 0.65),
	Color(0.96, 0.77, 0.19),
]

## COMBIEN D'AJOUTS, et combien de temps on a pour chacun.
##
## Trois, et la fenetre RETRECIT : la premiere se joue en regardant, la
## derniere demande de savoir ou est son flacon avant que l'aureole
## n'apparaisse. C'est la meme progression que les trois zones du demarreur,
## et pour la meme raison — la derniere doit donner le sentiment d'avoir
## reussi, pas d'avoir eu de la chance.
const AJOUTS := 3
const FENETRE: Array[float] = [3.4, 2.6, 1.9]

## Le calme entre deux demandes. Sans lui, les trois ajouts s'enchainent en
## une seule salve et le geste devient un test de reflexe.
const ENTRE_DEUX := 1.8

const LARGE := 250.0
const HAUTE := 130.0

var _hote: Control
var _panneau: Control
var _rng := RandomNumberGenerator.new()
var _audio: Audio

var _arme := false
var _tient := false

## Le flacon sous la main, de 0 a 2.
var _choisi := 0

## Le flacon reclame, ou -1 quand le ballon ne demande rien.
var _demande := -1

## Combien de temps il reste pour repondre, et combien on en avait.
var _reste := 0.0
var _fenetre := 0.0

## Le calme avant la prochaine demande.
var _attente := ENTRE_DEUX

var _rang := 0
var _reussis := 0

## Ce qui est arrive a chaque ajout : 1 juste, -1 rate, 0 pas encore joue.
var _verdicts: Array[int] = [0, 0, 0]

var _fin := 0.0


func _ready() -> void:
	add_to_group(GROUPE)
	_rng.randomize()
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


func capte_la_souris() -> bool:
	return _tient and _fin <= 0.0


## Un cran de molette : on passe au flacon suivant. La liste ne boucle PAS.
## Elle bouclait au premier essai, et on depassait son flacon sans s'en
## apercevoir — trois objets alignes sur une paillasse ne se referment pas
## sur eux-memes, et la main s'arrete au bout de la rangee.
func molette(sens: float) -> void:
	if not _tient or _fin > 0.0:
		return
	_choisi = clampi(_choisi + int(signf(sens)), 0, FLACONS.size() - 1)


func arme() -> bool:
	return _arme


func choisi() -> int:
	return _choisi


## Quel flacon le ballon reclame, ou -1 s'il ne reclame rien. Pour les
## verifications, qui ne voient pas l'aureole.
func demande() -> int:
	return _demande


func reussis() -> int:
	return _reussis


func _process(delta: float) -> void:
	if _fin > 0.0:
		_fin -= delta
		if _fin <= 0.0:
			_panneau.visible = false
			_tient = false
			_arme = false
			set_process(false)
			_terminer()
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

	# LA TOUCHE QUI VERSE est celle du demarreur — « gauche » — et elle se lit
	# dans l'InputMap : un joueur qui l'a remappee garde la sienne.
	if Input.is_action_just_pressed("gauche"):
		_verser()

	_avancer(delta)
	_panneau.queue_redraw()


func _prendre() -> void:
	_tient = true
	_panneau.visible = true
	if _son() != null:
		_son().bruit("labo_prendre")


# REPOSER MET LA REACTION EN PAUSE, contrairement a la plaque.
#
# Ce n'est pas une inconsequence : le ballon n'est plus sur le feu a ce
# battement, rien ne s'emballe tout seul. Et surtout, laisser courir les
# fenetres pendant que le joueur regarde ailleurs lui ferait rater les trois
# ajouts sans jamais comprendre pourquoi.
func _reposer() -> void:
	_tient = false
	_panneau.visible = false


func _avancer(delta: float) -> void:
	if _demande >= 0:
		_reste -= delta
		if _reste <= 0.0:
			_manque("trop_tard")
		return

	_attente -= delta
	if _attente <= 0.0:
		_reclamer()


func _reclamer() -> void:
	if _rang >= AJOUTS:
		return
	_demande = _rng.randi_range(0, FLACONS.size() - 1)
	_fenetre = FENETRE[mini(_rang, FENETRE.size() - 1)]
	if reglages != null:
		_fenetre *= reglages.cuisine_fournee_patience
	_reste = _fenetre


func _verser() -> void:
	if _demande < 0:
		# Verser quand rien n'est demande gache le flacon. Sans ce cas, la
		# strategie gagnante serait de marteler la touche sur les trois
		# flacons, et le mini-jeu n'aurait plus de moment.
		_manque("trop_tot")
		return
	if _choisi != _demande:
		_manque("mauvais")
		return
	_verdicts[_rang] = 1
	_reussis += 1
	if _son() != null:
		_son().bruit("labo_reaction")
	ajoute.emit(true, "")
	_suivant()


func _manque(raison: String) -> void:
	if _rang >= AJOUTS:
		return
	_verdicts[_rang] = -1
	if _son() != null:
		_son().bruit("labo_eclabousse")
	ajoute.emit(false, raison)
	_suivant()


func _suivant() -> void:
	_demande = -1
	_reste = 0.0
	_rang += 1
	_attente = ENTRE_DEUX
	if _rang >= AJOUTS:
		# Une seconde de lecture avant de rendre la main : couper a l'instant
		# du troisieme geste ne laisserait pas voir le dernier temoin.
		_fin = 1.2


# LA PURETE SE DECIDE ICI, et c'est ce que faisait la cuisson au curseur.
#
# Trois reussites donnent le haut de l'echelle, zero le plancher. On ressort
# toujours avec quelque chose, meme rate : c'est du brun, et le brun se vend
# mal. Rater ne bloque pas la mission, ca la paie moins — la regle est celle
# de cuisson.gd, et elle ne change pas parce que le geste a change.
func _terminer() -> void:
	# ATTENTION A L'UNITE : « poser » attend un palier de 1 a 5, pas un index
	# de 0 a 4. Elle le dit dans sa signature, et cuisson.gd s'y est trompe
	# depuis le premier jour — une cuisson parfaite y donnait « translucide »
	# et jamais « bleue ». Son test ne pouvait pas le voir : il recalculait le
	# nom au lieu de le RELIRE apres l'avoir pose.
	var haut := Purete.PALIERS.size()
	var palier := 1 + int(round(float(_reussis) / float(AJOUTS)
			* float(haut - 1)))
	var p := Purete.courante(self)
	if p != null:
		p.poser(clampi(palier, 1, haut))
	print("FOURNEE : %d/%d ajout(s) justes -> %s"
			% [_reussis, AJOUTS, p.nom() if p != null else "?"])
	finie.emit(_reussis)


func reinitialiser() -> void:
	_arme = false
	_tient = false
	_fin = 0.0
	_demande = -1
	_reste = 0.0
	_attente = ENTRE_DEUX
	_rang = 0
	_reussis = 0
	_choisi = 0
	_verdicts = [0, 0, 0]
	if _panneau != null:
		_panneau.visible = false
	set_process(false)


# ------------------------------------------------------------------- dessin


func _dessiner() -> void:
	if _panneau == null or not _panneau.visible:
		return
	var base := Vector2(_panneau.size.x * 0.09, _panneau.size.y * 0.80)

	_panneau.draw_rect(Rect2(base - Vector2(12.0, HAUTE + 10.0),
			Vector2(LARGE + 24.0, HAUTE + 44.0)),
			Color(0.03, 0.03, 0.04, 0.85))
	_panneau.draw_line(base, base + Vector2(LARGE, 0.0),
			Color(0.62, 0.60, 0.56), 2.0)

	_dessiner_ballon(base)
	_dessiner_flacons(base)
	_dessiner_temoins(base)
	_dessiner_consigne(base)


func _dessiner_ballon(base: Vector2) -> void:
	var centre := Vector2(base.x + LARGE * 0.5, base.y - 76.0)
	var r := 26.0

	# L'AUREOLE, ET CE QU'ELLE DIT. Sa couleur est le flacon reclame ; son
	# opacite est le temps qui reste. Elle ne compte pas a rebours, elle
	# s'eteint — un joueur voit qu'il doit se depecher sans lire un nombre.
	if _demande >= 0 and _fenetre > 0.0:
		var part := clampf(_reste / _fenetre, 0.0, 1.0)
		var teinte := FLACONS[_demande]
		for i in 3:
			var rayon := r + 6.0 + float(i) * 5.0
			_cercle(centre, rayon,
					Color(teinte.r, teinte.g, teinte.b, part * 0.55))

	_panneau.draw_circle(centre, r - 3.0, Color(0.66, 0.85, 0.91, 0.7))
	_cercle(centre, r, Color(0.72, 0.76, 0.78, 0.8))


func _dessiner_flacons(base: Vector2) -> void:
	var y := base.y - 20.0
	for i in FLACONS.size():
		var x := base.x + 52.0 + float(i) * 48.0
		var h := 22.0
		var l := 16.0
		# Le flacon lui-meme.
		_panneau.draw_rect(Rect2(x - l * 0.5, y - h, l, h),
				Color(FLACONS[i].r, FLACONS[i].g, FLACONS[i].b, 0.85))
		# CELUI QUE LA MAIN TIENT est encadre, pas colore autrement : changer
		# sa teinte le rendrait impossible a comparer avec l'aureole, ce qui
		# est exactement ce que le joueur a a faire.
		if i == _choisi:
			var cadre := Rect2(x - l * 0.5 - 3.0, y - h - 3.0, l + 6.0, h + 6.0)
			_panneau.draw_rect(cadre, Color(0.949, 0.925, 0.867, 0.95), false, 2.0)


# LES TROIS TEMOINS, comme sous le cadran du demarrage : ou l'on en est, et ce
# qu'on vaut. Plein clair pour un ajout juste, brun pour un rate — la meme
# couleur que le produit qu'il donnera.
func _dessiner_temoins(base: Vector2) -> void:
	for i in AJOUTS:
		var p := base + Vector2(LARGE - 40.0 + float(i) * 12.0, -HAUTE + 14.0)
		var teinte := Color(0.30, 0.30, 0.32)
		if _verdicts[i] > 0:
			teinte = Color(0.949, 0.925, 0.867)
		elif _verdicts[i] < 0:
			teinte = Color(0.44, 0.28, 0.15)
		_panneau.draw_rect(Rect2(p, Vector2(8.0, 8.0)), teinte)


func _dessiner_consigne(base: Vector2) -> void:
	var police := _panneau.get_theme_default_font()
	if police == null:
		return
	var texte := "%s   molette : le flacon        %s   verser" % [
			Touches.nom("interagir"), Touches.nom("gauche")]
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
