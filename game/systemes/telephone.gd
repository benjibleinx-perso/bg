# Le telephone.
#
# Un SGH-127 dessine par-dessus le jeu, comme la roue. DESSINE et pas assemble
# en noeuds, pour la meme raison qu'elle : le contenu du menu vient de
# donnees/telephone.json, et un menu fait de noeuds poses a la main devrait
# etre refait a chaque contact ajoute.
#
# Il ne connait aucun correspondant en particulier. Ajouter quelqu'un a la
# liste est une entree de JSON, et sa conversation vit dans dialogues.json
# comme toutes les autres — c'est le systeme de dialogue existant, declenche
# autrement.
class_name Telephone
extends Control

## Les etats se suivent dans l'ordre. Le clapet met un instant a s'ouvrir, la
## sonnerie dure, on parle, on raccroche : un menu qui apparaitrait
## instantanement et se fermerait sec n'aurait rien d'un telephone.
enum Etat { RANGE, MENU, CONTACTS, SONNE, EN_LIGNE, MISSION }

## Le menu « Mission » n'est pas dans donnees/telephone.json : il n'est pas
## une liste de correspondants mais une VUE sur l'etat du jeu. On le pose ici,
## en tete, parce que c'est ce qu'on vient chercher neuf fois sur dix.
const ENTREE_MISSION := "Mission"

## Combien de temps le telephone s'ouvre tout seul pour annoncer un objectif,
## en secondes. Il sort, montre, et se referme — c'est ce que demande le
## scenario, et c'est aussi ce qui evite d'interrompre le joueur.
const ANNONCE := 3.2

const FICHIER := "res://donnees/telephone.json"

## ------------------------------------------------------------- LA MATIERE
##
## Les couleurs du combine viennent de la charte (docs/20), pas d'un gris
## quelconque : un anthracite CHAUD, qui tire vers le kaki #6B7F5E plutot que
## vers le bleu, parce que tout le jeu est pose dans un desert.
##
## Les quatre premieres decrivent un seul plastique sous quatre lumieres —
## c'est ce qui donne du volume a un rectangle, et ca ne coute rien a dessiner.
const COQUE := Color(0.15, 0.145, 0.125, 0.97)
const COQUE_HAUT := Color(0.34, 0.33, 0.29, 0.95)
const COQUE_BAS := Color(0.055, 0.055, 0.045, 0.95)
const COQUE_BORD := Color(0.05, 0.05, 0.04, 0.9)

## Le vert-jaune d'une dalle a cristaux liquides retroeclairee, et la lueur de
## sa lampe — sur ces ecrans-la elle est sur UN seul bord, jamais derriere
## toute la surface.
const LCD := Color(0.50, 0.58, 0.28, 0.97)
const LCD_LUEUR := Color(0.68, 0.74, 0.40, 0.30)
const LCD_BORD := Color(0.13, 0.16, 0.09, 0.95)

## Les touches. Le vert et le rouge sont ceux de la charte — le kaki de Walt
## (#6B7F5E) et le rouge sourd de Jesse (#B23A2E) — et non un vert et un rouge
## d'interface. Deux couleurs du jeu sur un objet du jeu.
const VERT_DECROCHER := Color(0.42, 0.50, 0.37, 0.95)
const ROUGE_RACCROCHER := Color(0.70, 0.23, 0.18, 0.95)
const TOUCHE := Color(0.23, 0.225, 0.20, 0.95)
const TOUCHE_ENCRE := Color(0.62, 0.61, 0.55, 0.85)

signal appel(cle: String)
signal raccroche

@export var reglages: Reglages

var _audio: Audio

## Le systeme audio, retrouve A LA DEMANDE et garde ensuite.
##
## Pas dans _ready() : le noeud Audio est declare plus bas dans la scene, donc
## il n'est pas encore dans son groupe quand celui-ci s'initialise. Le chercher
## trop tot donnait null, definitivement, et le silence qui suit ressemble a un
## mecanisme pas encore branche.
func _son() -> Audio:
	if _audio == null:
		_audio = Audio.courant(self)
	return _audio
