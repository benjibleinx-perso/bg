# UN FOYER QUI BRULE, ET QU'ON N'ETEINDRA JAMAIS.
#
# POURQUOI IL EXISTE. Le camping-car sort de la route, deux hommes sont morts
# dedans, et il ne s'en degageait qu'un filet de fumee. Le retour du 23/08/2026
# le demande, et il dit precisement a quoi ca sert :
#
#   « Rajouter des flammes autour du RV. Elles serviront a 2 choses : 1 prendre
#     des degats, et 2, d'etape supplementaire dans la suite d'actions. Il faut
#     recuperer le materiel d'abord, en essayant de ne pas marcher dans les
#     flammes. »
#
# Ce n'est donc pas un decor. C'est ce qui transforme « aller chercher trois
# objets » en « aller chercher trois objets EN CONTOURNANT quelque chose », et
# c'est la difference entre un trajet et un geste.
#
# CE QU'IL NE FAIT PAS : s'eteindre. Jamais, par aucun moyen. Le point
# « Eteindre » se propose, Walter s'approche, recule en toussant, et le feu
# brule exactement pareil. C'est ecrit dans le retour et c'est une regle :
#
#   « Le jeu ne dira jamais au joueur qu'il est impossible d'eteindre les
#     flammes. C'est une mecanique pour creer du stress et etre fidele a la
#     serie. »
#
# Donc aucun bandeau, aucun refus, aucun message. Le joueur essaie, il voit ce
# qui se passe, et il en tire ce qu'il veut. Un « impossible » affiche ferait de
# ce moment une porte fermee au lieu d'une scene.
#
# LE FEU NE SAIT PAS QUI IL BRULE. Il mesure une distance et appelle blesser()
# sur ce qui l'approche. Il ne connait ni la mission, ni Walter, ni le
# camping-car — le jour ou une cuisine tourne mal, on posera le meme noeud.
class_name Feu
extends Node3D

## Rayon des flammes, en metres. On brule des qu'on est dedans.
##
## GENEREUX PAR RAPPORT A CE QU'ON VOIT, et c'est volontaire : les particules
## sont un panache qui bat, donc son bord exact change dix fois par seconde. Une
## zone calee au pixel donnerait « j'ai brule alors que j'etais a cote » aussi
## souvent que l'inverse. On brule un peu avant de toucher, ce qui est aussi ce
## que fait un vrai feu.
@export_range(0.5, 6.0, 0.1) var rayon: float = 1.6

## Degats par seconde passee dedans, sur les cent points de vie du joueur.
##
## VINGT, C'EST CINQ SECONDES POUR MOURIR. Le chiffre a ete choisi contre deux
## ecueils : a cinq, on traverse un foyer sans le sentir et les flammes
## redeviennent du decor ; a cinquante, un frolement tue et la scene devient un
## couloir a memoriser. Cinq secondes, c'est le temps qu'il faut pour comprendre
## qu'il faut ressortir, et pas assez pour flaner.
@export_range(1.0, 100.0, 1.0) var degats_par_seconde: float = 20.0

## La hauteur du panache, en metres. Elle commande aussi la taille des bouffees.
@export_range(0.5, 5.0, 0.1) var hauteur: float = 2.2

## Combien de bouffees vivent en meme temps.
##
## SOIXANTE-DOUZE, ET LA PREMIERE VERSION EN AVAIT TRENTE-QUATRE. Le melange
## est additif : c'est l'EMPILEMENT des bouffees qui fabrique le coeur clair, et
## rien d'autre. Trente-quatre bouffees larges donnaient exactement ce que la
## capture a montre — des disques dores qu'on distingue un par un, c'est-a-dire
## un nuage de poussiere. Il en faut assez pour qu'on ne puisse plus les
## compter.
##
## Ca reste peu : c'est un rendu de 2001, et cinq foyers a deux cents particules
## tueraient la scene.
@export_range(4, 200, 1) var bouffees: int = 72

## Tous les foyers sont dans ce groupe. Le point « Eteindre » cherche le sien
## par la, et rien d'autre ne s'en sert pour l'instant.
const GROUPE := "feu"

## L'age auquel une bouffee a fini de monter. Court : une flamme n'a pas la
## duree de vie d'une fumee, elle claque et disparait.
##
## C'EST CE CHIFFRE QUI FAIT LA DIFFERENCE ENTRE UN FEU ET UNE VAPEUR. A 1,1 s
## les bouffees vivaient assez longtemps pour s'ecarter les unes des autres et
## flotter — ce qui est exactement ce que fait de la fumee, et pas du tout ce
## que fait une flamme. A 0,7 s elles disparaissent avant d'avoir eu le temps de
## se disperser, et le panache reste une colonne.
const DUREE := 0.7

