# A quelle hauteur Walter est-il pose, ANIMATION PAR ANIMATION ?
#
#     godot --headless --path game --script res://verifs/diag_pieds.gd
#
# POURQUOI CE DIAGNOSTIC EXISTE. « Walter a les pieds dans le sol, il faudrait
# le surelever legerement » — Guillaume, 27/08/2026. Un enfoncement ne se juge
# pas sur une capture : le pied est petit, l'ombre est sombre, et on conclut ce
# qu'on veut. Trois fois de suite le projet a tranche « la voiture est dans le
# bon sens » sur une image ambigue ; elle etait a l'envers.
#
# ET IL MESURE TOUS LES CLIPS, PAS SEULEMENT CELUI QUI TOURNE. C'est la
# question qui decide de la reparation : un enfoncement IDENTIQUE partout est
# un decalage du corps, qui se corrige une fois dans joueur.tscn ; un
# enfoncement qui varie appartient a l'animation, et remonter le corps ferait
# alors flotter le personnage dans tous les autres clips.
#
# CE QU'IL MESURE, ET DANS QUEL ORDRE.
#
#   le SOL sous le joueur, par un rayon qui part d'au-dessus de lui ;
#   l'ORIGINE du corps, qui devrait tomber dessus — c'est le bas de la capsule ;
#   les CHEVILLES, sur les os et pas sur la boite englobante : celle-ci decrit
#     le maillage AVANT deformation par l'armature, et elle a deja menti de
#     quatre-vingt-quinze centimetres dans ce projet.
#
# L'ENFONCEMENT EST UN ECART, PAS UNE ALTITUDE. Le modele sort de la chaine
# d'integration pose au sol : dans le fichier, la plante du pied est a zero,
# donc la hauteur de la cheville AU REPOS est celle qu'elle devrait avoir
# au-dessus du sol en jeu. Ce qui manque a cet ecart, c'est ce qui est enterre.
extends SceneTree

const POSE := 30
const IMAGES_PAR_CLIP := 12

var _n := 0
var _monde: Node
var _joueur: Node3D
var _skel: Skeleton3D
var _anim: AnimationPlayer
var _clips: Array[String] = []
var _clip := 0
var _resume: Array[String] = []


func _initialize() -> void:
	_monde = (load("res://scenes/monde.tscn") as PackedScene).instantiate()
	root.add_child(_monde)


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false
	if _n == POSE:
		return _preparer()

	# Un clip toutes les IMAGES_PAR_CLIP images : le temps que le melange
	# d'animation s'installe. Mesurer a la premiere image donnerait la pose
	# precedente, en train de se resorber.
	var avance := _n - POSE
	if avance % IMAGES_PAR_CLIP != 0:
		return false

	var i := avance / IMAGES_PAR_CLIP - 1
	if i >= 0 and i < _clips.size():
		_mesurer(_clips[i])
	var suivant := i + 1
	if suivant >= _clips.size():
		_conclure()
		return true
	_anim.play(_clips[suivant])
	_anim.advance(0.3)
	return false


func _preparer() -> bool:
	_joueur = _monde.find_child("Joueur", true, false) as Node3D
	if _joueur == null:
		printerr("diag_pieds : joueur introuvable")
		quit(1)
		return true
	_skel = _squelette(_joueur)
	_anim = _trouver_anim(_joueur)
	if _skel == null or _anim == null:
		printerr("diag_pieds : squelette ou animations introuvables")
		quit(1)
		return true
	for c in _anim.get_animation_list():
		_clips.append(str(c))
	printerr("")
	printerr("--- ou Walter pose les pieds ---")
	printerr("  sol %.3f m, origine du corps %.3f m (ecart %+.3f)"
			% [_sol(), _joueur.global_position.y, _joueur.global_position.y - _sol()])
	printerr("")
	printerr("  %-22s %9s %9s   %s" % ["clip", "gauche", "droite", "bassin"])
	_anim.play(_clips[0])
	_anim.advance(0.3)
	return false


func _sol() -> float:
	var espace := _joueur.get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(
			_joueur.global_position + Vector3(0.0, 2.0, 0.0),
			_joueur.global_position - Vector3(0.0, 3.0, 0.0))
	params.exclude = [(_joueur as CollisionObject3D).get_rid()]
	var touche := espace.intersect_ray(params)
	return float(touche["position"].y) if touche.has("position") else NAN


## L'enfoncement d'une cheville : ce qui lui manque pour etre a la hauteur que
## le fichier lui donne quand le modele est pose au sol. Negatif = enterre.
func _enfoncement(nom: String, sol: float) -> float:
	var i := _skel.find_bone(nom)
	if i < 0:
		return NAN
	# LES OS SE MESURENT DANS LE REPERE DU MONDE : get_bone_global_pose() rend
	# des unites de squelette, et les lire telles quelles a deja annonce
	# 672 mm pour 16 mm reels dans ce projet.
	var p: Vector3 = _skel.global_transform * _skel.get_bone_global_pose(i).origin
	var repos: Vector3 = _skel.global_transform.basis \
			* _skel.get_bone_global_rest(i).origin
	return (p.y - sol) - repos.y


func _mesurer(clip: String) -> void:
	var sol := _sol()
	var g := _enfoncement("LeftFoot", sol)
	var d := _enfoncement("RightFoot", sol)
	var bassin := _enfoncement("Hips", sol)
	printerr("  %-22s %+8.3f %+8.3f   bassin %+8.3f" % [clip, g, d, bassin])
	_resume.append("%s %+.3f" % [clip, minf(g, d)])


func _conclure() -> void:
	printerr("")
	printerr("  Un chiffre proche de zero = le pied touche le sol.")
	printerr("  Negatif = enterre de cette hauteur, en metres.")
	printerr("")
	quit()


func _squelette(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n as Skeleton3D
	for e in n.get_children():
		var t := _squelette(e)
		if t != null:
			return t
	return null


func _trouver_anim(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n as AnimationPlayer
	for e in n.get_children():
		var t := _trouver_anim(e)
		if t != null:
			return t
	return null
