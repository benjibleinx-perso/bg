# CE QUE LE JOUEUR A FAIT, ECRIT PENDANT QU'IL LE FAIT.
#
# Le jeu n'imprimait rien en jouant. Trente-deux lignes au chargement, puis
# plus rien : une partie de dix minutes ne laissait aucune trace, et tout
# retour de Benjamin ou de Guillaume arrivait sous forme de souvenir — « le
# camping-car est tombe dans le vide », « il va beaucoup trop vite ». Deux
# phrases justes, et rien pour les situer ni les chiffrer.
#
# CE FICHIER MESURE CE QUI SE PASSE, PAS CE QUI EST REGLE. La vitesse est
# derivee de la POSITION entre deux echantillons, jamais lue sur le vehicule :
# reglages.tres annonce 130 km/h de vitesse maximale, ce qui ne dit rien de ce
# qu'on atteint reellement en remontant une cuvette de sable. C'est la meme
# raison qui fait mesurer le temps de chaque image plutot que le compteur
# d'images par seconde dans jauge_perf.gd.
#
# ET IL ECRIT AU FIL DE L'EAU. Un jeu qui plante est exactement la partie qu'on
# veut relire ; une trace gardee en memoire jusqu'a la fin serait perdue au
# moment ou elle devient interessante.
class_name Trace
extends Node

const GROUPE := "trace"

## Une seule trace, ecrasee a chaque partie — comme .tmp/tests/<suite>.txt.
## Celle qu'on veut garder se copie ; sans ca, le dossier accumule des parties
## qu'on ne relira jamais et la derniere devient introuvable.
const FICHIER := "user://trace.jsonl"

## Cinq echantillons par seconde. Assez pour qu'une chute de trois metres
## laisse deux points, assez peu pour qu'une demi-heure de jeu tienne dans un
## fichier qu'on lit d'un coup.
const PERIODE := 0.2

## Sous cette altitude, il n'y a plus de decor : le sol du desert est a zero et
## le fond du fosse a moins deux. Un sujet a moins dix est tombe au travers.
const ALTITUDE_DU_VIDE := -10.0

## En dessous, on ne dit pas qu'il roule. Sert au resume, pas a l'echantillon :
## la trace enregistre toutes les vitesses, y compris nulles.
const ROULE_KMH := 3.0

var _fichier: FileAccess = null
var _mission: Mission = null
var _controleur: Node = null
var _joueur: Node3D = null

var _horloge := 0.0
var _depuis_echantillon := 0.0
var _position_precedente := Vector3.ZERO
var _a_une_position := false
var _etape_precedente := ""
var _dans_le_vide := false
var _pv_precedent := -1.0


func _ready() -> void:
	add_to_group(GROUPE)
	_mission = Mission.courante(self)
	_controleur = _trouver_le_controleur()
	if _controleur == null:
		push_warning("TRACE : pas de Controleur, l'enregistrement n'aura ni sujet ni volant")
	_fichier = FileAccess.open(FICHIER, FileAccess.WRITE)
	if _fichier == null:
		push_warning("TRACE : impossible d'ecrire %s" % FICHIER)
		set_process(false)
		return
	print("TRACE : %s" % ProjectSettings.globalize_path(FICHIER))
	_ecrire({
		"quoi": "debut",
		"date": Time.get_datetime_string_from_system(),
		"mission": _mission.titre() if _mission != null else "",
		"etapes": _mission.etapes().size() if _mission != null else 0,
	})
	if _mission != null:
		_mission.etape_changee.connect(_sur_etape_changee)


# UN NOM DE NOEUD N'EST PAS UNE ADRESSE : on compte avant de s'en servir.
#
# find_child rend le PREMIER, en silence, et le projet a deja paye deux fois
# ce silence — deux PorteCampingCar a cent metres l'un de l'autre, un calque de
# filtre portant le nom du systeme qui le cree. Piege 54. Si un deuxieme
# Controleur apparait un jour, on veut l'apprendre ici et pas dans un chiffre
# aberrant trois semaines plus tard.
func _trouver_le_controleur() -> Node:
	var trouves: Array[Node] = []
	_recenser(get_tree().get_root(), "Controleur", trouves)
	if trouves.size() > 1:
		push_warning("TRACE : %d noeuds nommes Controleur, on prend le premier" % trouves.size())
	return trouves[0] if trouves.size() > 0 else null


func _recenser(noeud: Node, nom: String, vus: Array[Node]) -> void:
	if noeud.name == nom:
		vus.append(noeud)
	for enfant in noeud.get_children():
		_recenser(enfant, nom, vus)


func _process(delta: float) -> void:
	if _fichier == null:
		return
	_horloge += delta
	_depuis_echantillon += delta
	if _depuis_echantillon < PERIODE:
		return
	var ecoule := _depuis_echantillon
	_depuis_echantillon = 0.0
	_echantillonner(ecoule)


