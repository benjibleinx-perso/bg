# L'affichage tete haute.
#
# Il vit DANS le SubViewport, sur un Control de 512 x 384.
#
# L'ARGUMENT D'ORIGINE ETAIT FAUX, et il vaut mieux le dire que le laisser :
# « un texte net superpose a une image basse resolution trahirait un jeu
# moderne ». Les HUD PS2 partageaient le tampon de la 3D, c'est vrai — mais ici
# l'interface est agrandie 2,8 fois quand la 3D ne l'est que d'1,5. Elle n'a
# donc jamais partage le grain du jeu : elle est DEUX FOIS plus grossiere.
#
# Vu en jeu le 16/08/2026 : « c'est pixellise, ca fait trop vieux ». Le constat
# mesure et les deux impasses deja explorees sont dans
# docs/14-boite-a-idees.md — le chantier est ouvert, pas oublie.
#
# Regle de conduite : n'afficher que ce qui change. Un compteur immobile a
# l'ecran pendant qu'on marche est du bruit, pas de l'information.
class_name Hud
extends Control

@export var reglages: Reglages
@export var equipement: NodePath
@export var controleur: NodePath
@export var joueur: NodePath
@export var tir: NodePath

## L'icone du sac de billets, livree par Guillaume et detouree par
## outils/detourer.py. Sans elle le montant s'affiche quand meme, precede d'un
## dollar : une image manquante ne doit jamais faire disparaitre l'information.
@export var icone_argent: Texture2D

## Le portrait de Walter, a gauche de sa barre de vie.
##
## Ce n'est plus un dessin procedural depuis le 28/08/2026 : « refais le visage
## de Walter qui est horriblement laid (a cote de la barre de vie), mets une
## image de son visage (quand il a encore des cheveux) ». C'est une image
## generee, decrite dans outils/assets-ia.json sous la cle « hud_visage ».
##
## 64 pixels de texture pour 32 points d'interface : l'interface entiere est
## agrandie avant d'atteindre l'ecran, donc une texture a sa taille d'affichage
## y arrive deux fois trop grossiere.
@export var icone_visage: Texture2D

var _eq: Equipement
var _c: Node
var _j: Joueur
var _tir: Tir
var _bourse: Bourse
var _famille: Famille
var _reputation: Reputation
var _mission: Mission

## Le montant AFFICHE, qui rattrape le montant reel. Voir trois cent mille
## dollars apparaitre d'un coup ne se lit pas ; les voir defiler en une
## seconde, si — et c'est la seule facon de sentir la somme.
var _affiche: float = 0.0

## Compte a rebours d'affichage de l'objectif, apres un changement d'etape.
var _objectif: float = 0.0
var _texte_objectif: String = ""

## Rouge a l'ecran quand on prend un coup. C'est le seul retour immediat : une
## barre qui descend en haut a gauche ne se voit pas quand on regarde devant.
var _douleur: float = 0.0

## Compte a rebours d'affichage du nom de l'outil, en secondes. L'objet
## equipe se voit dans la main : le nom n'a d'interet qu'a l'instant du
## changement, apres quoi il encombre.
var _annonce: float = 0.0
var _texte_annonce: String = ""

## L'objet en main. Son nom ne s'affiche qu'une seconde et demie a l'equipement
## — assez pour savoir ce qu'on vient de prendre, pas pour s'en souvenir deux
## minutes plus tard. Le rappel permanent vit en bas a gauche.
var _outil: int = -1

## CE QUE LE GUIDAGE A DIT A LA DERNIERE IMAGE : combien de temps le picto doit
## encore se voir, sur quelle duree il s'efface, et de quel cote pointer.
var _voix_echo: float = 0.0
var _voix_duree: float = 1.0
var _voix_angle: float = 0.0

## LA PALETTE DE LA SERIE, en un endroit.
##
## Breaking Bad tient dans trois couleurs : le vert-olive de la case du
## tableau periodique, l'ambre du desert, le rouge du sang. Les avoir nommees
## ici evite qu'elles derivent d'un dessin a l'autre — c'est ce qui etait en
## train d'arriver, chaque fonction ayant sa propre nuance de vert.
const BB_OLIVE := Color(0.420, 0.498, 0.369)  # kaki de Walt, charte docs/20
const BB_AMBRE := Color(0.949, 0.776, 0.420)
const BB_ROUGE := Color(0.702, 0.208, 0.161)

