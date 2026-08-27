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
	# La cuisine, elle, est posee dans monde.tscn : son groupe est deja peuple
	# ici, et un seul branchement suffit — contrairement au demarreur, dont le
	# decor n'existe qu'une fois le fosse instancie.
	_brancher_la_cuisine()
	_brancher_les_roulages()
	_installer()
	# La PREMIERE etape n'emet aucun changement — on y est deja. Son objectif
	# et son conseil ne s'affichaient donc jamais, et la partie s'ouvrait sur un
	# salon sans rien dire de ce qu'on attend du joueur.
	_sur_etape(0)


# LE DECOR ARRIVE APRES NOUS, ET LA PREMIERE ETAPE N'ATTEND PERSONNE.
#
# Les trois mecanismes du fosse — les foyers, la traction, le guidage — vivent
# dans un decor que desert.gd instancie A L'EXECUTION. Le scenario, lui, branche
# ses signaux dans son `_commencer()`, quand les groupes sont encore vides. La
# parade tenait jusqu'ici en une ligne : on rebranche a CHAQUE changement
# d'etape, ce qui rattrape tout au premier franchissement.
#
# Elle ne tenait plus depuis que la premiere etape du jeu a besoin d'un de ces
# mecanismes. Le guidage n'etait donc jamais branche ; son signal de fin ne
# menait nulle part ; l'etape « suivre la voix » attendait pour toujours un
# evenement que personne n'emettait — et rien a l'ecran ne le disait, puisque
# le trajet, lui, se jouait normalement.
#
# ON RATTRAPE DONC AUSSI EN BOUCLE, tant que rien n'a ete trouve. Une fois le
# decor la, on ne repasse plus : la recherche coute trois lectures de groupe,
# mais la faire soixante fois par seconde pour rien serait une dette qu'on
# oublierait.
func _rattraper_le_decor() -> void:
	if _decor_branche:
		return
	if get_tree().get_nodes_in_group(Guidage.GROUPE).is_empty() \
			and get_tree().get_nodes_in_group(Traction.GROUPE).is_empty() \
			and get_tree().get_nodes_in_group(Feu.GROUPE).is_empty():
		return
	_decor_branche = true
	_brancher_les_feux()
	_brancher_la_traction()
	_brancher_le_guidage()


var _decor_branche := false


# ON AMENE LA VOITURE DU JOUEUR LA OU L'ETAPE LA VEUT.
#
# Une seule fois par etape, et seulement si elle le demande : le champ
# « gare_la_voiture » porte un nom de noeud, et rien ne bouge sans lui.
#
# ON REPOSE UN CORPS PHYSIQUE, PAS UN DECOR. Un VehicleBody3D qu'on teleporte
# en changeant sa seule position garde sa vitesse et son inertie : il arrive en
# glissant, se cabre sur ses suspensions et part en tonneau. C'est ce que
# _reveiller_l_epave a appris a ses depens sur le camping-car du fosse — on
# efface les deux vitesses et on pose le cap a plat.
func _garer_la_voiture() -> void:
	if _mission == null or _controleur == null:
		return
	var ou := str(_mission.etape().get("gare_la_voiture", ""))
	if ou == "":
		return
	# ON CHERCHE DEPUIS LA RACINE QUAND IL N'Y A PAS DE SCENE COURANTE.
	#
	# `current_scene` est null dans les suites, qui instancient le monde a la
	# main sous `root` — et un appel de methode sur null n'est pas un avertissement,
	# c'est un arret. C'est le meme repli que Passage.ou(), pour la meme raison.
	var racine: Node = get_tree().current_scene
	if racine == null:
		racine = get_tree().root
	var repere := racine.find_child(ou, true, false) as Node3D
	if repere == null:
		push_warning("scenario : « %s » introuvable, la voiture reste ou elle est" % ou)
		return
	var v := _controleur.call("vehicule_courant") as Node3D
	if v == null:
		return
	if v is VehicleBody3D:
		var corps := v as VehicleBody3D
		corps.linear_velocity = Vector3.ZERO
		corps.angular_velocity = Vector3.ZERO
	v.global_position = repere.global_position
	v.global_rotation = Vector3(0.0, repere.global_rotation.y, 0.0)


# LA VOIX QUI GUIDE SOUS LE MASQUE, si la scene en a une.
#
# Meme forme que les foyers et la traction, et meme raison : le decor du fosse
# est instancie a l'execution. Repasser a chaque etape ne coute rien.
#
# LA PREMIERE PHRASE PART ICI, et pas au premier jalon. C'est elle qui dit au
# joueur qu'il y a quelqu'un et qu'il faut aller quelque part ; l'attendre au
# premier jalon reviendrait a ne parler qu'a celui qui a deja trouve le chemin.
func _brancher_le_guidage() -> void:
	if _joueur == null:
		return
	for n in get_tree().get_nodes_in_group(Guidage.GROUPE):
		var g := n as Guidage
		if g == null:
			continue
		g.observer(_joueur)
		if not g.jalon_atteint.is_connected(_sur_jalon):
			g.jalon_atteint.connect(_sur_jalon)
		if not g.fini.is_connected(_sur_guidage_fini):
			g.fini.connect(_sur_guidage_fini)
		if not g.redire.is_connected(_sur_redire):
			g.redire.connect(_sur_redire)
		if g.active() and g.rang() == 0:
			_dire_la_voix(0)


