# Un point d'interaction : « F pour faire ceci ».
#
# UN SEUL script pour l'atelier de chimie, la marchandise de Jesse, le revolver
# de la boite a gants, la botte secrete sur le bureau de Tuco et le volant du
# camping-car. Chacun aurait pu avoir le sien ; ils auraient tous redit la meme
# chose — mesurer une distance, afficher une invite, se declencher une fois —
# et ils auraient diverge au troisieme.
#
# Ce qui les distingue tient en cinq champs poses dans la scene. Ce qui se
# passe ensuite ne regarde pas ce fichier : il annonce un EVENEMENT, et la
# mission decide si ca la fait avancer.
class_name Point
extends Node3D

signal utilise(point: Point)

## Ce qui s'affiche apres le E. Un verbe : « Cuisiner », « Ramasser ».
@export var invite: String = "Utiliser"

## L'evenement annonce a la mission. Vide = on ne lui dit rien, ce qui est le
## cas des points purement decoratifs comme le volant.
@export var evenement: String = ""

## L'objet donne au joueur, s'il y en a un. Sa cle dans outils.json.
@export var donne: String = ""

## CE QUE CA COUTE, en dollars. Zero = gratuit, ce qui reste le cas general.
##
## L'epicerie s'en sert : les courses etaient un bouton qui faisait monter la
## famille sans rien prelever, donc on pouvait le marteler sur place. Un geste
## qui ne coute rien n'est pas un choix — c'est la regle numero deux du projet.
##
## Comme `donne`, ce champ est une DONNEE : le point ne touche pas a la bourse,
## il annonce son prix et le controleur decide. Un point qui saurait retirer de
## l'argent saurait aussi le rendre, et on aurait deux caisses.
@export var coute: int = 0

## Le mecanisme sonore joue quand ca marche. Vide = silencieux.
##
## Un nom de la banque — voir donnees/sons.json — jamais un fichier.
@export var son: String = ""

## CE QU'IL FAUT AVOIR SUR SOI pour que ce point se propose. Vide = rien.
##
## Le pendant exact de `donne` : l'acheteur de marchandise ne s'affiche que si
## l'on a de quoi lui vendre. Sans ce champ, on lit « Livrer la marchandise »
## les mains vides et on appuie pour rien — l'invite promet alors quelque chose
## qu'elle ne peut pas tenir.
##
## Ce n'est PAS le point qui consomme l'objet : il annonce son evenement, et le
## scenario decide. Un point qui viderait l'inventaire saurait aussi le
## remplir, et on aurait deux inventaires.
@export var exige: String = ""

## Le point n'existe QUE pendant cette etape de la mission. Vide = toujours.
##
## C'est ce qui empeche de cuisiner avant d'etre arrive, et de vider la
## cachette pendant le premier dialogue. Sans lui, chaque point devrait
## interroger la mission lui-meme, et la moitie oublierait.
@export var etape: String = ""

## Le point existe A PARTIR de cette etape, et ne disparait plus ensuite.
##
## C'est ce qu'il fallait a la porte du camping-car. Elle portait `etape`, donc
## elle n'existait QUE pendant l'etape « entrer dans le camping-car » : une fois
## dedans l'etape changeait, et ressortir laissait le joueur devant un
## camping-car qu'il ne pouvait plus ouvrir. Une porte qui ne s'ouvre qu'une
## fois n'est pas une porte.
##
## Les deux champs se cumulent quand ils sont poses tous les deux.
@export var etape_minimale: String = ""

## Un refus affiche au lieu d'agir. Le volant du camping-car s'en sert : il
## faut pouvoir appuyer et s'entendre dire non, sinon on croit a un bug.
@export var refus: String = ""

## Une conversation a lancer. La porte du QG s'en sert : on frappe, le garde
## repond, et c'est la conversation qui decide de la suite.
@export var dialogue: String = ""

## Ou l'on ressort, si ce point est une porte. Zero = on ne bouge pas.
##
## Les portes du camping-car et du QG passent par ici plutot que par un
## Passage : un passage se franchit en marchant dessus, et le scenario veut
## qu'on APPUIE sur E devant une porte.
@export var emmene_a: Vector3 = Vector3.ZERO
@export var cap_degres: float = 0.0

## OU L'ON RESSORT, quand ce n'est pas une coordonnee mais un ENDROIT.
##
## Le nom d'un noeud du monde, cherche a l'instant du passage. Il l'emporte sur
## `emmene_a`, qui reste bon pour les lieux poses a la main.
##
## POURQUOI CE CHAMP EXISTE. Une coordonnee ecrite a la main qui vise un decor
## GENERE est juste tant que rien ne bouge, et personne ne saura le jour ou
## quelque chose bougera. La sortie du camping-car en portait une, calculee
## dans un commentaire a partir du desert, d'une mesa et d'un decalage : trois
## nombres dont deux appartiennent au generateur.
##
## ET LE NOM VISE DOIT ETRE UNIQUE DANS TOUT LE JEU. La recherche rend le
## PREMIER noeud du nom demande : viser « PorteCampingCar » depuis ici tombait
## sur celui de la mission de rodage, a cent metres de la clairiere. Le piege
## est deja ecrit dans test_mission.gd, et il a ete repaye le 23/08/2026.
@export var emmene_vers: String = ""

