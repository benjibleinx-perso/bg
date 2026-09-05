# Camera de poursuite.
#
# Deux lissages independants — position et rotation — parce qu'ils ne
# produisent pas la meme sensation. Une camera qui suit vite en position mais
# tourne lentement donne de la lourdeur ; l'inverse donne de la nervosite.
# C'est le reglage qui change le plus la perception de vitesse, donc il est au
# curseur comme le reste.
extends Camera3D

@export var reglages: Reglages
@export var cible: NodePath

var _cible: Node3D
var _vehicule: Vehicule
var _pieton: bool = false
var _position_lissee: Vector3
var _regard_lisse: Vector3
var _initialisee: bool = false

## Cap de la camera a pied, en radians. C'est une variable A PART ENTIERE,
## surtout pas deduite de l'orientation du personnage.
##
## Si la camera se placait derriere lui pendant que ses deplacements sont
## calcules par rapport a la camera, les deux se poursuivraient : avancer
## converge par hasard, mais reculer ou aller sur le cote n'a aucun point
## d'equilibre et le personnage tourne en rond sans fin. Rendre ce cap
## independant est la seule facon de casser la boucle.
var _cap: float = 0.0

## Cadrage resserre pour les interieurs. Le reste du comportement est
## identique : seule la distance change, parce qu'une piece de sept metres
## ne laisse pas la place d'un recul de rue.
var _dedans: bool = false

## Angle vertical, en radians. Commun au vehicule et a la marche.
var _tangage: float = 0.0

## Decalage de cap applique AU VEHICULE seulement. La camera de conduite est
## solidaire de la caisse — c'est ce qui fait qu'elle accompagne les virages —
## donc la visee libre s'ajoute par-dessus et se resorbe, au lieu de
## remplacer le cap comme a pied.
var _orbite: float = 0.0

## Temps restant avant que le recentrage automatique reprenne la main.
## Sans ce delai, la camera ramenerait de force des qu'on lache la souris, et
## regarder de cote en marchant serait impossible.
var _manuel: float = 0.0

## Recul, en proportion du nominal. Regle a la molette.
var _zoom: float = 1.0


func _ready() -> void:
	if reglages == null:
		push_error("camera_poursuite : aucune ressource Reglages assignee")
		set_physics_process(false)
		return
	var n := get_node_or_null(cible) as Node3D
	if n == null:
		push_warning("camera_poursuite : cible introuvable (%s)" % cible)
		set_physics_process(false)
		return
	suivre(n)
	fov = reglages.fov_arret


