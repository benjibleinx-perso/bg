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

	# ON CHERCHE LE SOL, PAS LE PREMIER OBSTACLE RENCONTRE.
	#
	# Un rayon qui s'arrete au premier contact trouve ce qui est POSE sur le sol
	# aussi bien que le sol lui-meme. Le semis de debris en a fait les frais : il
	# est centre sur le camping-car, dont la coque est une caisse de trois metres
	# de haut. Le rayon la touchait, et le semis entier se posait sur le TOIT —
	# en jeu, un anneau d'eclats flottant a hauteur de tete, « les debris sont la
	# mais volent ».
	#
	# On traverse donc : a chaque contact on exclut le corps touche et on
	# recommence. Le dernier contact avant le vide est le sol, puisque rien n'est
	# enterre sous le terrain. C'est plus juste que n'importe quel filtre par
	# couche ou par nom — « le sol est ce qu'il y a de plus bas » ne se demode
	# pas, et ca marche aussi pour un objet pose sous un vehicule.
	var espace := get_world_3d().direct_space_state
	var haut := global_position + Vector3.UP * portee
	var bas := global_position + Vector3.DOWN * portee
	var ignores: Array[RID] = []
	var sol := Vector3.INF
	# Huit : la pile la plus profonde du jeu est terrain + vehicule + un objet.
	# Une boucle sans borne sur une geometrie inattendue bloquerait le chargement.
	for _essai in 8:
		var p := PhysicsRayQueryParameters3D.create(haut, bas)
		p.exclude = ignores
		var touche := espace.intersect_ray(p)
		if touche.is_empty():
			break
		sol = touche["position"]
		ignores.append(touche["rid"])

	if sol == Vector3.INF:
		push_warning("pose_au_sol : rien sous '%s', il reste ou il etait" % name)
		return
	global_position = sol + Vector3.UP * decalage