var _etat: int = Etat.RANGE
var _contacts: Array = []
var _entrees: Array = []          # les lignes du menu principal
var _selection: int = 0
var _ouverture: float = 0.0       # 0 range, 1 en main — pour l'animation
var _attente: float = 0.0         # temps restant sur l'etat courant
var _appele: String = ""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_charger()
	set_process(true)


func _charger() -> void:
	if not FileAccess.file_exists(FICHIER):
		push_error("telephone : %s introuvable" % FICHIER)
		return
	var lu: Variant = JSON.parse_string(FileAccess.get_file_as_string(FICHIER))
	if typeof(lu) != TYPE_DICTIONARY:
		push_error("telephone : %s illisible. Verifier les virgules." % FICHIER)
		return
	_contacts = (lu as Dictionary).get("contacts", [])
	_entrees = (lu as Dictionary).get("menu", ["Appeler"])
	if not _entrees.has(ENTREE_MISSION):
		_entrees.insert(0, ENTREE_MISSION)
	print("TELEPHONE : %d contact(s)" % _contacts.size())


## La mission a suivre. Facultative : sans elle le menu reste, et il est vide.
func suivre(m: Mission) -> void:
	_mission = m


## Sort le telephone pour ANNONCER l'objectif courant, puis le range tout seul.
## C'est ce que le scenario demande a chaque changement d'etape.
func annoncer() -> void:
	if _etat != Etat.RANGE:
		return
	_etat = Etat.MISSION
	_annonce = ANNONCE
	visible = true
	if _son() != null:
		_son().bruit("roue_ouvre")


## Est-on en train de s'annoncer tout seul ? Le controleur ne bloque pas le
## joueur pendant ce temps : une annonce qui immobilise trois secondes est une
## punition, pas une information.
func annonce_en_cours() -> bool:
	return _annonce > 0.0

var _mission: Mission
var _annonce: float = 0.0


func sorti() -> bool:
	return _etat != Etat.RANGE


## Le repertoire, pour le test : il verifie que chaque correspondant a bien
## une fiche de dialogue. Une cle mal orthographiee donne un appel qui sonne
## et n'aboutit jamais, sans la moindre erreur.
func contacts() -> Array:
	return _contacts


## L'entree visee, pour le test. La selection est invisible autrement qu'en
## lisant l'ecran dessine, ce qu'aucun test ne peut faire.
func selection() -> int:
	return _selection


## Est-on dans un moment ou le telephone parle tout seul ? Le controleur s'en
## sert pour ne pas laisser la touche interrompre une sonnerie en cours.
func occupe() -> bool:
	return _etat == Etat.SONNE


func sortir() -> void:
	if _etat != Etat.RANGE:
		return
	_etat = Etat.MENU
	_selection = 0
	visible = true
	if _son() != null:
		_son().bruit("roue_ouvre")


## LE TELEPHONE SONNE, ET ON DECROCHE. Rien d'autre.
##
## Un appel recu passait par sortir(), donc par le MENU : pendant que l'homme
## de Tuco parlait, le joueur pouvait remonter dans le repertoire, appeler
## quelqu'un d'autre, ou raccrocher au nez de celui qui lance la mission. Ce
## n'est pas un telephone qu'on consulte, c'est un telephone qui sonne — on le
## subit, et la seule chose a faire est de lire.
##
## L'etat EN_LIGNE est deja ignore par _naviguer(). Il suffisait d'y entrer
## directement au lieu de passer par le menu.
func decrocher(qui: String) -> void:
	if _etat != Etat.RANGE:
		return
	_etat = Etat.EN_LIGNE
	_impose = true
	_appelant = qui
	_selection = 0
	visible = true
	if _son() != null:
		_son().bruit("roue_ouvre")


## Est-ce un appel qu'on subit ? Le controleur s'en sert pour ne pas laisser
## la touche T raccrocher au milieu d'une conversation de mission.
func impose() -> bool:
	return _impose

var _impose: bool = false

## Le nom affiche sur l'ecran pendant un appel recu. Il ne vient pas du
## repertoire : celui qui appelle Walter n'y est pas, et c'est tout le sujet.
var _appelant: String = ""