## CE QUE L'ETAPE FAIT PORTER A WALTER, s'il y a quelque chose.
##
## Le champ « porte » nomme une cle d'outils.json. On ne passe pas par
## l'inventaire : voir Equipement.imposer_le_port — un masque a gaz n'est pas
## un objet qu'on choisit dans une roue, c'est un objet qu'on subit.
##
## LA LISTE DE CE QU'ON A POSE EST GARDEE, et c'est ce qui permet de le
## retirer. Chercher « tout ce qui se porte et qu'aucune etape ne demande »
## reviendrait a arracher le chapeau que le joueur a mis lui-meme.
func _porter_ce_que_l_etape_demande() -> void:
	if _equipement == null or _mission == null:
		return
	var voulu := str(_mission.etape().get("porte", ""))
	for cle in _imposes:
		if cle != voulu:
			_equipement.imposer_le_port(str(cle), false)
	_imposes.clear()
	if voulu == "":
		return
	_equipement.imposer_le_port(voulu, true)
	_imposes.append(voulu)


# Ce que les etapes ont mis sur Walter, et que lui n'a pas choisi.
var _imposes: Array[String] = []


## UN JALON EST ATTEINT : Jesse donne la consigne suivante.
func _sur_jalon(rang: int) -> void:
	_dire_la_voix(rang)


## JESSE REDIT OU ALLER, parce qu'on n'y est pas encore.
##
## Les phrases vivent dans « voix_relance » de l'etape, rangees par direction.
## Le guidage a calcule un cote ; ce fichier choisit quoi crier, et le fait
## TOURNER dans la liste plutot que de tirer au sort — une suite qui joue doit
## rendre deux fois le meme verdict sur le meme depot (piege 43).
func _sur_redire(direction: String) -> void:
	if _mission == null or _controleur == null:
		return
	var table: Dictionary = _mission.etape().get("voix_relance", {})
	var phrases: Array = table.get(direction, [])
	if phrases.is_empty():
		return
	_crier(phrases[_relance % phrases.size()])
	_relance += 1


# COMBIEN DE FOIS JESSE A DEJA REPETE. Sert a ne pas redire mot pour mot la
# meme chose deux fois de suite : quelqu'un qui repete a l'identique cesse
# d'etre quelqu'un.
var _relance: int = 0


## LE TRAJET EST FINI. La derniere phrase tombe — « enlevez-moi ce truc de la
## tete » — et l'evenement fait passer a l'etape ou le masque se retire.
##
## L'ORDRE COMPTE : la phrase AVANT l'evenement. L'evenement change d'etape, et
## les phrases sont lues sur l'etape courante ; annoncer apres reviendrait a
## chercher la quatrieme voix dans une etape qui n'en a aucune.
func _sur_guidage_fini() -> void:
	if _mission == null:
		return
	_dire_la_voix(_mission.etape().get("voix", []).size() - 1)
	_mission.evenement("guidage:fini")


# CE QUE LA VOIX DIT AU RANG DEMANDE, s'il y a quelque chose.
#
# Les phrases vivent dans le champ « voix » de l'etape : ce fichier ne sait pas
# ce que Jesse raconte, il sait a quel moment le demander. Une phrase de plus ou
# un jalon en moins se regle dans le JSON.
#
# ELLES PASSENT PAR LE BANDEAU, comme les pensees et les rappels de zone : c'est
# le canal de ce qui ne fige rien. Un cadre de dialogue immobiliserait Walter au
# moment precis ou on lui demande de marcher.
func _dire_la_voix(rang: int) -> void:
	if _mission == null or _controleur == null:
		return
	var voix: Array = _mission.etape().get("voix", [])
	if rang < 0 or rang >= voix.size():
		return
	_crier(voix[rang])


# JESSE CRIE : le sous-titre passe, et la voix sort d'un endroit.
#
# « Il faudra ajouter les voix de Jesse qui nous guide jusqu'a lui [...] Les
# voix sont surtout la pour rajouter du realisme. » — retour du 27/08/2026.
#
# UNE PHRASE EST UN DICTIONNAIRE, comme dans dialogues.json : « texte » est le
# sous-titre francais, « vo » ce qui se dit en anglais, « jeu » la direction
# d'acteur. Une simple chaine reste acceptee — c'est ce que ce champ contenait
# jusqu'ici, et une mission ecrite sans voix enregistrees doit continuer de
# marcher, muette mais lisible.
#
# LE SON SORT DU JALON, PAS DU HAUT-PARLEUR. C'est toute la difference avec le
# bandeau : on doit pouvoir se tourner vers la voix. Voir
# Guidage.source_de_la_voix pour la liberte que ca prend avec la position reelle
# de Jesse, et pourquoi elle est necessaire.
func _crier(phrase: Variant, source: Vector3 = Vector3.INF) -> void:
	if _controleur == null:
		return
	var replique: Dictionary = phrase if phrase is Dictionary else {"texte": str(phrase)}
	var texte := str(replique.get("texte", ""))
	if texte != "":
		_controleur.call("annoncer", texte)

	var chemin := Dialogue.chemin_de("Jesse", replique)
	if chemin == "":
		return

	# D'OU LA VOIX SORT. L'appelant le dit quand il le sait — Jesse debout a
	# cote du camping-car pendant le demarrage, par exemple. Sans indication, on
	# retombe sur le guidage, qui est le seul a savoir ou l'on doit aller ;
	# faute des deux, on ne joue rien plutot que de faire parler l'origine du
	# monde, a neuf cents metres de tout.
	var ou := source
	if ou == Vector3.INF:
		var g := get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
		if g == null:
			return
		ou = g.source_de_la_voix()
	# LE CANAL SE CHOISIT AVANT DE JOUER, exactement comme dans une conversation :
	# en changer pendant la lecture ne reprend pas ce qui est deja parti au
	# melangeur, et la premiere syllabe sortirait sur le bus precedent. C'est par
	# la que passe l'acouphene de l'ouverture — la replique porte « canal »:
	# « acouphene », comme une replique de telephone porte le sien.
	var canal := str(replique.get("canal", ""))
	var bus: String = Dialogue.BUS_PAR_CANAL.get(canal, Dialogue.BUS_VOIX)
	if AudioServer.get_bus_index(bus) < 0:
		push_warning("scenario : bus '%s' introuvable, voix en direct" % bus)
		bus = Dialogue.BUS_VOIX
	_haut_parleur().bus = bus
	_haut_parleur().global_position = ou
	_haut_parleur().stream = ResourceLoader.load(chemin) as AudioStream
	_haut_parleur().play()