## LES TROIS RESSOURCES ONT CHACUNE LEUR TEINTE, prises dans la charte
## (docs/20) : jaune securite pour l'argent, bleu ardoise pour la famille,
## rouge sourd pour la rue. Elles ne servent QUE la, et surtout pas au decor —
## la charte reserve ces couleurs a ce qu'elles signifient.
const BB_JAUNE := Color(0.96, 0.77, 0.19)
const BB_BLEU := Color(0.44, 0.58, 0.74)
const BB_RUE := Color(0.78, 0.36, 0.28)

## La taille du portrait A L'ECRAN, en points d'interface. La texture, elle, est
## deux fois plus fine : voir le commentaire dans _etat_du_joueur.
const PORTRAIT := 32.0
const COULEUR_FOND := Color(0.055, 0.050, 0.042, 0.80)

## LE NOIR DE L'INTERFACE EST CHAUD.
##
## Il etait a #0B0E16 — un bleu nuit. Sur un jeu entierement pose dans un
## desert d'adobe et de sable (#C19A6B, #D9C7A3 dans la charte), un fond bleu
## n'appartient a aucune des images qu'il recouvre : c'est ce qui le fait lire
## comme une couche etrangere plutot que comme une ombre du decor.
##
## #0E0D0B : le meme noir, decale vers le brun. Personne ne nommera la
## difference, tout le monde verra que ca tient ensemble.
const FOND := Color(0.055, 0.050, 0.042, 0.62)


func _ready() -> void:
	_eq = get_node_or_null(equipement) as Equipement
	_c = get_node_or_null(controleur)
	_j = get_node_or_null(joueur) as Joueur
	_tir = get_node_or_null(tir) as Tir
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _eq != null:
		_eq.change.connect(_sur_changement_outil)
	if _j != null:
		_j.blesse.connect(_sur_blessure)
	# La bourse et la mission sont retrouvees APRES la construction de la
	# scene : elles se declarent dans leur groupe a leur propre _ready, qui
	# peut passer apres celui-ci.
	call_deferred("_brancher_la_mission")
	set_process(true)


func _brancher_la_mission() -> void:
	_bourse = Bourse.courante(self)
	_famille = Famille.courante(self)
	_reputation = Reputation.courante(self)
	_mission = Mission.courante(self)
	if _bourse != null:
		_affiche = float(_bourse.montant())
	if _mission != null:
		_mission.etape_changee.connect(_sur_etape)
		# La PREMIERE etape n'emet aucun changement : on y est deja. Son
		# objectif ne s'affichait donc jamais, et la partie s'ouvrait sans dire
		# ce qu'on attend du joueur.
		_sur_etape(_mission.index())


## COMBIEN DE TEMPS L'OBJECTIF RESTE A L'ECRAN, en secondes.
##
## Il tenait quatre secondes, en petit, par-dessus le decor. Sur un ecran de
## 512 pixels ou l'on est en train de traverser une rue, quatre secondes ne
## suffisent pas a lire une phrase et a decider quoi en faire — l'information
## passait avant d'avoir servi.
##
## Une minute, c'est ce que le ticket demande, et c'est aussi la duree pendant
## laquelle un objectif est encore une NOUVELLE. Apres, il vit dans le
## telephone : c'est la qu'on va le relire.
const OBJECTIF_DUREE := 60.0

## Sur combien de temps il s'efface, a la fin. Assez long pour qu'on voie qu'il
## part, assez court pour ne pas trainer.
const OBJECTIF_FONDU := 2.5


func _sur_etape(_index: int) -> void:
	if _mission == null:
		return
	_texte_objectif = _mission.objectif()
	# UNE ETAPE FACULTATIVE LE DIT.
	#
	# Le pantalon du fosse peut se sauter — on remonte dans le camping-car et la
	# mission continue — mais son objectif s'affichait exactement comme les
	# autres. Resultat : « le pantalon est obligatoire pour continuer
	# l'histoire ? ». On ne peut pas repondre non a une question que le jeu pose
	# lui-meme en affichant la consigne du meme ton que les vraies.
	#
	# Deux mots entre parenthetes, et rien de plus : ce n'est pas un chiffre, et
	# ca ne dit pas ce qu'on gagne a le faire. Le joueur presse passe, celui qui
	# fouille trouve — c'est exactement ce que le script voulait.
	if not _texte_objectif.is_empty() \
			and bool(_mission.etape().get("facultative", false)):
		_texte_objectif += "  (facultatif)"
	_objectif = 0.0 if _texte_objectif == "" else OBJECTIF_DUREE


