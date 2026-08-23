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

## Ce passage n'existe qu'a partir de cette etape de la mission. C'est ce qui
## empeche d'aller chez Tuco avant d'avoir la marchandise — et le refus
## ci-dessous explique pourquoi, au lieu de laisser croire a un decor ferme.
@export var etape_minimale: String = ""
@export var refus_etape: String = ""


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
@export var roule_depuis: float = 0.0

## Vitesse minimale pour que ces secondes comptent, en km/h. En dessous, on
## est a l'arret sur la piste — ce qui n'est pas « rouler ».
@export var vitesse_minimale: float = 8.0

## Depuis combien de temps on roule dans cette zone. Remis a zero des qu'on en
## sort ou qu'on s'arrete.
var _roule: float = 0.0


## Compte le temps passe a rouler dedans, et dit si la condition est remplie.
## Appele a chaque image par le controleur, pour le vehicule qu'il conduit.
func rouler(dedans: bool, vitesse_kmh: float, delta: float) -> bool:
	if roule_depuis <= 0.0:
		return true
	if not dedans or vitesse_kmh < vitesse_minimale:
		_roule = 0.0
		return false
	_roule += delta
	return _roule >= roule_depuis


## A-t-on roule assez longtemps pour que ce passage s'ouvre ? Vrai d'office
## pour les passages qui ne demandent rien.
func roule_assez() -> bool:
	return roule_depuis <= 0.0 or _roule >= roule_depuis


## Depuis combien de temps on roule dedans, en secondes. Pour les
## verifications : un compte a rebours qui ne se lit pas ne se mesure qu'a ses
## effets, donc trop tard.
func temps_de_roulage() -> float:
	return _roule


## Remet le compteur a zero. Sert quand on recommence la mission.
func cesser_de_rouler() -> void:
	_roule = 0.0


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
