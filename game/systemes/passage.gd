# Un passage : une zone qu'on franchit pour arriver ailleurs.
#
# Il ne teleporte rien lui-meme. Il constate qu'on est dedans, et le dit au
# controleur — qui seul sait s'il faut emmener la voiture, ou refuser parce
# qu'on est a pied. Un declencheur qui deplacerait le joueur devrait connaitre
# l'etat du jeu, et cet etat vit deja ailleurs.
#
# On SCRUTE plutot que d'ecouter body_entered.
#
# La raison est mesurable : le joueur au volant est desactive — process_mode a
# DISABLED, capsule retiree du monde physique — et ce n'est donc pas lui qui
# entre dans la zone, c'est le vehicule. Un signal branche sur le mauvais corps
# ne se declenche jamais, et rien ne le signale. En demandant a la zone ce
# qu'elle contient, on lit la verite du moment quel que soit l'etat.
class_name Passage
extends Area3D

## Ou l'on ressort, en coordonnees du monde.
@export var destination: Vector3 = Vector3.ZERO

## Dans quelle direction on regarde en arrivant, en degres.
@export var cap_degres: float = 0.0

## Faut-il un vehicule ? Le passage vers le desert l'exige ; celui du retour
## non, sinon quelqu'un qui descend de voiture reste coince la-bas.
@export var exige_vehicule: bool = true

## Ce qu'on affiche a pied quand le vehicule est exige.
@export var refus: String = "Vous devez etre en voiture pour vous rendre ici"

## Le nom du lieu ou l'on arrive, annonce a la mission. Vide = on ne dit rien,
## ce qui est le cas des passages de retour : revenir en ville ne fait avancer
## aucun objectif.
@export var zone: String = ""

## L'HEURE A LAQUELLE ON ARRIVE, de 0 a 24. Negatif = on ne touche a rien.
##
## Un passage n'est pas toujours un deplacement : celui qui ouvre le flashback
## de « Deux corps » fait reculer l'histoire de trois semaines, et le script
## decrit ce qu'on doit y trouver — « desert, JOUR, chaleur, lumiere crue ».
##
## Sans ca, on franchissait la crete a 21h30 et on cuisinait dans le noir. Le
## fondu au noir est deja la, il ne restait qu'a changer le moment derriere.
@export var heure: float = -1.0

## UNE CONVERSATION QUI SE JOUE AU FRANCHISSEMENT — AVANT le fondu, sur place.
## Vide = on part en silence, ce qui reste le cas de tous les autres passages.
##
## C'est le seul manque que le JSON de « Deux corps » signalait lui-meme :
## « la conversation existe et elle est doublee — trois repliques, cle
## crash_pompiers. Il lui manque un declencheur automatique a l'entree de zone.
## C'est le seul endroit du deroule qui demande du code. »
##
## Le battement A9 est une CINEMATIQUE : on franchit la crete, la sirene se
## revele etre un camion de pompiers, et les trois repliques tombent toutes
## seules. Or rien dans le jeu n'ouvrait une conversation sans qu'on appuie sur
## quelque chose — et en faire une etape validee par « dialogue:crash_pompiers »
## aurait bloque le joueur pour toujours, puisque personne n'aurait pu la lancer.
##
## Un passage sait deja qu'on vient d'arriver quelque part. Il lui manquait le
## droit de le dire autrement qu'en nommant une zone.
@export var dialogue: String = ""

## UNE CINEMATIQUE JOUEE AU FRANCHISSEMENT, par son nom de fichier.
##
## Le battement A9 n'est pas une conversation : « le RV avance, camera face au
## RV et qui le suit [...] il se met a ne plus rouler droit et finit sa course
## sur le cote de la route [...] LONG PLAN ou on VOIT le camion de pompier
## rouler sur la route, passer devant Walter et Jesse ». C'est une suite de
## plans, avec un vehicule qui traverse le champ — rien de tout ca ne rentre
## dans un cadre de dialogue.
##
## Elle passe AVANT le fondu et avant le carton : on regarde la scene, puis le
## noir, puis « Trois semaines plus tot ».
@export var cinematique: String = ""

## Ce passage n'existe qu'a partir de cette etape de la mission. C'est ce qui
## empeche d'aller chez Tuco avant d'avoir la marchandise — et le refus
## ci-dessous explique pourquoi, au lieu de laisser croire a un decor ferme.
@export var etape_minimale: String = ""
@export var refus_etape: String = ""