func _sur_blessure(_restant: float) -> void:
	_douleur = 1.0


func _sur_changement_outil(i: int) -> void:
	_texte_annonce = _eq.nom_de(i) if i >= 0 else "Mains vides"
	_annonce = reglages.hud_annonce
	_outil = i


func _process(delta: float) -> void:
	if _annonce > 0.0:
		_annonce = maxf(0.0, _annonce - delta)
	if _objectif > 0.0:
		_objectif = maxf(0.0, _objectif - delta)
	if _douleur > 0.0:
		_douleur = maxf(0.0, _douleur - delta * 1.6)
	if _bourse != null:
		var somme := float(_bourse.montant())
		# Un rattrapage proportionnel a l'ECART, avec un plancher : sans le
		# plancher, les derniers dollars mettent une eternite ; sans le
		# proportionnel, trois cent mille prendraient une minute.
		var pas := maxf(absf(somme - _affiche) * 3.0, 900.0) * delta
		_affiche = move_toward(_affiche, somme, pas)
	_relever_la_voix()
	queue_redraw()


## CE QU'ON DEMANDE AU GUIDAGE, UNE FOIS PAR IMAGE ET PAS PENDANT LE DESSIN.
##
## `_draw` ne doit rien chercher dans l'arbre : la recherche d'un groupe et
## l'appel de trois methodes d'un autre systeme au milieu d'un tracage se paient
## comptant, et ca s'est vu — la suite « ouverture » s'arretait sans un mot,
## code 255, apres avoir passe tous ses controles. Le dessin ne lit plus que
## trois nombres poses ici.
func _relever_la_voix() -> void:
	_voix_echo = 0.0
	var g := get_tree().get_first_node_in_group(Guidage.GROUPE) as Guidage
	if g == null or not g.active():
		return
	_voix_echo = g.echo_restant()
	if _voix_echo <= 0.0:
		return
	_voix_duree = g.echo
	_voix_angle = g.angle_du_jalon()


func _au_volant() -> bool:
	# On interroge le controleur plutot que de deviner : c'est lui qui possede
	# l'etat, et deux sources de verite finissent toujours par diverger.
	return _c != null and _c.call("au_volant")


func _draw() -> void:
	var police := get_theme_default_font()
	if police == null:
		return

	_version(police)
	_bandeau(police)
	_etat_du_joueur(police)
	_objectif_courant(police)
	_objet_en_main(police)
	_reticule()
	_d_ou_vient_la_voix()

	# LE COMPTEUR DE VITESSE A ETE RETIRE le 08/08/2026, et il n'avait jamais eu
	# sa place ici.
	#
	# Deux raisons, et la seconde suffisait a elle seule.
	#
	# Il occupait le coin bas droit, ou la minimap est arrivee : les deux se
	# recouvraient. Mais surtout, la REGLE 1 du projet ne souffre que trois
	# exceptions — l'argent, la famille, la reputation — et une vitesse n'en est
	# pas une. « Un chiffre transforme un choix en optimisation. » On sent qu'on
	# va vite au bruit du moteur, a la camera qui recule et au grain de la
	# route ; on n'a pas besoin de lire 87.
	#
	# Le cadran etait soigne — arc de 200 degres cale sur la vitesse maximale
	# reelle, aiguille, graduations — et c'est justement pour ca qu'il valait la
	# peine de dire pourquoi il part.

	if _annonce > 0.0:
		# Fondu sur le dernier tiers, pour que ca ne disparaisse pas d'un coup.
		var a := clampf(_annonce / maxf(0.01, reglages.hud_annonce * 0.33), 0.0, 1.0)
		_ecrire(police, _texte_annonce, Vector2(size.x / 2.0, size.y - 62.0),
				17, Color(0.949, 0.776, 0.42, a), true)


