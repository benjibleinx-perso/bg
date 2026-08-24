# TRAINER UN CORPS PAR LES PIEDS, ET S'ARRETER POUR SOUFFLER.
#
# POURQUOI. Les deux morts du fosse etaient un objectif qu'on regarde, et rien
# de plus. Le retour du 23/08/2026 en fait une etape entiere, et il la decrit
# geste par geste :
#
#   « Il faut maintenir la touche action sur un corps (ce qui va faire se
#     pencher le personnage (dos courbe) pour l'attraper par les pieds) et il
#     faudra reculer jusqu'a l'entree du RV pour le trainer leennntement. Le
#     personnage fatigue et lachera 2 fois le cadavre pour souffler un peu
#     (animation d'essoufflement + impossibilite de reprendre le cadavre
#     pendant l'animation (3-4s). [...] La tractation complete doit bien
#     prendre au moins 20 secondes. »
#
# C'EST LE PREMIER GESTE DU JEU QUI SE TIENT AU LIEU DE SE PRESSER. Tout le
# reste — ramasser, ouvrir, mettre le contact — est un appui. Ici la touche
# reste enfoncee pendant vingt secondes, et la lacher a mi-chemin repose le
# corps la ou il est. C'est ce qui fait qu'on SENT le poids : rien d'autre dans
# le mecanisme ne le dit, aucun chiffre ne s'affiche, et les pauses ne
# s'annoncent pas.
#
# CE QU'IL NE FAIT PAS : decider quand il est actif. C'est une donnee de
# mission — « traction »: true sur l'etape — au meme titre que le filtre du
# masque ou le niveau de la sirene. Un systeme qui reconnaitrait l'etape a son
# nom est le piege 39, paye trois fois.
class_name Traction
extends Node3D

## Emis quand tous les corps sont a l'interieur. Le scenario en fait un
## evenement de mission ; ce fichier ne sait pas ce qu'est une etape.
signal charges

## Emis quand Walter repose un corps pour souffler. Le scenario y accroche la
## phrase qui tombe en fond — savoir qui parle et quand est son travail, pas le
## notre.
signal souffle(reste: int)

const GROUPE := "traction"

## Les corps a embarquer, dans l'ordre ou on les trouve. Vides = ce noeud ne
## fait rien, ce qui est le cas de toutes les scenes sauf une.
@export var corps: Array[NodePath] = []

## OU L'ON DEPOSE. Le nom d'un noeud, cherche a l'instant du depot.
##
## La porte du camping-car accidente. Elle SUIT LE VEHICULE, donc ce n'est pas
## une coordonnee : la caisse est posee par desert.gd avec les angles du crash,
## et trois nombres recopies a la main s'en ecarteraient au premier reglage.
@export var porte: NodePath

## A quelle distance du corps on peut l'attraper, en metres.
##
## Genereux : on vise des pieds poses au sol, et un rayon serre obligerait a
## chercher le pixel juste au lieu de se baisser.
@export_range(0.5, 5.0, 0.1) var portee: float = 2.4

## A quelle distance de la porte le corps passe a l'interieur.
##
## « Une fois devant l'entree du RV, le corps se teleportera a l'interieur. »
## On ne demande donc pas d'appuyer sur quoi que ce soit : arriver suffit, et
## c'est ce qui evite un geste de plus a la fin d'un geste long.
@export_range(1.0, 6.0, 0.1) var depot: float = 2.6

## CELUI QUI MONTRE. Jesse, et c'est tout l'interet de l'etape.
##
##   « Important, durant cette etape, Jesse part devant et tracte sont cadavre
##     lui-meme. Cela permettra au joueur de voir ce qu'il faut faire. Seul
##     Walter fera des pauses, Jesse lui fait tout d'une traite. »
##     — retour du 23/08/2026.
##
## C'EST UN TUTORIEL QUI NE S'ECRIT PAS. Le meme retour reclame partout moins de
## texte de mission et plus de « PNJ autour qui parlent ou agissent pour nous
## attirer vers la suite » : ici, personne n'explique rien. Quelqu'un se baisse,
## attrape deux pieds et recule — et on a compris.
##
## Vide = personne ne montre, et Walter porte les deux.
@export var aide: NodePath