## ET IL CESSE D'EXISTER UNE FOIS CETTE ETAPE PASSEE. Vide = il reste ouvert.
##
## LE PENDANT DE `jusqu_a_etape` SUR LES DECORS, et il manquait. Masquer un
## decor ne desactive pas ses zones : Godot ne coupe que le rendu, et la boucle
## des passages ne regarde pas la visibilite. La crete du flashback restait donc
## scrutee apres avoir ete franchie, invisible et active.
##
## Elle est a 96 metres de la clairiere — pas neuf cents, comme trois
## commentaires de ce depot l'affirment ; mesure du 23/08/2026. A pied on n'y
## retourne pas par hasard ; en camping-car, c'est quelques secondes. Or on
## arrivait justement au volant.
##
## Repasser dessus rejouait tout : le fondu, la teleportation « sur la route »,
## le carton « Trois semaines plus tot » et le dialogue des pompiers. C'est le
## dernier morceau du bug de Guillaume, et celui qui explique sa phrase — « puis
## le script that is not them, it's the firetruck s'est lance ».
@export var etape_maximale: String = ""


## Tous les passages se declarent ici. Le controleur, lui, recoit sa liste par
## l'inspecteur ; le groupe sert a les INVENTORIER — notamment pour verifier
## que chaque zone attendue par la mission a bien quelqu'un pour l'annoncer.
const GROUPE := "passage"

## OU L'ON ARRIVE, PAR NOM DE LIEU plutot que par coordonnees. Vide = c'est
## `destination` qui decide.
##
## Un lieu nomme se recalcule a chaque generation de la ville ; une coordonnee
## ecrite a la main se perime au premier elargissement de chaussee — c'est
## arrive deux fois au panneau du desert, et une fois de plus ici. Le retour du
## desert deposait le joueur a quatre cents metres de la sortie, en pleine
## ville : « un peu au milieu d'une route », dit le retour du 23/08/2026.
@export var destination_lieu: String = ""

## Decalage applique DANS LE REPERE DU LIEU, l'avant etant -Z comme pour tout
## noeud Godot. « Quinze metres devant la sortie » reste devant elle quel que
## soit le sens de la route.
@export var destination_decalage: Vector3 = Vector3.ZERO

## Prendre aussi le cap du lieu, au lieu de `cap_degres`. On arrive alors
## tourne comme la rue, pas comme un axe du monde.
@export var destination_cap_du_lieu: bool = false

## OU L'ON ARRIVE, PAR NOM DE NOEUD. Le plus fort des trois : il l'emporte sur
## `destination_lieu` comme sur `destination`.
##
## La difference avec `destination_lieu` compte : celui-la vise un lieu de la
## carte et lui applique un decalage, celui-ci vise **exactement l'endroit ou
## une chose est**. Quand la cible est un decor ancre — donc pose relativement
## a un lieu, avec son propre decalage et sa propre regle de cap — recalculer
## le meme point de deux facons revient a tenir deux comptes qui divergeront.
##
## La crete du flashback en est l'exemple : sa destination etait ecrite
## (843, 1, -708), avec le calcul en commentaire — desert, plus mesa 3, plus le
## decalage de la clairiere. Elle tombait juste, a trois metres du camping-car.
## Mais elle additionnait trois nombres dont deux appartiennent a un decor
## GENERE : elle etait juste tant que rien ne bougeait, et rien n'aurait
## signale le jour ou quelque chose bouge.
##
## LE NOM VISE DOIT ETRE UNIQUE DANS TOUT LE JEU. La recherche rend le PREMIER
## noeud du nom demande, et le jeu contient deux « PorteCampingCar », deux
## « Sortie » et plusieurs « Porte ».
##
## Il se resout au FRANCHISSEMENT et non au chargement : un decor ancre n'est
## pas forcement pose quand le passage s'eveille.
@export var destination_vers: String = ""

## ON ARRIVE A PIED, ET LE VEHICULE RESTE OU IL ETAIT.
##
## Par defaut un passage emmene la voiture avec le joueur : c'est ce qu'on veut
## d'une route qui continue ailleurs. Ce n'est pas ce qu'on veut d'un SAUT DANS
## LE TEMPS.
##
## Le pire bug du retour du 23/08/2026 vient de la : « quand je suis sorti du
## camping car, je me suis retrouve sur la route, loin du camping car et
## surtout, il y avait sur la route, pres de moi, un AUTRE camping car (2 dans
## la meme vue) ». La crete du flashback se franchit AU VOLANT — trois secondes
## de roulage, c'est sa condition — donc le camping-car accidente de la sequence
## A etait teleporte avec le joueur, et se garait a cote de celui de la
## clairiere. Trois semaines plus tot, avec le vehicule des trois semaines plus
## tard.
##
## Il ne se masque pas : il RESTE ou il etait, a neuf cents metres, hors de vue.
## Le faire disparaitre serait un tour de passe-passe ; ne pas l'emmener est
## simplement ce qui aurait du se produire.
@export var a_pied: bool = false

