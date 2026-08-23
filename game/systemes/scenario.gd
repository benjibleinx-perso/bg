# Ce qui est PROPRE a la mission 1.
#
# Le controleur sait marcher, conduire, entrer, parler. Il ne sait pas qu'un
# homme de Tuco appelle cinq secondes apres qu'on sort de chez soi, ni que
# tirer sur Skyler termine la partie. Tout cela vit ici.
#
# La separation vaut le fichier de plus. Le controleur fait deja six cents
# lignes et il est le seul endroit ou l'on bascule entre marcher et conduire :
# y verser un scenario reviendrait a melanger ce qui vaudra pour toutes les
# missions avec ce qui ne vaut que pour celle-ci — et la deuxieme mission
# devrait alors demeler les deux.
#
# Ce script ecoute, decide, et redonne la main. Il ne dessine rien et ne
# deplace personne : il annonce des evenements a la mission, joue des sons, et
# demande au controleur de faire ce qu'il sait deja faire.
class_name Scenario
extends Node

## Delai avant l'appel de l'homme de Tuco, une fois sorti de chez Walter.
const AVANT_L_APPEL := 5.0

## Combien de temps Tuco patiente avant de faire tirer, une fois la botte
## secrete decouverte. Le scenario dit une minute.
const PATIENCE_DE_TUCO := 60.0

## Entre deux repliques de menace, quand le joueur ne fait rien.
const ENTRE_DEUX_MENACES := 7.0

## Le silence entre la fin de « this is not meth » et la deflagration, en
## secondes. Court : c'est un temps de suspension, pas une pause.
const APRES_LA_REPLIQUE := 0.45

## L'HEURE DE LA MISSION, lieu par lieu.
##
## Le scenario est explicite : on part en journee, on arrive dans le desert en
## fin d'apres-midi, et il fait le meme jour finissant chez Tuco. Le jeu
## demarrait a l'heure du fichier monde.json — la nuit, par defaut — ce qui
## faisait une mission entiere jouee dans le noir et des references visuelles
## qui ne correspondaient a rien.
##
## Elle est POSEE AUX ARRIVEES, pas avancee en continu : un cycle qui tourne
## ferait finir la scene de Tuco en pleine nuit selon le temps qu'on met a y
## aller, et le crepuscule est ici une intention de mise en scene.
const HEURES := {
	"camping": 17.4,
	"qg": 18.6,
}

@export var mission: NodePath
@export var joueur: NodePath
@export var controleur: NodePath

## L'homme de main qui vient fouiller Walter chez Tuco. C'est l'un des trois
## qui attendent derriere le joueur : celui du milieu.
@export var garde_fouilleur: NodePath

## D'ou recharger l'etat quand le joueur reprend apres une mort.
@export var sauvegarde: NodePath

var _mission: Mission
var _joueur: Joueur
var _controleur: Node
var _dialogue: Dialogue

## Walter a le mot de la fin, une fois le bandeau efface.
var _fin_a_dire := false
var _telephone: Telephone
var _bourse: Bourse
var _tir: Tir
var _fin: FinDePartie
var _sauvegarde: Sauvegarde
var _cachette: Cachette
var _equipement: Equipement
var _audio: Audio

## Compte a rebours de l'appel d'ouverture. Negatif = deja passe.
var _appel: float = -1.0
var _sorti_de_chez_lui: bool = false

## La scene finale chez Tuco.
var _patience: float = -1.0
var _menace: float = 0.0

## Les reactions aux tirs. Elles vivent ici plutot qu'en donnees parce
## qu'elles sont des REGLES DE SCENARIO, pas des reglages : « ne tuez pas
## votre femme tout de suite » n'a de sens que dans cette mission-la.
const TIRS := {
	"skyler": "Je sais que c'est tentant, mais ne tuez pas votre femme tout de suite",
	"jesse": "Jesse est mort",
	"mission_jesse_camping": "Jesse est mort",
	"garde": "Il n'etait pas seul",
	"tuco": "Personne ne braque Tuco Salamanca",
}


func brancher(dialogue: Dialogue, telephone: Telephone, tir: Tir,
		fin: FinDePartie, cachette: Cachette, equipement: Equipement) -> void:
	_dialogue = dialogue
	_telephone = telephone
	_tir = tir
	_fin = fin
	_cachette = cachette
	_equipement = equipement


func _ready() -> void:
	_mission = get_node_or_null(mission) as Mission
	_joueur = get_node_or_null(joueur) as Joueur
	_controleur = get_node_or_null(controleur)
	_sauvegarde = get_node_or_null(sauvegarde) as Sauvegarde
	call_deferred("_commencer")


func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio


func _commencer() -> void:
	_bourse = Bourse.courante(self)
	# Retenue AVANT tout : c'est l'heure du monde au chargement, celle sur
	# laquelle on retombe si la mission n'en impose aucune.
	_heure_de_depart = Reglages.heure
	if _mission == null:
		return
	var voulue := _mission.heure_de_depart()
	if voulue >= 0.0:
		_heure_de_depart = voulue
	if _telephone != null:
		_telephone.suivre(_mission)
	_mission.etape_changee.connect(_sur_etape)
	_mission.accomplie.connect(_sur_victoire)
	if _joueur != null:
		_joueur.mort.connect(_sur_mort)
	if _fin != null:
		_fin.recommence.connect(recommencer)
		_fin.reprendre.connect(reprendre_apres_mort)
	if _cachette != null:
		_cachette.range.connect(_sur_argent_cache)
	if _tir != null:
		_tir.touche.connect(_sur_tir_sur_quelqu_un)
	if _dialogue != null:
		_dialogue.effet.connect(_sur_effet)
	_brancher_le_demarreur()
	_installer()
	# La PREMIERE etape n'emet aucun changement — on y est deja. Son objectif
	# et son conseil ne s'affichaient donc jamais, et la partie s'ouvrait sur un
	# salon sans rien dire de ce qu'on attend du joueur.
	_sur_etape(0)