# D'OU VIENT LA VOIX, quand on ne voit rien.
#
# LE SEUL REPERE DIRECTIONNEL DU JEU, et il est demande noir sur blanc :
#
#   « peut-etre faire apparaitre un picto leger sur la vision du joueur pour
#     lui indiquer d'ou vient le son. Afin qu'il puisse quand meme atteindre sa
#     destination rien qu'avec le visuel. Les voix sont surtout la pour
#     rajouter du realisme. » — retour du 27/08/2026
#
# CE QUI LE REND ACCEPTABLE MALGRE LA REGLE : il n'est pas permanent. Il ne
# vit que trois secondes apres chaque replique de Jesse, et c'est le guidage
# qui tient ce compte a rebours — le HUD lui demande « combien de temps
# encore » et « de quel cote », il ne decide de rien, comme pour le bandeau.
# Une boussole allumee en continu serait l'inverse de la scene : on ne voit
# rien, on ECOUTE, et ce chevron est l'echo de ce qu'on vient d'entendre.
#
# CE QU'IL DESSINE : un chevron pose sur un arc au-dessus du reticule, decale
# horizontalement selon l'angle. Devant, il est au centre ; sur le cote, il
# glisse vers le bord ; derriere, il se colle au bord et se retourne. Pas de
# distance, pas de fleche pleine, pas de cible — « leger » est le mot du
# retour, et un demi-cercle de six pixels suffit a dire « par la ».
func _d_ou_vient_la_voix() -> void:
	if _voix_echo <= 0.0:
		return

	# Le fondu se calcule sur la duree ANNONCEE par le guidage, pas sur une
	# constante recopiee : les deux divergeraient au premier reglage.
	var a := clampf(_voix_echo / maxf(0.01, _voix_duree * 0.5), 0.0, 1.0)
	var angle := _voix_angle
	var derriere := absf(angle) > PI * 0.5

	# L'ANGLE DEVIENT UNE POSITION. Un quart de tour couvre la moitie de la
	# largeur : au-dela on est colle au bord, ce qui est exactement ce qu'on
	# veut dire — « c'est plus loin de ce cote-la ».
	var t := clampf(angle / (PI * 0.5), -1.0, 1.0)
	var x := size.x * 0.5 + t * size.x * 0.42
	var y := size.y * 0.5 - 34.0
	var couleur := Color(BB_AMBRE.r, BB_AMBRE.g, BB_AMBRE.b, a)

	# Le chevron pointe VERS la source : a droite quand elle est a droite, et
	# retourne quand elle est derriere — un chevron qui pointe vers l'avant
	# alors qu'il faut faire demi-tour est pire que pas de chevron.
	var sens := signf(t) if absf(t) > 0.05 else 0.0
	var large := 7.0
	var haut := 5.0
	if sens == 0.0:
		# DEVANT : deux traits qui montent, comme une pointe vers le haut.
		draw_line(Vector2(x - large, y + haut), Vector2(x, y), couleur, 2.0)
		draw_line(Vector2(x, y), Vector2(x + large, y + haut), couleur, 2.0)
		return
	if derriere:
		# DERRIERE : le meme chevron, tete en bas, colle au bord.
		draw_line(Vector2(x - large, y - haut), Vector2(x, y), couleur, 2.0)
		draw_line(Vector2(x, y), Vector2(x + large, y - haut), couleur, 2.0)
		return
	# DE COTE : couche, la pointe vers le bord.
	draw_line(Vector2(x - large * sens, y - haut), Vector2(x, y), couleur, 2.0)
	draw_line(Vector2(x, y), Vector2(x - large * sens, y + haut), couleur, 2.0)