func ranger() -> void:
	if _etat == Etat.RANGE:
		return
	_etat = Etat.RANGE
	_appele = ""
	_impose = false
	if _son() != null:
		_son().bruit("roue_ferme")
	raccroche.emit()


func _process(delta: float) -> void:
	var vers := 0.0 if _etat == Etat.RANGE else 1.0
	var pas := delta / maxf(0.01, reglages.telephone_ouverture)
	_ouverture = move_toward(_ouverture, vers, pas)
	if _etat == Etat.RANGE and _ouverture <= 0.0:
		visible = false

	if _annonce > 0.0:
		_annonce = maxf(0.0, _annonce - delta)
		if _annonce == 0.0 and _etat == Etat.MISSION:
			ranger()

	if _attente > 0.0:
		_attente = maxf(0.0, _attente - delta)
		if _attente == 0.0 and _etat == Etat.SONNE:
			# La sonnerie est finie : on decroche, et le dialogue prend la main.
			_etat = Etat.EN_LIGNE
			appel.emit(_appele)

	_naviguer()
	queue_redraw()


# On SCRUTE les touches, on n'ecoute pas les evenements.
#
# Toute l'interface vit dans le SubViewport de rendu, ou Godot ne propage
# aucune entree : un _unhandled_input y serait silencieusement mort. C'est le
# piege qui avait rendu la roue des outils inutilisable, et il vaut ici aussi.
func _naviguer() -> void:
	# L'ecran de mission ne se navigue pas : il se lit, et on en sort.
	if _etat == Etat.MISSION:
		if _annonce <= 0.0 and Input.is_action_just_pressed("interagir"):
			_etat = Etat.MENU
			_selection = 0
		return
	if _etat != Etat.MENU and _etat != Etat.CONTACTS:
		return

	var liste := _entrees if _etat == Etat.MENU else _contacts
	if liste.is_empty():
		return

	var bouge := 0
	if Input.is_action_just_pressed("frein"):
		bouge = 1
	elif Input.is_action_just_pressed("gaz"):
		bouge = -1
	if bouge != 0:
		_selection = (_selection + bouge + liste.size()) % liste.size()
		if _son() != null:
			_son().bruit("roue_cran")

	if Input.is_action_just_pressed("interagir"):
		_valider()


func _valider() -> void:
	if _son() != null:
		_son().bruit("roue_cran")
	if _etat == Etat.MENU:
		if str(_entrees[_selection]) == ENTREE_MISSION:
			_etat = Etat.MISSION
			return
		_etat = Etat.CONTACTS
		_selection = 0
		return

	var fiche: Dictionary = _contacts[_selection]
	_appele = str(fiche.get("cle", ""))
	_etat = Etat.SONNE
	_attente = reglages.telephone_sonnerie
	if _son() != null:
		_son().bruit("sonnerie")


