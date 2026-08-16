# Sauvegarder et reprendre une partie.
#
# On ecrit ce qui doit survivre a une session : l'heure, l'argent, l'inventaire,
# la position, et l'etat de la mission. PAS le monde - il est genere et se
# refabrique a l'identique depuis sa graine, l'ecrire serait le plus gros du
# fichier pour rien. La sauvegarde vit dans user://, jamais dans le depot.
#
# QUAND on sauve : a la fin d'une mission (signal accomplie) et en quittant par
# le menu pause. Pas de sauvegarde libre - c'est un choix de design du ticket.
#
# QUAND on reprend : au lancement, si une sauvegarde existe, on la charge et on
# repose l'etat sans rejouer la mission depuis le debut.
#
# Ce qui n'est PAS encore la, et viendra quand ces systemes existeront : la
# purete, la famille, la reputation. Le format est un dictionnaire, on y ajoute
# une cle sans casser les sauvegardes ecrites avant.
class_name Sauvegarde
extends Node

const FICHIER := "user://partie.json"

## Version du format. Si sa forme change un jour, on saura lire l'ancienne ou
## la refuser proprement, au lieu de planter sur un champ absent.
const VERSION := 1

@export var bourse: NodePath
@export var purete: NodePath
@export var temps: NodePath
@export var equipement: NodePath
@export var joueur: NodePath
@export var mission: NodePath

## Le controleur, pour savoir si l'on quitte A PIED ou AU VOLANT — et pour
## remettre le joueur dans sa voiture a la reprise.
##
## C'est LUI qu'on branche, pas le vehicule : il connait deja les deux corps, et
## seul lui sait faire monter quelqu'un proprement — desactiver le personnage,
## rendre la main a la voiture, deplacer la camera. Reposer un joueur « au
## volant » en ecrivant nous-memes ces trois choses les dupliquerait, et elles
## divergeraient au premier changement.
@export var controleur: NodePath

## La valeur de Controleur.Etat.AU_VOLANT. Recopiee parce que controleur.gd n'a
## pas de class_name : sans lui, l'enum n'est pas nommable depuis ici.
const VOLANT := 1

var _bourse: Bourse
var _purete: Purete
var _famille: Famille
var _reputation: Reputation
var _temps: Temps
var _equipement: Equipement
var _joueur: Node3D
var _mission: Mission
var _controleur: Node


func _ready() -> void:
	_bourse = get_node_or_null(bourse) as Bourse
	_purete = get_node_or_null(purete) as Purete
	_famille = Famille.courante(self)
	_reputation = Reputation.courante(self)
	_temps = get_node_or_null(temps) as Temps
	_equipement = get_node_or_null(equipement) as Equipement
	_joueur = get_node_or_null(joueur) as Node3D
	_mission = get_node_or_null(mission) as Mission
	_controleur = get_node_or_null(controleur)
	# On sauve a la fin d'une mission, sans que personne n'ait a y penser.
	if _mission and not _mission.accomplie.is_connected(sauver):
		_mission.accomplie.connect(sauver)
	# DIFFERE, et ce n'est pas une precaution : au lancement chaque systeme pose
	# son etat de depart dans son propre _ready(). Restaurer ici serait ecrase
	# une image plus tard. On attend que tout le monde soit pret.
	call_deferred("_reprendre_si_possible")


func existe() -> bool:
	return FileAccess.file_exists(FICHIER)


## Ecrit l'etat courant. Appele a la fin d'une mission et en quittant.
func sauver() -> void:
	var d := etat()
	var f := FileAccess.open(FICHIER, FileAccess.WRITE)
	if f == null:
		push_error("sauvegarde : impossible d'ecrire %s" % FICHIER)
		return
	f.store_string(JSON.stringify(d, "  "))
	f.close()
	print("SAUVEGARDE : %d $, heure %.1f, mission etape %d"
		% [d["argent"], d["heure"], d["mission"]["index"]])