## Le nom du lieu ou l'on arrive, annonce a la mission.
@export var zone: String = ""

## Arrive-t-on DANS un endroit clos ?
##
## La camera de poursuite se rapproche alors, et les pas sonnent comme a
## l'interieur. Sans ce reglage, on entre dans un camping-car de deux metres
## quarante de large avec une camera posee quatre metres derriere : elle passe
## a travers la paroi, on ne voit plus que du decor retourne, et le personnage
## parait coince alors qu'il marche normalement.
@export var interieur: bool = false

## Disparait-il une fois utilise ? Vrai pour tout ce qui se ramasse.
@export var une_fois: bool = true

## Distance a laquelle on peut agir, en metres.
@export_range(0.5, 6.0, 0.1) var portee: float = 2.2

## ON PEUT LE FAIRE DE N'IMPORTE OU. La portee ne s'applique plus.
##
## Un seul geste du jeu en a besoin, et c'est celui qui a motive ce champ :
## retirer le masque a gaz. « L'option "retirer le masque" n'est cliquable que
## devant le RV. Elle devrait l'etre depuis n'importe ou. » — retour du
## 23/08/2026.
##
## Ce n est pas un point pose quelque part : c'est quelque chose que Walter
## porte sur le visage. Lui donner une portee revenait a dire qu'on ne peut
## retirer son propre masque qu'a six metres d'un endroit precis.
##
## Un champ plutot qu'une portee enorme : « portee = 400 » aurait le meme effet
## et ne dirait pas pourquoi — et la plage de l'inspecteur s'arrete a 6.
@export var partout: bool = false

## CE GESTE SE FAIT-IL ASSIS AU VOLANT ?
##
## Un point ordinaire se propose a pied, quand on est assez pres. Celui-ci fait
## l'inverse : il n'existe QUE pour qui conduit, et jamais pour un pieton.
##
## C'est le demarrage du camping-car. Il etait un point comme un autre, donc on
## tournait la cle depuis l'exterieur, derriere le vehicule — « j'ai du aller
## dans le cul du camping, c'est bizarre ». Le geste supposait le poste de
## conduite et rien ne l'exigeait.
##
## La portee ne s'applique plus : on est dedans, on atteint le tableau de bord.
@export var au_volant: bool = false

## CET OBJET SE SIGNALE-T-IL TOUT SEUL ?
##
## Le script le demande pour les trois preuves du fosse : « trois objets au sol,
## REPERABLES PAR SURBRILLANCE AU SURVOL ». C'est le seul endroit du jeu ou l'on
## cherche des objets menus, de nuit, dans du sable de la meme couleur qu'eux —
## et le premier essai en jeu l'a confirme : « je vois bien les trois, mais je
## les traverse ».
##
## CE N'EST PAS GLOBAL, ET C'EST VOLONTAIRE. Allumer tous les points du jeu
## ferait briller les portes, l'atelier et la boite a gants, c'est-a-dire des
## choses qu'on trouve tres bien sans aide. Un objet perdu dans le decor le
## declare ; le reste ne change pas.
@export var surbrillance: bool = false

## COMBIEN D'APPUIS AVANT QUE CA PRENNE.
##
## 1, c'est-a-dire tout de suite, pour tous les points du jeu sauf un : le
## demarrage du camping-car dans le fosse. Le script de Guillaume y demande
## « le moteur tousse a la premiere tentative, 2 a 3 appuis, jamais plus
## (reussite forcee au 3e) ».
##
## Le nombre exact est tire au premier appui, entre 2 et cette valeur. Deux
## bornes, et chacune porte une intention :
##
##   - JAMAIS 1, parce qu'un moteur qui part du premier coup ne raconte rien.
##     C'est le seul moment de la mission ou le jeu resiste, et Jesse hurle
##     par-dessus ;
##   - JAMAIS PLUS DE 3, parce qu'au-dela le joueur cesse de croire que ca va
##     marcher et commence a chercher ce qu'il fait de travers. Guillaume ecrit
##     « jamais plus », et c'est une regle de rythme, pas une approximation.
##
## Un point qui rate ne se consomme PAS : il rend son message comme n'importe
## quel refus, et se represente. Tout le mecanisme etait deja la.
@export var essais: int = 1

## Ce qu'on annonce tant que ca n'a pas pris.
@export var essai_rate: String = ""