## Change de sujet. Appele au moment ou l'on monte dans le vehicule ou l'on
## en descend : le cadrage n'est pas le meme a pied qu'au volant, et la
## camera se replace sans transition brutale grace au lissage.
func suivre(n: Node3D) -> void:
	_cible = n
	_vehicule = n as Vehicule
	_pieton = n is Joueur
	_cap = n.rotation.y          # on demarre derriere le sujet
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if _manuel > 0.0:
		_manuel = maxf(0.0, _manuel - delta)
	elif not _pieton:
		# Au volant, la camera se remet dans l'axe toute seule : elle est
		# solidaire de la caisse, et la visee libre n'est qu'un ecart qui se
		# resorbe. A pied, le cap reste ou la souris l'a laisse, point.
		_orbite = move_toward(_orbite, 0.0, reglages.souris_retour * delta)

	var voulue := _ancrage()
	var vise := _cible.global_position + Vector3.UP * reglages.cible_hauteur

	if not _initialisee:
		_position_lissee = voulue
		_regard_lisse = vise
		_initialisee = true

	# Lissage independant du framerate : a 30 comme a 144 images/s, la camera
	# met le meme temps reel a rattraper. Sans ca, tout reglage trouve sur une
	# machine serait faux sur l'autre.
	var lissage := reglages.pieton_lissage if _pieton else reglages.lissage_position
	_position_lissee = _position_lissee.lerp(voulue, _facteur(lissage, delta))
	_regard_lisse = _regard_lisse.lerp(vise, _facteur(reglages.lissage_rotation, delta))

	global_position = _degager(_position_lissee, _regard_lisse, delta)

	# LA SECOUSSE S'AJOUTE APRES LE LISSAGE ET LE DEGAGEMENT, jamais dedans :
	# un ecart qui entrerait dans la position lissee se resorberait sur
	# plusieurs images au lieu de trembler, et un ecart qui passerait par le
	# degagement se ferait rogner par le premier mur venu. Elle s'amortit
	# lineairement jusqu'a zero, et le look_at qui suit la transmet a la
	# rotation — c'est ce qui fait qu'un choc se voit, pas seulement un
	# deplacement.
	if _secousse_restant > 0.0:
		_secousse_restant = maxf(0.0, _secousse_restant - delta)
		var part := _secousse_restant / _secousse_duree
		global_position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)) * _secousse_amplitude * part

	if global_position.distance_squared_to(_regard_lisse) > 0.01:
		look_at(_regard_lisse, Vector3.UP)

	# Le champ de vision ne s'ouvre qu'en vehicule : a pied, l'ecart de
	# vitesse est trop faible pour que ca veuille dire quelque chose.
	if _vehicule != null:
		# LE PLAFOND EST CELUI DU VEHICULE CONDUIT, pas celui des reglages : un
		# camping-car bride a 75 km/h n ouvrirait jamais le champ s il etait
		# rapporte aux 130 de la berline, et roulerait toujours comme a l arret.
		var t := clampf(_vehicule.vitesse_kmh() / maxf(1.0, _vehicule.vitesse_max_kmh()), 0.0, 1.0)
		fov = lerpf(reglages.fov_arret, reglages.fov_pleine_vitesse, t)
	elif _pieton:
		fov = reglages.fov_arret


# Distance actuellement concedee a un obstacle. Gardee d'une image a l'autre
# pour que le retour au recul normal soit progressif.
var _recul_libre: float = 0.0


# Rapproche la camera si un mur la separe du sujet.
#
# Le clamp est fait APRES le lissage, sur la position finale, et pas sur la
# position visee. Lisser vers une cible deja corrigee laisserait la camera
# traverser le mur pendant qu'elle rattrape — c'est-a-dire exactement au
# moment ou ca se voit.
func _degager(position: Vector3, regard: Vector3, delta: float) -> Vector3:
	if not reglages.camera_collision:
		return position

	var vers := position - regard
	var distance := vers.length()
	if distance < 0.05:
		return position
	var direction := vers / distance

	var espace := get_world_3d().direct_space_state
	var requete := PhysicsRayQueryParameters3D.create(regard, position)
	# Seulement le decor : le sujet suivi est evidemment sur le trajet, et le
	# joueur vit sur sa propre couche pour cette raison.
	requete.collision_mask = 1
	if _cible is CollisionObject3D:
		requete.exclude = [(_cible as CollisionObject3D).get_rid()]

	var touche := espace.intersect_ray(requete)
	var libre := distance
	if not touche.is_empty():
		libre = maxf(0.2, regard.distance_to(touche["position"]) - reglages.camera_marge)

	# Se rapprocher est instantane, s'eloigner est progressif.
	if libre < _recul_libre or _recul_libre <= 0.0:
		_recul_libre = libre
	else:
		_recul_libre = move_toward(_recul_libre, libre, reglages.camera_retour * delta)

	return regard + direction * minf(_recul_libre, distance)


static func _facteur(lissage: float, delta: float) -> float:
	return 1.0 - pow(1.0 - clampf(lissage, 0.001, 0.999), delta * 60.0)