## L'etat courant, en dictionnaire. Public : les tests le lisent sans fichier.
func etat() -> Dictionary:
	var d := {
		"version": VERSION,
		"heure": Reglages.heure,
		"argent": _bourse.montant() if _bourse else 0,
		# LE PALIER, PAS LA VALEUR BRUTE. Meme dans un fichier que le joueur ne
		# lira sans doute jamais, on se parle en paliers : le jour ou quelqu'un
		# ouvre la sauvegarde, il n'y trouve pas de pourcentage a optimiser.
		"purete": _purete.palier() if _purete else 1,
		"famille": _famille.points() if _famille else Famille.DEPART,
		"reputation": _reputation.points() if _reputation else Reputation.DEPART,
		"inventaire": {
			"possedes": _equipement.cles_possedees() if _equipement else [],
			"tenu": _equipement.cle_equipee() if _equipement else "",
			"portes": _equipement.cles_portees() if _equipement else [],
		},
		# ON ECRIT AUSSI DE QUELLE MISSION IL S'AGIT.
		#
		# L'index seul ne veut rien dire : c'est un rang dans une liste, et la
		# liste change quand la mission change. Une partie sauvee sur « Un client
		# impatient » a l'etape 15 sur 15 se rechargeait sur « Deux corps » a
		# l'etape 15 sur 18 — le joueur reprenait au milieu d'une mission qu'il
		# n'avait jamais jouee, trois etapes avant une fin qu'il n'avait pas
		# gagnee. Vu a la capture le 16/08/2026.
		"mission": {
			"fichier": _mission.fichier if _mission else "",
			"index": _mission.index() if _mission else 0,
			"faites": _mission.faites() if _mission else [],
		},
	}
	if _joueur:
		var p := _joueur.global_position
		d["position"] = [p.x, p.y, p.z]

	# LA VOITURE ET LE VOLANT.
	#
	# La position du joueur ne suffit pas quand il conduit : au volant il est
	# desactive et retire du monde physique, et sa position n'est plus celle du
	# jeu. Reprendre restituait donc un Walter a pied quelque part, pendant que
	# la voiture attendait la ou la scene l'avait posee au lancement — mesure du
	# 09/08/2026 : 760 m plus loin.
	if _controleur:
		d["au_volant"] = int(_controleur.get("_etat")) == VOLANT
		# TOUS LES VEHICULES, CHACUN SOUS SON NOM.
		#
		# On enregistrait « le » vehicule, celui que le controleur tenait a cet
		# instant. Tant qu'il n'y en avait qu'un, ca revenait au meme ; depuis
		# que le camping-car se conduit, le controleur designe le plus proche —
		# et l'on sauvegardait donc la position de l'un pour la rendre a
		# l'autre. La suite l'a dit tout de suite : 760 m d'ecart, c'est-a-dire
		# la distance exacte de la ville au desert.
		#
		# Le nom du noeud est la seule chose stable ici : deux vehicules ne
		# peuvent pas partager un nom dans le meme parent, et un troisieme
		# s'enregistrera sans qu'on touche a ce fichier.
		var tous: Dictionary = {}
		for n in get_tree().get_nodes_in_group(Vehicule.GROUPE):
			var v := n as Node3D
			if v == null:
				continue
			var q := v.global_position
			tous[str(v.name)] = [q.x, q.y, q.z, v.rotation.y]
		if not tous.is_empty():
			d["vehicules"] = tous
	return d


## Efface la sauvegarde. Pour quand on recommence de zero.
func effacer() -> void:
	if existe():
		DirAccess.remove_absolute(FICHIER)


## Recharge la partie depuis le fichier, si elle existe. Public : c'est ce
## qu'on appelle a la reprise apres une mort. _reprendre_si_possible fait deja
## le travail ; recharger() lui donne un nom qui dit l'intention depuis dehors.
func recharger() -> void:
	_reprendre_si_possible()


func _reprendre_si_possible() -> void:
	if not existe():
		return
	var brut: Variant = JSON.parse_string(FileAccess.get_file_as_string(FICHIER))
	if typeof(brut) != TYPE_DICTIONARY:
		push_error("sauvegarde : fichier illisible, ignore")
		return
	appliquer(brut)
	_annoncer_la_reprise()


## « Reprendre » doit dire ce qu'il reprend.
##
## On choisit un bouton dans un menu, un fondu passe, et on se retrouve quelque
## part sans savoir si c'est le debut ou la suite. Ca s'est vu en jouant le
## 07/08/2026 — « je spawn dans la rue » — et ce n'etait pas une panne : depuis
## que la position est restauree, une partie arretee dans une rue REPREND dans
## cette rue. C'est correct, et c'est deroutant parce que pendant quinze
## versions ca n'a jamais ete vrai.
##
## Une ligne suffit a lever le doute : elle dit ce qu'on etait en train de
## faire. Elle passe par le bandeau du controleur, le meme canal que les tutos
## et les pensees de Walter, donc elle s'efface toute seule et n'interrompt
## rien.
func _annoncer_la_reprise() -> void:
	if _controleur == null or not _controleur.has_method("annoncer"):
		return
	var quoi := _mission.objectif() if _mission else ""
	_controleur.call("annoncer",
			"Reprise — %s" % quoi if quoi != "" else "Reprise de la partie")