var _joueur: Node3D
var _reglages: Reglages

## Le corps que l'aide s'est reserve. Walter ne peut pas le prendre : deux
## personnes qui tirent le meme cadavre chacune de leur cote est un spectacle
## qu'on ne veut pas avoir a debuguer.
var _corps_de_l_aide: Node3D

## Ou en est l'aide : 0 il n'a pas commence, 1 il va vers son corps, 2 il le
## traine, 3 c'est fini.
var _etat_aide: int = 0

## Le corps qu'on traine, ou null. Un seul a la fois : on a deux mains et il en
## faut deux.
var _tire: Node3D

## Ce qui est deja dedans. On garde les noeuds plutot qu'un compteur : le jour
## ou l'on pourra ressortir un corps, un compteur mentirait.
var _dedans: Array[Node3D] = []

## Distance tiree depuis la derniere pause, en metres. C'est elle qui declenche
## l'essoufflement — pas un minuteur : un joueur qui s'arrete de marcher ne se
## fatigue pas, et une pause qui tombe a l'arret passerait pour un bug.
var _tire_depuis: float = 0.0

## Combien de pauses ce corps a deja coutees. Deux, et le retour est precis
## la-dessus : « lachera 2 fois le cadavre ».
var _pauses: int = 0

## Ce qui reste de la pause en cours, en secondes. Negatif = on n'y est pas.
var _repos: float = -1.0


func _ready() -> void:
	add_to_group(GROUPE)
	set_process(false)


## Le joueur a surveiller, et les reglages de ressenti. Poses par le scenario,
## comme pour les foyers : ce noeud n'a aucun moyen de savoir qui joue.
func observer(n: Node3D, r: Reglages) -> void:
	_joueur = n
	_reglages = r
	set_process(n != null)


## L'ETAPE COURANTE DEMANDE-T-ELLE DE PORTER QUELQUE CHOSE ?
##
## Lu a chaque image plutot que memorise a un changement d'etape : c'est ce qui
## fait qu'un chargement de sauvegarde au milieu de la scene retrouve le bon
## etat sans qu'on ait rien a sauvegarder de plus.
func active() -> bool:
	var m := Mission.courante(self)
	if m == null or m.finie():
		return false
	return bool(m.etape().get("traction", false))


## Traine-t-on quelque chose en ce moment ?
func porte_un_corps() -> bool:
	return _tire != null


## Souffle-t-on ? Pendant ce temps la touche ne rend rien, et c'est le sujet.
func au_repos() -> bool:
	return _repos >= 0.0


func restants() -> int:
	return _libres().size() + (1 if _tire != null else 0)


## CE QUE LA TOUCHE FERAIT MAINTENANT, ou une chaine vide.
##
## Rendue au controleur, qui l'affiche et qui possede la touche. On ne dessine
## rien nous-memes : deux systemes qui ecrivent au meme endroit de l'ecran
## finissent par s'ecraser l'un l'autre, et celui qui perd est toujours celui
## qui aide.
func invite() -> String:
	if not active() or _joueur == null:
		return ""
	if _repos >= 0.0:
		# ON N'ANNONCE PAS LA PAUSE. Walter est plie en deux, il souffle, et
		# c'est visible : ecrire « reprenez votre souffle » expliquerait une
		# image qui se suffit. Le retour demande moins de texte, pas plus.
		return ""
	if _tire != null:
		return "Maintenir pour tirer"
	if _plus_proche() != null:
		return "Maintenir pour attraper les pieds"
	return ""


