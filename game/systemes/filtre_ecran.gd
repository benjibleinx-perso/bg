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

## ET CE QU'ON ENTEND DANS SA PROPRE TETE.
##
## « On entend la voix de Jesse (faible et diffuse DANS UN ACOUPHENE) » — retour
## du 27/08/2026. L'acouphene n'est pas un effet sur la voix : c'est un son a
## part, un sifflement qui vit dans l'oreille de Walter et par-dessus lequel
## tout le reste doit passer. Le filtre POSE sur la voix — passe-bas et reverb,
## bus « Acouphene » — dit qu'elle vient de loin ; celui-ci dit POURQUOI.
##
## Il s'arrete avec le masque, comme la respiration : ces deux sons appartiennent
## au meme instant, et l'un qui survivrait a l'autre ferait croire a un bug.
const SIFFLEMENTS := {
	"masque_a_gaz": "res://assets/sons/mission/acouphene.ogg",
}

## Le volume de la respiration. Presente sans couvrir : la premiere replique de
## la mission se dit sous le masque, et elle doit rester comprehensible.
const VOLUME := -5.0

## CELUI DU SIFFLEMENT, NETTEMENT PLUS BAS. Un acouphene qu'on remarque est un
## bruit qui gene ; un acouphene qui marche est celui qu'on n'identifie qu'en
## s'en apercevant apres coup. A -18 dB il tient sous la respiration et sous la
## voix, et c'est le silence qu'il laisse en partant qu'on entend.
const VOLUME_SIFFLEMENT := -18.0

var _calque: ColorRect
var _pose: String = ""
var _fondu: Tween
var _souffle: AudioStreamPlayer
var _sifflement: AudioStreamPlayer


## DE COMBIEN LA ROTATION DE LA CAMERA TROUBLE L'IMAGE.
##
## Un tour de souris couvre le champ en un quart de seconde ; a 1.0 la trainee
## ferait la largeur de l'ecran et il ne resterait qu'une bouillie. A 0,55 on
## perd l'image quand on tourne vite et on la retrouve des qu'on s'arrete, ce
## qui est exactement ce que fait un obturateur lent.
const FORCE := 0.55

## LE PLAFOND, en UV. Sans lui, un demi-tour a la souris en une image donne une
## derive de plusieurs largeurs d'ecran : le shader echantillonne alors n'importe
## ou et l'image devient une trainee de pixels du bord.
const DERIVE_MAX := 0.05

## A QUELLE VITESSE LA TRAINEE RETOMBE. Une pose qui s'arreterait net avec le
## geste serait un flou de rotation, pas une remanence : c'est la retombee qui
## donne l'impression d'etre sonne.
const RETOMBEE := 9.0

## LE CHAMP HORIZONTAL DE LA CAMERA, en radians, pour convertir un angle en
## fraction d'ecran. Repris du reglage de la camera de poursuite ; une valeur
## approchee suffit — c'est un ressenti, pas une mesure optique.
const CHAMP := 1.22

var _cap_avant: float = 0.0
var _derive: Vector2 = Vector2.ZERO
var _cam: Node
var _force_capture: float = -1.0


func _process(delta: float) -> void:
	var voulu := _filtre_demande()
	if voulu != _pose:
		if voulu == "":
			_lever()
		else:
			_poser(voulu)
		_pose = voulu
	_suivre_le_mouvement(delta)


# CE QUE LE SHADER NE PEUT PAS SAVOIR : de combien l'image vient de bouger.
#
# Un shader d'ecran ne connait ni la camera ni l'image d'avant. On lui pousse
# donc la derive, calculee ici sur le CAP de la camera — la seule chose qui
# deplace vraiment l'image dans cette scene, ou l'on se traine a 1,15 m/s.
#
# ON LISSE VERS ZERO PLUTOT QUE DE POSER LA VALEUR BRUTE. Une derive posee telle
# quelle disparait a l'image ou la souris s'arrete, et le flou s'eteint comme un
# interrupteur. La retombee est ce qui fait la remanence.
func _suivre_le_mouvement(delta: float) -> void:
	if _calque == null:
		_cap_avant = _cap_courant()
		return
	var mat := _calque.material as ShaderMaterial
	if mat == null:
		return

	if _force_capture >= 0.0:
		mat.set_shader_parameter("derive", Vector2(_force_capture, 0.0))
		return

	var cap := _cap_courant()
	var vire := angle_difference(_cap_avant, cap)
	_cap_avant = cap

	# Le signe : la camera tourne a droite, l'image defile vers la gauche.
	var voulue := Vector2(clampf(vire / CHAMP * FORCE,
			-DERIVE_MAX, DERIVE_MAX), 0.0)
	# On PREND la pointe tout de suite et on la lache lentement : un flou qui
	# monterait progressivement arriverait apres le geste qui l'a cause.
	if absf(voulue.x) > absf(_derive.x):
		_derive = voulue
	else:
		_derive = _derive.lerp(voulue, clampf(delta * RETOMBEE, 0.0, 1.0))
	mat.set_shader_parameter("derive", _derive)


func _cap_courant() -> float:
	var cam := _camera()
	if cam != null and cam.has_method("cap"):
		return float(cam.call("cap"))
	return _cap_avant


# La camera de poursuite, cherchee par sa METHODE et gardee. Meme geste que dans
# systemes/guidage.gd, et pour la meme raison : elle n'est dans aucun groupe et
# son chemin depend de la scene.
func _camera() -> Node:
	if _cam == null:
		_cam = _chercher_camera(get_tree().root)
	return _cam


func _chercher_camera(n: Node) -> Node:
	if n is Camera3D and n.has_method("cap"):
		return n
	for e in n.get_children():
		var t := _chercher_camera(e)
		if t != null:
			return t
	return null