# LE LECTEUR POSITIONNE, fabrique a la premiere replique et garde.
#
# QUINZE METRES DE PORTEE ET PAS TROIS. Le trajet fait vingt-sept metres et le
# joueur s'eloigne du jalon avant d'y revenir : avec l'attenuation par defaut,
# la seule consigne qu'il entend est celle qu'il n'a plus besoin d'entendre.
# On garde l'attenuation — c'est elle qui donne la direction — mais large.
func _haut_parleur() -> AudioStreamPlayer3D:
	if _voix_3d == null:
		_voix_3d = AudioStreamPlayer3D.new()
		_voix_3d.name = "VoixDuGuidage"
		_voix_3d.bus = Dialogue.BUS_VOIX
		_voix_3d.unit_size = 15.0
		_voix_3d.max_distance = 60.0
		add_child(_voix_3d)
	return _voix_3d


var _voix_3d: AudioStreamPlayer3D


# LES FOYERS QUI BRULENT, s'il y en a dans la scene.
#
# Un feu mesure une distance et blesse ce qui l'approche ; il ne sait pas qui
# joue, et le chercher dans l'arbre par son nom serait une adresse de plus a
# maintenir. On la lui donne, comme le controleur donne le joueur a l'habitant
# d'une maison.
#
# Meme groupe, meme raison que le demarreur : le decor du fosse est instancie a
# l'execution, donc le groupe est vide au moment ou le scenario branche ses
# signaux. Repasser a chaque etape ne coute rien et rattrape tout.
func _brancher_les_feux() -> void:
	if _joueur == null:
		return
	for n in get_tree().get_nodes_in_group(Feu.GROUPE):
		var f := n as Feu
		if f != null:
			f.observer(_joueur)


# LE MINI-JEU DU DEMARRAGE, s'il est dans la scene.
#
# Il vit dans le decor du fosse, qui est instancie a l'execution : on le
# cherche par son groupe plutot que par un chemin, et son absence n'est pas
# une erreur — toutes les missions n'ont pas de vehicule a demarrer.
# TIRER LES CORPS, si la scene le demande.
#
# Meme forme et meme raison que le demarreur et les foyers : le decor du fosse
# est instancie a l'execution, donc le groupe est vide quand le scenario
# branche ses signaux. Repasser a chaque etape ne coute rien et rattrape tout.
func _brancher_la_traction() -> void:
	if _joueur == null:
		return
	for n in get_tree().get_nodes_in_group(Traction.GROUPE):
		var t := n as Traction
		if t == null:
			continue
		t.observer(_joueur, _joueur.reglages)
		if not t.charges.is_connected(_sur_corps_charges):
			t.charges.connect(_sur_corps_charges)
		if not t.souffle.is_connected(_sur_souffle):
			t.souffle.connect(_sur_souffle)


## LES DEUX CORPS SONT DEDANS. La traction ne sait pas ce qu'est une etape ;
## c'est ici que son signal devient un evenement de mission.
func _sur_corps_charges() -> void:
	if _mission != null:
		_mission.evenement("corps:charges")


# WALTER REPOSE LE CORPS POUR SOUFFLER, ET QUELQU'UN PARLE PAR-DESSUS.
#
# « a chaque pause, Walt puis Jesse lancera une phrase en fond : "Allez",
# "Ils arrivent, depeche !!", ou "putain qu'il sont lourds". » — retour du
# 23/08/2026, et les trois phrases sont de lui.
#
# EN FOND veut dire dans le bandeau, pas dans un cadre de dialogue : la pause
# dure trois secondes et demie, et ouvrir une conversation par-dessus
# ajouterait une touche a presser au moment precis ou l'on ne peut rien faire.
#
# Elles tournent au lieu d'etre tirees au hasard : deux pauses par corps, quatre
# en tout, et un tirage aleatoire sur trois phrases en repete une fois sur deux.
const AU_SOUFFLE := [
	"Walter : ... attendez. Attendez.",
	"Jesse : Ils arrivent, depechez-vous !!",
	"Walter : Putain, ce qu'ils sont lourds.",
	"Jesse : Allez, Mr. White. Allez !",
]