## L'ETAT DE LA TOUCHE, donne par le controleur a chaque image.
##
## On ne lit pas Input ici, et c'est la meme discipline que partout : le
## controleur attribue la touche, parce que lui seul sait si un dialogue, un
## menu ou un telephone la reclame en meme temps.
func tenir(appuye: bool) -> void:
	if not active() or _joueur == null:
		return
	if _repos >= 0.0:
		# On lache tout pendant la pause, meme si le joueur maintient : c'est
		# exactement ce que le retour demande — « impossibilite de reprendre le
		# cadavre pendant l'animation ».
		return
	if not appuye:
		_lacher()
		return
	if _tire == null:
		var candidat := _plus_proche()
		if candidat != null:
			_attraper(candidat)


func _attraper(c: Node3D) -> void:
	_tire = c
	_tire_depuis = 0.0
	# IL SE TOURNE VERS CE QU'IL RAMASSE, UNE FOIS, ET PLUS JAMAIS ENSUITE.
	#
	# Tant qu'il tire, le personnage ne pivote plus (voir Joueur.traine) : il
	# recule en gardant le corps devant lui. Ce cap-la est donc celui qu'il aura
	# pendant tout le trajet, et s'il est faux au depart il sera faux jusqu'au
	# bout — on le voyait tirer de cote, le cadavre en travers.
	if _joueur != null:
		var vers := c.global_position - _joueur.global_position
		vers.y = 0.0
		if vers.length_squared() > 0.0001:
			_joueur.rotation.y = atan2(-vers.x, -vers.z)


func _lacher() -> void:
	if _tire == null:
		return
	# Il reste OU IL EST. Le remettre a sa place d'origine annulerait le
	# travail deja fait, et lacher a mi-chemin est un choix qu'on a le droit de
	# faire — pour aller voir ce que fait Jesse, ou parce qu'on a peur.
	_tire = null
	_tire_depuis = 0.0


func _process(delta: float) -> void:
	# L'ETAT DU JOUEUR SE POSE A CHAQUE IMAGE, y compris quand on ne tire rien.
	#
	# Un booleen qu'on pose sans jamais l'annuler est un bug qui attend : lacher
	# le corps a mi-chemin laisserait Walter se trainer a 0,75 m/s pour le reste
	# de la partie, sans que rien ne l'explique. C'est exactement ce qui est
	# arrive a « entrave » sous le masque a gaz.
	if _joueur != null and "traine" in _joueur:
		_joueur.set("traine", _tire != null)
	if not active():
		return
	_avancer_l_aide(delta)
	if _repos >= 0.0:
		_repos -= delta
		return
	if _tire == null:
		return

	# LE CORPS SUIT LES PIEDS DE WALTER, il ne se teleporte pas sur lui.
	#
	# Un decalage vers l'arriere du personnage, pas vers l'avant : il tire, donc
	# la masse est derriere lui. Sans ce decalage on le voit marcher DANS le
	# cadavre, ce qui est a la fois laid et faux.
	var arriere := _joueur.global_transform.basis.z
	arriere.y = 0.0
	if arriere.length_squared() < 0.0001:
		arriere = Vector3.BACK
	var voulu := _joueur.global_position + arriere.normalized() * LAISSE
	var avant := _tire.global_position
	# IL SUIT LE SOL SOUS WALTER, pas son altitude de depart.
	#
	# Garder l'altitude d'origine paraissait plus simple et ne l'etait pas : la
	# cuvette creuse 2,30 m sur quinze metres, donc un corps tire depuis le fond
	# vers la portiere se serait enterre jusqu'a la taille en remontant la
	# pente. Walter, lui, marche sur ce sol : sa hauteur est la bonne mesure.
	voulu.y = _joueur.global_position.y + REPOSE
	_tire.global_position = voulu

	# ET IL SE TOURNE DANS L'AXE DU TRAJET. Un corps tire par les pieds arrive
	# dans le sens ou on l'emmene ; garder son orientation d'origine le fait
	# glisser en crabe sur dix metres.
	var trajet := voulu - avant
	trajet.y = 0.0
	if trajet.length() > 0.001:
		_tire.rotation.y = atan2(-trajet.x, -trajet.z)

	_tire_depuis += trajet.length()

	# ARRIVE ? On depose, sans rien demander.
	var p := _porte()
	if p != null and _a_plat(voulu, p.global_position) <= depot:
		_embarquer()
		return

	# FATIGUE. Elle se compte en METRES TIRES et pas en secondes : un joueur
	# qui s'arrete ne se fatigue pas, et une pause qui tomberait a l'arret
	# passerait pour un mecanisme casse.
	if _pauses < PAUSES and _tire_depuis >= _entre_deux_pauses():
		_pauses += 1
		_repos = _duree_du_repos()
		var reste := restants()
		_lacher()
		souffle.emit(reste)