func _draw() -> void:
	if _ouverture <= 0.0:
		return
	var police := get_theme_default_font()
	if police == null:
		return

	# Le combine monte depuis le bas, en bas a droite : c'est la ou une main
	# tient un telephone, et ca laisse l'ecran libre.
	var l := reglages.telephone_largeur
	var h := reglages.telephone_hauteur
	# Une marge sous le combine : pose a ras du bord, il se lit comme une image
	# coupee plutot que comme un objet tenu en main.
	var repos := size.y - 10.0
	var coin := Vector2(size.x - l - 14.0, repos - h * _ouverture)

	# ------------------------------------------------------- LE COMBINE
	#
	# CE QUE C'ETAIT : un rectangle noir, un carre vert dedans, six traits gris
	# pour les touches. « Le telephone est moche » — retour du 27/08/2026, et
	# c'etait exact : ce n'etait pas un objet, c'etait un schema.
	#
	# CE QUI FAIT QU'UN OBJET SE LIT COMME UN OBJET, et aucun de ces gestes ne
	# coute plus de deux lignes :
	#
	#   une EPAISSEUR — le corps se detache du fond par une ombre portee, pas
	#     par un contour ;
	#   une LUMIERE — un liseré clair en haut, plus sombre en bas : c'est ce qui
	#     dit qu'il y a du volume, et c'est ce qu'une bordure uniforme ne dit
	#     jamais ;
	#   un ECRAN ENFONCE — le verre est en retrait dans la coque, donc son bord
	#     haut porte une ombre et son bord bas une lueur ;
	#   et une COULEUR QUI VIENT DE LA CHARTE plutot que d'un gris quelconque.
	#     Le corps tire vers le brun-olive de docs/20, pas vers le bleu.
	var corps := Rect2(coin, Vector2(l, h))

	# L'ombre portee, decalee vers le bas a droite. C'est elle qui pose le
	# combine DEVANT l'ecran au lieu de le coller dessus.
	_boitier(Rect2(corps.position + Vector2(3.0, 4.0), corps.size),
			Color(0.0, 0.0, 0.0, 0.35))

	# LES COINS SONT COUPES.
	#
	# Aucun objet moule n'a d'angle vif, et c'est la premiere chose que l'oeil
	# releve sans savoir la nommer : un rectangle parfait se lit comme un
	# SCHEMA, meme bien colore. Trois pixels de chanfrein suffisent a le
	# transformer en objet, et le seul cout est un polygone au lieu d'un rect.
	_boitier(corps, COQUE)
	# Le plastique prend la lumiere par le haut : la moitie superieure est
	# eclaircie d'un voile, ce qui remplace un degrade qu'on ne peut pas
	# dessiner ici sans texture.
	draw_rect(Rect2(corps.position + Vector2(1.0, 1.0),
			Vector2(corps.size.x - 2.0, corps.size.y * 0.38)),
			Color(1.0, 0.97, 0.88, 0.05))
	# Le biseau : clair en haut, sombre en bas. Deux traits d'un pixel.
	draw_line(corps.position + Vector2(3.0, 0.5),
			corps.position + Vector2(corps.size.x - 3.0, 0.5), COQUE_HAUT, 1.0)
	draw_line(corps.position + Vector2(3.0, corps.size.y - 0.5),
			corps.position + Vector2(corps.size.x - 3.0, corps.size.y - 0.5),
			COQUE_BAS, 1.0)

	# LA GRILLE DU HAUT-PARLEUR, au-dessus de l'ecran. Trois traits courts et
	# centres : c'est le detail qui fait qu'on reconnait un telephone et pas une
	# calculatrice, et il tient en trois lignes.
	var grille_y := coin.y + 4.0
	for i in 3:
		var large := 16.0 - float(i) * 2.0
		draw_line(Vector2(coin.x + l * 0.5 - large * 0.5, grille_y + float(i)),
				Vector2(coin.x + l * 0.5 + large * 0.5, grille_y + float(i)),
				COQUE_BAS, 1.0)

	# L'ecran : le vert-jaune d'un ecran a cristaux liquides retroeclaire.
	var marge := 6.0
	var ecran := Rect2(coin + Vector2(marge, marge + 5.0),
			Vector2(l - marge * 2.0, h * 0.52))
	# Le logement, un pixel plus grand que le verre : c'est le creux ou l'ecran
	# est encastre.
	draw_rect(Rect2(ecran.position - Vector2(1.0, 1.0),
			ecran.size + Vector2(2.0, 2.0)), COQUE_BAS)
	draw_rect(ecran, LCD)
	# La lueur du retroeclairage se concentre en haut de la dalle, comme sur les
	# ecrans de l'epoque, dont la lampe est sur un seul bord.
	draw_rect(Rect2(ecran.position, Vector2(ecran.size.x, ecran.size.y * 0.45)),
			LCD_LUEUR)
	draw_rect(ecran, LCD_BORD, false, 1.0)

	if _ouverture < 0.85:
		return

	var encre := Color(0.10, 0.13, 0.07)
	# L'HEURE A SA PROPRE LIGNE, ET LE CONTENU COMMENCE SOUS ELLE.
	#
	# Les deux partageaient la premiere ligne : l'heure calee a droite, le
	# contenu a gauche, et n'importe quel texte un peu long passait dessous.
	# « > Mission » suffisait, et le titre de la mission traversait l'ecran de
	# part en part. Deux textes superposes ne se lisent ni l'un ni l'autre.
	#
	# Une ligne coute quatre pixels sur cet ecran, et elle rend les quatre
	# autres lisibles.
	var y := ecran.position.y + 21.0
	var x := ecran.position.x + 5.0

	# L'HEURE, en haut a droite de l'ecran, quel que soit le menu affiche.
	#
	# C'est la premiere chose qu'on regarde sur un telephone, et le jeu n'avait
	# aucun autre endroit ou lire l'heure — alors que la mission entiere se
	# joue sur un compte a rebours de journee et que le ciel change.
	#
	# Elle est dessinee AVANT le contenu et en petit : elle ne doit jamais
	# disputer la place a ce qu'on est venu lire.
	var horloge := get_tree().get_first_node_in_group(Temps.GROUPE) as Temps
	if horloge != null:
		var heure := horloge.texte()
		var largeur := police.get_string_size(heure, HORIZONTAL_ALIGNMENT_LEFT,
				-1, 8).x
		draw_string(police, Vector2(ecran.end.x - 4.0 - largeur,
				ecran.position.y + 9.0),
				heure, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(encre, 0.75))

	match _etat:
		Etat.MISSION:
			_ecran_de_mission(police, ecran, x, y, encre)
		Etat.SONNE:
			draw_string(police, Vector2(x, y), "Appel...",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)
			draw_string(police, Vector2(x, y + 13.0), _nom_de(_appele),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 11, encre)
		Etat.EN_LIGNE:
			draw_string(police, Vector2(x, y), "En ligne",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)
			draw_string(police, Vector2(x, y + 13.0), _nom_de(_appele),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 11, encre)
		_:
			var liste := _entrees if _etat == Etat.MENU else _contacts
			for i in liste.size():
				var texte: String = (str(liste[i]) if _etat == Etat.MENU
						else str((liste[i] as Dictionary).get("nom", "?")))
				var vise := i == _selection
				# Le curseur est un chevron, pas une couleur : a dix pixels de
				# haut sur un fond vert, deux teintes de vert ne se distinguent
				# pas, alors qu'un caractere en plus se voit toujours.
				draw_string(police, Vector2(x, y + float(i) * 12.0),
						("> " if vise else "  ") + texte,
						HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)

	_clavier(police, coin, l, marge, ecran)


