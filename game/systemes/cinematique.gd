# L'ouverture, au demarrage d'une nouvelle partie.
#
# CE QU'ELLE FAIT ET CE QU'ELLE NE FAIT PAS.
#
# Elle joue une liste de plans fixes pris DANS LE MONDE deja charge — pas une
# video, pas une scene a part. Trois raisons, et la troisieme est la vraie :
#
#   1. Une video pese, se reencode a chaque changement de decor, et jure avec
#      un rendu a 960x720 qu'elle ne partage pas.
#   2. Une scene separee obligerait a charger le monde deux fois.
#   3. Ce qu'on montre est le VRAI jeu. Une ouverture qui promet autre chose
#      que ce qui suit est un mensonge qu'on paie a la premiere image jouable.
#
# ELLE NE SE JOUE QU'UNE FOIS. « Nouvelle partie » efface la sauvegarde avant
# de charger le monde ; il suffit donc de regarder si quelque chose a ete
# repris. Rien a transmettre entre les deux scenes, rien a stocker.
extends Node

@export var reglages: Reglages
@export var sauvegarde: NodePath
@export var controleur: NodePath
@export var interface: NodePath

## LE SUBVIEWPORT OU LE 3D EST RENDU, et il faut le nommer explicitement.
##
## Piege paye : ce noeud vit sous Monde, pas sous Rendu. get_viewport() y rend
## donc la FENETRE, pas le SubViewport — sa camera 3D est nulle, la camera de
## l'ouverture etait creee a cote de la scene et make_current() la rendait
## active pour un viewport que personne ne regarde.
##
## Le symptome : l'ouverture se deroulait normalement — cartons, fondu, plans
## qui defilent — sur un plan fixe de Walter vu de dos. Tout marchait sauf ce
## qu'on voyait.
@export var rendu: NodePath

const FICHIER := "res://donnees/cinematique.json"

## Emis quand elle se termine, passee ou jouee jusqu'au bout.
signal finie

## EST-CE QU'ELLE TOURNE EN CE MOMENT ? UN ETAT, PAS SEULEMENT UN SIGNAL.
##
## Le signal `finie` reste le chemin normal — c'est lui qui enchaine sur la
## suite — mais il ne rattrape pas ce qui s'est passe avant qu'on l'ecoute, et
## un appelant qui arrive en retard ne peut rien constater. C'est la parade
## deja ecrite pour le guidage et pour « volant » : un etat se demande a
## n'importe quel moment (piege 60).
func active() -> bool:
	return is_processing()

var _plans: Array = []
var _musique_chemin: String = ""
var _i: int = -1
var _reste: float = 0.0
var _joue: bool = false

var _camera: Camera3D
var _avant: Camera3D
var _voile: ColorRect
var _texte: Label
var _lecteur: AudioStreamPlayer
var _fondu: float = 1.0
var _sens: float = -1.0

## L'heure du monde avant l'ouverture, rendue a la fin. Voir _demarrer().
var _heure_avant: float = -1.0


func _ready() -> void:
	set_process(false)
	# On attend une image : la sauvegarde se reprend sur un appel differe, et
	# l'interroger tout de suite dirait toujours « rien de repris ».
	call_deferred("_decider")


func _decider() -> void:
	await get_tree().process_frame
	# ELLE NE DEMARRE PAS TOUTE SEULE SOUS UN OUTIL.
	#
	# Les suites de test chargent le monde et verifient l'etat qui suit.
	# L'ouverture y tournait : elle pose l'heure de ses plans — six heures du
	# matin pour le desert — et la suite `jour` l'a dit tout de suite, « la
	# mission impose 09.00 h, le monde est a 06.21 h ».
	#
	# On regarde --script et pas le mode headless : bg.ps1 lance les suites AVEC
	# une fenetre, sur l'ecran choisi, pour que Godot rende vraiment. Le premier
	# essai coupait sur headless et ne changeait donc rien.
	#
	# `jouer()` reste public : la situation de capture `cinematique` la force,
	# et c'est le seul endroit qui doit encore la voir.
	if "--script" in OS.get_cmdline_args():
		finie.emit()
		return
	var s := get_node_or_null(sauvegarde)
	if s != null and s.has_method("existe") and s.call("existe"):
		# Une partie en cours : on ne rejoue pas l'ouverture.
		finie.emit()
		return
	if not _charger():
		finie.emit()
		return
	_demarrer()