func _embarquer() -> void:
	var c := _tire
	_lacher()
	_pauses = 0
	_ranger(c)


# UN CORPS PASSE A L'INTERIEUR. Le meme geste pour celui de Walter et celui de
# Jesse : deux facons de ranger un cadavre finiraient par ne plus ranger pareil,
# et c'est le compte des corps restants qui decide de la fin de l'etape.
func _ranger(c: Node3D) -> void:
	if c == null or _dedans.has(c):
		return
	c.visible = false
	# On le SORT du monde physique en meme temps qu'on le cache : un corps
	# invisible qui garde sa collision devant la portiere est un mur qu'on ne
	# voit pas, et c'est le genre de chose qu'on met une soiree a diagnostiquer.
	c.process_mode = Node.PROCESS_MODE_DISABLED
	_dedans.append(c)
	if _libres().is_empty() and _tire == null and _corps_de_l_aide == null:
		charges.emit()


# JESSE FAIT LE SIEN, ET IL LE FAIT D'UNE TRAITE.
#
# Trois etats et rien de plus : il va vers son corps, il le traine, c'est fini.
# Aucune pause — « seul Walter fera des pauses » — et aucune reaction a ce que
# fait le joueur : il part devant, quoi qu'on decide de son cote.
#
# IL PART TOUT DE SUITE. La demonstration ne vaut que si elle passe DEVANT le
# joueur au moment ou celui-ci se demande quoi faire ; attendre qu'il ait
# essaye, c'est expliquer apres coup.
func _avancer_l_aide(_delta: float) -> void:
	var qui := get_node_or_null(aide) as Pnj
	if qui == null or _etat_aide == 3:
		return

	if _etat_aide == 0:
		_corps_de_l_aide = _corps_le_plus_loin_du_joueur()
		if _corps_de_l_aide == null:
			_etat_aide = 3
			return
		_etat_aide = 1
		qui.aller_vers(_corps_de_l_aide.global_position, ALLURE_VERS_LE_CORPS)
		return

	if _etat_aide == 1:
		if not qui.arrive():
			return
		# Il l'a atteint : il se baisse, et il repart vers la portiere.
		_etat_aide = 2
		var p := _porte()
		if p == null:
			_etat_aide = 3
			return
		qui.aller_vers(p.global_position, ALLURE_CHARGE)
		return

	# _etat_aide == 2 : le corps le suit, exactement comme celui de Walter.
	if _corps_de_l_aide == null:
		_etat_aide = 3
		return
	var arriere := qui.global_transform.basis.z
	arriere.y = 0.0
	if arriere.length_squared() < 0.0001:
		arriere = Vector3.BACK
	var ou := qui.global_position + arriere.normalized() * LAISSE
	ou.y = qui.global_position.y + REPOSE
	var trajet := ou - _corps_de_l_aide.global_position
	trajet.y = 0.0
	if trajet.length() > 0.001:
		_corps_de_l_aide.rotation.y = atan2(-trajet.x, -trajet.z)
	_corps_de_l_aide.global_position = ou

	if qui.arrive():
		var c := _corps_de_l_aide
		_corps_de_l_aide = null
		_etat_aide = 3
		_ranger(c)