var _souffles := 0


func _sur_souffle(_reste: int) -> void:
	if _controleur == null:
		return
	_controleur.call("annoncer", str(AU_SOUFFLE[_souffles % AU_SOUFFLE.size()]))
	_souffles += 1


func _brancher_le_demarreur() -> void:
	for n in get_tree().get_nodes_in_group(Demarreur.GROUPE):
		var d := n as Demarreur
		if d == null:
			continue
		if not d.reussi.is_connected(_sur_moteur_lance):
			d.reussi.connect(_sur_moteur_lance)
		if not d.rate.is_connected(_sur_demarrage_rate):
			d.rate.connect(_sur_demarrage_rate)
		if not d.contact_mis.is_connected(_sur_contact):
			d.contact_mis.connect(_sur_contact)


# QUELQU'UN REAGIT QUAND ON ROULE, et c'est tout ce qui manquait.
#
# La sortie du fosse demande trois secondes de conduite. Pendant ces trois
# secondes, le jeu ne disait RIEN — le code l'assumait : « rien ne s'affiche,
# parce qu'il n'y a rien a corriger ». Sauf qu'un joueur qui s'arrete au bout
# d'une seconde et demie recommence a zero sans jamais savoir pourquoi.
#
# Guillaume est reste bloque dessus le 23/08/2026 a 23 h 24. Ca marchait.
#
# On ne met pas de compte a rebours : Guillaume en veut MOINS, du texte de
# mission — « faire en sorte que les PNJ autour parlent ou agissent pour nous
# attirer vers la suite ». C'est donc Jesse qui parle, et il dit exactement ce
# qu'un type paniqué dirait dans un camping-car qui remonte une pente.
func _brancher_les_roulages() -> void:
	for n in get_tree().get_nodes_in_group(Passage.GROUPE):
		var p := n as Passage
		if p == null or p.roule_depuis <= 0.0:
			continue
		if not p.commence.is_connected(_sur_roulage_commence):
			p.commence.connect(_sur_roulage_commence)
		if not p.interrompu.is_connected(_sur_roulage_interrompu):
			p.interrompu.connect(_sur_roulage_interrompu)


func _sur_roulage_commence() -> void:
	if _controleur != null:
		_controleur.call("annoncer", "Jesse : C'est ca, roule ! T'arrete pas !")


func _sur_roulage_interrompu() -> void:
	if _controleur != null:
		_controleur.call("annoncer",
				"Jesse : Non non non, pourquoi tu t'arretes ?!")


# LE MOTEUR A PRIS. C'est la reussite du geste qui vaut evenement, plus un
# appui sur un point : l'epave se reveille et la mission avance.
func _sur_moteur_lance() -> void:
	_reveiller_l_epave()
	if _mission != null:
		_mission.evenement(Demarreur.EVENEMENT)


# ET QUAND CA NE PREND PAS, JESSE LE DIT.
#
# « Si le joueur se trompe : Son de moteur qui se noie [...] Jesse fait une
# remarque style "Mr. White, seriously !" » Le son est joue par le demarreur ;
# la phrase est ici, parce que savoir qui parle et quand est le travail du
# scenario.
## LE MOTEUR SE NOIE, ET JESSE LE PREND MAL.
##
## La phrase etait ECRITE ICI, en anglais, sans sous-titre : « Jesse : Mr.
## White, seriously ! » Une replique en dur dans le code est une replique qu'on
## ne peut ni traduire, ni doubler, ni varier — et celle-ci tombait a
## l'identique aux trois echecs de suite.
##
## Elles vivent maintenant dans l'etape, sous « voix_demarrage », comme les
## consignes du guidage vivent sous « voix_relance ».
func _sur_demarrage_rate(_zone: int) -> void:
	_jesse_au_demarrage("rate")


## ON MET LE CONTACT : « come on, come on, come on ».
##
## « Jesse pendant le mini-jeu : au debut et de temps en temps. » — le retour
## du 23/08/2026. « De temps en temps » se lit ici : une phrase a l'ouverture du
## cadran, puis une toutes les quelques secondes tant qu'on cherche la zone.
func _sur_contact(mis: bool) -> void:
	_relance_demarrage = 0.0
	if mis:
		_jesse_au_demarrage("contact")


# CE QUE JESSE DIT PENDANT QU'ON CHERCHE, s'il y a lieu.
#
# Appele a chaque image par _process : le compte a rebours ne tourne QUE si un
# cadran est ouvert quelque part. Un demarreur ferme, et il n'y a rien a dire.
func _jesse_pendant_le_demarrage(delta: float) -> void:
	var ouvert := false
	for n in get_tree().get_nodes_in_group(Demarreur.GROUPE):
		var d := n as Demarreur
		if d != null and d.ouvert():
			ouvert = true
			break
	if not ouvert:
		_relance_demarrage = 0.0
		return
	_relance_demarrage += delta
	if _relance_demarrage >= RELANCE_DEMARRAGE:
		_relance_demarrage = 0.0
		_jesse_au_demarrage("attente")


