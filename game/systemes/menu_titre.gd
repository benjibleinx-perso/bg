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
# RIEN. Il a d'abord montre le pays du jeu — un ciel delave, une mesa, du
# sable — peint ici en rectangles et en triangles.
#
# CE PAYS PEINT A ETE RETIRE LE 28/08/2026, ET LA NOTE QUI LE DEFENDAIT AUSSI.
#
# Elle disait : « ni image ni texture (...) une photo du Nouveau-Mexique
# derriere un menu low-poly promettrait autre chose que ce qui suit ». Le
# raisonnement se tenait ; le resultat, non — « le fond est incroyablement
# moche ! » (Guillaume, 27/08/2026), qui livre en meme temps le visuel a
# mettre a la place. Il porte son titre, donc le titre dessine ici — deux
# tuiles de tableau periodique — n'a plus lieu d'etre : deux titres l'un sur
# l'autre.
#
# C'EST UN FOND PROVISOIRE, ET IL EST ECRIT QU'IL L'EST. La demande complete
# est « en attendant », avec une question a cote : combien couterait le meme
# ecran refait en 3D dans l'esthetique du jeu. Le jour ou cette scene existe,
# elle remplace la texture ici et rien d'autre ne bouge.
#
# Ce qui reste dessine : la mention « un jeu de fan, non commercial », que
# l'image ne porte pas et dont le DISCLAIMER depend.
class_name MenuTitre
extends Control

## LE FOND, LIVRE PAR GUILLAUME LE 27/08/2026.
##
## Il est range a 512 x 384 — LES COTES EXACTS DU RENDU INTERNE, pas ceux du
## fichier livre (1366 x 1024). Le menu est dessine dans ce repere puis agrandi
## d'un facteur 1,875 par titre.gd : une texture plus fine ne serait pas plus
## nette a l'ecran, elle serait seulement le seul element du jeu a ne pas
## porter son grain. C'est la meme regle que les 128 px des textures d'objet.
const FOND := preload("res://assets/images/ecran_titre.png")

## LES COULEURS VIENNENT DE LA CHARTE, et chacune a son emploi ecrit.
##
## Le jaune securite est celui des combinaisons ; les teintes claires sont
## desaturees comme le demande la regle generale — « aucune de ces teintes ne
## doit jamais apparaitre saturee a 100 % ».
const CHOISI := Color(0.96, 0.77, 0.19)
const REPOS := Color(0.86, 0.83, 0.76)
const ROUGE := Color(0.70, 0.23, 0.18)             # #B23A2E
const OMBRE := Color(0.05, 0.05, 0.06, 0.85)

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
	_peindre_le_fond()

	var cx := size.x / 2.0
	_peindre_la_mention(police, cx)

	# UN BANDEAU SOUS LE MENU, et il n'est pas decoratif : pose a meme le fond,
	# « Nouvelle partie » tombait sur trois valeurs differentes dans le meme
	# mot. C'etait vrai du paysage peint — horizon et route — et ca l'est plus
	# encore de l'image livree, ou cette hauteur porte la balance, le becher et
	# le telephone. Le bandeau rend le fond uniforme la ou il y a a lire.
	var depart := size.y * 0.68
	var large := 280.0
	var haut := depart - 28.0
	var bas := depart + float(_liste.size()) * 26.0 + 26.0
	var boite := Rect2((size.x - large) / 2.0, haut, large, bas - haut)
	# Une BOITE, pas une bande pleine largeur : celle-ci coupait l'image en deux.
	# Le meme cadre que le menu pause et la roue — c'est deja la forme du jeu,
	# il n'y a pas de raison d'en inventer une.
	# ET LA BOITE EST OPAQUE. A 72 %, la route du paysage peint passait AU
	# TRAVERS et se lisait comme un triangle noir pose sur le menu. Une boite
	# dont le role est de « rendre le fond uniforme la ou il y a a lire » et qui
	# laisse passer la forme la plus contrastee du fond ne fait pas son travail.
	draw_rect(boite, Color(0.055, 0.050, 0.042, 0.94))
	# Deux filets plutot qu'un cadre : un jaune securite en haut, un trait
	# sombre en bas. Un rectangle entierement cercle ressemble a une fenetre de
	# systeme ; deux filets ressemblent a une plaque.
	draw_rect(Rect2(boite.position, Vector2(boite.size.x, 2.0)),
			Color(0.957, 0.769, 0.188, 0.85))
	draw_rect(Rect2(boite.position + Vector2(0.0, boite.size.y - 1.0),
			Vector2(boite.size.x, 1.0)), Color(0.0, 0.0, 0.0, 0.5))

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


# LE FOND, ET C'EST UNE IMAGE DEPUIS LE 28/08/2026.
#
# Elle est dessinee a la taille du Control — 512 x 384, exactement les cotes de
# la texture — puis l'ensemble est agrandi par titre.gd. Aucune deformation :
# le fichier a ete recadre en 4:3 avant d'etre reduit, parce que 1366 x 1024
# n'est pas tout a fait 4:3 et que 0,4 % d'etirement se voit sur un horizon.
func _peindre_le_fond() -> void:
	draw_texture_rect(FOND, Rect2(Vector2.ZERO, size), false)


# LA MENTION LEGALE, la seule chose que l'image ne dit pas.
#
# ELLE EST AU PIED DE L'IMAGE, ET C'EST LA CAPTURE QUI L'Y A MISE. Posee sous
# « THE GAME » — le seul endroit ou il y avait du ciel — elle se collait au
# sous-titre : deux lignes de tailles differentes a huit pixels l'une de
# l'autre se lisent comme un titre rate. En bas, la table est sombre et la
# ligne se detache sans rien toucher ; c'est aussi la place ou on la cherche.
#
# Elle compte — c'est la seule ligne de l'ecran qui dit ce qu'est ce jeu, et le
# DISCLAIMER en depend. En jaune pale, avec son ombre portee.
func _peindre_la_mention(police: Font, cx: float) -> void:
	_texte(police, "un jeu de fan, non commercial",
			Vector2(cx, size.y * 0.965), 11, Color(0.93, 0.86, 0.62, 0.95))


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