# LE MINI-JEU DU DEMARRAGE, s'il est dans la scene.
#
# Il vit dans le decor du fosse, qui est instancie a l'execution : on le
# cherche par son groupe plutot que par un chemin, et son absence n'est pas
# une erreur — toutes les missions n'ont pas de vehicule a demarrer.
func _brancher_le_demarreur() -> void:
	for n in get_tree().get_nodes_in_group(Demarreur.GROUPE):
		var d := n as Demarreur
		if d == null:
			continue
		if not d.reussi.is_connected(_sur_moteur_lance):
			d.reussi.connect(_sur_moteur_lance)
		if not d.rate.is_connected(_sur_demarrage_rate):
			d.rate.connect(_sur_demarrage_rate)


# LE MOTEUR A PRIS. C'est la reussite du geste qui vaut evenement, plus un
# appui sur un point : l'epave se reveille et la mission avance.
func _sur_moteur_lance() -> void:
	_reveiller_l_epave()
	if _mission != null:
		_mission.evenement("action:demarrer")


# ET QUAND CA NE PREND PAS, JESSE LE DIT.
#
# « Si le joueur se trompe : Son de moteur qui se noie [...] Jesse fait une
# remarque style "Mr. White, seriously !" » Le son est joue par le demarreur ;
# la phrase est ici, parce que savoir qui parle et quand est le travail du
# scenario.
func _sur_demarrage_rate(_zone: int) -> void:
	if _controleur != null:
		_controleur.call("annoncer", "Jesse : Mr. White, seriously !")


# L'etat de depart : l'argent du jour, et les mains presque vides.
func _installer() -> void:
	if _bourse != null:
		_bourse.poser(_mission.argent_de_depart())
	if _equipement != null:
		_equipement.definir_inventaire(_mission.objets_de_depart())
	_regler_l_heure(_heure_de_depart)
	_rendre_jesse_a_sa_maison()


## L'HEURE DU LANCEMENT, ET POURQUOI ELLE SE FORCE MAINTENANT.
##
## Elle ne pouvait pas l'etre. Trois choses etaient decidees a la construction
## du monde et n'en bougeaient plus : les vitres allumees, peintes dans la
## texture de facade ; la lumiere de porche, creee ou non selon l'heure ; les
## phares. Poser 12 h 30 apres coup donnait un ciel de midi au-dessus d'une
## facade a porche allume — le defaut exact que le cycle avait ete ecrit pour
## supprimer.
##
## Les trois ont ete reprises depuis : les vitres sont un masque d'emission que
## le jeu module, le porche est cree puis masque, les phares suivent l'heure.
## Une mission peut donc dire l'heure a laquelle elle se joue, et le monde s'y
## pose — voir Mission.heure_de_depart().
##
## Ce qui est retenu ici, c'est l'heure effectivement posee au lancement, pour
## pouvoir y revenir quand on recommence la mission apres etre passe par le
## desert.
var _heure_de_depart: float = -1.0


## Pose l'heure du monde. Le noeud Temps se trouve par son groupe : le scenario
## n'a pas a savoir ou il est declare dans la scene.
func _regler_l_heure(h: float) -> void:
	var t := get_tree().get_first_node_in_group(Temps.GROUPE) as Temps
	if t != null:
		t.regler(h)


func recommencer() -> void:
	_mission.recommencer()
	_appel = -1.0
	_sorti_de_chez_lui = false
	_patience = -1.0
	_menace = 0.0
	_installer()
	if _joueur != null:
		_joueur.ressusciter()
	for n in get_tree().get_nodes_in_group("point"):
		(n as Point).reinitialiser()
	for n in get_tree().get_nodes_in_group(Pnj.GROUPE):
		var p := n as Pnj
		p.abattu = false
		# Le garde de la fouille a traverse le bureau : il reprend sa place
		# sans marcher, sinon on le voit revenir pendant le premier plan.
		p.replacer()
	if _controleur != null:
		_controleur.call("recommencer_la_partie")


## Reprise apres une mort : on remet d'abord le jeu dans un etat jouable (comme
## recommencer - le joueur ressuscite, la scene se reinitialise), PUIS on
## recharge le dernier point par-dessus : argent, inventaire, position, heure,
## etape de mission. Une mort ne remet plus tout a zero.
func reprendre_apres_mort() -> void:
	recommencer()
	if _sauvegarde != null:
		_sauvegarde.recharger()


# ------------------------------------------------------------------ le fil


func _sur_etape(_index: int) -> void:
	# Le telephone SORT, montre l'objectif, et se range. C'est ce que demande
	# le scenario, et c'est aussi ce qui evite un bandeau de plus a l'ecran.
	# Pas au LANCEMENT : sortir un telephone sur la premiere image du jeu, dans
	# le salon, avant que quiconque ait appele, annonce une mission qui n'a pas
	# encore commence. L'objectif de depart s'affiche a l'ecran, ca suffit.
	if _telephone != null and not _mission.finie() and _mission.index() > 0:
		_telephone.annoncer()

	# LE CONSEIL ATTEND QU'ON SOIT DEHORS.
	#
	# « Direction le desert, il vous faut la voiture » s'affichait a la seconde
	# ou la conversation avec Jesse se terminait — donc dans son salon, avant
	# meme d'avoir franchi la porte. On dit au joueur de prendre sa voiture
	# alors qu'il est assis chez quelqu'un : le conseil arrive avant la
	# situation qu'il decrit, et il ne sert plus a rien quand elle arrive.
	#
	# On le garde en attente, et il sort au moment ou l'on met le pied dehors.
	_tuto_en_attente = _mission.prendre_le_tuto()
	_livrer_le_tuto()

	# L'etape ou Tuco decouvre la botte secrete : le compte a rebours part.
	#
	# ET SEULEMENT DANS LA MISSION DE RODAGE. Ce declencheur ne connait qu'un NOM
	# d'etape, pas la mission d'ou il vient. « Deux corps » avait aussi une etape
	# « fuir » — sortir du fosse au volant du camping-car — et le scenario y
	# lisait la fuite du QG : Tuco envoyait ses hommes en plein desert, on se
	# faisait tirer dessus, et on mourait dans une scene ou il n'y a personne.
	#
	# Les deux etapes ont ete renommees pour ne plus se croiser, mais un nom ne
	# se reserve pas : la prochaine mission qui aura une etape « fuir » referait
	# exactement ca. On demande donc AUSSI de quelle mission il s'agit.
	if _mission.fichier.ends_with("mission1.json") and _mission.a_l_etape("fuir"):
		_patience = PATIENCE_DE_TUCO
		_menace = ENTRE_DEUX_MENACES