## LE GRONDEMENT. Une boucle spatialisee, pas un son de la banque.
##
## Audio.bruit_ici() joue un COUP : une portiere, un pas, un coup de feu. Un
## foyer ne fait pas un bruit, il en fait un en continu — et il doit venir d'un
## endroit, sinon on ne sait pas de quel cote il est.
##
## C'EST AUSSI LE SEUL AVERTISSEMENT QUE LE JOUEUR RECOIT. On brule un peu avant
## de toucher les flammes, et un feu muet ferait passer ca pour un bug ; un feu
## qui gronde de plus en plus fort a mesure qu'on approche dit tout seul ou est
## la limite, sans qu'aucune ligne ne s'affiche.
const GRONDEMENT := "res://assets/sons/mission/feu_carburant.ogg"

var _joueur: Node3D
var _particules: GPUParticles3D
var _son: AudioStreamPlayer3D


func _ready() -> void:
	add_to_group(GROUPE)
	# Tant que personne ne lui a dit qui surveiller, il ne coute rien : six
	# foyers qui mesurent une distance a chaque image contre un joueur absent,
	# c'est six fois rien, mais c'est six fois rien de trop.
	set_process(false)
	_fabriquer()
	_faire_gronder()


## Le corps a surveiller. Pose par le controleur, comme pour les PNJ : ce noeud
## n'a aucun moyen de savoir qui joue, et le chercher par son nom serait une
## adresse de plus a maintenir.
func observer(n: Node3D) -> void:
	_joueur = n
	set_process(n != null)


## Est-on dedans ? Publique pour que la verification MESURE au lieu de refaire
# le calcul de son cote — deux endroits qui disent la meme chose finissent par
# ne plus la dire pareil.
func contient(ou: Vector3) -> bool:
	# LA DISTANCE SE MESURE A PLAT.
	#
	# Un foyer est une colonne, pas une boule : sa hauteur ne doit pas eloigner
	# le joueur qui se tient a son pied. Avec une distance en trois dimensions,
	# un panache de 2,20 m mesure depuis son centre laissait un anneau de sable
	# tiede tout autour de la base — l'endroit exact ou l'on passe.
	var d := ou - global_position
	d.y = 0.0
	return d.length() <= rayon


func _process(delta: float) -> void:
	if _joueur == null or not is_instance_valid(_joueur):
		return
	if not contient(_joueur.global_position):
		return
	if _joueur.has_method("blesser"):
		_joueur.call("blesser", degats_par_seconde * delta)