# Un bandeau en haut de l'ecran, quand le jeu a quelque chose a refuser ou a
# annoncer. Le texte vient du controleur : le HUD ne decide de rien, il dessine.
#
# Une bande sombre derriere, pas seulement du texte : le haut de l'ecran est
# le ciel, et un texte clair sur un ciel clair de midi ne se lit pas.
func _bandeau(police: Font) -> void:
	if _c == null:
		return
	var texte: String = _c.call("bandeau")
	if texte == "":
		return
	var a: float = _c.call("bandeau_opacite")
	var h := 22.0
	# IL PASSE SOUS LES RESSOURCES ET SOUS L'OBJECTIF, et il ne le faisait pas.
	#
	# Il etait pose a y = 26 : le bloc des trois ressources occupe 2 a 50, et
	# l'objectif 52 a 71. « Jesse : Par ici, Mr. White ! » se dessinait donc
	# PAR-DESSUS « Famille 60 » et « Rue 10 », les deux textes melanges dans la
	# meme bande de vingt pixels. Vu sur deux captures d'affilee le 27/08/2026 —
	# et jamais avant, parce qu'aucune vue de controle ne montrait le HUD avec
	# une replique en cours.
	#
	# Les trois blocs se suivent maintenant : ressources, objectif, ce qui se
	# dit. Un quatrieme qui arriverait un jour se posera a 100.
	_voile(Rect2(Vector2(0.0, 75.0), Vector2(size.x, h)),
			Color(FOND.r, FOND.g, FOND.b, 0.80 * a), Vector2(0.0, 1.0), 0.15)
	_ecrire(police, texte, Vector2(size.x / 2.0, 90.0), 13,
			Color(0.949, 0.925, 0.867, a), true)


# La version, en haut a droite, en permanence.
#
# C'est la seule chose affichee tout le temps, et elle enfreint donc la regle
# de conduite du fichier. La raison la vaut : quand quelqu'un envoie une
# capture d'ecran en disant que quelque chose ne marche pas, la premiere
# question est toujours « tu es sur quelle version ». Elle est maintenant sur
# l'image.
#
# Assez petite et assez pale pour disparaitre du regard — 9 points a 512 de
# large, c'est la taille d'une mention legale.
func _version(police: Font) -> void:
	# UNE PLAQUE SOUS ELLE, POUR LA MEME RAISON QUE SOUS LES RESSOURCES.
	#
	# Grise a 55 % sur un ciel de midi, elle disparaissait completement — et
	# c'est exactement ce qu'elle ne doit pas faire : elle existe pour qu'une
	# capture d'ecran envoyee a deux heures du matin dise sur quelle version
	# elle a ete prise. Vue illisible sur les deux captures du 27/08/2026, celle
	# de l'entree de ville et celle du labo.
	#
	# La plaque est plus discrete que celle des ressources — c'est une mention
	# legale, pas une information de jeu.
	var texte := Version.texte()
	var large := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1,
			9).x
	draw_rect(Rect2(Vector2(size.x - large - 12.0, 4.0),
			Vector2(large + 10.0, 15.0)),
			Color(0.055, 0.050, 0.042, 0.42))
	_ecrire(police, texte, Vector2(size.x - 6.0, 14.0), 9,
			Color(0.88, 0.86, 0.80, 0.75), false, HORIZONTAL_ALIGNMENT_RIGHT)