# LA CAMERA NE CHERCHE PLUS LE DOS DU PERSONNAGE, ET C'EST LA CORRECTION LA
# PLUS IMPORTANTE DE TOUTES.
#
# Elle se replacait derriere lui a chaque image. Comme il lisait sa direction
# de marche sur elle, les deux se poursuivaient : aller sur le cote faisait
# tourner la camera, qui faisait tourner la direction, qui la faisait tourner
# encore. On a longtemps traite le symptome — ne recentrer qu'en avancant,
# figer le repere a l'appui, puis retirer au personnage le droit de se
# deplacer lateralement et lui donner les commandes d'un char.
#
# La boucle se coupe a sa source : le cap n'obeit qu'a la souris. Plus rien ne
# le calcule a partir du personnage, donc plus rien ne peut se poursuivre, et
# les commandes redeviennent celles de n'importe quel jeu a la troisieme
# personne — c'est le retour de Guillaume du 23/08/2026.
#
# Ce que ca coute : apres un demi-tour a la souris, la camera reste ou on l'a
# mise. C'est le comportement attendu, pas un oubli.


## Le cap de la camera, en radians : la direction qui va du sujet VERS elle.
## Le personnage le lit pour savoir ou est « devant ».
func cap() -> float:
	return _cap


## Pose le cap sans lissage. Pour les cinematiques, et pour les tests qui
## veulent regarder dans une direction sans simuler un geste de souris.
func poser_le_cap(angle: float) -> void:
	_cap = angle


## LE CADRAGE D'UNE MORT : on regarde d'en haut.
##
## La camera de marche suit une nuque a hauteur d'epaule. Elle convient tant
## que le sujet est debout ; quand il s'affaisse, elle descend avec lui et
## finit au ras du sol, le nez contre le mur — vu a la capture le 23/08/2026,
## et c'est illisible.
##
## Un plongeant regle les deux : le corps reste dans le cadre en tombant, et
## on voit le sol ou il arrive. C'est aussi le plan que ce genre de scene a
## toujours eu, pour la meme raison.
func cadrer_la_mort() -> void:
	_tangage = deg_to_rad(clampf(34.0, reglages.tangage_min, reglages.tangage_max))
	_zoom = 1.35
	# Le cadrage resserre des interieurs ne vaut pas ici : c'est ce
	# rapprochement qui colle la camera au corps.
	_dedans = false


# CE QUI A ETE ESSAYE ET RETIRE, pour que personne ne le retente : choisir le
# cap le plus DEGAGE autour du corps — douze rayons, on garde la direction ou
# la camera peut le plus reculer.
#
# Ca n'a rien change a l'image, et la raison est bete : dans une chambre de
# cinq metres, un recul de 4,8 m est coupe par un mur DANS TOUTES LES
# DIRECTIONS. Le probleme n'est ni l'angle ni la hauteur, c'est la piece.
#
# Ce qu'il faudrait : un vrai plan de cinematique — camera posee au-dessus du
# corps, visant le sol, sans recul horizontal. Ca ne se regle pas ici, dans la
# camera qui suit quelqu'un qui marche.


## Visee libre. Recoit un deplacement de souris en PIXELS.
##
## Les evenements ne sont pas lus ici : cette camera vit dans le SubViewport
## de rendu, et Godot n'y propage aucune entree. C'est le controleur, qui est
## en dehors, qui les recoit et appelle cette methode. Un _input local ne
## serait jamais declenche, sans que rien ne le signale.
func tourner(deplacement: Vector2) -> void:
	# Le signe est NEGATIF, et ce n'est pas arbitraire.
	#
	# _cap designe la direction du sujet VERS la camera. Le regard est donc
	# l'oppose, et son lacet vaut _cap. Or en Godot un lacet positif tourne
	# vers -X, c'est-a-dire vers la GAUCHE quand on regarde vers -Z. Pour que
	# la souris vers la droite fasse tourner la vue a droite, il faut donc
	# diminuer.
	#
	# La premiere version ajoutait, et le test affirmait que c'etait le bon
	# sens : j'avais inscrit le defaut dans sa propre verification.
	# Le signe negatif ne vaut QUE pour l'horizontale. Une premiere version le
	# mettait dans la sensibilite elle-meme, et inversait donc aussi le haut
	# et le bas en corrigeant la gauche et la droite.
	var s := reglages.souris_sensibilite
	if _pieton:
		_cap -= deplacement.x * s
	else:
		_orbite -= deplacement.x * s

	# LA VERTICALE ETAIT INVERSEE, comme un simulateur de vol.
	#
	# _tangage fait MONTER la camera : plus il est grand, plus on regarde le
	# personnage d'en haut. Or pousser la souris vers l'avant veut dire
	# « regarder plus haut », donc BAISSER la camera — et Godot compte un
	# deplacement vers l'avant en y negatif. Le signe est donc positif, et
	# c'est le reglage « souris inversee » qui le retourne, pas l'inverse.
	#
	# La version precedente faisait le contraire, et son test le validait :
	# il verifiait que le tangage bougeait, jamais dans quel sens on voyait.
	var sens := -1.0 if reglages.souris_inversee else 1.0
	_tangage = clampf(_tangage + deplacement.y * s * sens,
			deg_to_rad(reglages.tangage_min), deg_to_rad(reglages.tangage_max))

	_manuel = reglages.souris_repos