## FIGE LA DERIVE POUR UNE CAPTURE, et rien d'autre.
##
## Un flou de mouvement ne se photographie pas : l'outil de capture pose sa
## propre camera, qui ne tourne pas, donc la derive vaut zero et l'image montre
## le filtre d'avant. Passer -1 rend la main au mouvement reel.
func forcer_la_derive(valeur: float) -> void:
	_force_capture = valeur


## Ce que l'etape en cours reclame, ou rien. On passe par la mission plutot que
## par le controleur : c'est une propriete du SCENARIO, pas de l'affichage.
func _filtre_demande() -> String:
	# PAS DE FILTRE PENDANT UNE CINEMATIQUE.
	#
	# UN FILTRE EST UN ETAT DE JEU, PAS DE FILM : il decrit ce que le PERSONNAGE
	# a devant les yeux, et pendant une cinematique on ne regarde pas par ses
	# yeux, on regarde des plans.
	#
	# CE QUE CETTE LIGNE NE CORRIGE PAS, ET IL FAUT LE DIRE. Elle a ete ecrite
	# le 27/08/2026 en croyant tenir le defaut que Guillaume decrit — « la
	# cinematique, elle marche juste pas » — parce qu'une capture montrait
	# l'ouverture derriere la vignette verte du masque. C'etait faux deux fois :
	# la cinematique de cette capture ne s'etait pas lancee (l'instrument etait
	# mal regle, piege 18), et l'interface est DEJA masquee par
	# Cinematique._bloquer_le_jeu, calque du filtre compris. Debranchee, la
	# capture est identique au pixel pres.
	#
	# Elle reste parce qu'elle couvre le cas que le masquage ne couvre pas : un
	# calque CREE pendant la cinematique, donc ajoute apres le masquage. C'est
	# une precaution, pas une reparation, et confondre les deux est ce qui fait
	# croire qu'un defaut est regle.
	var cine := _cinematique()
	if cine != null and cine.has_method("active") and bool(cine.call("active")):
		return ""

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
	# PAS « FiltreEcran » : c'est le nom de CE NOEUD-CI, dans monde.tscn.
	#
	# Le systeme et le calque qu'il cree portaient le meme nom, et une recherche
	# par nom rend le premier trouve — donc toujours le systeme, qui ne
	# disparait jamais. Un controle ecrit pour verifier que le filtre se LEVE ne
	# pouvait pas passer : il trouvait le systeme et concluait que le calque
	# etait encore la.
	#
	# Meme piege que les deux « PorteCampingCar », a ceci pres que l'homonyme
	# est cree ici, par ce fichier. Voir le piege 54.
	_calque.name = "CalqueFiltre"
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
	# ELLE BOUCLE, ET ELLE NE LE FAISAIT PAS. Le clip dure quatorze secondes,
	# l'ouverture au masque en dure plus de soixante : la respiration s'arretait
	# donc au quart de la scene, sans que rien ne le signale — le lecteur avait
	# bien joue, et le silence qui suit ressemble a un son qu'on n'a pas fait.
	# Trouve le 27/08/2026 en branchant l'acouphene, qui a exactement le meme
	# defaut d'import (« loop=false ») pour la meme raison.
	if flux is AudioStreamOggVorbis:
		(flux as AudioStreamOggVorbis).loop = true
	if _souffle == null:
		_souffle = AudioStreamPlayer.new()
		_souffle.name = "RespirationMasque"
		_souffle.bus = Audio.BUS_AMBIANCE
		add_child(_souffle)
	_souffle.stream = flux
	_souffle.volume_db = VOLUME
	_souffle.play()
	_siffler(nom)


# L'ACOUPHENE, sur son propre lecteur.
#
# Pas sur celui de la respiration : les deux tournent EN MEME TEMPS, en boucle,
# et un seul lecteur ne joue qu'un flux — le second aurait simplement remplace
# le premier, sans erreur, et on aurait cherche pourquoi la respiration avait
# disparu le jour ou l'acouphene est arrive.
func _siffler(nom: String) -> void:
	var chemin := str(SIFFLEMENTS.get(nom, ""))
	if chemin == "":
		return
	var flux := load(chemin) as AudioStream
	if flux == null:
		return
	# EN BOUCLE, ET C'EST LE FLUX QUI LE PORTE. Un Ogg importe sans boucle
	# s'arrete au bout de quatorze secondes : l'acouphene s'eteindrait tout seul
	# au milieu de la scene, ce qui est exactement le contraire d'un acouphene.
	if flux is AudioStreamOggVorbis:
		(flux as AudioStreamOggVorbis).loop = true
	if _sifflement == null:
		_sifflement = AudioStreamPlayer.new()
		_sifflement.name = "Acouphene"
		_sifflement.bus = Audio.BUS_AMBIANCE
		add_child(_sifflement)
	_sifflement.stream = flux
	_sifflement.volume_db = VOLUME_SIFFLEMENT
	_sifflement.play()


func _taire() -> void:
	if _souffle != null:
		_souffle.stop()
	if _sifflement != null:
		_sifflement.stop()


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


# LA CINEMATIQUE, cherchee une fois et gardee.
#
# Par son NOM et non par un groupe : elle n'en a pas, et lui en donner un pour
# ce seul usage ajouterait un nom global au projet. Elle vit dans monde.tscn,
# a un endroit fixe — contrairement au decor du fosse, qui est instancie.
func _cinematique() -> Node:
	if _cine == null or not is_instance_valid(_cine):
		var racine: Node = get_tree().current_scene
		if racine == null:
			racine = get_tree().root
		_cine = racine.find_child("Cinematique", true, false)
	return _cine


var _cine: Node