## Toutes les combien de secondes il s'impatiente. Assez long pour qu'on ait le
## temps de rater une zone entre deux — trois secondes en feraient un metronome.
const RELANCE_DEMARRAGE := 4.5

var _relance_demarrage: float = 0.0
var _tour_demarrage: int = 0


# Les phrases vivent dans l'etape, rangees par moment : « contact », « attente »,
# « rate ». Une etape qui n'en declare pas est simplement muette, ce qui est le
# cas de toutes celles qui ne demarrent rien.
func _jesse_au_demarrage(moment: String) -> void:
	if _mission == null:
		return
	var table: Dictionary = _mission.etape().get("voix_demarrage", {})
	var phrases: Array = table.get(moment, [])
	if phrases.is_empty():
		return
	_crier(phrases[_tour_demarrage % phrases.size()], _ou_est_jesse())
	_tour_demarrage += 1


# D'OU SORT SA VOIX quand il n'y a pas de guidage pour le dire : de lui.
#
# Jesse est debout a cote du camping-car pendant qu'on essaie de le demarrer —
# c'est le battement A4 — et sa voix doit venir de la, pas du haut-parleur.
# A defaut, le joueur : mieux vaut une voix mal placee qu'une voix muette.
func _ou_est_jesse() -> Vector3:
	var racine: Node = get_tree().current_scene
	if racine == null:
		racine = get_tree().root
	var n := racine.find_child("JesseCrash", true, false) as Node3D
	if n != null:
		return n.global_position
	return _joueur.global_position if _joueur != null else Vector3.ZERO


# LES GESTES DE CUISINE, s'ils sont dans la scene.
#
# Meme forme que le demarreur, et pour la meme raison : la cuisine est une
# scene instanciee, on la cherche par son groupe. Son absence n'est pas une
# erreur — une partie sur deux ne passe jamais par le camping-car.
func _brancher_la_cuisine() -> void:
	for n in get_tree().get_nodes_in_group(Verseuse.GROUPE):
		var v := n as Verseuse
		if v != null:
			if not v.reussi.is_connected(_sur_versement_reussi):
				v.reussi.connect(_sur_versement_reussi)
			if not v.rate.is_connected(_sur_versement_rate):
				v.rate.connect(_sur_versement_rate)
			continue
		var c := n as Chauffe
		if c != null:
			if not c.reussi.is_connected(_sur_chauffe_reussie):
				c.reussi.connect(_sur_chauffe_reussie)
			if not c.rate.is_connected(_sur_chauffe_ratee):
				c.rate.connect(_sur_chauffe_ratee)
			continue
		var f := n as Fournee
		if f != null:
			if not f.finie.is_connected(_sur_fournee_finie):
				f.finie.connect(_sur_fournee_finie)
			if not f.ajoute.is_connected(_sur_ajout):
				f.ajoute.connect(_sur_ajout)


# LE BECHER EST PLEIN AU TRAIT. C'est la reussite du geste qui fait avancer
# l'etape, plus un appui sur un point.
func _sur_versement_reussi() -> void:
	if _mission != null:
		_mission.evenement(Verseuse.EVENEMENT)


# ET QUAND CA TOMBE A COTE, WALTER LE DIT — differemment selon la faute.
#
# « Les dialogues sont super, il faut les garder voire en rajouter. » Trois
# phrases, parce qu'un professeur de chimie ne corrige pas un debit trop fort
# comme une fiole videe pour rien : la premiere est une question de main, la
# seconde une question de tete.
const VERSEMENT_RATE := {
	"court": "Walter : Plus bas. Le verre n'ira pas le chercher.",
	"long": "Walter : Trop. Doucement — la vitesse est l'ennemie de la precision.",
	"vide": "Walter : Il n'en reste plus. Tout est par terre. On recommence.",
}


func _sur_versement_rate(faute: String) -> void:
	if _controleur == null:
		return
	_controleur.call("annoncer", VERSEMENT_RATE.get(faute,
			"Walter : Non. Recommence."))


# LA FOURNEE A PRIS SA COULEUR.
func _sur_chauffe_reussie() -> void:
	if _mission != null:
		_mission.evenement(Chauffe.EVENEMENT)


# ET QUAND CA DEBORDE, C'EST JESSE QUI PARLE.
#
# Pas Walter : il vient de faire un discours sur la precision, et le lui faire
# repeter au premier debordement en ferait un donneur de lecons. Jesse constate,
# ce qui est plus dur a entendre.
const CHAUFFE_RATEE := {
	"deborde": "Jesse : Ca deborde, ca deborde ! Baissez le feu !",
}


func _sur_chauffe_ratee(faute: String) -> void:
	if _controleur == null:
		return
	_controleur.call("annoncer", CHAUFFE_RATEE.get(faute,
			"Jesse : On a perdu la fournee."))


# LA FOURNEE EST FINIE, bien ou mal. L'etape avance dans les deux cas : c'est
# le seul geste de la cuisine qui ne se recommence pas, et il se paie en
# purete plutot qu'en temps.
func _sur_fournee_finie(_reussis: int) -> void:
	if _mission != null:
		_mission.evenement(Fournee.EVENEMENT)