## Rapproche ou eloigne, a la molette.
func zoomer(crans: float) -> void:
	_zoom = clampf(_zoom - crans * reglages.zoom_pas,
			reglages.zoom_min, reglages.zoom_max)


## La camera a-t-elle deja pris sa place ? Le personnage fige son repere de
## deplacement sur elle : tant qu'elle n'est pas posee, il figerait une
## orientation perimee et partirait dans une direction qui n'a rien a voir
## avec ce qu'on voit — pour toute la duree de l'appui.
func pret() -> bool:
	return _initialisee


## Resserre ou relache le cadrage. Appele au passage d'une porte.
func interieur(dedans: bool) -> void:
	_dedans = dedans


## Replace la camera d'un coup, sans lissage. Indispensable apres une
## teleportation : le lissage mettrait plusieurs secondes a traverser les six
## cents metres qui separent la ville des interieurs, et on verrait le vide.
func recaler() -> void:
	_cap = _cible.rotation.y
	_initialisee = false


## Une secousse en cours : ce qui reste a jouer, sa duree totale, et son
## amplitude au depart. Voir _physics_process pour ou elle s'applique.
var _secousse_restant: float = 0.0
var _secousse_duree: float = 0.0
var _secousse_amplitude: float = 0.0


## SECOUER LA CAMERA, en metres et en secondes. Le filet s'en sert quand il
## repose quelqu'un : le joueur doit sentir qu'il a ete rattrape, sans un mot
## et sans un chiffre. Une nouvelle secousse remplace celle en cours.
func secouer(amplitude: float, duree: float) -> void:
	_secousse_amplitude = maxf(0.0, amplitude)
	_secousse_duree = maxf(0.01, duree)
	_secousse_restant = _secousse_duree


## Reste-t-il une secousse a jouer ? Pour les verifications.
func secoue() -> bool:
	return _secousse_restant > 0.0


func _ancrage() -> Vector3:
	var derriere: Vector3
	var recul: float
	var haut: float

	if _pieton:
		derriere = Vector3(sin(_cap), 0.0, cos(_cap))
		recul = reglages.interieur_recul if _dedans else reglages.pieton_recul
		haut = reglages.interieur_hauteur if _dedans else reglages.pieton_hauteur
	else:
		# La direction vient de la caisse, pas d'un axe du monde : c'est ce qui
		# fait que la camera accompagne les virages. L'orbite s'ajoute par
		# dessus et se resorbe.
		derriere = _cible.global_transform.basis.z.rotated(Vector3.UP, _orbite)
		recul = reglages.recul
		haut = reglages.hauteur

	recul *= _zoom

	# Le tangage fait pivoter la camera AUTOUR du sujet : elle monte et se
	# rapproche en meme temps. Se contenter de lever la hauteur donnerait une
	# camera qui plane sans jamais regarder d'en haut.
	return (_cible.global_position
			+ derriere * recul * cos(_tangage)
			+ Vector3.UP * (haut + sin(_tangage) * recul))
