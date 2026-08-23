# Le dessin de l'ecran-titre, et rien d'autre.
#
# Il vit DANS le SubViewport du titre, a la resolution du jeu : c'est ce qui
# fait que le menu a le meme grain que ce qu'il annonce.
#
# IL NE CONNAIT PAS Titre, et c'est delibere : deux scripts qui se nomment l'un
# l'autre par class_name forment un cycle que GDScript refuse de compiler. Le
# titre POUSSE ici ce qu'il faut peindre ; la seule chose qui remonte, c'est ou
# chaque entree a ete posee, parce que lui seul le sait.
#
# CE QU'IL ETAIT, ET POURQUOI IL A ETE REFAIT LE 23/08/2026.
#
# « Ameliorer GRANDEMENT l'ecran titre qui est tout moche. Changer notamment la
# police pour quelque chose qui se rapproche plus de la charte graphique de
# Breaking Bad. » Il etait deux lignes de texte sur un fond noir uni.
#
# On n'a pas de police a soi, et en telecharger une n'est pas une reponse : ce
# qui rendait cet ecran pauvre n'etait pas la fonte, c'etait qu'il ne montrait
# RIEN. Il montre maintenant le pays du jeu — un ciel delave, une mesa, du
# sable — dans les teintes de docs/20-charte-graphique.md.
#
# LE TITRE EMPRUNTE LE PRINCIPE, JAMAIS LE LOGO. La charte est explicite :
# « on s'inspire ici du principe (tuile de tableau periodique, jeu de mots
# chimique), jamais du fichier logo lui-meme — l'execution graphique doit
# rester la votre ». Deux tuiles dessinees ici, avec leur numero atomique et
# leur nom, dans le vert de chimie que la charte reserve au titre.
class_name MenuTitre
extends Control

## LES COULEURS VIENNENT DE LA CHARTE, et chacune a son emploi ecrit.
##
## Le vert de chimie est « reserve au titre, aux menus, jamais a un decor
## jouable » ; le jaune securite est celui des combinaisons ; les teintes de
## fond sont celles du desert du Sud-Ouest, desaturees comme le demande la
## regle generale — « aucune de ces teintes ne doit jamais apparaitre saturee
## a 100 % ».
const VERT_CHIMIE := Color(0.008, 0.40, 0.21)      # #026635
const VERT_CLAIR := Color(0.30, 0.55, 0.36)
const JAUNE := Color(0.96, 0.77, 0.19)             # #F4C430
const CIEL_HAUT := Color(0.42, 0.52, 0.60)
const CIEL_BAS := Color(0.66, 0.78, 0.85)          # #A9C6D9 desature
const SABLE := Color(0.72, 0.65, 0.53)             # #D9C7A3 desature
const MESA := Color(0.55, 0.45, 0.34)
const MESA_LOIN := Color(0.62, 0.58, 0.52)
const TERRE := Color(0.51, 0.36, 0.22)             # #B5651D desature
const CHOISI := Color(0.96, 0.77, 0.19)
const REPOS := Color(0.86, 0.83, 0.76)
const ROUGE := Color(0.70, 0.23, 0.18)             # #B23A2E
const OMBRE := Color(0.05, 0.05, 0.06, 0.85)

## Ou l'horizon coupe l'image. Bas : le ciel du desert est « immense », et
## c'est le fond permanent du jeu selon la charte.
const HORIZON := 0.60

var _liste: Array = []
var _choix: int = 0
var _confirme: bool = false

## Ou chaque entree a ete posee, dans le repere du rendu interne. Rempli au
## dessin : c'est le dessin qui decide de la mise en page, donc c'est lui qui
## sait ce qu'on peut cliquer.
var _zones: Array[Rect2] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Le curseur n'entre pas dans ce viewport : c'est Titre qui convertit sa
	# position et interroge index_sous(). Laisser le filtre par defaut ferait
	# croire a une zone cliquable qui ne recevra jamais rien.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Ce qu'il y a a peindre. Appele par Titre a chaque changement d'etat.
func montrer(liste: Array, choix: int, confirme: bool) -> void:
	_liste = liste
	_choix = choix
	_confirme = confirme
	queue_redraw()


## L'entree posee sous ce point, ou -1. Le point est attendu dans le repere du
## RENDU INTERNE, pas dans celui de la fenetre : la conversion appartient a
## Titre, qui est le seul a savoir de combien l'image est agrandie.
func index_sous(p: Vector2) -> int:
	for i in _zones.size():
		if _zones[i].has_point(p):
			return i
	return -1