# CE QUE JESSE DIT A CHAQUE AJOUT.
#
# Rien quand c'est juste : un commentaire a chaque bon geste transformerait
# trois ajouts en trois felicitations, et Walter vient d'expliquer que la
# precision est la norme, pas un exploit. Il ne parle que quand ca derape.
const AJOUT_RATE := {
	"mauvais": "Jesse : Pas celui-la, Mr. White !",
	"trop_tot": "Jesse : Attendez qu'elle le demande...",
	"trop_tard": "Jesse : Trop tard. Elle est retombee.",
}


func _sur_ajout(juste: bool, raison: String) -> void:
	if juste or _controleur == null:
		return
	_controleur.call("annoncer", AJOUT_RATE.get(raison, "Jesse : Aie."))


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
	# ON REBRANCHE LE DEMARREUR A CHAQUE ETAPE, et ce n'est pas de la
	# prudence gratuite.
	#
	# Il vit dans le decor du fosse, que desert.gd instancie A L'EXECUTION :
	# au moment ou le scenario branche ses signaux, ce decor n'existe pas
	# encore et le groupe est vide. Le mini-jeu se jouait donc, le moteur
	# « prenait », et rien ne reveillait l'epave — elle restait gelee, et le
	# camping-car ne repondait plus aux gaz.
	#
	# La connexion est idempotente, donc la refaire ne coute rien.
	_brancher_le_demarreur()

	# ET LES FOYERS, POUR LA MEME RAISON ET AU MEME ENDROIT.
	#
	# Un feu ne sait pas qui joue, et le chercher dans l'arbre par son nom
	# serait une adresse de plus a maintenir. On le lui donne — exactement comme
	# le controleur donne le joueur a l'habitant d'une maison.
	_brancher_les_feux()
	_brancher_la_traction()
	_brancher_le_guidage()

	# L'ETAPE PEUT DEMANDER QUE LA VOITURE DU JOUEUR SOIT GAREE QUELQUE PART.
	#
	# « Il faut pouvoir (devoir) rentrer avec notre voiture, garee non loin du
	# RV. » — retour du 23/08/2026. Le flashback se joue a neuf cents metres de
	# la ville : sans ca, la voiture est restee devant chez Walter et le passage
	# du retour, qui l'exige maintenant, serait une porte fermee.
	#
	# C'est un NOM DE NOEUD dans une donnee d'etape, comme tout le reste ici. Ce
	# fichier ne sait pas qu'il existe une clairiere.
	_garer_la_voiture()

	# EST-CE QUE L'ETAPE ENTRAVE LE JOUEUR ? C'est une donnee de la mission,
	# au meme titre que son filtre d'ecran : « lent »: true, et Walter se
	# traine. L'ouverture au masque s'en sert, et rien d'autre pour l'instant.
	if _joueur != null and _mission != null:
		_joueur.entrave = bool(_mission.etape().get("lent", false))

	# ET EST-CE QU'ELLE LUI MET QUELQUE CHOSE SUR LE VISAGE ?
	#
	# « J'ai aussi depose un model 3d de masque a gaz, a placer evidemment sur
	# Walter tant qu'il le porte. » — retour du 27/08/2026. Meme forme que le
	# filtre et que « lent » : l'ETAPE le declare, et ce fichier ne reconnait
	# aucun nom d'etape. Une blessure au bras, une capuche ou un tablier s'en
	# serviront sans qu'on touche au code.
	#
	# ON RETIRE CE QUI N'EST PLUS DEMANDE. Sans cette seconde moitie, Walter
	# garderait son masque a gaz pendant les vingt etapes suivantes, et
	# personne ne ferait le lien avec l'ouverture une heure plus tard — c'est
	# exactement ce qui est arrive a l'entrave « lent », ci-dessus.
	_porter_ce_que_l_etape_demande()

	# L'ETAPE PARLE TOUTE SEULE, SI ELLE A QUELQUE CHOSE A DIRE.
	#
	# « Enlever l'action de "ecouter", ca ne devrait pas etre une etape
	# cliquable, mais un dialogue lance automatiquement [...]. Pendant ce
	# dialogue, le joueur peut toujours jouer. » — retour du 23/08/2026.
	#
	# La conversation ne passe PAS par _parler() : c'est lui, et lui seul, qui
	# pose « bloque » sur Walter. Lancee d'ici, elle s'affiche pendant qu'on
	# marche, exactement comme celle de la botte secrete a l'atelier.
	#
	# LE NOM VIT DANS LA DONNEE. Ce fichier ne sait pas ce qu'est « crash_sirenes »
	# et n'a pas a le savoir — sans quoi on aurait ecrit « a l'etape remonter,
	# dire ceci », c'est-a-dire un nom d'etape reconnu par du code, qui est le
	# piege 39 et qui a deja coute trois soirees.
	_faire_parler_l_etape()

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