## La joue de force, quelle que soit la sauvegarde. POUR LES OUTILS.
##
## Une situation de capture reprend toujours une partie — c'est ce que fait
## monde.tscn au chargement — donc l'ouverture n'y demarre jamais et aucune
## image ne peut la montrer. Meme porte que Mission.aller_a(), pour la meme
## raison : ce qui se mesure et ce qui se joue ont besoin d'entrees separees.
##
## L'argument saute directement a un plan, pour capturer le troisieme sans
## attendre les douze secondes des deux premiers.
func jouer(depuis: int = 0) -> void:
	if _joue:
		return
	if not _charger():
		return
	_demarrer()
	if depuis > 0:
		_i = depuis - 1
		_suivant()


## JOUER UNE AUTRE CINEMATIQUE QUE L'OUVERTURE, nommee par son fichier.
##
## Une mission en a desormais DEUX : celle qui l'ouvre, declaree dans son JSON,
## et celle de la fuite du fosse — le battement A9, que le franchissement de la
## crete declenche. Le systeme ne savait jouer que la premiere, parce qu'il n'y
## en avait jamais eu d'autre.
##
## Renvoie faux si le fichier est introuvable ou vide : l'appelant enchaine
## alors sans elle plutot que de rester bloque sur un fondu qui n'arrive pas.
func jouer_fichier(chemin: String) -> bool:
	if _joue:
		return false
	_impose = chemin
	var ok := _charger()
	_impose = ""
	if not ok:
		return false
	_demarrer()
	return true


## Le fichier demande par jouer_fichier(), le temps du chargement. Vide le reste
## du temps : c'est un argument qui traverse deux appels, pas un etat.
var _impose: String = ""


## CHAQUE MISSION PEUT AVOIR SON OUVERTURE.
##
## Le fichier etait une constante, ecrite quand il n'existait qu'une mission :
## six plans qui traversent le desert, la ville, la rue, et rendent la main
## « devant chez lui, la ou la partie commence ». Depuis que « Deux corps » est
## branchee, la partie commence dans un camping-car retourne au fond d'un fosse,
## et le dernier plan MENT — sans que rien ne le signale, puisque le fichier est
## parfaitement valide.
##
## C'est le meme motif que le piege 39 sous un autre jour : pas un nom d'etape
## partage, mais un FICHIER unique la ou il en faut un par mission. La mission
## nomme donc le sien ; celles qui n'en nomment pas gardent l'ouverture du jeu.
func _fichier() -> String:
	if _impose != "":
		return _impose
	var m := Mission.courante(self)
	if m != null:
		var propre := str(m.donnees().get("cinematique", ""))
		if propre != "":
			return "res://donnees/" + propre
	return FICHIER


func _charger() -> bool:
	var fichier := _fichier()
	if not FileAccess.file_exists(fichier):
		push_warning("cinematique : %s introuvable" % fichier)
		return false
	var brut: Variant = JSON.parse_string(FileAccess.get_file_as_string(fichier))
	if typeof(brut) != TYPE_DICTIONARY:
		push_error("cinematique : %s illisible" % fichier)
		return false
	_plans = (brut as Dictionary).get("plans", [])
	_musique_chemin = str((brut as Dictionary).get("musique", ""))
	return not _plans.is_empty()


func _demarrer() -> void:
	var vp := get_node_or_null(rendu) as SubViewport
	if vp == null:
		push_error("cinematique : aucun SubViewport assigne, l'ouverture "
				+ "s'afficherait sur un plan fixe")
		finie.emit()
		return
	_avant = vp.get_camera_3d()

	# UNE CAMERA A ELLE, ET DANS LE BON VIEWPORT.
	#
	# La camera de poursuite reecrit sa position a chaque image : lui poser un
	# plan revient a le perdre a l'image suivante. capture.gd cree la sienne
	# pour la meme raison, et la met DANS le SubViewport — c'est ce detail-la
	# qui manquait ici.
	_camera = Camera3D.new()
	_camera.name = "CameraOuverture"
	_camera.fov = 62.0
	_camera.near = 0.1
	_camera.far = 900.0
	vp.add_child(_camera)
	_camera.make_current()

	# L'HEURE EST EMPRUNTEE, PAS PRISE.
	#
	# Les plans posent leur propre heure pour avoir leur lumiere — l'aube sur
	# le desert, le plein jour sur la rue. Mais la mission impose la sienne au
	# demarrage (neuf heures, dans mission1.json), et l'ouverture l'ecrasait :
	# la suite `jour` l'a dit tout de suite, « la mission impose 09.00 h, le
	# monde est a 06.21 h ».
	#
	# On la note ici et on la rend a la fin. Sauter l'ouverture ou la regarder
	# en entier laisse donc le monde exactement dans le meme etat — et c'est la
	# seule facon qu'une cinematique sautable ne change rien au jeu.
	_heure_avant = Reglages.heure
	_poser_le_voile()
	_bloquer_le_jeu(true)

	if _musique_chemin != "" and ResourceLoader.exists(_musique_chemin):
		_lecteur = AudioStreamPlayer.new()
		_lecteur.stream = load(_musique_chemin)
		_lecteur.bus = "Musique"
		add_child(_lecteur)
		_lecteur.play()

	_joue = true
	_i = -1
	_suivant()
	set_process(true)