## Le conseil en attente, s'il y en a un.
var _tuto_en_attente: String = ""


func _livrer_le_tuto() -> void:
	if _tuto_en_attente == "" or _controleur == null:
		return
	if _controleur.call("dedans"):
		return
	_controleur.call("annoncer", _tuto_en_attente)
	_tuto_en_attente = ""


func _sur_victoire() -> void:
	if _son() != null:
		_son().bruit("victoire")
	if _controleur != null:
		_controleur.call("annoncer_longtemps", "MISSION ACCOMPLIE")
	# LA MISSION SE TERMINE, WALTER A ENCORE QUELQUE CHOSE A DIRE.
	#
	# La replique existait dans dialogues.json sous la cle « mission_fin »,
	# ecrite et doublee, et n'etait appelee de NULLE PART — verifie le
	# 09/08/2026 : aucun .gd, aucun .tscn ne la nommait. La mission s'arretait
	# donc sur un bandeau en capitales, c'est-a-dire sur du vocabulaire de jeu.
	#
	# Ce qu'elle dit compte : il vient de vendre pour la premiere fois, et sa
	# premiere pensee est de CACHER. Ca conclut la mission et ca ouvre la suite
	# dans la meme phrase, sans rien promettre qui n'existe pas.
	#
	# ELLE N'APPARTIENT QU'A LA MISSION DE RODAGE, et il a fallu la voir tomber
	# ailleurs pour s'en apercevoir. « Deux corps » se termine sur une premiere
	# CUISINE : Walter n'a pas un dollar sur lui, il n'a rien a cacher, et la
	# replique arrivait quand meme — juste sur le signal « une mission vient de
	# finir », qui ne dit pas LAQUELLE.
	#
	# C'est le troisieme morceau de la mission de rodage a se declencher sur la
	# nouvelle, apres les tueurs de Tuco et le decompte. Le motif est toujours le
	# meme : un fil branche a une epoque ou il n'existait qu'une seule mission.
	#
	# Et on ne lui donne PAS d'equivalent ici. Le script de Guillaume s'arrete en
	# B8 sur « fondu, retour au monde ouvert, mission terminee » — pas de dernier
	# mot. Lui en ecrire un serait ajouter du texte a un scenario qu'on a promis
	# de suivre au plus pres.
	if _mission == null or not _mission.fichier.ends_with("mission1.json"):
		return
	_fin_a_dire = true


# On attend que le bandeau se soit efface, comme les marmonnements : une
# conversation qui s'ouvre par-dessus « MISSION ACCOMPLIE » ecrase le seul
# marqueur qui dit au joueur qu'il a fini.
func _gerer_le_mot_de_la_fin() -> void:
	if not _fin_a_dire or _dialogue == null or _controleur == null:
		return
	if _dialogue.actif():
		return
	if _controleur.has_method("bandeau") and str(_controleur.call("bandeau")) != "":
		return
	_fin_a_dire = false
	_dialogue.demarrer("mission_fin")


## Appele par le controleur a chaque image.
func traiter(delta: float) -> void:
	if _mission == null or _joueur == null:
		return
	_gerer_l_appel(delta)
	_gerer_la_menace(delta)
	_gerer_l_etat_present()
	_livrer_le_tuto()
	_gerer_le_mot_de_la_fin()


# CERTAINES ETAPES SONT DEJA REMPLIES QUAND ELLES ARRIVENT.
#
# « Trouver la voiture de Walt » attend qu'on monte au volant. Mais on y est
# souvent DEJA : on prend la voiture pour aller chez Jesse, on lui parle par la
# fenetre ou on redescend une seconde, et l'etape s'ouvre alors qu'on est
# assis dedans. Plus aucun « monter » n'aura lieu, et l'objectif reste affiche
# pour toujours.
#
# Le scenario le disait des le depart : « si le joueur s'est directement dirige
# vers sa voiture, ignorer cette etape et la valider ». Un evenement ne se
# declenche qu'une fois ; un ETAT, on peut le constater a tout moment. On
# regarde donc l'etat present a chaque image, et pas seulement la transition.
func _gerer_l_etat_present() -> void:
	if _controleur == null or _mission.finie():
		return
	if str(_mission.etape().get("valide_par", "")) == "volant" \
			and _controleur.call("au_volant"):
		_mission.evenement("volant")


# L'appel d'ouverture. Il part cinq secondes apres qu'on met le pied dehors,
# et pas au lancement : recevoir un coup de fil sur l'ecran-titre ne raconte
# rien, alors que sonner pendant qu'on decouvre la rue installe la mission.
func _gerer_l_appel(delta: float) -> void:
	if not _mission.a_l_etape("appel") or _controleur == null:
		return
	if not _sorti_de_chez_lui:
		if not _controleur.call("dedans"):
			_sorti_de_chez_lui = true
			_appel = AVANT_L_APPEL
		return
	if _appel <= 0.0:
		return
	_appel -= delta
	if _appel <= 0.0:
		_appel = -1.0
		_controleur.call("recevoir_un_appel", "mission_tuco_appel")


# Chez Tuco, apres la fouille. Le joueur est libre de bouger — c'est ce que
# demande le scenario — mais le temps joue contre lui.
func _gerer_la_menace(delta: float) -> void:
	if _patience <= 0.0:
		return
	_patience -= delta
	if _patience <= 0.0:
		_patience = -1.0
		if _tir != null:
			_tir.riposte_mortelle(_joueur)
		return
	_menace -= delta
	if _menace <= 0.0:
		_menace = ENTRE_DEUX_MENACES
		if _dialogue != null and not _dialogue.actif():
			_dialogue.demarrer("mission_tuco_menace")


# ---------------------------------------------------------------- reactions