func _draw() -> void:
	var police := get_theme_default_font()
	if police == null:
		return
	_peindre_le_pays()

	var cx := size.x / 2.0
	_peindre_le_titre(police, cx)

	# UN BANDEAU SOUS LE MENU, et il n'est pas decoratif : pose a meme le
	# paysage, « Nouvelle partie » tombait sur la ligne d'horizon et sur la
	# route — deux zones claires et une sombre sous le meme mot. Vu a la
	# capture. Le bandeau rend le fond uniforme la ou il y a a lire.
	var depart := size.y * 0.68
	var large := 280.0
	var haut := depart - 28.0
	var bas := depart + float(_liste.size()) * 26.0 + 26.0
	var boite := Rect2((size.x - large) / 2.0, haut, large, bas - haut)
	# Une BOITE, pas une bande pleine largeur : celle-ci coupait le paysage en
	# deux et cachait la route. Le meme cadre que le menu pause et la roue —
	# c'est deja la forme du jeu, il n'y a pas de raison d'en inventer une.
	draw_rect(boite, Color(0.05, 0.05, 0.06, 0.72))
	draw_rect(boite, Color(0.36, 0.33, 0.26, 0.9), false, 1.0)

	if _confirme:
		_texte(police, "Ecraser la sauvegarde ?", Vector2(cx, depart - 30.0),
				15, ROUGE)

	_zones = []
	for i in _liste.size():
		var y := depart + float(i) * 26.0
		var sel := i == _choix
		# Un chevron, comme dans tous les autres menus du jeu. Les tirets
		# encadrants d'avant etaient une convention de plus, pour rien.
		var etiquette: String = ("> " if sel else "   ") + str(_liste[i])
		_texte(police, etiquette, Vector2(cx, y), 16,
				CHOISI if sel else REPOS)
		_zones.append(Rect2(cx - 110.0, y - 16.0, 220.0, 24.0))

	# LES TOUCHES SE DISENT, ELLES NE SE DEVINENT PAS.
	#
	# Le menu se navigue avec W/S et se valide avec E — les memes touches que
	# partout ailleurs dans le jeu — et rien ne l'ecrivait. « J'ai du mal a
	# choisir Nouvelle partie, Charger, Quitter, c'est trop bizarre les
	# touches. » C'est le tout premier ecran du jeu : celui ou l'on ne connait
	# encore aucune convention, et le seul ou l'on ne peut demander a personne.
	#
	# Elles se lisent maintenant dans l'InputMap : quelqu'un qui a remappe sa
	# touche d'action doit voir la sienne, pas celle d'usine.
	_texte(police, "W / S   choisir        %s   valider" % Touches.nom("interagir"),
			Vector2(cx, depart + float(_liste.size()) * 26.0 + 12.0), 11, REPOS)


# LE PAYS DU JEU, en quatre bandes et deux formes.
#
# Ni image ni texture : des rectangles et des triangles, comme le decor du jeu
# lui-meme. Une photo du Nouveau-Mexique derriere un menu low-poly promettrait
# autre chose que ce qui suit — c'est deja la raison pour laquelle l'ouverture
# est jouee dans le monde plutot que filmee.
func _peindre_le_pays() -> void:
	var h := size.y * HORIZON

	# Le ciel, en degrade par bandes. Huit suffisent a cette resolution, et
	# les bandes se voient a peine — c'est le meme procede que le ciel du jeu.
	var bandes := 8
	for i in bandes:
		var t := float(i) / float(bandes - 1)
		var y := h * float(i) / float(bandes)
		draw_rect(Rect2(0.0, y, size.x, h / float(bandes) + 1.0),
				CIEL_HAUT.lerp(CIEL_BAS, t))

	# Les mesas : deux plans, le lointain plus pale. La perspective aerienne
	# fait tout le travail de profondeur, et elle ne coute rien.
	_mesa(size.x * 0.16, h, 92.0, 34.0, MESA_LOIN)
	_mesa(size.x * 0.78, h, 120.0, 44.0, MESA_LOIN)
	_mesa(size.x * 0.44, h, 150.0, 58.0, MESA)

	# Le sol, et une bande de terre cuite a l'horizon : c'est elle qui empeche
	# le sable de ressembler a du carton beige.
	draw_rect(Rect2(0.0, h, size.x, size.y - h), SABLE)
	draw_rect(Rect2(0.0, h, size.x, 6.0), TERRE)

	# LA ROUTE, qui file vers l'horizon. Le jeu est un jeu de conduite dans un
	# desert : le dire en une forme vaut mieux qu'en une ligne de texte.
	var route := PackedVector2Array([
		Vector2(size.x * 0.5 - 8.0, h),
		Vector2(size.x * 0.5 + 8.0, h),
		Vector2(size.x * 0.5 + 120.0, size.y),
		Vector2(size.x * 0.5 - 120.0, size.y),
	])
	draw_colored_polygon(route, Color(0.31, 0.30, 0.29))
	# Les bandes centrales, de plus en plus larges en approchant.
	var y := h + 14.0
	var pas := 12.0
	while y < size.y:
		var largeur := 1.5 + (y - h) / (size.y - h) * 5.0
		var hauteur := 4.0 + (y - h) / (size.y - h) * 14.0
		draw_rect(Rect2(size.x * 0.5 - largeur, y, largeur * 2.0, hauteur),
				Color(0.78, 0.70, 0.42, 0.75))
		y += hauteur + pas
		pas += 5.0

	# LE GRAIN. « La serie elle-meme vieillit ses couleurs plutot que de les
	# rendre eclatantes » : un voile chaud tres leger sur tout, et un
	# assombrissement des bords qui ramene l'oeil au centre.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.55, 0.45, 0.30, 0.10))
	var marge := 26.0
	draw_rect(Rect2(0.0, 0.0, size.x, marge), Color(0.05, 0.05, 0.05, 0.30))
	draw_rect(Rect2(0.0, size.y - marge, size.x, marge),
			Color(0.05, 0.05, 0.05, 0.30))