## Le bruit d'un essai qui ne prend pas, et la hauteur a laquelle on le joue —
## le meme demarreur, joue plus grave, s'entend comme un moteur qui peine.
@export var son_rate: String = ""
@export var hauteur_rate: float = 1.0

## CE GESTE FAIT-IL MONTER LA SIRENE, ET JUSQU'OU ? Zero = il n'y touche pas.
##
## La montee de la sequence A est portee par les ETAPES : chacune declare son
## niveau, et le fichier de mission se lit comme une partition. Guillaume en
## nomme trois qui comptent — « le premier objet, le dernier objet, LES CORPS ».
##
## Les deux premieres sont des etapes. La troisieme ne l'est plus : le meme
## retour sort les corps du suivi de mission, donc plus rien dans le deroule ne
## sait qu'on est alle les voir. Sans ce champ, le seul des trois moments que
## Guillaume cite en dernier serait le seul a ne rien faire monter.
##
## C'EST UN PLANCHER, PAS UN NIVEAU. La sirene continue de suivre l'etape ; ce
## point l'empeche seulement de redescendre en dessous. Un niveau ferme aurait
## fait retomber le son a l'etape suivante, c'est-a-dire tout de suite.
@export_range(0.0, 1.0, 0.01) var sirene: float = 0.0

## Tous les points sont dans ce groupe, et c'est ainsi que le controleur les
## trouve. La mission en pose une dizaine repartis dans quatre decors : les
## enumerer a la main dans l'inspecteur garantirait d'en oublier un, et un
## point oublie est une etape que rien ne peut plus franchir.
const GROUPE := "point"

var _fait: bool = false

# Combien d'appuis on a deja donnes, et combien il en faut — tire au premier,
# pour que deux parties ne se ressemblent pas exactement.
var _essais_faits: int = 0
var _essais_requis: int = 0
var _a_rate: bool = false


func _ready() -> void:
	add_to_group(GROUPE)


func fait() -> bool:
	return _fait


## Le dernier declencher() a-t-il rate faute d'essais ? Le controleur s'en sert
## pour distinguer ce cas d'un refus ordinaire : les deux rendent un message,
## mais un seul des deux a un bruit a jouer.
func a_rate() -> bool:
	return _a_rate


## Ce point est-il proposable maintenant ? Il faut etre assez pres, ne pas
## l'avoir deja consomme, et etre a la bonne etape.
func offert(joueur: Node3D, mission: Mission) -> bool:
	if not disponible(mission):
		return false
	if joueur == null:
		return false
	if partout:
		return true
	return joueur.global_position.distance_to(global_position) <= portee


## EXISTE-T-IL EN CE MOMENT, sans regarder ou se trouve le joueur ?
##
## C'est « offert » moins la distance, et la separation n'est pas cosmetique.
## La surbrillance des objets a ramasser doit se voir DE LOIN — c'est meme tout
## ce qu'on lui demande, puisque le probleme est de les trouver. Ecrite sur
## « offert », elle ne se serait allumee qu'une fois le joueur a portee,
## c'est-a-dire une fois l'objet deja trouve : un phare qui ne s'allume qu'au
## port.
func disponible(mission: Mission) -> bool:
	if _fait and une_fois:
		return false
	if not visible:
		return false
	if etape != "" and (mission == null or not mission.a_l_etape(etape)):
		return false
	if etape_minimale != "":
		if mission == null:
			return false
		if not mission.a_l_etape(etape_minimale) \
				and not mission.passee(etape_minimale):
			return false
	return true


func distance(joueur: Node3D) -> float:
	if joueur == null:
		return INF
	return joueur.global_position.distance_to(global_position)


## On s'en sert. Renvoie le refus s'il y en a un — l'appelant l'affiche alors
## en bandeau au lieu de declencher quoi que ce soit.
func declencher() -> String:
	_a_rate = false
	if refus != "":
		return refus
	# CA NE PREND PAS ENCORE. On rend un message sans rien consommer : le point
	# reste offert, le joueur reappuie, et l'etape n'avance pas.
	if essais > 1:
		if _essais_requis == 0:
			_essais_requis = randi_range(2, essais)
		_essais_faits += 1
		if _essais_faits < _essais_requis:
			_a_rate = true
			return essai_rate
	_fait = true
	if une_fois:
		visible = false
	utilise.emit(self)
	return ""


## Tout remettre en place. Recommencer une partie doit redonner un atelier
## utilisable et une boite a gants pleine.
func reinitialiser() -> void:
	_fait = false
	visible = true
	# Y COMPRIS LE COMPTEUR D'ESSAIS. Sans ca, recommencer une partie laissait
	# le moteur demarrer du premier coup, parce qu'il avait deja tousse.
	_essais_faits = 0
	_essais_requis = 0
	_a_rate = false