## QUI DIT QUOI, ET QUAND.
##
## Un habitant porte une cle unique — Jesse chez lui, c'est « jesse » — et il
## raconte donc toujours la meme chose. Pendant une mission, ce n'est pas ce
## qu'on veut : a l'etape ou l'on doit lui parler de la commande, c'est la
## conversation de la MISSION qu'il doit tenir, pas sa causette habituelle.
##
## La table vit ici et pas sur le personnage : c'est le scenario qui sait a
## quel moment quelqu'un a autre chose a dire. Le PNJ, lui, n'a pas a connaitre
## la mission en cours.
const REMPLACEMENTS := {
	"jesse": [["parler_jesse", "mission_jesse_maison"]],
	# Jesse DEVANT le camping-car. Une fois la marchandise en poche il n'a plus
	# rien a dire sur la cuisine : sans cette ligne, on ressortait du
	# camping-car et il proposait encore d'aller cuisiner, ce qui donnait
	# l'impression d'avoir saute une etape.
	"mission_jesse_camping": [["aller_tuco", "mission_jesse_livre"]],
	# Jesse dans le camping-car. Il cuisine, donc il envoie promener — jusqu'a
	# ce que la botte secrete soit sortie de l'atelier. La aussi son noeud
	# porte une cle unique : sans cette ligne il repond « je suis concentre »
	# pour l'eternite, et l'etape suivante ne peut plus etre franchie.
	"mission_jesse_occupe": [["jesse_pret", "mission_jesse_pret"]],
	# Jesse dans la clairiere, sequence B de « Deux corps ». Il accueille Walter
	# a l'arrivee, puis n'a plus rien a dire jusqu'au micro-choix du raccourci —
	# c'est lui qui propose de sauter l'etape, et c'est le seul vrai choix de la
	# mission. Sans cette ligne il rejouerait « Bienvenue dans le bureau » a
	# chaque fois qu'on lui parle, et l'etape « raccourci » ne passerait jamais.
	"cuisine_arrivee": [["raccourci", "cuisine_raccourci"]],
}


## CE QU'ON DIT AUTREMENT QUAND WALTER PORTE QUELQUE CHOSE.
##
## Jesse et Tuco voient la boite d'oeufs. Ils ne la commentent pas par
## coquetterie : c'est la seule facon que le detour se SENTE. La reputation
## baisse au meme moment, et un compteur qui tombe sans que personne en parle
## passe pour un bug — c'est deja la regle pour tout le reste du jeu, sauf que
## la, il y a quelqu'un en face.
const REMPLACEMENTS_OBJET := {
	"mission_jesse_camping": [["oeufs", "mission_jesse_camping_oeufs"]],
	"mission_tuco_vente": [["oeufs", "mission_tuco_vente_oeufs"]],
}

## LES VARIANTES COMPTENT COMME LEUR ORIGINAL.
##
## dialogue_fini() emet « dialogue:<cle> », et c'est ce qui fait avancer la
## mission : l'etape « jesse_dehors » se valide par
## « dialogue:mission_jesse_camping ». Sans cette table, jouer la version avec
## les oeufs emettait une cle que la mission ne connait pas — on tenait la
## bonne conversation et l'etape ne passait jamais.
##
## Autrement dit : prendre les courses aurait BLOQUE la mission 1, et le
## symptome serait apparu trois ecrans plus loin.
const VARIANTES := {
	"mission_jesse_camping_oeufs": "mission_jesse_camping",
}

## CE QUI N'EST QU'UNE OUVERTURE, ET CE QUI SUIT.
##
## Chez Tuco, la boite d'oeufs ne remplace pas la scene : elle l'introduit. La
## vente fait vingt repliques et porte DEUX effets — l'argent et la fouille —
## et la recopier pour trois lignes d'ouverture aurait donne deux scenes
## centrales a maintenir. Le jour ou l'une change, l'autre ment.
##
## On joue donc l'ouverture, puis on enchaine sur la vraie. L'evenement de
## mission part a la fin de CELLE-CI, comme d'habitude : rien d'autre a prevoir.
const OUVERTURES := {
	"mission_tuco_vente_oeufs": "mission_tuco_vente",
}


## La conversation a jouer pour ce personnage, maintenant. Renvoie la cle
## d'origine s'il n'y a rien de special.
##
## L'ETAPE PASSE AVANT L'OBJET. Une fois la marchandise en poche, Jesse doit
## dire « qu'est-ce que vous attendez » meme si l'on porte encore les courses :
## ce qui a change entre-temps compte plus que ce qu'on tient.
func dialogue_pour(cle: String) -> String:
	if _mission == null:
		return cle
	if REMPLACEMENTS.has(cle):
		for regle in REMPLACEMENTS[cle]:
			if _mission.a_l_etape(str(regle[0])):
				return str(regle[1])
	if REMPLACEMENTS_OBJET.has(cle) and _equipement != null:
		for regle in REMPLACEMENTS_OBJET[cle]:
			if _equipement.possede(str(regle[0])):
				return str(regle[1])
	return cle


## Une conversation vient de se terminer. Renvoie vrai si elle a fait avancer
## la mission — le controleur n'a alors rien d'autre a faire.
func dialogue_fini(cle_jouee: String) -> bool:
	# UNE OUVERTURE ENCHAINE SUR SA SCENE, et n'emet rien elle-meme.
	#
	# Tuco vient de remarquer la boite d'oeufs ; la vente commence maintenant.
	# On rend vrai pour dire au controleur qu'on a pris la main : sans ca il
	# croirait la conversation close et rendrait le joueur a ses commandes au
	# milieu du bureau de Tuco.
	if OUVERTURES.has(cle_jouee) and _dialogue != null:
		_dialogue.demarrer(str(OUVERTURES[cle_jouee]))
		return true
	if _mission == null:
		return false
	# Une variante fait avancer la mission comme son original. Voir VARIANTES :
	# c'est ce qui evite que prendre les courses bloque la mission 1.
	var cle := str(VARIANTES.get(cle_jouee, cle_jouee))
	# L'argent et la fouille NE SONT PLUS ICI : ils se declenchent sur la
	# replique qui les annonce — voir _sur_effet et le champ 'effet' dans
	# donnees/dialogues.json. Les faire a la fin de la conversation les
	# decalait d'une quinzaine de repliques.
	#
	# Jesse a dit qu'il partait devant. Il part donc : rester chez lui
	# pendant que Walter va le retrouver dans le desert fait deux Jesse.
	if cle == "mission_jesse_maison":
		_jesse_quitte_sa_maison()
	# Le garde s'ecarte, et on monte. La teleportation est faite APRES la
	# conversation, sinon on la lirait dans le bureau alors qu'elle se joue
	# sur le trottoir.
	if cle == "mission_garde" and _controleur != null:
		_controleur.call("emmener", QG_INTERIEUR, 0.0, "", true)
	# B1 : « Jesse ouvre la portiere du camping-car, fier, presque ceremonieux. »
	#
	# Le battement est marque « Rien — cinematique » et se termine par « passage
	# a l'interieur ». Ce n'est donc pas au joueur d'aller pousser une porte : il
	# regarde Jesse l'ouvrir, et il est dedans.
	#
	# On y entrait a la main, ce qui laissait Walter planté devant un
	# camping-car apres une invitation — « bienvenue dans le bureau, professeur »
	# suivi de rien. La porte de la clairiere reste posee pour qui ressort et
	# veut revenir ; elle n'est simplement plus le chemin normal.
	if cle == "cuisine_arrivee" and _controleur != null:
		_controleur.call("emmener", CUISINE_INTERIEUR, PI, "camping_interieur", true)
	return _mission.evenement("dialogue:" + cle)