# Le voile et le carton vivent dans l'interface du jeu, donc DANS le viewport :
# ils partagent le grain du rendu. Un texte net sur une image de 960 pixels se
# verrait comme une incrustation.
## La hauteur d'une bande noire, en fraction de l'ecran.
##
## 0,12 en haut et en bas ramene un 4:3 a peu pres au format large. Ce n'est pas
## qu'un habillage : les bandes disent « ce n'est pas encore a toi de jouer »
## avant le premier plan, et le joueur repose la manette tout seul. Elles
## partent au meme moment que la main lui revient.
const BANDE := 0.12


func _poser_les_bandes(hote: Control) -> void:
	for haut in [true, false]:
		var b := ColorRect.new()
		b.color = Color(0.0, 0.0, 0.0, 1.0)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.set_anchors_preset(Control.PRESET_FULL_RECT)
		if haut:
			b.anchor_bottom = BANDE
		else:
			b.anchor_top = 1.0 - BANDE
		hote.add_child(b)
		_bandes.append(b)


func _poser_le_voile() -> void:
	var hote := get_node_or_null(interface) as Control
	if hote == null:
		return
	_voile = ColorRect.new()
	_voile.color = Color(0.02, 0.02, 0.03, 1.0)
	_voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_voile.set_anchors_preset(Control.PRESET_FULL_RECT)
	hote.add_child(_voile)

	_texte = Label.new()
	_texte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_texte.add_theme_font_size_override("font_size", 17)
	_texte.add_theme_color_override("font_color", Color(0.949, 0.925, 0.867))
	_texte.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03))
	_texte.add_theme_constant_override("outline_size", 6)
	_texte.set_anchors_preset(Control.PRESET_FULL_RECT)
	_texte.offset_top = 250.0
	hote.add_child(_texte)

	# Les bandes APRES le carton : elles doivent passer par-dessus lui, sinon
	# un texte pose bas mordrait sur la bande du bas au lieu de tenir dedans.
	_poser_les_bandes(hote)

	# La voix sort sur le meme bus que les dialogues du jeu : c'est du
	# hors-champ, et ca la met sous le meme curseur de volume.
	_voix = AudioStreamPlayer.new()
	_voix.name = "VoixOuverture"
	_voix.bus = Dialogue.BUS_VOIX
	add_child(_voix)


## Ce qu'on garde a l'ecran pendant l'ouverture : le voile et le carton, et
## rien d'autre. Le reste est masque puis remis tel qu'on l'a trouve.
var _masques: Array[CanvasItem] = []

## Les deux bandes noires. Gardees pour pouvoir les retirer : une bande laissee
## en place mangerait un quart de l'ecran pour toute la partie.
var _bandes: Array[ColorRect] = []