# L'ETAT DU JOUEUR : son visage, sa vie, son argent. Un seul bloc.
#
# Les trois etaient dispersés : l'argent en haut a gauche, la barre de vie
# dessous et SEULEMENT quand elle n'etait pas pleine, ce qui deplacait tout au
# premier coup recu. Trois informations sur la meme personne se lisent comme
# une seule, et une interface qui bouge toute seule oblige a la relire.
#
# La barre est desormais TOUJOURS la. La regle du fichier dit de n'afficher que
# ce qui change ; celle-ci est l'exception que sa fonction justifie, comme
# l'argent et la version — on veut savoir ou l'on en est avant de pousser une
# porte, pas apres avoir pris une balle.
func _etat_du_joueur(police: Font) -> void:
	var coin := Vector2(6.0, 6.0)
	var haut := 26.0
	var x := coin.x

	# UNE PLAQUE SOUS TOUT LE BLOC, et elle n'est pas decorative.
	#
	# Le desert est clair, les facades d'adobe aussi : l'olive du texte y
	# passait du lisible au devinable selon l'endroit ou l'on se tenait. Vu a
	# la capture de l'entree de ville, ou « Famille 60 » se posait sur un ciel
	# de midi.
	#
	# Elle est SOMBRE ET TRANSPARENTE plutot qu'opaque : ce qu'elle porte doit
	# se lire, mais un bandeau plein en haut de l'ecran mangerait le decor
	# qu'on est en train de traverser.
	_voile(Rect2(coin - Vector2(6.0, 6.0), Vector2(300.0, haut + 26.0)),
			FOND, Vector2(1.0, 0.35), 0.0)

	if icone_visage != null:
		# LA TAILLE D'AFFICHAGE EST FIXE, elle ne suit plus celle du fichier.
		#
		# Le portrait etait dessine a sa taille native. Le jour ou il est passe
		# de 32 a 64 pixels — pour qu'il cesse d'etre grossier une fois
		# l'interface agrandie — il a double a l'ecran et recouvert le bandeau
		# d'objectif. Vu a la capture.
		#
		# Ce que la texture gagne en finesse ne doit rien changer a la mise en
		# page : trente-deux points d'interface, quelle que soit sa definition.
		var cadre := Rect2(coin, Vector2(PORTRAIT, PORTRAIT))
		# Un lisere derriere le portrait : sans lui il flotte sur le decor, et
		# sur une facade claire on ne distingue plus ses contours.
		draw_rect(Rect2(coin - Vector2(1.0, 1.0),
				Vector2(PORTRAIT + 2.0, PORTRAIT + 2.0)),
				Color(0.055, 0.050, 0.042, 0.8))
		draw_texture_rect(icone_visage, cadre, false)
		x += PORTRAIT + 5.0

	# LA BARRE DE VIE EST SEGMENTEE, comme une jauge de laboratoire.
	#
	# Elle etait un rectangle plein qui se vidait en continu. A 512 pixels de
	# large, une longueur continue ne se lit pas : on voit qu'elle a baisse,
	# jamais de combien. Douze segments se COMPTENT du coin de l'oeil, et c'est
	# ce qu'on veut d'une barre de vie — savoir combien il en reste, pas
	# regarder un degrade.
	#
	# Le segment en cours de perte reste allume a demi : sans ca la barre saute
	# par a-coups de huit pour cent et donne l'impression de mentir.
	if _j != null:
		var l := 78.0
		var h := 7.0
		var barre := Vector2(x, coin.y + 2.0)
		draw_rect(Rect2(barre, Vector2(l, h)), COULEUR_FOND)
		var part := clampf(_j.pv / 100.0, 0.0, 1.0)
		# Olive quand tout va bien, ambre, puis rouge : la couleur dit
		# l'urgence avant que le compte ne se lise.
		var teinte := BB_ROUGE.lerp(BB_AMBRE, clampf(part * 2.0, 0.0, 1.0))
		teinte = teinte.lerp(BB_OLIVE, clampf((part - 0.5) * 2.0, 0.0, 1.0))
		var n := 12
		var pas := l / float(n)
		for k in n:
			var rempli := part * n - k
			if rempli <= 0.0:
				continue
			var c := teinte
			if rempli < 1.0:
				c.a = 0.45
			draw_rect(Rect2(barre + Vector2(k * pas + 1.0, 1.0),
					Vector2(pas - 2.0, h - 2.0)), c)
		draw_rect(Rect2(barre, Vector2(l, h)), Color(0.72, 0.70, 0.64, 0.45),
				false, 1.0)

	# L'argent, sous la barre, aligne sur elle.
	if _bourse == null:
		return
	var xa := x
	var ya := coin.y + haut - 6.0
	if icone_argent != null:
		draw_texture(icone_argent, Vector2(xa, ya - 8.0))
		xa += icone_argent.get_width() + 4.0
	# CHAQUE RESSOURCE A SA COULEUR, ET C'EST LA CHARTE QUI LES DONNE.
	#
	# Les trois etaient olive, donc identiques : trois nombres de la meme
	# teinte alignes sur une ligne se lisent comme un seul bloc, et il faut
	# lire les mots pour savoir lequel est lequel. Or on les regarde en
	# conduisant.
	#
	# docs/20-charte-graphique.md associe une teinte a un sens, et ces trois-la
	# tombent juste : le jaune securite est « le business de la meth, danger
	# autant qu'excitation » — c'est l'argent ; le bleu ardoise est Skyler,
	# « loyaute, un foyer qui tient encore » — c'est la famille ; le rouge
	# sourd est Jesse et la rue.
	_ecrire(police, Bourse.ecrire(roundi(_affiche)), Vector2(xa, ya + 3.0), 13,
			BB_JAUNE, false)

	# LES POINTS DE FAMILLE, a droite de l'argent et en permanence.
	#
	# C'est l'UN DES TROIS chiffres que le jeu montre — l'argent, la famille, la
	# reputation — et la regle 1 du projet n'en admet pas d'autre. Ce
	# commentaire disait « le seul chiffre du jeu qui se montre », ce qui etait
	# faux le jour ou il a ete ecrit : les trois ressources sont a l'ecran en
	# permanence depuis la meme decision du 06/08/2026, et elles sont dessinees
	# a quinze lignes d'ici. Il se lit d'un coup d'oeil en conduisant, donc il
	# CHANGE DE COULEUR plutot que de demander une comparaison : on ne calcule
	# pas « 22 sur 100 » au volant, on voit du rouge.
	if _famille == null:
		return
	var p := _famille.points()
	# Le bleu au repos, l'ambre quand ca se fissure, le rouge quand ca lache :
	# la couleur dit l'etat avant que le nombre ne se lise. C'est deja ce que
	# fait la barre de vie, et pour la meme raison — on ne calcule pas « 22 sur
	# 100 » au volant.
	var teinte := BB_BLEU
	if p <= 25:
		teinte = BB_ROUGE
	elif p <= 50:
		teinte = BB_AMBRE
	_ecrire(police, "Famille %d" % p, Vector2(xa + 74.0, ya + 3.0), 13,
			teinte, false)

	# LA REPUTATION, troisieme et dernier compteur. Elle monte quand la famille
	# descend — c'est tout le sujet du jeu, et les avoir cote a cote est ce qui
	# le donne a voir sans une ligne de dialogue.
	if _reputation == null:
		return
	var r := _reputation.points()
	# Et la rue monte vers le jaune quand elle devient dangereuse : une
	# reputation elevee n'est pas une bonne nouvelle dans ce jeu.
	_ecrire(police, "Rue %d" % r, Vector2(xa + 152.0, ya + 3.0), 13,
			BB_RUE if r < 60 else BB_JAUNE, false)