## Ou l'on atterrit dans le bureau de Tuco. La seule coordonnee ecrite dans ce
## fichier, parce qu'elle est la seule a ne pas pouvoir vivre sur un noeud : on
## y arrive a la fin d'une conversation, pas en marchant sur une zone.
##
## AU CENTRE DE LA PIECE, DEBOUT, FACE AU BUREAU. La piece est declaree dans
## scenes/mission1.tscn autour de (-1200, -900) et fait 8,2 m de profondeur ;
## on arrivait a -897, c'est-a-dire colle au mur d'entree, dos a la porte et a
## six metres de Tuco. Toute la scene est construite sur un face-a-face — on la
## commence donc en face.
const QG_INTERIEUR := Vector3(-1200.0, 0.4, -898.7)

## OU L'ON ATTERRIT DANS LE CAMPING-CAR, a la fin de B1.
##
## Meme raison que celle du QG : on y arrive a la fin d'une CONVERSATION, pas en
## marchant sur une zone, donc la coordonnee ne peut pas vivre sur un noeud de
## passage. C'est la meme que celle de la porte posee dans la clairiere — la
## recopier ici est un doublon assume, et le seul autre choix serait d'aller
## chercher un noeud par son nom depuis le scenario.
##
## A l'entree du couloir, tourne vers le fond : la paillasse est au bout, et
## c'est ce qu'on doit voir en arrivant.
const CUISINE_INTERIEUR := Vector3(300.0, 0.4, 1201.0)


# ------------------------------------------------- ce qui arrive PENDANT qu'on
# parle. Le dialogue annonce un effet nomme ; c'est ici qu'on decide ce qu'il
# veut dire.


func _sur_effet(nom: String) -> void:
	match nom:
		"argent":
			_encaisser()
		"fouille":
			_faire_fouiller()
		"sirene_pompiers":
			_reveler_les_pompiers()
		"raccourci_pris":
			_regler_la_premiere_fournee(2)
		"raccourci_refuse":
			_regler_la_premiere_fournee(4)


# ON A COURU POUR DES POMPIERS.
#
# Le battement A9, et Guillaume en fait le seul endroit de toute la mission ou
# le son porte a lui seul un retournement : « le joueur ne percoit le twist que
# si les deux sirenes sont clairement differentes dans leur timbre — sinon il
# faut juste lire le texte de Jesse ».
#
# La sirene de police se coupe NET, un battement de silence, puis le camion
# passe et s'eloigne. C'est ce silence qui fait comprendre que quelque chose a
# change ; un fondu enchaine aurait donne un son qui se deforme.
# L'epave se repose sur ses roues et redevient conduisible. On la degele une
# seule fois : rappeler ceci sur un vehicule deja libre ne coute rien, mais
# remettre freeze a false pendant qu'il roule le reposerait a l'arret.
func _reveiller_l_epave() -> void:
	for n in get_tree().get_nodes_in_group(Desert.EPAVE):
		var v := n as VehicleBody3D
		if v == null or not v.freeze:
			continue
		# ON LA REMET D'APLOMB EN MEME TEMPS QU'ON LA LIBERE.
		#
		# Degeler seul lachait onze tonnes inclinees de seize degres dans une
		# cuvette : elle glissait, se balancait et se reposait toute seule
		# pendant qu'on regardait — « le camping bouge un peu tout seul a cause
		# du creux ». Ce n'est pas faux physiquement, c'est juste que personne
		# n'a demande ce spectacle, et il se produit pile au moment ou le joueur
		# vient enfin de reussir a demarrer.
		#
		# On garde son CAP — elle a quitte la piste en travers et elle y est
		# encore — mais on efface tangage et roulis : le moteur a pris, elle
		# s'est posee sur ses suspensions.
		v.linear_velocity = Vector3.ZERO
		v.angular_velocity = Vector3.ZERO
		v.rotation = Vector3(0.0, v.rotation.y, 0.0)
		v.freeze = false


func _reveler_les_pompiers() -> void:
	var s := get_tree().get_first_node_in_group("sirene")
	if s != null:
		s.call("basculer")


# LA PREMIERE FOURNEE, ET CE QU'ELLE VAUT.
#
# Battement B5 : Jesse propose de sauter une etape, et le script tranche pour
# nous — « les deux options reussissent, teinte du cristal legerement
# differente selon l'option, JAMAIS COMMENTEE A L'ECRAN ».
#
# Les deux mots qui decident de l'implementation sont « legerement » et
# « jamais ». Deux paliers d'ecart, pas cinq : il faut que ce soit perceptible
# quand on compare, pas quand on regarde. Et aucune annonce, aucun bandeau,
# aucun son de reussite — c'est le premier indice de la regle couleur, et le
# joueur doit la deviner en voyant le cristal, pas l'apprendre en la lisant.
#
# C'est aussi le seul vrai choix du jeu a ce jour, et il respecte la regle
# numero deux : ceder fait gagner du temps a l'ecran et coute deux paliers ;
# insister coute une scene de plus. Aucune des deux options n'est meilleure sur
# tous les plans.
func _regler_la_premiere_fournee(palier: int) -> void:
	var p := Purete.courante(self)
	if p != null:
		p.poser(palier)


# Tuco paie, et le compteur monte SOUS LES YEUX du joueur pendant qu'il dit
# « compte-les si tu veux ». Le HUD fait defiler la somme en une seconde : c'est
# la seule facon de sentir trois cent mille dollars, et ca n'a de sens qu'a
# l'instant ou la phrase est prononcee.
func _encaisser() -> void:
	if _bourse != null and _mission != null:
		_bourse.ajouter(_mission.montant_de_la_vente())
	if _equipement != null:
		_equipement.retirer("meth")