func _bloquer_le_jeu(bloque: bool) -> void:
	var c := get_node_or_null(controleur)
	if c != null and c.has_method("set_process_unhandled_input"):
		c.set_process_unhandled_input(not bloque)
	if c != null:
		c.set_process(not bloque)
	# La souris reste visible : on ne la capture pas pour regarder un film.
	Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if bloque
			else Input.MOUSE_MODE_CAPTURED)

	# LE HUD N'A RIEN A FAIRE SUR UNE OUVERTURE.
	#
	# Vu a la premiere capture : l'argent, la famille, la reputation, la
	# minimap et l'objectif de mission s'affichaient par-dessus les cartons.
	# Trois ressources et un plan de ville pendant qu'on presente le
	# personnage, c'est le contraire de ce qu'une ouverture fait — elle
	# demande qu'on regarde une chose a la fois.
	#
	# On note ce qu'on masque plutot que de tout rallumer a la fin : un element
	# deja cache pour une autre raison — le cadre de dialogue, le menu pause —
	# ne doit pas reapparaitre parce que l'ouverture s'est terminee.
	var hote := get_node_or_null(interface) as Control
	if hote == null:
		return
	if bloque:
		_masques.clear()
		for e in hote.get_children():
			if e is CanvasItem and e != _voile and e != _texte \
					and (e as CanvasItem).visible:
				_masques.append(e as CanvasItem)
				(e as CanvasItem).visible = false
	else:
		for e in _masques:
			if is_instance_valid(e):
				e.visible = true
		_masques.clear()


## LE PLAN BOUGE, MAIS SES DEUX CADRES SONT ECRITS.
##
## Le fichier de donnees disait « pourquoi des plans fixes et pas des
## mouvements : une camera qui glisse demande un chemin, une vitesse, un
## lissage, et rate son cadre au premier changement de decor ». L'argument
## reste vrai — c'est pourquoi on ne donne PAS de chemin.
##
## Un plan qui bouge declare simplement son cadre d'ARRIVEE, 'camera_fin' et
## 'vise_fin'. Les deux bouts sont donc poses a la main et verifiables a la
## capture, exactement comme un plan fixe ; entre les deux on interpole, et il
## n'y a rien qui puisse deriver. Un plan sans 'camera_fin' ne bouge pas : les
## anciens plans continuent de se jouer tels quels.
var _ou := Vector3.ZERO
var _vers_ou := Vector3.ZERO
var _quoi := Vector3.ZERO
var _vers_quoi := Vector3.ZERO
var _bouge := false
var _duree := 3.0

## Ce qui se dit par-dessus le plan. Les voix du jeu existent deja, rangees
## sous assets/voix/ : un plan nomme un personnage et une phrase, et on joue
## le fichier que le dialogue jouerait. Rien a doubler en plus.
var _voix: AudioStreamPlayer


## Joue la voix d'un plan, s'il en declare une.
##
## 'qui' et 'dit' sont ceux d'une replique de dialogues.json, mot pour mot :
## c'est la meme empreinte, donc le meme fichier. Ecrire une phrase qui n'y est
## pas ne produit rien, et le dit — plutot que de laisser un plan muet dont on
## se demandera trois semaines plus tard s'il l'etait volontairement.
func _dire(p: Dictionary) -> void:
	if _voix == null:
		return
	_voix.stop()
	var qui := str(p.get("qui", ""))
	var dit := str(p.get("dit", ""))
	if qui == "" or dit == "":
		return
	# ON PASSE PAR LA FONCTION DU JEU, on ne recopie pas sa regle.
	#
	# Une replique dirigee porte son intention dans son empreinte : le fichier
	# de « It has to work. » s'appelle d'apres « [tense] It has to work. ». Un
	# calcul refait ici aurait cherche l'autre nom et le plan serait reste
	# muet — sans erreur, comme toujours avec les voix.
	var dise: Dictionary = {"vo": dit, "jeu": str(p.get("jeu", ""))}
	var chemin := Dialogue.VOIX % [Dialogue._simplifier(qui),
			Dialogue._prononce(dise).md5_text().substr(0, 10)]
	if not ResourceLoader.exists(chemin):
		push_warning("cinematique : aucune voix pour %s « %s »" % [qui, dit])
		return
	_voix.stream = ResourceLoader.load(chemin) as AudioStream
	_voix.play()


func _vec(a: Variant) -> Vector3:
	var t: Array = a
	return Vector3(float(t[0]), float(t[1]), float(t[2]))