# La conversation que l'etape qui commence porte dans son champ « dit ».
#
# Rien si elle n'en porte pas, rien non plus si une autre est deja a l'ecran :
# deux conversations superposees ne se lisent ni l'une ni l'autre, et celle qui
# est en cours a ete demandee par le joueur.
func _faire_parler_l_etape() -> void:
	if _dialogue == null or _mission == null or _mission.finie():
		return
	var cle := str(_mission.etape().get("dit", ""))
	if cle == "" or _dialogue.actif():
		return
	_dialogue.demarrer(cle)


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
	_rattraper_le_decor()
	_gerer_l_appel(delta)
	_jesse_pendant_le_demarrage(delta)
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

	# ET LE TRAJET GUIDE, POUR LA MEME RAISON ET AVEC UNE HISTOIRE PLUS CHERE.
	#
	# Le guidage emet bien un signal quand son dernier jalon tombe, et c'est lui
	# qui fait tomber la derniere replique au bon moment. Mais il vit dans le
	# decor du fosse, que desert.gd instancie A L'EXECUTION : le scenario le
	# branche donc en retard, et c'est le premier mecanisme du jeu dont on a
	# besoin des la premiere etape.
	#
	# Selon la vitesse de la machine, le joueur pouvait finir son trajet avant
	# que quiconque n'ecoute. Le signal partait dans le vide, l'ouverture
	# attendait pour toujours, et le MEME jeu marchait une fois sur deux —
	# le genre de defaut qu'on met une heure a croire.
	#
	# On constate donc l'ETAT a chaque image, comme pour le volant juste
	# au-dessus. Le signal reste, il n'est plus le seul chemin.
	if str(_mission.etape().get("valide_par", "")) == "guidage:fini":
		for n in get_tree().get_nodes_in_group(Guidage.GROUPE):
			var g := n as Guidage
			if g != null and g.termine():
				_mission.evenement("guidage:fini")
				break


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
	# Jesse dans la clairiere. Il accueille Walter a l'arrivee, propose le
	# raccourci a mi-cuisine, et ferme la mission en disant a QUI l'on va vendre
	# ce qu'on vient de faire. Sans ces lignes il rejouerait « Bienvenue dans le
	# bureau » a chaque fois qu'on lui parle, et deux etapes ne passeraient
	# jamais.
	"cuisine_arrivee": [
		["raccourci", "cuisine_raccourci"],
		["conclusion", "cuisine_krazy8"],
	],
	# JESSE AU FOND DU FOSSE, ET IL REPOND SELON CE QU'ON EN EST.
	#
	# « On peut parler a Jesse n'importe quand. Selon l'etape ou en est le
	# joueur, il peut repondre par la panique "on est dans la merde.." ou une
	# indication sur ce qu'il faut faire, style "on peux pas laisser tout le
	# matos dehors, on va se faire choper direct". » — retour du 23/08/2026.
	#
	# Son noeud porte une cle unique, donc sans ces lignes il rejouait « faut y
	# aller MAINTENANT » a chaque fois qu'on lui adressait la parole, y compris
	# le materiel deja en poche. Un personnage qui repete la meme phrase pendant
	# toute une scene cesse d'etre quelqu'un.
	#
	# Les trois etapes de ramassage partagent la meme reponse : ce qu'il dit
	# alors ne depend pas du nombre d'objets, et lui faire compter a voix haute
	# donnerait au joueur le chiffre que l'objectif lui refuse expres.
	"crash_panique": [
		["preuve_1", "crash_jesse_ramassage"],
		["preuve_2", "crash_jesse_ramassage"],
		["preuve_3", "crash_jesse_ramassage"],
		["demarrer", "crash_jesse_tout_pris"],
	],
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
	# LE PANTALON DECIDE DE LA QUESTION QU'ON POSE.
	#
	# « Une fois les 3 objets ramasses, on peut parler a Jesse, il nous demande
	# si on a bien tout pris. On a un choix a faire [...] SI le joueur a trouve
	# le pantalon avant de parler a Jesse, celui-ci ne proposera pas le choix. A
	# la place il fera une remarque sur le pantalon de Walt. » — retour du
	# 23/08/2026.
	#
	# C'est toute l'astuce de Guillaume : la question « t'as bien tout pris ? »
	# met la puce a l'oreille SANS jamais nommer le pantalon. La poser a un homme
	# qui le tient deja a la main serait la seule facon de la rendre stupide.
	"crash_jesse_tout_pris": [["pantalon", "crash_jesse_pantalon"]],
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
				cle = str(regle[1])
				break
	# L'OBJET RAFFINE CE QUE L'ETAPE A CHOISI, il ne se contente plus d'attendre
	# qu'elle n'ait rien dit.
	#
	# Cette table rendait la main des qu'une regle d'etape avait repondu : un
	# « return » sortait de la fonction. Ca suffisait tant que les deux tables ne
	# parlaient jamais du meme moment.
	#
	# Le retour du 23/08/2026 en demande un ou elles se croisent : « une fois les
	# 3 objets ramasses, on peut parler a Jesse, il nous demande si on a bien tout
	# pris [...] SI le joueur a trouve le pantalon avant de parler a Jesse,
	# celui-ci ne proposera pas le choix. A la place il fera une remarque sur le
	# pantalon de Walt. » C'est l'etape QUI decide qu'on en est la, et l'objet qui
	# decide laquelle des deux versions se joue.
	#
	# L'ORDRE NE CHANGE RIEN AUX DEUX CAS EXISTANTS : la boite d'oeufs vise
	# « mission_jesse_camping », que sa regle d'etape ne remplace qu'a
	# « aller_tuco » — et la version remplacee ne figure dans aucune des deux
	# tables. Les deux chemins donnent donc ce qu'ils donnaient.
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