# LE CLAVIER.
#
# CE QU'IL ETAIT : neuf rectangles gris identiques, sans un chiffre. De loin,
# ca ne se distinguait pas d'une grille d'aeration.
#
# Ce qui fait qu'on reconnait un telephone, c'est la RANGEE DE FONCTION —
# decrocher a gauche, raccrocher a droite, l'une verte et l'autre rouge. Elle
# tient en deux touches et elle porte a elle seule l'identification de l'objet.
# Les couleurs sont celles de la charte : le kaki de Walt, le rouge sourd de
# Jesse.
#
# Le clavier reste decoratif — on ne compose aucun numero. Mais un decor qui
# ment sur ce qu'il represente se remarque plus qu'un decor absent.
func _clavier(police: Font, coin: Vector2, l: float, marge: float,
		ecran: Rect2) -> void:
	var haut := ecran.position.y + ecran.size.y + 6.0
	var large := (l - marge * 2.0 - 8.0) / 3.0
	var t := Vector2(large, 7.0)
	var pas := t.y + 2.5

	# La rangee de fonction : deux touches larges, aux couleurs de la charte.
	var lf := (l - marge * 2.0 - 4.0) / 2.0
	_touche(Rect2(Vector2(coin.x + marge, haut), Vector2(lf, t.y)),
			VERT_DECROCHER)
	_touche(Rect2(Vector2(coin.x + marge + lf + 4.0, haut), Vector2(lf, t.y)),
			ROUGE_RACCROCHER)

	# Puis les trois rangees de chiffres. Le chiffre est dessine a 6 pixels : a
	# cette taille il ne se LIT pas vraiment, et ce n'est pas ce qu'on lui
	# demande — il donne la texture d'un clavier, ce qu'un aplat ne fait pas.
	for r in 3:
		for c in 3:
			var place := Rect2(Vector2(
					coin.x + marge + float(c) * (t.x + 4.0),
					haut + pas + 3.0 + float(r) * pas), t)
			_touche(place, TOUCHE)
			var chiffre := str(r * 3 + c + 1)
			var mesure := police.get_string_size(chiffre,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 6)
			draw_string(police,
					place.position + Vector2(
							(place.size.x - mesure.x) * 0.5,
							place.size.y - 1.5),
					chiffre, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, TOUCHE_ENCRE)