## IL FAUT ROULER DEPUIS TANT DE SECONDES POUR QUE CA SE DECLENCHE.
##
## Zero = le passage se franchit des qu'on entre dedans, comme tous les autres.
##
## « On ne devrait pas sortir pour declencher la suite, on ne comprend pas. Le
## mieux serait de declencher une cinematique des qu'on se trouve les 4 roues
## sur la route et qu'on roule pendant au moins 3 secondes. » — retour du
## 23/08/2026, a propos de la sortie du fosse.
##
## CE QUE CA CHANGE POUR LE JOUEUR : il n'y a plus de ligne invisible a
## franchir. On monte sur la piste, on roule, et la scene part. Personne ne
## cherche ou est la limite, parce qu'il n'y en a plus.
##
## ET LE COMPTEUR NE S'ARRETE PAS AU BORD DE LA ZONE. C'est la reparation du
## 04/09/2026, et elle vaut d'etre lue avant de toucher a ceci.
##
## La zone de la sortie du fosse fait 26 m de long et exigeait trois secondes
## de roulage DEDANS. Or 26 m se traversent en 1,25 s a 75 km/h : au-dessus de
## 31 km/h, la condition ne pouvait plus etre remplie DU TOUT — et la piste se
## prend a 75. Le franchissement exigeait en plus d'etre encore dans la zone au
## moment ou le compte finit, ce qui ajoutait un second verrou par-dessus le
## premier. Benjamin, manette en main : « je continue sur la route et ca
## declenche rien ».
##
## UNE DUREE CROISEE AVEC UNE ZONE DE LONGUEUR FIXE FABRIQUE UN SEUIL DE
## VITESSE QUE PERSONNE N'ECRIT. Allonger la zone n'aurait fait que deplacer le
## seuil, et il serait revenu le jour ou la piste change ou ou un vehicule va
## plus vite.
##
## Donc : la zone dit QUAND ON COMMENCE a compter, et plus rien d'autre. Une
## fois entame, le compte suit le joueur tant qu'il roule, dedans ou dehors.
## C'est mot pour mot ce que Guillaume demandait — « des qu'on se trouve les 4
## roues sur la route et qu'on roule pendant au moins 3 secondes ».
@export var roule_depuis: float = 0.0

## Vitesse minimale pour que ces secondes comptent, en km/h. En dessous, on
## est a l'arret sur la piste — ce qui n'est pas « rouler ».
@export var vitesse_minimale: float = 8.0

## ON A COMMENCE A ROULER DEDANS, et le compteur part.
##
## POURQUOI CES DEUX SIGNAUX EXISTENT. La sortie du fosse se declenchait en
## franchissant une ligne invisible ; Guillaume l'a dit — « on ne devrait pas
## sortir pour declencher la suite, on ne comprend pas ». On l'a remplacee par
## un temps de roulage, et on a remplace une chose invisible PAR UNE AUTRE : le
## code dit lui-meme « rien ne s'affiche, parce qu'il n'y a rien a corriger ».
##
## Le 23/08/2026 a 23 h 24, Guillaume : « j'arrive pas a declencher les
## pompiers, je vais sur la piste mais ca declenche rien. » Ca marchait — il ne
## roulait simplement pas assez longtemps d'affilee, et RIEN ne le lui disait.
##
## Un compte a rebours de trois secondes n'a pas besoin d'etre affiche. Il a
## besoin que quelqu'un dans la voiture reagisse.
signal commence

## On s'est arrete ou on est sorti avant la fin, et le compteur retombe a zero.
signal interrompu

## Depuis combien de temps on roule. Remis a zero des qu'on s'arrete.
var _roule: float = 0.0

## Le compte a-t-il ete ENTAME DANS LA ZONE ? C'est la seule chose que la zone
## decide desormais. Sans ce drapeau, rouler n'importe ou dans le desert
## ouvrirait la sortie.
var _entame: bool = false