# LE GARDE VIENT, FOUILLE, ET REPART.
#
# La botte secrete quittait la poche de Walter a la fin de la conversation,
# c'est-a-dire bien apres que le garde ait annonce l'avoir trouvee. On la lui
# retire maintenant, au moment ou Tuco l'ordonne — et le garde se DEPLACE,
# parce qu'une fouille annoncee par un homme qui n'a pas bouge du fond de la
# piece ne raconte rien.
func _faire_fouiller() -> void:
	var garde := get_node_or_null(garde_fouilleur) as Pnj
	if garde != null and _joueur != null:
		# A cote de Walter, pas dessus : deux capsules au meme endroit se
		# poussent l'une l'autre et le joueur part en glissade.
		garde.aller_vers(_joueur.global_position
				+ _joueur.global_transform.basis.x * 0.85)
		await get_tree().create_timer(2.4).timeout
	if _equipement != null:
		_equipement.retirer("botte")
	if _son() != null:
		_son().bruit("roue_cran")
	if garde != null:
		# Il la POSE SUR LE BUREAU. C'est de la qu'on la reprendra a l'etape
		# suivante, et c'est le seul endroit ou le joueur regarde a ce
		# moment-la. Puis il retourne a sa place, derriere.
		garde.aller_vers(QG_INTERIEUR + Vector3(1.5, 0.0, -3.4))
		await get_tree().create_timer(2.6).timeout
		garde.rentrer()


## Un point d'interaction vient d'etre utilise.
func point_utilise(p: Point) -> void:
	if p.donne != "" and _equipement != null:
		# LE NOM DE CE QU'ON VIENT DE PRENDRE, et pas le dernier de la roue.
		# L'annonce lisait le rang « nombre() - 1 », alors que la roue est
		# triee sur l'ordre du catalogue : tout ramassage s'annoncait donc
		# « Porkpie », qui ferme la liste.
		if _equipement.donner(p.donne) and _controleur != null:
			_controleur.call("annoncer", "%s : recupere"
					% _equipement.nom_pour_cle(p.donne))
	# L'atelier lance la conversation de la botte secrete PENDANT qu'on
	# manipule : Walter parle en travaillant, il ne s'arrete pas pour discuter.
	if p.evenement == "objet:botte" and _dialogue != null:
		_dialogue.demarrer("mission_jesse_botte")
	# LE MOTEUR A PRIS : l'epave redevient un vehicule.
	#
	# Elle etait gelee dans la pose du crash — neuf degres de tangage, seize de
	# roulis — parce qu'un corps rigide lache dans cette position se redresse en
	# une seconde et va se poser a plat au fond de la cuvette. Le degel se fait
	# au moment ou le moteur prend, et pas avant : c'est le battement A7, et
	# c'est aussi la seule seconde ou le vehicule a le droit de bouger tout seul.
	if p.evenement == "action:demarrer":
		_reveiller_l_epave()
	if p.evenement == "action:botte_bureau":
		_faire_exploser()
	if p.evenement == "action:livraison":
		livrer_la_marchandise()
	if p.evenement == "action:courses_posees":
		var avec := poser_les_courses()
		if _dialogue != null:
			_dialogue.demarrer("skyler_courses_oui" if avec else "skyler_courses_non")
	if p.evenement != "" and _mission != null:
		_mission.evenement(p.evenement)


## Walter a-t-il cet objet sur lui ? Le controleur s'en sert pour n'afficher
## l'invite d'un point que si sa condition est remplie — l'acheteur de
## marchandise ne se propose pas les mains vides.
func possede(cle: String) -> bool:
	return _equipement != null and _equipement.possede(cle)


## CE QUE VAUT UNE LIVRAISON, avant la purete.
##
## Trois cents dollars le sachet au palier 1. Tuco paie trois cent mille pour
## une commande entiere ; un contact de rue achete l'unite, et la difference
## d'echelle est le sujet — c'est ce qui donne envie de monter.
const PRIX_DE_BASE := 300

## Ce que chaque palier au-dessus du premier ajoute, en pourcentage du prix de
## base. Du brun au bleu, la valeur triple : livrer du bon se paie, et c'est la
## seule facon de sentir la purete sans jamais l'afficher.
const PAR_PALIER := 0.5


## ON VEND CE QU'ON A CUISINE, ET LE PRIX DIT LA QUALITE.
##
## Le puits economique du jeu, hors mission : cuisiner, livrer, etre paye,
## recommencer. Sans lui, l'argent n'arrive que par les missions et il n'y a
## aucune raison de rejouer entre deux.
##
## RIEN N'ANNONCE LE PRIX A L'AVANCE. On livre, la bourse monte, et c'est en
## comparant deux livraisons qu'on comprend que la purete se paie. Un ecran de
## vente avec un cours affiche transformerait une scene en tableur.
func livrer_la_marchandise() -> void:
	if _equipement == null or not _equipement.possede("meth"):
		return
	var palier := 1
	var p := Purete.courante(self)
	if p != null:
		palier = p.palier()
	var prix := roundi(PRIX_DE_BASE * (1.0 + PAR_PALIER * float(palier - 1)))

	_equipement.retirer("meth")
	if _bourse != null:
		_bourse.ajouter(prix)
	# La reputation suit la purete par le meme chemin que le prix : livrer du
	# bleu se raconte, livrer du brun se paie et s'oublie.
	var r := Reputation.courante(self)
	if r != null:
		r.livre(palier)
	if _controleur != null:
		_controleur.call("annoncer", "Marchandise livree")