# UN POINT DU PLAN : UN NOM DE NOEUD, OU TROIS NOMBRES.
#
# L'ouverture ecrit ses coordonnees en dur, et c'est legitime : un plan de
# camera au-dessus d'une ville n'a pas d'autre facon d'exister.
#
# LA FUITE, ELLE, SE JOUE DANS UN DECOR GENERE. Le fosse est publie par
# gen_desert.py, la piste serpente, et la sortie s'ancre dessus : trois nombres
# recopies ici seraient justes tant que la graine ne bouge pas, et personne ne
# saurait le jour ou elle bougera. C'est le meme mal que les coordonnees du
# semis de debris, celles du camping-car, et celles de la sortie du camping-car
# — trois fois payees, trois fois par le meme remede.
#
# On accepte donc « camera »: "PompiersDepart" a la place de « camera »: [x,y,z].
# Le nom est cherche a l'instant du plan, et il DOIT ETRE UNIQUE dans le jeu.
func _point(p: Dictionary, cle: String, defaut: Vector3) -> Vector3:
	if not p.has(cle):
		return defaut
	var brut: Variant = p[cle]
	if typeof(brut) == TYPE_STRING:
		var racine: Node = get_tree().current_scene
		if racine == null:
			racine = get_tree().root
		var n := racine.find_child(str(brut), true, false) as Node3D
		if n == null:
			push_warning("cinematique : « %s » introuvable" % brut)
			return defaut
		return n.global_position
	return _vec(brut)


# `avance` va de 0 a 1 sur la duree du plan. La courbe est adoucie aux deux
# bouts : un travelling qui demarre et s'arrete net se lit comme un defaut,
# alors qu'une camera d'epaule part et s'arrete toujours mollement.
func _cadrer(avance: float) -> void:
	var t := smoothstep(0.0, 1.0, clampf(avance, 0.0, 1.0))

	# CE QUI TRAVERSE LE PLAN AVANCE D'ABORD, et la camera le suit ensuite : un
	# plan peut viser le camion pendant qu'il roule, et l'ordre inverse le
	# cadrerait avec une image de retard.
	#
	# LE MOBILE, LUI, VA A VITESSE CONSTANTE — pas de smoothstep. La camera part
	# et s'arrete mollement parce qu'une epaule humaine le fait ; un camion qui
	# ralentit en passant devant nous puis repart aurait l'air de nous avoir vus.
	if _mobile != null and is_instance_valid(_mobile):
		_mobile.global_position = _mobile_de.lerp(_mobile_a,
				clampf(avance, 0.0, 1.0))

	if _camera == null:
		return
	_camera.global_position = _ou.lerp(_vers_ou, t)
	var cible := _quoi.lerp(_vers_quoi, t)
	if not _camera.global_position.is_equal_approx(cible):
		_camera.look_at(cible, Vector3.UP)


## Ce qui traverse le plan en cours, et ses deux bouts. Null la plupart du
## temps : un plan qui ne deplace rien est le cas general.
var _mobile: Node3D
var _mobile_de: Vector3 = Vector3.ZERO
var _mobile_a: Vector3 = Vector3.ZERO


func _suivant() -> void:
	_i += 1
	if _i >= _plans.size():
		_terminer()
		return
	var p: Dictionary = _plans[_i]
	_ou = _point(p, "camera", Vector3(0, 2, 0))
	_vers_ou = _point(p, "camera_fin", _ou)
	_quoi = _point(p, "vise", Vector3.ZERO)
	_vers_quoi = _point(p, "vise_fin", _quoi)
	# CE QUI BOUGE DANS LE PLAN, en plus de la camera.
	#
	# Jusqu'ici seule la camera se deplacait : six plans qui derivent au-dessus
	# d'une ville endormie, et rien dedans n'avait a bouger. Le battement A9
	# demande l'inverse — « un LONG PLAN ou on VOIT le camion de pompier rouler
	# sur la route, passer devant Walter et Jesse, et se diriger vers la zone ou
	# il y avait le feu ». Une camera fixe sur un camion immobile ne raconte
	# rien du tout.
	#
	# On deplace un NOEUD NOMME entre deux points, sur la duree du plan, avec la
	# meme courbe adoucie que la camera. C'est un travelling d'objet, pas une
	# simulation : le camion ne roule pas, il glisse — et a cette distance, sur
	# une route droite, personne ne fait la difference.
	_mobile = null
	if p.has("deplace"):
		var d: Dictionary = p["deplace"]
		var racine: Node = get_tree().current_scene
		if racine == null:
			racine = get_tree().root
		_mobile = racine.find_child(str(d.get("quoi", "")), true, false) as Node3D
		if _mobile != null:
			# « de » EST FACULTATIF : sans lui, on part d'ou la chose se trouve.
			#
			# C'est ce qu'il faut pour le camping-car : au moment ou la scene
			# commence, il est la ou le JOUEUR l'a laisse — on ne peut pas
			# l'ecrire dans un fichier. Le camion de pompiers, lui, part
			# toujours du meme bout de piste et le nomme.
			_mobile_de = _point(d, "de", _mobile.global_position)
			_mobile_a = _point(d, "a", _mobile.global_position)
			# IL REGARDE OU IL VA, et une seule fois : un vehicule qui pivote
			# pendant un travelling rectiligne se lit comme un objet qu'on
			# pousse a la main.
			var cap := _mobile_a - _mobile_de
			cap.y = 0.0
			if cap.length_squared() > 0.0001:
				_mobile.global_rotation = Vector3(
						0.0, atan2(-cap.x, -cap.z), 0.0)
			_mobile.visible = true

	_bouge = (_ou != _vers_ou) or (_quoi != _vers_quoi) or _mobile != null
	_cadrer(0.0)

	_dire(p)

	if p.has("heure"):
		var t := get_tree().get_first_node_in_group(Temps.GROUPE) as Temps
		if t != null:
			t.regler(float(p["heure"]))

	if _texte != null:
		_texte.text = str(p.get("carton", ""))

	# Le fondu : « ouvre » part du noir, « ferme » y retourne, et sans mention
	# on reste ou l'on est. Un fondu a chaque plan hacherait l'ouverture.
	var f := str(p.get("fondu", ""))
	if f == "ouvre":
		_fondu = 1.0
		_sens = -1.0
	elif f == "ferme":
		_sens = 1.0
	else:
		_sens = -1.0
	_duree = maxf(0.1, float(p.get("duree", 3.0)))
	_reste = _duree