# ON ESSAIE D'ETEINDRE, ET CA NE MARCHE JAMAIS.
#
#   « Si on execute l'action, Walter s'approche du feu puis recule de 2 pas en
#     toussant et en se couvrant la bouche de son coude. Cela pourra rajouter du
#     temps de jeu et du stress au joueur quand il entendra les sirenes. Le jeu
#     ne dira JAMAIS au joueur qu'il est impossible d'eteindre les flammes.
#     C'est une mecanique pour creer du stress et etre fidele a la serie. »
#     — retour du 23/08/2026.
#
# LA DERNIERE PHRASE EST LA PLUS DURE A TENIR, parce que tout dans ce projet
# pousse a la trahir. Un point qui ne fait rien passe pour casse : la parade
# habituelle est le champ « refus » de point.gd, qui affiche une ligne du genre
# « les flammes sont trop hautes ». Ce serait exactement le texte de mission que
# le meme retour demande de supprimer partout ailleurs, et il transformerait un
# geste en porte fermee.
#
# CE QUI REMPLACE LE TEXTE : le corps. Walter est repousse de deux pas sans se
# retourner, il tousse, et le feu brule pareil. Il n'y a rien a lire et rien a
# comprendre — on a essaye, on a vu, on decide soi-meme si on reessaie.
#
# Et le cout est le seul vrai : trois secondes de moins, pendant qu'une sirene
# monte.
func _essayer_d_eteindre(p: Point) -> void:
	if _joueur == null:
		return
	# LE RECUL PART DU FEU, PAS DU POINT.
	#
	# Les deux sont au meme endroit aujourd'hui — le point est pose sur le
	# foyer — et c'est precisement pourquoi il faut choisir : le jour ou l'on
	# decalera l'invite pour qu'elle se propose d'un cote precis, un recul
	# calcule sur elle pousserait Walter de travers.
	var foyer: Node3D = p.get_parent() as Node3D
	if foyer == null:
		foyer = p
	var vers_l_arriere := _joueur.global_position - foyer.global_position
	# A l'aplomb du foyer — ce qui ne devrait pas arriver, mais qui arriverait
	# le jour ou l'on baisse une portee — il recule vers ou il regarde.
	if vers_l_arriere.length_squared() < 0.01:
		vers_l_arriere = -_joueur.global_transform.basis.z
	_joueur.repousser(vers_l_arriere, DUREE_DU_RECUL)
	if _son() != null:
		_son().bruit_ici("toux", _joueur.global_position)


# LE PREMIER TOUR DE CLE : LE MOTEUR TOUSSE ET NE PREND PAS.
#
# « JUSTE au moment de d'essayer de demarrer le RV pour la premiere fois (bruit
# de moteur qui ne demarre pas), l'un des deux personnage lance un dialogue
# (stop le RV aussi). » — retour du 23/08/2026.
#
# TROIS CHOSES, DANS CET ORDRE, ET L'ORDRE EST LE SUJET :
#
#   1. le bruit. Le demarreur du jeu, joue GRAVE — le meme geste que sur un
#      essai rate du mini-jeu, et il s'entend comme un moteur qui se noie ;
#   2. Walter descend. « Stop le RV aussi » : rester assis pendant que Jesse
#      dit qu'il faut aller chercher les corps ferait une scene ou personne ne
#      bouge, et obligerait le joueur a trouver tout seul qu'il doit sortir ;
#   3. la conversation. Elle n'est PAS lancee ici : elle est le champ « dit »
#      de l'etape suivante, qui commence a la seconde ou cet evenement
#      l'a validee. Une conversation lancee a la main ici se serait jouee
#      pendant que Walter est encore au volant, c'est-a-dire avant le geste
#      qu'elle commente.
func _le_moteur_ne_prend_pas() -> void:
	if _son() != null:
		_son().bruit("demarreur", Audio.BUS_INTERFACE, 0.55)
	if _controleur != null and _controleur.has_method("descendre_du_vehicule"):
		_controleur.call("descendre_du_vehicule")


## Combien de temps Walter recule devant les flammes, en secondes.
##
## Un peu plus d'une seconde a l'allure la plus lente du jeu, c'est-a-dire les
## deux pas que le retour decrit. Plus long donnerait une fuite ; plus court, un
## recul qu'on ne verrait pas.
const DUREE_DU_RECUL := 1.2


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
	if p.evenement == "action:eteindre":
		_essayer_d_eteindre(p)
	if p.evenement == "action:contact":
		_le_moteur_ne_prend_pas()
	if p.evenement == "action:botte_bureau":
		_faire_exploser()
	if p.evenement == "action:livraison":
		livrer_la_marchandise()
	if p.evenement == "action:courses_posees":
		var avec := poser_les_courses()
		if _dialogue != null:
			_dialogue.demarrer("skyler_courses_oui" if avec else "skyler_courses_non")
	# CE GESTE FAIT MONTER LA SIRENE. Voir Point.sirene : c'est un plancher, pas
	# un niveau, et le seul a s'en servir aujourd'hui est le regard sur les deux
	# corps — que le retour du 23/08/2026 a sorti du suivi de mission, donc
	# qu'aucune etape ne peut plus faire monter.
	if p.sirene > 0.0:
		var s := get_tree().get_first_node_in_group("sirene")
		if s != null and s.has_method("pousser"):
			s.call("pousser", p.sirene)
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