## LES COURSES SE PAIENT A L'EPICERIE ET SE COMPTENT A LA MAISON.
##
## Toute la mecanique tient dans cette dissociation. L'epicerie prend quatre
## dollars et rend une boite ; ce plan de travail est le seul endroit du jeu ou
## les points de famille arrivent. Entre les deux, deux cent quatre-vingts
## metres pendant lesquels on peut mourir, se faire prendre, ou simplement ne
## jamais rentrer.
##
## Renvoie vrai si on avait de quoi poser. LES MAINS VIDES, ON RENTRE QUAND
## MEME — et c'est l'appelant qui fait alors parler Skyler. Si oublier ne
## produisait rien, oublier ne couterait rien, et un choix sans cout n'est pas
## un choix.
##
## PUBLIQUE, ET SANS LE DIALOGUE, POUR ETRE MESURABLE. La suite de tests ne
## peut pas ouvrir de conversation : le lecteur de voix n'y est pas branche et
## Godot s'arrete net — verifie en y demarrant une fiche qui existe depuis des
## semaines. La partie qui compte se teste donc ici, et le fait qu'on PARLE se
## verifie autrement : les deux fiches existent, et point_utilise choisit.
func poser_les_courses() -> bool:
	var avec := _equipement != null and _equipement.possede("oeufs")
	if avec:
		_equipement.retirer("oeufs")
		var famille := Famille.courante(self)
		if famille != null:
			famille.merci("courses")
	return avec


## On est arrive quelque part. Le controleur l'annonce apres chaque passage.
func zone_atteinte(nom: String) -> void:
	# L'heure du lieu, s'il en impose une. Voir HEURES : le desert et le QG se
	# jouent en fin d'apres-midi, quelle que soit l'heure a laquelle on y va.
	if HEURES.has(nom):
		_regler_l_heure(float(HEURES[nom]))
	if nom == "camping":
		_arriver_au_camping_car()
	if _mission != null:
		_mission.evenement("zone:" + nom)


# ARRIVER AVEC LES COURSES SE PAIE.
#
# Si Walter debarque au camping-car avec la boite d'oeufs, c'est qu'il a fait
# demi-tour pour passer a l'epicerie : Jesse a attendu, et Tuco attend derriere
# lui. Le detour coute donc de la reputation de rue.
#
# Sans ce cout, prendre les oeufs serait meilleur sur tous les plans — et un
# choix sans cout n'est pas un choix. C'est la regle numero deux de la
# direction, et c'est tout le sujet de l'appel de Skyler : le detour coute du
# temps, le retard coute une reputation.
#
# ON NE L'ANNONCE PAS, MAIS QUELQU'UN LE DIT. Le compteur baisse en silence,
# comme tout le reste ; ce qui l'explique, c'est Jesse qui voit la boite —
# voir REMPLACEMENTS_OBJET.
func _arriver_au_camping_car() -> void:
	if _equipement == null or not _equipement.possede("oeufs"):
		return
	var r := Reputation.courante(self)
	if r != null:
		r.tant_pis("retard")


# ------------------------------------------------------------------- Jesse
#
# IL N'EST PLUS CHEZ LUI UNE FOIS QU'IL EN EST PARTI.
#
# Sa derniere replique est « le camping-car, dans le desert, j'y vais devant ».
# Il restait pourtant plante dans son salon, et l'on pouvait donc lui reparler
# a Albuquerque pendant qu'il nous attendait a neuf cents metres de la. Deux
# Jesse au meme moment, c'est le genre de detail qui defait tout le reste.
#
# On le RANGE plutot que de le supprimer : la partie se recommence, et un
# personnage detruit ne revient pas.

var _jesse_maison: Pnj
var _jesse_cle: String = ""


func _jesse_chez_lui() -> Pnj:
	if _jesse_maison != null and is_instance_valid(_jesse_maison):
		return _jesse_maison
	for n in get_tree().get_nodes_in_group(Pnj.GROUPE):
		var p := n as Pnj
		# Sa cle d'origine, celle de l'habitant — pas celles de la mission, qui
		# designent les Jesse du desert.
		if p != null and p.cle == "jesse":
			_jesse_maison = p
			_jesse_cle = p.cle
			return p
	return null


## IL SORT, ET ON LE VOIT SORTIR.
##
## Il disparaissait a la seconde ou la conversation se terminait : le probleme
## des deux Jesse etait regle, mais sa derniere phrase — « le camping-car dans
## le desert, j'y vais devant » — n'etait suivie d'aucun geste. Quelqu'un qui
## s'evapore dans son salon ne part pas, il cesse d'exister.
##
## Il marche donc jusqu'a sa porte, et c'est en la franchissant qu'il quitte la
## piece. La porte est celle du repere de sortie de la maison : la meme que
## celle du joueur, donc elle ne peut pas etre ailleurs.
func _jesse_quitte_sa_maison() -> void:
	var p := _jesse_chez_lui()
	if p == null:
		return
	if _jesse_cle == "":
		_jesse_cle = p.cle
	# Muet des maintenant : on ne le retient pas par la manche pendant qu'il
	# traverse la piece.
	p.cle = ""

	var chez_lui := _maison_de(p)
	if chez_lui != null:
		p.aller_vers(chez_lui.entree())
		# On attend qu'il ARRIVE, pas un delai : la piece peut changer de
		# taille, et un compte a rebours le ferait disparaitre en chemin.
		while not p.arrive() and is_instance_valid(p):
			await get_tree().process_frame
		if not is_instance_valid(p):
			return
		if _son() != null:
			_son().bruit_ici("porte_ouvre", p.global_position)
			await get_tree().create_timer(0.35).timeout
			if not is_instance_valid(p):
				return
			_son().bruit_ici("porte_ferme", p.global_position)
	p.visible = false


# La maison qui contient ce personnage. On remonte l'arbre plutot que de la
# passer par l'inspecteur : l'habitant est cree par la maison elle-meme, il est
# donc toujours sous elle, et un NodePath de plus serait un NodePath de plus a
# tenir a jour.
func _maison_de(p: Node) -> Maison:
	var n := p.get_parent()
	while n != null:
		if n is Maison:
			return n as Maison
		n = n.get_parent()
	return null
	# La cle videe plus haut le rend muet : c'est ainsi que le controleur
	# decide a qui l'on peut parler, et le rendre invisible seul aurait laisse
	# une voix sortir d'une piece vide.


func _rendre_jesse_a_sa_maison() -> void:
	var p := _jesse_chez_lui()
	if p == null:
		return
	p.visible = true
	if _jesse_cle != "":
		p.cle = _jesse_cle


## Un evenement de jeu, sans categorie. Pour ceux qui n'ont ni zone, ni objet,
## ni conversation — monter dans la voiture, par exemple.
func signaler(nom: String) -> void:
	if _mission != null:
		_mission.evenement(nom)


## Peut-on ouvrir la cachette maintenant ? Et avec quel argent.
func ouvrir_la_cachette() -> void:
	if _cachette == null or _bourse == null or _mission == null:
		return
	_cachette.ouvrir(_bourse.montant(), _mission.reste_maximum())