# Une touche : le plastique, son biseau clair en haut, son ombre en bas. Les
# trois memes gestes que la coque, a l'echelle d'un demi-centimetre — c'est ce
# qui fait que le clavier appartient au meme objet que le boitier.
func _touche(place: Rect2, teinte: Color) -> void:
	draw_rect(place, teinte)
	draw_line(place.position, place.position + Vector2(place.size.x, 0.0),
			teinte.lightened(0.28), 1.0)
	draw_line(place.position + Vector2(0.0, place.size.y),
			place.position + place.size, teinte.darkened(0.5), 1.0)


# L'ecran de suivi. Ce qui est fait est BARRE d'une croix, ce qui reste est
# pointe par un chevron.
#
# Une coche et une case vide auraient demande deux symboles distincts sur un
# ecran vert de dix pixels de haut, ou deux glyphes fins se confondent. Une
# croix pleine et un chevron ne se ressemblent pas, meme flous.
func _ecran_de_mission(police: Font, ecran: Rect2, x: float, y: float,
		encre: Color) -> void:
	if _mission == null:
		draw_string(police, Vector2(x, y), "Aucune mission",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)
		return

	# LE TITRE NE PASSE PLUS SOUS L'HORLOGE.
	#
	# Il etait dessine tel quel, sans mesure et sans troncature, sur la meme
	# ligne que l'heure : « Deux corps, un camping-car » traversait l'ecran de
	# part en part et se superposait a « 21:44 ». Deux textes l'un sur l'autre
	# ne se lisent ni l'un ni l'autre — c'etait la premiere chose visible en
	# ouvrant le telephone, et c'etait illisible.
	#
	# L'horloge a sa propre ligne au-dessus, donc le titre dispose de toute la
	# largeur — mais il faut quand meme le couper : « Deux corps, un
	# camping-car » fait deux fois l'ecran. Une seule ligne, avec des points de
	# suspension : c'est un titre, pas un texte, et un ecran de quatre lignes
	# n'a pas de quoi en donner deux au nom de la mission.
	var titre := _mission.titre()
	var coupe := _couper(police, titre, 10, ecran.end.x - 5.0 - x)
	if not coupe.is_empty():
		titre = str(coupe[0])
		if coupe.size() > 1:
			titre += "..."
	draw_string(police, Vector2(x, y), titre,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)
	# Un filet sous le titre : sans lui, la liste commence sans qu'on sache
	# que c'en est une.
	draw_line(Vector2(x, y + 3.0), Vector2(ecran.end.x - 5.0, y + 3.0),
			Color(encre, 0.45), 1.0)

	if _mission.finie():
		draw_string(police, Vector2(x, y + 18.0), "Mission accomplie",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 11, encre)
		return

	# Les deux dernieres etapes faites, puis l'etape en cours. L'ecran fait
	# quatre lignes : tout afficher demanderait de le faire defiler, et il n'y
	# a pas de quoi lire quinze objectifs sur un telephone de 2008.
	var dispo := ecran.end.x - 5.0 - x
	var faites := _mission.faites()
	var total := _mission.etapes().size()
	var ligne := y + 13.0

	# LA PROGRESSION D'ABORD, EN UN COUP D'OEIL.
	#
	# L'ecran listait la derniere etape faite en toutes lettres, puis l'etape
	# courante. Sur cinquante pixels de large, ca faisait cinq lignes de texte
	# gris ou l'on ne distinguait plus ce qui etait fait de ce qui restait — et
	# surtout, rien ne DISAIT qu'on venait de progresser.
	#
	# Une jauge et un compte le disent sans une phrase : la barre avance, le
	# chiffre monte. C'est ce qu'on vient verifier neuf fois sur dix, et ca
	# tient sur une ligne.
	var part := clampf(float(faites.size()) / maxf(1.0, float(total)), 0.0, 1.0)
	var jauge := Rect2(Vector2(x, ligne - 5.0), Vector2(dispo - 20.0, 4.0))
	draw_rect(jauge, Color(encre, 0.22))
	draw_rect(Rect2(jauge.position, Vector2(jauge.size.x * part, jauge.size.y)),
			Color(encre, 0.85))
	draw_string(police, Vector2(jauge.end.x + 3.0, ligne),
			"%d/%d" % [faites.size(), total],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 8, encre)
	ligne += 11.0

	# La derniere etape franchie, BARREE d'une croix et en petit : elle sert de
	# repere — « c'est bien ca que je viens de faire » — pas de lecture.
	if not faites.is_empty():
		var derniere: String = str(faites[faites.size() - 1])
		var lignes := _couper(police, "x " + derniere, 8, dispo)
		# Une seule ligne, coupee net : c'est un accuse de reception, et
		# l'objectif courant doit garder la place.
		draw_string(police, Vector2(x, ligne), str(lignes[0]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(encre, 0.5))
		ligne += 11.0

	for morceau in _couper(police, "> " + _mission.objectif(), 10, dispo):
		draw_string(police, Vector2(x, ligne), morceau,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, encre)
		ligne += 11.0


# Coupe un texte en lignes qui tiennent dans la largeur donnee.
#
# L'ecran du combine fait cinquante pixels de large. « Rejoindre le labo dans le
# desert » y occupait cent soixante pixels : le texte sortait du telephone et
# continuait par-dessus le decor, ce qui donnait un objectif illisible dessine
# sur une rue. Godot sait faire du retour a la ligne dans un Label, mais cet
# ecran est DESSINE — c'est ce qui lui donne son grain — et draw_string ne
# coupe rien tout seul.
static func _couper(police: Font, texte: String, taille: int,
		largeur: float) -> Array:
	var lignes: Array = []
	var courante := ""
	for mot in texte.split(" ", false):
		var essai := mot if courante == "" else courante + " " + mot
		if police.get_string_size(essai, HORIZONTAL_ALIGNMENT_LEFT, -1,
				taille).x <= largeur or courante == "":
			courante = essai
			continue
		lignes.append(courante)
		courante = mot
	if courante != "":
		lignes.append(courante)

	# UN MOT PLUS LARGE QUE L'ECRAN DEBORDAIT QUAND MEME.
	#
	# La boucle garde le mot en cours meme s'il ne tient pas — « courante == "" »
	# — parce qu'il faut bien poser quelque chose. Sur un ecran de cinquante
	# pixels, « Recuperer » ne tient pas, et il continuait par-dessus le cadre du
	# telephone puis par-dessus le decor.
	#
	# On coupe donc au caractere en dernier recours. C'est laid et c'est voulu :
	# des points de suspension disent qu'il manque du texte, alors qu'un mot qui
	# sort du cadre dit que l'affichage est casse.
	var tenues: Array = []
	for l in lignes:
		var mot := str(l)
		while mot.length() > 1 and police.get_string_size(mot,
				HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > largeur:
			mot = mot.substr(0, mot.length() - 1)
		if mot.length() < str(l).length():
			mot = mot.substr(0, maxi(1, mot.length() - 1)) + "."
		tenues.append(mot)
	return tenues


func _nom_de(cle: String) -> String:
	if _impose:
		return _appelant
	for c in _contacts:
		if str((c as Dictionary).get("cle", "")) == cle:
			return str((c as Dictionary).get("nom", cle.capitalize()))
	return cle.capitalize()


# Un boitier aux coins coupes. Huit points valent mieux qu'un rectangle : c'est
# la difference entre un objet et une case.
func _boitier(place: Rect2, teinte: Color, chanfrein: float = 3.0) -> void:
	var p := place.position
	var s := place.size
	var c := chanfrein
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(c, 0.0),
		p + Vector2(s.x - c, 0.0),
		p + Vector2(s.x, c),
		p + Vector2(s.x, s.y - c),
		p + Vector2(s.x - c, s.y),
		p + Vector2(c, s.y),
		p + Vector2(0.0, s.y - c),
		p + Vector2(0.0, c),
	]), teinte)