func _echantillonner(ecoule: float) -> void:
	var sujet := _sujet()
	if sujet == null:
		return
	var ou := sujet.global_position

	# LA VITESSE VIENT DU DEPLACEMENT REEL, et l'ecart de temps est celui qu'on
	# a mesure, pas la periode nominale : une image longue rendrait une vitesse
	# fausse de tout son retard.
	var kmh := 0.0
	if _a_une_position and ecoule > 0.0:
		kmh = (ou - _position_precedente).length() / ecoule * 3.6
	_position_precedente = ou
	_a_une_position = true

	var pv := _pv()
	var au_volant := _au_volant()

	_ecrire({
		"t": snappedf(_horloge, 0.01),
		"x": snappedf(ou.x, 0.1),
		"y": snappedf(ou.y, 0.1),
		"z": snappedf(ou.z, 0.1),
		"kmh": snappedf(kmh, 0.1),
		"volant": au_volant,
		"etape": _cle_etape(),
		"pv": snappedf(pv, 1.0),
		"touches": _touches_pressees(),
	})

	_surveiller_le_vide(ou)
	_surveiller_la_vie(pv)


# TOMBER DANS LE VIDE EST UN EVENEMENT, PAS UNE VALEUR A RELIRE.
#
# Un y de moins quarante dans une colonne de trois mille lignes se retrouve a
# la lecture ; encore faut-il le chercher. On l'ecrit donc au moment ou ca
# arrive, avec l'endroit — c'est cet endroit-la qui designe le trou dans le
# decor, et pas la profondeur atteinte ensuite.
func _surveiller_le_vide(ou: Vector3) -> void:
	if ou.y < ALTITUDE_DU_VIDE and not _dans_le_vide:
		_dans_le_vide = true
		_ecrire({
			"quoi": "vide",
			"t": snappedf(_horloge, 0.01),
			"x": snappedf(ou.x, 0.1),
			"y": snappedf(ou.y, 0.1),
			"z": snappedf(ou.z, 0.1),
			"etape": _cle_etape(),
			"volant": _au_volant(),
		})
	elif ou.y >= ALTITUDE_DU_VIDE and _dans_le_vide:
		_dans_le_vide = false


# ON ECRIT LA MORT AU MOMENT OU ELLE ARRIVE.
#
# « Walter est mort en chemin. Sa vie : 100 » — le chiffre etait exact et son
# sens etait faux : la reprise remet la vie a cent, donc une lecture d'apres
# coup mesure un homme qu'on vient de remettre debout. Piege 64.
func _surveiller_la_vie(pv: float) -> void:
	if _pv_precedent > 0.0 and pv <= 0.0:
		_ecrire({
			"quoi": "mort",
			"t": snappedf(_horloge, 0.01),
			"etape": _cle_etape(),
		})
	_pv_precedent = pv


func _sur_etape_changee(index: int) -> void:
	var cle := _cle_etape()
	if cle == _etape_precedente:
		return
	_etape_precedente = cle
	_ecrire({
		"quoi": "etape",
		"t": snappedf(_horloge, 0.01),
		"i": index,
		"etape": cle,
		"objectif": _mission.objectif() if _mission != null else "",
	})


# CE QUE LE JOUEUR TIENT ENFONCE, LU DANS LA CARTE DES ACTIONS.
#
# Une liste ecrite a la main perimerait sans rien dire le jour ou une touche
# s'ajoute — c'est le piege 65, et il a deja coute un menu de test dont chaque
# ligne echouait en silence. On la deduit donc de InputMap, en ecartant les
# actions du moteur, qui commencent toutes par ui_.
func _touches_pressees() -> Array:
	var pressees: Array = []
	for action in InputMap.get_actions():
		var nom := String(action)
		if nom.begins_with("ui_"):
			continue
		if Input.is_action_pressed(action):
			pressees.append(nom)
	return pressees


func _sujet() -> Node3D:
	if _controleur != null and _controleur.has_method("sujet"):
		var s: Node3D = _controleur.call("sujet")
		if s != null:
			return s
	return _joueur_courant()


func _joueur_courant() -> Node3D:
	if _joueur == null or not is_instance_valid(_joueur):
		var trouves: Array[Node] = []
		_recenser(get_tree().get_root(), "Joueur", trouves)
		_joueur = trouves[0] as Node3D if trouves.size() > 0 else null
	return _joueur


func _au_volant() -> bool:
	if _controleur != null and _controleur.has_method("au_volant"):
		return bool(_controleur.call("au_volant"))
	return false


func _pv() -> float:
	var j := _joueur_courant()
	return float(j.get("pv")) if j != null else -1.0


func _cle_etape() -> String:
	return _mission.cle_etape() if _mission != null else ""


func _ecrire(ligne: Dictionary) -> void:
	if _fichier == null:
		return
	_fichier.store_line(JSON.stringify(ligne))
	# Un jeu qui plante est la partie qu'on veut relire : on vide le tampon a
	# chaque ligne plutot qu'a la fermeture.
	_fichier.flush()


func _exit_tree() -> void:
	if _fichier == null:
		return
	_ecrire({"quoi": "fin", "t": snappedf(_horloge, 0.01)})
	_fichier.close()
	_fichier = null