func _process(delta: float) -> void:
	if not _joue:
		return
	# ELLE SE PASSE A LA PREMIERE TOUCHE. Une ouverture qu'on ne peut pas
	# sauter se deteste au deuxieme lancement, et on relance beaucoup un jeu
	# qu'on developpe.
	if Input.is_anything_pressed():
		_terminer()
		return

	_fondu = clampf(_fondu + _sens * delta * 1.6, 0.0, 1.0)
	if _voile != null:
		_voile.color.a = _fondu
	if _texte != null:
		_texte.modulate.a = 1.0 - _fondu

	# L'AVANCE DU PLAN, POUR LE MOUVEMENT. On la recalcule depuis la duree
	# plutot que de l'accumuler : une somme de delta derive, et sur un plan de
	# cinq secondes la camera arriverait a cote de son cadre de fin.
	if _bouge and _duree > 0.001:
		_cadrer(1.0 - (_reste / _duree))

	_reste -= delta
	if _reste <= 0.0:
		_suivant()


func _terminer() -> void:
	if not _joue:
		return
	_joue = false
	set_process(false)

	# LES BANDES PARTENT AVEC L'OUVERTURE. Une bande oubliee mangerait un quart
	# de l'ecran pour toute la partie, et se confondrait avec un reglage.
	# Elles glissent hors champ plutot que de disparaitre : c'est le moment ou
	# la main revient au joueur, et ca se sent mieux que ca ne se voit.
	for b in _bandes:
		if is_instance_valid(b):
			var g := create_tween()
			var haut := b.anchor_top < 0.5
			g.tween_property(b, "anchor_bottom" if haut else "anchor_top",
					0.0 if haut else 1.0, 0.7)
			g.tween_callback(b.queue_free)
	_bandes.clear()

	if _voix != null:
		_voix.stop()
		_voix.queue_free()
		_voix = null

	if _lecteur != null:
		# On coupe court plutot que de laisser le theme finir sur le jeu : la
		# musique d'ouverture appartient a l'ouverture.
		var f := create_tween()
		f.tween_property(_lecteur, "volume_db", -40.0, 1.2)
		f.tween_callback(_lecteur.queue_free)
	if _voile != null:
		var t := create_tween()
		t.tween_property(_voile, "color:a", 0.0, 0.8)
		t.tween_callback(_voile.queue_free)
	if _texte != null:
		_texte.queue_free()
	if _avant != null and is_instance_valid(_avant):
		_avant.make_current()
	if _camera != null:
		_camera.queue_free()
	# On rend l'heure empruntee. Sans ca, sauter l'ouverture laisse le monde a
	# l'aube du premier plan alors que la mission demarre a neuf heures.
	if _heure_avant >= 0.0:
		var t := get_tree().get_first_node_in_group(Temps.GROUPE) as Temps
		if t != null:
			t.regler(_heure_avant)
	_bloquer_le_jeu(false)
	finie.emit()