func _sur_argent_cache(somme: int) -> void:
	if _bourse == null:
		return
	_bourse.retirer(somme)
	if _bourse.montant() <= _mission.reste_maximum():
		_mission.evenement("argent_cache")


## Peut-on sortir de chez Walter avec ce qu'on a sur soi ? Renvoie le refus,
## ou "" si la porte s'ouvre.
func refus_de_sortie() -> String:
	if _mission == null or _bourse == null:
		return ""
	if not _mission.a_l_etape("cacher"):
		return ""
	if _bourse.montant() <= _mission.reste_maximum():
		return ""
	return _mission.refus_sortie()


# La botte secrete jetee au sol. Le fulminate de mercure : ca n'est pas de la
# meth, et Tuco l'apprend a ses depens.
func _faire_exploser() -> void:
	_patience = -1.0
	if _son() == null:
		if _controleur != null:
			_controleur.call("souffler_l_explosion")
		return
	# LA REPLIQUE D'ABORD, ENTIERE, l'explosion ensuite. C'est tout le sens de
	# la scene : Walt annonce ce qu'il tient avant de le lancer.
	#
	# L'attente etait de 1,15 s, ecrite a la main. La replique dure plus, et la
	# deflagration lui coupait donc la parole a chaque fois. On lit maintenant
	# la DUREE REELLE du son, plus un souffle : le jour ou la prise est
	# reenregistree, le minutage suit tout seul.
	_son().bruit("pas_de_meth")
	await get_tree().create_timer(
			_son().duree("pas_de_meth") + APRES_LA_REPLIQUE).timeout
	if not is_instance_valid(_joueur):
		return
	_son().bruit_ici("explosion", _joueur.global_position)
	if _controleur != null:
		_controleur.call("souffler_l_explosion")


# Tirer sur quelqu'un. Dans cette mission ce n'est jamais un combat : c'est
# une scene, et elle se termine mal a chaque fois.
func _sur_tir_sur_quelqu_un(qui: Pnj) -> void:
	var cle := qui.cle
	if TIRS.has(cle):
		if cle == "garde" or cle == "tuco":
			# On ne voit personne, et on meurt vite. C'est une punition, pas
			# un echange de coups — le scenario est explicite.
			if _tir != null:
				_tir.riposte_mortelle(_joueur)
			return
		perdre(TIRS[cle], qui)
		return
	# Un passant quelconque : rien de scenarise, mais on ne laisse pas passer
	# ca sans un mot.
	if _controleur != null:
		_controleur.call("annoncer", "Ce n'etait pas necessaire")


func _sur_mort() -> void:
	perdre("Vous etes mort")


## POUR LES CAPTURES, ET POUR ELLES SEULES. Abat le personnage portant cette
## cle, comme si on lui avait tire dessus.
##
## Y arriver autrement demanderait de placer le joueur, de lui donner l'arme,
## de viser et de tirer — quatre gestes dont aucun n'est ce qu'on veut
## montrer, et qui rateraient une fois sur trois.
func abattre_pour_capture(cle: String) -> void:
	for n in get_tree().get_nodes_in_group(Pnj.GROUPE):
		var p := n as Pnj
		if p != null and p.cle == cle:
			perdre(TIRS.get(cle, "Quelqu'un est mort"), p)
			return
	push_warning("scenario : aucun personnage '%s' a abattre" % cle)


## Combien de temps on reste sur celui qui meurt avant qu'il tombe, en
## secondes REELLES. Une seconde, comme demande : « un plan sur le personnage
## qui meurt, au ralenti, 1 seconde avant de lancer son animation de mort
## (qu'on ait le temps de suivre) ».
const AVANT_LA_CHUTE := 1.0

## Et le temps qu'on laisse a la chute avant le carton.
##
## IL SE CALCULE, il ne s'ecrit pas. La chute avance avec le temps DU JEU,
## donc au ralenti : une demi-seconde de bascule en dure deux a la montre. Un
## delai fixe de 0,9 s — le premier essai — faisait s'ecrire « GAME OVER »
## par-dessus quelqu'un encore debout. Vu a la capture, pas dans le code.
##
## La marge, elle, est du temps de lecture : on voit le corps au sol avant que
## le carton le recouvre.
const APRES_LA_CHUTE_MARGE := 0.4


func _apres_la_chute() -> float:
	return Pnj.CHUTE / maxf(0.05, Engine.time_scale) + APRES_LA_CHUTE_MARGE


## Termine la partie avec ce titre.
##
## `victime` est celui qui meurt, quand ce n'est pas le joueur. C'EST TOUT LE
## SUJET : jusqu'au 23/08/2026, tirer sur Jesse faisait s'effondrer WALTER et
## affichait « Jesse est mort » — on lisait la mort de l'un sur le corps de
## l'autre. « Il faut que ce soit un plan sur le personnage qui meurt. »
func perdre(titre: String, victime: Node3D = null) -> void:
	if _fin == null or _fin.actif():
		return
	if victime == null or victime == _joueur:
		if _controleur != null:
			_controleur.call("effondrer_le_joueur")
		_fin.declencher(titre)
		return
	_perdre_sur_quelqu_un(titre, victime)


# LA MORT DE QUELQU'UN D'AUTRE, EN TROIS TEMPS.
#
# On regarde, il tombe, puis le carton. Le joueur est bloque du premier
# instant : c'est une scene, pas un moment ou l'on peut encore faire quelque
# chose.
#
# LES ATTENTES IGNORENT LE RALENTI. `create_timer` suit `Engine.time_scale`,
# et l'ecran de fin le met a 0,25 : une seconde annoncee en durerait quatre.
# Le quatrieme argument dit au minuteur de compter en temps reel — c'est le
# meme calcul que fin_de_partie.gd fait sur son propre compteur.
func _perdre_sur_quelqu_un(titre: String, victime: Node3D) -> void:
	if _controleur != null:
		_controleur.call("regarder_mourir", victime)

	await get_tree().create_timer(AVANT_LA_CHUTE, true, false, true).timeout
	if victime.has_method("tomber"):
		victime.call("tomber")

	await get_tree().create_timer(_apres_la_chute(), true, false, true).timeout
	if _fin != null and not _fin.actif():
		_fin.declencher(titre)