# Celui que Jesse prend : LE PLUS LOIN DE WALTER.
#
# Pas « le plus proche de Jesse », qui donnerait deux personnages qui se
# croisent en diagonale au milieu du fosse. Le plus loin du joueur, c'est celui
# vers lequel Walter n'ira pas d'instinct — donc chacun le sien, sans qu'on ait
# eu a se le dire.
func _corps_le_plus_loin_du_joueur() -> Node3D:
	var meilleur: Node3D = null
	var loin := -1.0
	for c in _libres():
		var d := _a_plat(_joueur.global_position, c.global_position)
		if d > loin:
			loin = d
			meilleur = c
	return meilleur


## L'allure de Jesse quand il va CHERCHER son corps, en metres par seconde.
## Vif : il court presque, et c'est ce qui fait qu'on le remarque partir.
const ALLURE_VERS_LE_CORPS := 2.4

## Et quand il le TRAINE. Plus lent que sa marche, plus rapide que Walter : il
## ne s'arrete jamais, donc il arrive avant — ce qui est exactement ce qu'il
## faut pour que la demonstration soit finie quand on en a besoin.
const ALLURE_CHARGE := 1.05


## COMBIEN DE PAUSES PAR CORPS. Deux, et c'est le retour qui le dit.
const PAUSES := 2

## A quelle distance derriere Walter le corps se tient, en metres.
const LAISSE := 1.15

## De combien le corps flotte au-dessus du sol sur lequel Walter marche.
##
## Un homme couche sur le dos n'a pas son origine a la meme hauteur qu'un homme
## debout : c'est l'epaisseur de son torse, et c'est le decalage que les deux
## corps portent deja dans la scene.
const REPOSE := 0.25


# La distance a tirer entre deux pauses. On la deduit du TRAJET REEL plutot que
# de l'ecrire : les corps et la porte bougent avec le vehicule, et un nombre
# fixe donnerait trois pauses sur un trajet long et zero sur un trajet court.
func _entre_deux_pauses() -> float:
	var p := _porte()
	if p == null or _tire == null:
		return 4.0
	# Le trajet restant au moment ou l'on a attrape, divise en trois : on souffle
	# au tiers et aux deux tiers, jamais au depart ni a l'arrivee.
	return maxf(2.0, _a_plat(_tire.global_position, p.global_position) / 3.0)


func _duree_du_repos() -> float:
	return _reglages.traction_repos if _reglages != null else 3.5


func _libres() -> Array[Node3D]:
	var reste: Array[Node3D] = []
	for chemin in corps:
		var c := get_node_or_null(chemin) as Node3D
		# CELUI DE JESSE N'EST PAS LIBRE. Sans cette exclusion, Walter pouvait
		# attraper les pieds d'un cadavre que quelqu'un d'autre etait en train
		# de tirer : les deux le placaient a chaque image, chacun derriere soi,
		# et il partait en vibration entre les deux.
		if c != null and not _dedans.has(c) and c != _tire \
				and c != _corps_de_l_aide:
			reste.append(c)
	return reste


func _plus_proche() -> Node3D:
	var meilleur: Node3D = null
	var mini := portee
	for c in _libres():
		var d := _a_plat(_joueur.global_position, c.global_position)
		if d < mini:
			mini = d
			meilleur = c
	return meilleur


func _porte() -> Node3D:
	return get_node_or_null(porte) as Node3D


# A PLAT, comme partout dans ce fosse : la cuvette creuse deux metres trente,
# et une distance en trois dimensions ferait croire qu'on est plus loin de la
# porte qu'on ne l'est en marchant.
func _a_plat(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()


## Tout remettre en place. Recommencer une partie doit redonner deux corps
## dehors, a leur place, et un Walter qui n'a rien dans les mains.
func reinitialiser() -> void:
	_lacher()
	for c in _dedans:
		c.visible = true
		c.process_mode = Node.PROCESS_MODE_INHERIT
	_dedans.clear()
	_pauses = 0
	_repos = -1.0
	_corps_de_l_aide = null
	_etat_aide = 0
	# Jesse retourne a sa place : recommencer une partie ne doit pas le laisser
	# plante devant la portiere, la ou la traction precedente l'avait envoye.
	var qui := get_node_or_null(aide) as Pnj
	if qui != null:
		qui.replacer()