# L'OBJECTIF COURANT, en haut a gauche, sous l'argent.
#
# Il etait pose au milieu du bas de l'ecran, en texte nu, quatre secondes. Trois
# choses n'allaient pas et se cumulaient : le bas de l'ecran est deja occupe par
# l'invite et le cadre de dialogue, un texte sans fond se perd sur un decor
# clair, et quatre secondes ne se lisent pas.
#
# Il a maintenant sa place a lui, une bande sombre derriere, et il reste une
# minute — voir OBJECTIF_DUREE. Le petit chevron devant reprend celui du
# telephone : c'est le meme objet a deux endroits, et il doit se reconnaitre.
func _objectif_courant(police: Font) -> void:
	if _objectif <= 0.0 or _texte_objectif == "":
		return
	var a := clampf(_objectif / OBJECTIF_FONDU, 0.0, 1.0)
	var texte := "> " + _texte_objectif
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 13).x
	# Sous la bande de refus, qui occupe la largeur entiere de 26 a 48 : les
	# deux peuvent parler en meme temps, et l'un ne doit pas manger l'autre.
	var coin := Vector2(6.0, 52.0)
	_voile(Rect2(coin, Vector2(largeur + 34.0, 19.0)),
			Color(FOND.r, FOND.g, FOND.b, 0.72 * a), Vector2(1.0, 0.0), 0.0)
	# Un filet ambre sur le bord gauche. C'est ce qui distingue l'objectif du
	# bandeau de refus, qui est de la meme famille de gris et vit juste au-dessus.
	draw_rect(Rect2(coin, Vector2(2.0, 19.0)), Color(0.949, 0.776, 0.42, 0.85 * a))
	_ecrire(police, texte, coin + Vector2(8.0, 13.0), 13,
			Color(0.949, 0.925, 0.867, a), false)