## Compte le temps de roulage, et dit si la condition est remplie. Appele a
## chaque image par le controleur, pour le vehicule qu'il conduit.
##
## `dedans` n'est requis que pour COMMENCER. Voir roule_depuis pour pourquoi.
func rouler(dedans: bool, vitesse_kmh: float, delta: float) -> bool:
	if roule_depuis <= 0.0:
		return true

	# ON S'EST ARRETE. Le compteur retombe, et quelqu'un le DIT — voir les
	# signaux plus haut pour ce que ce silence a coute.
	if vitesse_kmh < vitesse_minimale:
		if _roule > 0.35:
			interrompu.emit()
		_roule = 0.0
		_entame = false
		return false

	# ON ROULE, MAIS ON N'A PAS COMMENCE DANS LA ZONE. Rien ne se compte, et il
	# n'y a rien a annoncer : le joueur roule ailleurs, c'est tout.
	if not _entame and not dedans:
		return false

	if _roule <= 0.0:
		_entame = true
		commence.emit()
	_roule += delta
	return _roule >= roule_depuis


## A-t-on roule assez longtemps pour que ce passage s'ouvre ? Vrai d'office
## pour les passages qui ne demandent rien.
func roule_assez() -> bool:
	return roule_depuis <= 0.0 or _roule >= roule_depuis


## LE COMPTE EST FINI, ET IL A ETE ENTAME ICI — donc ce passage s'ouvre meme si
## on a quitte sa zone entre-temps.
##
## C'est l'autre moitie de la reparation du 04/09/2026 : le controleur exigeait
## `contient(corps)` pour franchir, ce qui remettait exactement le verrou qu'on
## venait d'enlever. A 75 km/h, le compte finit toujours hors de la zone.
func roule_ouvert() -> bool:
	return roule_depuis > 0.0 and _entame and _roule >= roule_depuis


## Depuis combien de temps on roule dedans, en secondes. Pour les
## verifications : un compte a rebours qui ne se lit pas ne se mesure qu'a ses
## effets, donc trop tard.
func temps_de_roulage() -> float:
	return _roule


## Remet le compteur a zero. Sert quand on recommence la mission.
func cesser_de_rouler() -> void:
	_roule = 0.0
	_entame = false


## UN CARTON PLEIN ECRAN A L'ARRIVEE. Vide = on arrive directement.
##
## « Le titre "3 semaines plus tot" doit apparaitre a la fin de la
## cinematique. Sur un fond noir pendant quelques secondes et non en jeu.
## C'est une vraie pause. » Le saut de trois semaines etait annonce par un
## bandeau de tuto, en haut a gauche, de la meme forme que « E pour
## interagir » — c'est-a-dire de la meme forme qu'une consigne de touche.
@export var carton: String = ""


func _ready() -> void:
	add_to_group(GROUPE)
	if destination_lieu == "":
		return
	var fiche := Ancrage.trouver(destination_lieu)
	if fiche.is_empty():
		push_error("passage : aucun lieu nomme '%s'" % destination_lieu)
		return
	var p: Array = fiche.get("pos", [0, 0, 0])
	var cap_lieu := float(fiche.get("cap", 0.0))
	destination = Vector3(float(p[0]), float(p[1]), float(p[2])) \
			+ destination_decalage.rotated(Vector3.UP, cap_lieu)
	if destination_cap_du_lieu:
		cap_degres = rad_to_deg(cap_lieu)


func cap() -> float:
	return deg_to_rad(cap_degres)


## Ce corps est-il dans la zone ? On passe le corps plutot que de chercher un
## type : le controleur sait qui conduit, le passage n'a pas a le deviner.
func contient(corps: Node3D) -> bool:
	if corps == null:
		return false
	for c in get_overlapping_bodies():
		if c == corps:
			return true
	return false


## OU L'ON ARRIVE VRAIMENT, resolu maintenant.
##
## Trois sources, de la plus forte a la plus faible : un noeud vise, un lieu de
## la carte, une coordonnee ecrite. On rend toujours quelque chose — si le noeud
## nomme est introuvable, on retombe sur ce qui etait prevu plutot que de
## deposer le joueur a l'origine du monde.
func ou(depuis: Node) -> Vector3:
	if destination_vers == "":
		return destination
	var racine: Node = depuis.get_tree().current_scene
	if racine == null:
		racine = depuis.get_tree().root
	var cible := racine.find_child(destination_vers, true, false) as Node3D
	if cible == null:
		push_error("passage : '%s' introuvable, on retombe sur la coordonnee"
				% destination_vers)
		return destination
	return cible.global_position