func _mesa(cx: float, base: float, largeur: float, hauteur: float,
		couleur: Color) -> void:
	# Une mesa n'est pas un triangle : c'est un plateau. Les flancs tombent,
	# le sommet est PLAT — c'est ce qui la distingue d'une montagne, et c'est
	# ce qu'on voit autour d'Albuquerque.
	var demi := largeur / 2.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - demi, base),
		Vector2(cx - demi * 0.62, base - hauteur),
		Vector2(cx + demi * 0.55, base - hauteur),
		Vector2(cx + demi, base),
	]), couleur)


# LE TITRE : deux tuiles de tableau periodique et un mot.
#
# Br pour « Breaking », Ba pour « Bad ». Le principe est celui que la charte
# autorise — la tuile et le jeu de mots chimique — et le dessin est le notre :
# numero atomique en haut a gauche, symbole au centre, nom en bas, dans le
# vert que la charte reserve au titre.
func _peindre_le_titre(police: Font, cx: float) -> void:
	var y := size.y * 0.13
	var cote := 54.0
	var ecart := 8.0

	# Les deux tuiles encadrent le mot : « Br [eaking] Ba [d] » se lit d'un
	# coup, et l'ensemble tient dans la largeur du rendu.
	var largeur_mot := police.get_string_size("EAKING", HORIZONTAL_ALIGNMENT_LEFT,
			-1, 26).x
	var largeur_fin := police.get_string_size("D", HORIZONTAL_ALIGNMENT_LEFT,
			-1, 26).x
	var total := cote + largeur_mot + ecart + cote + largeur_fin + ecart
	var x := cx - total / 2.0

	_tuile(police, Vector2(x, y), cote, "35", "Br", "brome")
	x += cote + ecart * 0.5
	_texte_gauche(police, "EAKING", Vector2(x, y + cote * 0.72), 26, REPOS)
	x += largeur_mot + ecart

	_tuile(police, Vector2(x, y), cote, "56", "Ba", "baryum")
	x += cote + ecart * 0.5
	_texte_gauche(police, "D", Vector2(x, y + cote * 0.72), 26, REPOS)

	# Le sous-titre en JAUNE PALE, pas en gris : gris sur ciel gris-bleu, il se
	# devinait plus qu'il ne se lisait. Et il compte — c'est la seule ligne de
	# l'ecran qui dit ce qu'est ce jeu, et le DISCLAIMER en depend.
	_texte(police, "un jeu de fan, non commercial",
			Vector2(cx, y + cote + 26.0), 10, Color(0.93, 0.86, 0.62, 0.92))


func _tuile(police: Font, coin: Vector2, cote: float, numero: String,
		symbole: String, nom: String) -> void:
	var r := Rect2(coin, Vector2(cote, cote))
	draw_rect(r, VERT_CHIMIE)
	draw_rect(r, VERT_CLAIR, false, 1.0)
	_texte_gauche(police, numero, coin + Vector2(4.0, 12.0), 9, JAUNE)
	var l := police.get_string_size(symbole, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
	_texte_gauche(police, symbole,
			coin + Vector2((cote - l) / 2.0, cote * 0.68), 30, REPOS)
	var ln := police.get_string_size(nom, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	_texte_gauche(police, nom,
			coin + Vector2((cote - ln) / 2.0, cote - 5.0), 8,
			Color(0.86, 0.83, 0.76, 0.8))


func _texte(police: Font, texte: String, ou: Vector2, taille: int,
		couleur: Color) -> void:
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, taille).x
	_texte_gauche(police, texte, ou - Vector2(largeur / 2.0, 0.0), taille,
			couleur)


func _texte_gauche(police: Font, texte: String, p: Vector2, taille: int,
		couleur: Color) -> void:
	# UNE OMBRE PORTEE, ET PAS UN LISERE. Le fond n'est plus noir : un texte
	# clair pose sur un ciel clair se lisait mal, et l'ombre d'un pixel ne
	# suffisait plus. Deux pixels en bas a droite, opaques.
	police.draw_string(get_canvas_item(), p + Vector2(2, 2), texte,
			HORIZONTAL_ALIGNMENT_LEFT, -1, taille,
			Color(OMBRE.r, OMBRE.g, OMBRE.b, OMBRE.a * couleur.a))
	police.draw_string(get_canvas_item(), p, texte, HORIZONTAL_ALIGNMENT_LEFT,
			-1, taille, couleur)