## Repose l'etat d'une sauvegarde. Public : les tests s'en servent directement,
## sans passer par le fichier. Chaque champ est facultatif : une sauvegarde
## d'une version anterieure a laquelle il manque une cle ne plante pas.
func appliquer(d: Dictionary) -> void:
	if _temps and d.has("heure"):
		_temps.regler(float(d["heure"]))
	if _bourse and d.has("argent"):
		_bourse.poser(int(d["argent"]))
	if _purete and d.has("purete"):
		_purete.poser(int(d["purete"]))
	if _famille and d.has("famille"):
		_famille.poser(int(d["famille"]))
	if _reputation and d.has("reputation"):
		_reputation.poser(int(d["reputation"]))
	if _equipement and d.has("inventaire"):
		var inv: Dictionary = d["inventaire"]
		_equipement.restaurer(inv.get("possedes", []), str(inv.get("tenu", "")),
			inv.get("portes", []))
	if _mission and d.has("mission"):
		var m: Dictionary = d["mission"]
		# UNE SAUVEGARDE D'UNE AUTRE MISSION NE DIT RIEN DE CELLE-CI.
		#
		# On ne refuse pas la partie pour autant — l'argent, la reputation, la
		# famille, l'inventaire et la position restent parfaitement valides, et
		# les jeter obligerait a recommencer pour une raison que le joueur ne
		# peut pas comprendre. Seule la mission repart de son debut.
		#
		# Les anciennes sauvegardes n'ont pas ce champ : sans lui on ne peut pas
		# savoir, et on suppose que c'est la bonne — c'etait le cas jusqu'au
		# 16/08/2026, puisqu'il n'y avait qu'une mission.
		var ecrite := str(m.get("fichier", _mission.fichier))
		if ecrite != _mission.fichier:
			print("SAUVEGARDE : elle vient de '%s', la mission chargee est '%s'"
					% [ecrite.get_file(), _mission.fichier.get_file()])
			print("             la mission repart du debut, le reste est garde")
			_mission.reprendre(0, [])
		else:
			_mission.reprendre(int(m.get("index", 0)), m.get("faites", []))
	if _joueur and d.has("position"):
		var p: Array = d["position"]
		if p.size() == 3:
			_joueur.global_position = Vector3(
				float(p[0]), float(p[1]), float(p[2]))

	# LA VOITURE D'ABORD, LE VOLANT ENSUITE, et l'ordre n'est pas indifferent :
	# monter deplace le joueur vers la portiere, donc reposer la voiture apres
	# coup le laisserait accroche a l'ancien endroit.
	# CHACUN RETROUVE SA PLACE, par son nom. Les sauvegardes d'avant ne
	# connaissent qu'un vehicule et l'appellent « vehicule » : on les lit encore,
	# et on rend cette position a celui que le controleur tient — c'est ce que
	# faisait l'ancienne version, et c'etait juste tant qu'il n'y en avait qu'un.
	var places: Dictionary = d.get("vehicules", {})
	if _controleur and places.is_empty() and d.has("vehicule"):
		var seul := _controleur.get("_v") as Node3D
		if seul != null:
			places = {str(seul.name): d["vehicule"]}
	for n in get_tree().get_nodes_in_group(Vehicule.GROUPE):
		var v := n as Node3D
		if v == null or not places.has(str(v.name)):
			continue
		var q: Array = places[str(v.name)]
		if q.size() != 4:
			continue
		v.global_position = Vector3(float(q[0]), float(q[1]), float(q[2]))
		v.rotation.y = float(q[3])
		# Une voiture reposee garde sa vitesse d'avant si on ne la coupe
		# pas : elle repartirait toute seule a la reprise.
		if v is VehicleBody3D:
			(v as VehicleBody3D).linear_velocity = Vector3.ZERO
			(v as VehicleBody3D).angular_velocity = Vector3.ZERO
	if _controleur and bool(d.get("au_volant", false)):
		if int(_controleur.get("_etat")) != VOLANT:
			_controleur.call("_monter")
	print("REPRISE : partie chargee")