# LE RAPPEL DE CE QU'ON TIENT, en bas a gauche.
#
# Le nom de l'objet s'annonce une seconde et demie a l'equipement, puis
# disparait. C'est juste au moment ou l'on choisit ; ca ne l'est plus deux
# minutes apres, quand on approche de quelqu'un sans savoir si on a le
# revolver a la main. Une interface doit repondre a « qu'est-ce que je tiens »
# sans qu'on ait a rouvrir la roue pour le verifier.
#
# Discret : une case sombre et le nom en petit. On n'affiche RIEN les mains
# vides — c'est l'etat par defaut, et la regle du fichier reste de ne montrer
# que ce qui merite un coup d'oeil.
func _objet_en_main(police: Font) -> void:
	if _outil < 0 or _eq == null:
		return
	var nom := _eq.nom_de(_outil)
	if nom == "":
		return
	var largeur := police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT,
			-1, 11).x
	var coin := Vector2(6.0, size.y - 24.0)
	draw_rect(Rect2(coin, Vector2(largeur + 14.0, 17.0)), COULEUR_FOND)
	# Le filet olive du bord gauche, comme l'objectif porte son filet ambre :
	# deux bandes de la meme famille de gris se distinguent par leur liseré.
	draw_rect(Rect2(coin, Vector2(2.0, 17.0)), BB_OLIVE)
	_ecrire(police, nom, coin + Vector2(9.0, 12.0), 11,
			Color(0.86, 0.85, 0.80), false)


# Le reticule, et le voile rouge des blessures.
#
# Le reticule est une CROIX OUVERTE, pas un point : un point de un pixel
# disparait sur un mur clair, et un cercle plein cache exactement ce qu'on
# vise. Quatre traits laissent le centre libre.
func _reticule() -> void:
	if _douleur > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size),
				Color(0.55, 0.06, 0.05, 0.34 * _douleur))
	if _tir == null or not _tir.vise():
		return
	var c := size / 2.0
	var couleur := Color(0.95, 0.93, 0.87, 0.85)
	for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		draw_line(c + d * 3.0, c + d * 8.0, couleur, 1.0)


func _ecrire(police: Font, texte: String, ou: Vector2, taille: int,
		couleur: Color, centre: bool,
		alignement: int = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, taille).x
	var p := ou
	if centre:
		p.x -= largeur / 2.0
	elif alignement == HORIZONTAL_ALIGNMENT_RIGHT:
		p.x -= largeur

	var ombre := Color(0.055, 0.050, 0.042, couleur.a)
	for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		police.draw_string(get_canvas_item(), p + d, texte,
				HORIZONTAL_ALIGNMENT_LEFT, -1, taille, ombre)
	police.draw_string(get_canvas_item(), p, texte,
			HORIZONTAL_ALIGNMENT_LEFT, -1, taille, couleur)


# UN VOILE, PAS UNE PLAQUE.
#
# CE QUE C'ETAIT : `draw_rect` d'un bleu-nuit a 55 % d'opacite. Un rectangle
# opaque a bord franc pose sur le decor — « il y a des fonds noirs, l'HUD fait
# PS2 », retour du 27/08/2026.
#
# Le defaut n'est pas la couleur, c'est le BORD. Un aplat uniforme qui s'arrete
# net sur une arete verticale se lit comme un morceau d'image colle par-dessus
# le jeu ; le meme aplat qui s'eteint progressivement se lit comme une ombre, et
# l'oeil ne le compte plus comme un objet.
#
# `draw_polygon` accepte une couleur PAR SOMMET et les interpole : le degrade
# ne coute donc ni texture, ni shader, ni le moindre passage supplementaire.
#
# `vers` dit ou le voile s'eteint : Vector2(1, 0) vers la droite, (0, 1) vers le
# bas, (1, 1) en diagonale.
func _voile(place: Rect2, teinte: Color, vers: Vector2 = Vector2(1.0, 0.0),
		reste: float = 0.0) -> void:
	var p := place.position
	var s := place.size
	var pale := Color(teinte.r, teinte.g, teinte.b, teinte.a * reste)
	# Le poids de chaque coin : 0 la ou le voile est plein, 1 la ou il s'eteint.
	var poids := [
		vers.x * 0.0 + vers.y * 0.0,   # haut gauche
		vers.x * 1.0 + vers.y * 0.0,   # haut droit
		vers.x * 1.0 + vers.y * 1.0,   # bas droit
		vers.x * 0.0 + vers.y * 1.0,   # bas gauche
	]
	var maxi: float = maxf(1.0, vers.x + vers.y)
	var teintes := PackedColorArray()
	for w in poids:
		teintes.append(teinte.lerp(pale, clampf(float(w) / maxi, 0.0, 1.0)))
	draw_polygon(PackedVector2Array([
		p, p + Vector2(s.x, 0.0), p + s, p + Vector2(0.0, s.y),
	]), teintes)
