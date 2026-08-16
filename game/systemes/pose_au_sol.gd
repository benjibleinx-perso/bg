# Pose ce noeud SUR LE SOL, quel que soit le relief sous lui.
#
# POURQUOI CE SCRIPT EXISTE.
#
# Le site du crash est ancre sur le « fosse », dont la position publiee est son
# FOND. Tout ce qu'on y pose a hauteur zero se retrouve donc au niveau du point
# le plus bas de la cuvette — et la cuvette fait quinze metres de rayon pour
# 2,30 m de creux. A cinq metres du centre, le sable est deja soixante-dix
# centimetres plus haut : Jesse y avait les genoux dans le sol.
#
# C'est le meme mal que les coordonnees recopiees a la main, en plus discret : la
# position horizontale est juste, seule la verticale ment, et une silhouette a
# moitie enterree se remarque moins qu'un personnage a vingt-neuf metres.
#
# ON DEMANDE AU SOL PLUTOT QUE DE LE DEVINER. Un rayon part d'au-dessus, tombe,
# et le noeud se pose la ou il touche. Ca vaut pour le fosse, pour une dune, et
# pour le terrain du jour ou il sera regenere autrement.
class_name PoseAuSol
extends Node3D

## De combien on cherche, au-dessus et en dessous. Huit metres couvrent le creux
## du fosse et la hauteur d'un camping-car couche.
@export var portee: float = 8.0

## Ce qu'on ajoute apres avoir trouve le sol. Zero pose dessus ; un objet qui
## doit AFFLEURER — une verrerie a moitie enfouie — se descend d'ici.
@export var decalage: float = 0.0


func _ready() -> void:
	# Deux images : le terrain du desert est instancie dans le _ready de
	# desert.gd, et ses collisions sont ajoutees juste apres. Un rayon lance
	# trop tot ne touche rien et le noeud reste ou il etait, ce qui est
	# exactement la panne qu'on repare.
	await get_tree().process_frame
	await get_tree().process_frame
	var espace := get_world_3d().direct_space_state
	var p := PhysicsRayQueryParameters3D.create(
			global_position + Vector3.UP * portee,
			global_position + Vector3.DOWN * portee)
	var touche := espace.intersect_ray(p)
	if touche.is_empty():
		push_warning("pose_au_sol : rien sous '%s', il reste ou il etait" % name)
		return
	global_position = (touche["position"] as Vector3) + Vector3.UP * decalage