# LE PANACHE. Fabrique ici plutot que pose dans la scene, et c'est ce qui permet
# d'en semer six autour d'une carcasse sans recopier six fois quarante lignes de
# .tscn — dont on saurait, le jour ou l'on change la couleur, qu'on en a oublie
# une.
#
# Le shader est CELUI DE LA FUMEE. Il fait deja tout ce qu'une flamme demande :
# un disque aux bords fondus, un grain qui differe d'une bouffee a l'autre, un
# cycle de vie, et surtout le fondu de contact — sans lui, le quad se coupe net
# la ou il traverse la tole, et l'arete droite au milieu du feu tue l'illusion.
# Ecrire un shader de flamme aurait recopie ces quatre choses pour changer une
# couleur.
func _fabriquer() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://rendu/particule_douce.gdshader")
	# L'ORANGE EST TRES CLAIR PARCE QUE LE MELANGE EST ADDITIF. Un orange de
	# nuancier — 0.9, 0.45, 0.1 — s'additionne au sable clair du desert et rend
	# un jaune sale. Ce qu'on veut est le coeur blanc-jaune d'une flamme, dont
	# les bords virent au rouge en s'eteignant : c'est l'accumulation des
	# bouffees qui fait la couleur, pas chacune d'elles.
	mat.set_shader_parameter("couleur", Color(1.0, 0.55, 0.16, 0.85))
	mat.set_shader_parameter("douceur_contact", 0.3)
	# BIEN AU-DESSUS DE 1, ET C'EST CE QUI FABRIQUE LE COEUR.
	#
	# En additif, chaque bouffee AJOUTE sa couleur : la ou dix se superposent —
	# c'est-a-dire au centre de la colonne — le total sature vers le blanc-jaune,
	# et les bords, ou il n'y en a qu'une ou deux, restent orange. C'est
	# exactement ce que fait une flamme, et c'est gratuit.
	#
	# A 0,9, aucune zone n'atteignait jamais la saturation : tout le panache
	# avait la meme valeur, donc pas de coeur, donc un nuage.
	mat.set_shader_parameter("opacite", 1.8)
	# MOINS DECHIQUETE QU'IL N'Y PARAIT. Le premier essai etait a 0,85 : chaque
	# bouffee devenait une dentelle, et vingt dentelles superposees rendent une
	# purée uniforme. Le grain sert a casser le bord du disque, pas a le manger.
	mat.set_shader_parameter("grain", 0.5)
	mat.set_shader_parameter("grain_echelle", 6.0)

	var quad := QuadMesh.new()
	quad.material = mat
	# PETITES. Elles faisaient plus d'un metre de cote : a cette taille on les
	# distingue une par une, et « une par une » veut dire « ce ne sont pas des
	# flammes ». Le panache doit etre fait de beaucoup de petites choses.
	quad.size = Vector2(hauteur * 0.3, hauteur * 0.3)

	var proc := ParticleProcessMaterial.new()
	proc.direction = Vector3(0, 1, 0)
	# Etroit : le feu monte droit, il ne s'evase pas. Un spread large donne un
	# feu de camp qu'on regarde, pas un vehicule qui brule.
	proc.spread = 10.0
	# TROIS FOIS PLUS VITE QUE LA PREMIERE VERSION. A 1,3 m/s contre une gravite
	# de 1,4, les bouffees montaient a peine plus qu'elles ne s'ecartaient : le
	# panache s'etalait au sol au lieu de se dresser. Une flamme est d'abord une
	# chose qui MONTE.
	proc.initial_velocity_min = hauteur * 0.85
	proc.initial_velocity_max = hauteur * 1.35
	# La gravite tire vers le HAUT : l'air chaud monte, et c'est ce qui donne
	# l'acceleration qu'on reconnait sans savoir la nommer.
	#
	# REGLE DEUX FOIS, ET DANS LES DEUX SENS. Trop faible, le panache s'etalait
	# au sol ; trop fort, les bouffees les plus rapides depassaient le toit du
	# camping-car et s'en detachaient une par une, comme des ballons. Le champ
	# « hauteur » doit vouloir dire quelque chose : c'est a peu pres la ou le
	# panache s'arrete.
	proc.gravity = Vector3(0, 1.7, 0)
	proc.scale_min = 0.6
	proc.scale_max = 1.3
	# Les bouffees retrecissent en montant : c'est ce qui fait la pointe.
	var courbe := Curve.new()
	courbe.add_point(Vector2(0.0, 1.0))
	courbe.add_point(Vector2(1.0, 0.05))
	var texture := CurveTexture.new()
	texture.curve = courbe
	proc.scale_curve = texture
	# LA BASE EST UN DISQUE, PAS UN POINT. Un foyer nait sur une flaque de
	# carburant : ses bouffees partent de partout sur sa surface.
	#
	# BEAUCOUP PLUS SERRE QUE LE RAYON QUI BRULE. Les deux ne mesurent pas la
	# meme chose : le rayon dit jusqu'ou on se brule — genereux, parce que le
	# bord d'un panache bat dix fois par seconde — et celui-ci dit d'ou part le
	# feu. A 55 % du rayon, la colonne naissait sur un metre de large et se
	# lisait comme une nappe.
	proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE_SURFACE
	proc.emission_sphere_radius = rayon * 0.28

	_particules = GPUParticles3D.new()
	_particules.name = "Flammes"
	_particules.draw_pass_1 = quad
	_particules.process_material = proc
	_particules.amount = bouffees
	_particules.lifetime = DUREE
	# Pre-remplies : sans ca, le foyer s'allume sous les yeux du joueur a la
	# premiere image ou il entre dans le champ, et on voit le feu prendre.
	_particules.preprocess = DUREE
	# La boite de visibilite est calculee une fois : sans elle, Godot la deduit
	# et fait disparaitre le panache des qu'on regarde par le travers.
	_particules.visibility_aabb = AABB(
			Vector3(-rayon, 0.0, -rayon),
			Vector3(rayon * 2.0, hauteur * 1.6, rayon * 2.0))
	add_child(_particules)


func _faire_gronder() -> void:
	if not ResourceLoader.exists(GRONDEMENT):
		return
	var flux := load(GRONDEMENT) as AudioStream
	if flux == null:
		return
	# LA BOUCLE SE DEMANDE AU FLUX, PAS AU LECTEUR.
	#
	# Un AudioStreamPlayer3D n'a pas de case « boucler » : c'est la ressource
	# qui porte le reglage. Sans cette ligne, chaque foyer gronde douze secondes
	# puis se tait pour toujours, et le silence arrive pile quand le joueur a
	# fini de faire le tour du camping-car.
	if flux is AudioStreamOggVorbis:
		(flux as AudioStreamOggVorbis).loop = true

	_son = AudioStreamPlayer3D.new()
	_son.name = "Grondement"
	_son.stream = flux
	_son.bus = Audio.BUS_AMBIANCE
	_son.volume_db = -6.0
	# Il porte a peine plus loin que le double de son rayon : cinq foyers qu'on
	# entend depuis l'autre bout du desert feraient un grondement permanent ou
	# plus rien ne se detache. On veut savoir qu'on APPROCHE, pas qu'il y a du
	# feu quelque part.
	_son.max_distance = maxf(rayon * 6.0, 12.0)
	_son.unit_size = rayon * 2.0
	# Chacun demarre a un endroit different de la boucle : cinq foyers cales sur
	# la meme crepitation s'entendent comme un seul son joue cinq fois fort, et
	# les attaques se superposent en battements qu'on remarque tout de suite.
	add_child(_son)
	_son.play(randf() * 12.0)
