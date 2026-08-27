# Verifie que les sons sont reellement BRANCHES.
#
#   godot --path game --script res://verifs/test_sons.gd
#
# Le mode de defaillance du son, c'est le silence : un fichier qui manque, un
# nom mal orthographie, un signal jamais connecte donnent tous exactement le
# meme resultat — rien. Et rien ne se distingue pas de « ce mecanisme n'est
# pas encore fait ».
#
# Ce test compte donc les LECTEURS effectivement crees et joues. C'est la
# seule preuve qu'on puisse obtenir sans oreilles.
extends SceneTree

# Plus long que le plus court des flux mis en boucle — 1,24 s pour le
# roulement. C'est la seule facon de distinguer « il joue » de « il boucle » :
# un test plus court passait au vert sur un fichier qui s'arretait a la fin.
const POSE := 200

var _n := 0
var _erreurs: Array[String] = []
var _audio: Audio
var _monde: Node


func _initialize() -> void:
	var ps := ResourceLoader.load("res://scenes/monde.tscn") as PackedScene
	_monde = ps.instantiate()
	root.add_child(_monde)


func _verifier(ok: bool, message: String) -> void:
	if ok:
		print("  ok   " + message)
	else:
		_erreurs.append(message)
		printerr("  ECHEC " + message)


func _process(_d: float) -> bool:
	_n += 1
	if _n < POSE:
		return false

	_audio = root.get_tree().get_first_node_in_group(Audio.GROUPE) as Audio
	if _audio == null:
		printerr("  ECHEC aucun noeud dans le groupe '%s'" % Audio.GROUPE)
		printerr("        les systemes se trouvent par la : sans ce groupe, "
				+ "TOUT est muet et rien ne le dit.")
		quit(1)
		return true
	print("  ok   le groupe '%s' repond" % Audio.GROUPE)

	_le_rangement()
	_la_banque()
	_les_lecteurs()
	_les_pas()
	_le_roulement()

	print("")
	if _erreurs.is_empty():
		print("TEST SONS OK")
		quit(0)
	else:
		printerr("TEST SONS ECHOUE : %d probleme(s)" % _erreurs.size())
		quit(1)
	return true


# Rien ne doit trainer a la racine de assets/sons/.
#
# Un fichier pose la n'est branche sur rien, et il est le plus souvent le
# DOUBLON d'un fichier deja range — donc une version perimee de celui qui
# sert. C'est arrive deux fois : une livraison faite avec une version
# anterieure du script de rangement, puis un « git add -A » en plein rebase
# qui a ressuscite les vingt-huit originaux d'avant leur conversion en PCM.
#
# Les deux fois, le jeu marchait parfaitement. C'est bien le probleme.
func _le_rangement() -> void:
	print("\n--- rien ne traine a la racine de assets/sons/ ---")
	var vrac: Array[String] = []
	for f in DirAccess.get_files_at("res://assets/sons"):
		# .import et .remap sont poses par Godot a cote des sources ; ici il
		# n'y a pas de source, donc leur seule presence est deja le symptome.
		if f.get_extension() in ["wav", "ogg", "mp3", "import"]:
			vrac.append(f)
	if vrac.is_empty():
		print("  ok   la racine ne contient que le LISEZ-MOI")
	else:
		_verifier(false, "%d fichier(s) a la racine : %s"
				% [vrac.size(), ", ".join(vrac)])
		printerr("        Ils doivent aller dans vehicule/, pas/, maison/, "
				+ "interface/, telephone/ ou ambiance/.")


# Chaque nom cite dans le code doit exister dans la banque. C'est la faute la
# moins visible de toutes : une faute de frappe dans « portiere_ouvre » ne
# produit qu'un avertissement au fond de la console, une seule fois.
func _la_banque() -> void:
	print("\n--- la banque connait ce que le code reclame ---")
	# ON LIT LE CODE, ON NE RECOPIE PLUS UNE LISTE.
	#
	# Cette liste etait ecrite a la main, et elle avait deja pris du retard :
	# « demarreur », reclame par systemes/demarreur.gd depuis le mini-jeu du
	# 17/08/2026, n'y figurait pas. Une clef renommee d'un cote et pas de
	# l'autre ne produit qu'un avertissement au fond de la console, une fois —
	# c'est exactement ce que cette suite existe pour attraper, et elle ne
	# regardait qu'un sous-ensemble choisi trois semaines plus tot.
	#
	# Meme lecon que la table des phases du menu de test, payee le meme jour
	# (piege 65) : quand une liste peut se DEDUIRE de ce qu'elle decrit, la
	# deduire.
	var attendus := _cles_citees_dans_le_code()
	_verifier(not attendus.is_empty(),
			"%d nom(s) de son cites dans le code" % attendus.size())
	for nom in attendus:
		_verifier(_audio.connait(nom), "'%s'" % nom)

	# Les objets composent leur nom a partir de la cle. On verifie que la
	# composition tombe juste pour ceux qui sont censes sonner. Ceux-la
	# RESTENT ecrits ici : un nom fabrique a l'execution — « objet_%s » — ne se
	# lit pas dans le source, et c'est la seule famille dans ce cas.
	for cle in ["livre", "chapeau", "meth"]:
		_verifier(_audio.connait("objet_%s" % cle), "'objet_%s'" % cle)

	# LES PORTIERES AUSSI SE COMPOSENT, depuis que chaque vehicule declare sa
	# famille de portes. On lit les prefixes dans les SCENES plutot que de les
	# recopier : un vehicule ajoute demain avec un prefixe sans entree dans la
	# banque serait muet a chaque fois qu'on y monte, et rien ne le dirait.
	for famille in _familles_de_portes():
		_verifier(_audio.connait("%s_ouvre" % famille), "'%s_ouvre'" % famille)
		_verifier(_audio.connait("%s_ferme" % famille), "'%s_ferme'" % famille)

	# LES GAINS SONT LUS, et pas seulement declares.
	#
	# Le klaxon a ete enregistre a 16 % de l'echelle quand la portiere culmine
	# a 99 % : en jouant, on ne l'entendait pas. Le rattrapage vit dans
	# sons.json, et une section que personne ne relit est une section qu'on
	# croit active alors qu'une faute de frappe l'a rendue muette.
	_verifier(_audio.gain_de("klaxon") > 0.0,
			"le klaxon est remonte (%+.0f dB)" % _audio.gain_de("klaxon"))
	_verifier(_audio.gain_de("portiere_ouvre") == 0.0,
			"et un son deja au bon niveau n'est pas touche")

	print("\n--- les nappes durent, et s'arretent ---")
	# Une nappe ne se distingue d'un bruitage que par sa FIN : les deux
	# demarrent pareil. Ce qui compte est donc qu'elle tienne, qu'un second
	# appel ne la relance pas, et qu'on sache l'arreter.
	_verifier(_audio.connait("roue_maintien"), "'roue_maintien'")
	_verifier(not _audio.nappe_en_cours("roue_maintien"), "rien ne tourne au depart")
	_audio.nappe("roue_maintien")
	_verifier(_audio.nappe_en_cours("roue_maintien"), "elle demarre")
	var n_avant := _lecteurs_de(_audio).size()
	_audio.nappe("roue_maintien")
	_verifier(_lecteurs_de(_audio).size() == n_avant,
			"la redemander ne cree pas un second lecteur")
	_audio.couper_nappe("roue_maintien", 0.01)
	_verifier(not _audio.nappe_en_cours("roue_maintien"), "et elle s'arrete")


# On demande un son, et on regarde s'il apparait un lecteur qui joue. Verifier
# que la banque contient le fichier ne prouverait rien : la premiere version
# de bruit_ici() creait bien le lecteur, mais posait sa position AVANT de
# l'ajouter a l'arbre — global_position n'existe pas encore, et le son partait
# a l'origine du monde.
func _les_lecteurs() -> void:
	print("\n--- un son demande produit un lecteur qui joue ---")
	var avant := _lecteurs_de(_audio).size()
	_audio.bruit("roue_ouvre")
	var apres := _lecteurs_de(_audio)
	_verifier(apres.size() > avant,
			"bruit() cree un lecteur (%d -> %d)" % [avant, apres.size()])
	if apres.size() > avant:
		var p: Node = apres[apres.size() - 1]
		_verifier(p.playing, "il joue")

	var ou := Vector3(12.0, 1.0, -8.0)
	_audio.bruit_ici("portiere_ferme", ou)
	var trois_d := _lecteurs_de(_audio).filter(
			func(p: Node) -> bool: return p is AudioStreamPlayer3D)
	_verifier(not trois_d.is_empty(), "bruit_ici() cree un lecteur positionne")
	if not trois_d.is_empty():
		var p := trois_d[trois_d.size() - 1] as AudioStreamPlayer3D
		var d := p.global_position.distance_to(ou)
		_verifier(d < 0.01,
				"il est POSE au bon endroit (ecart %.3f m)" % d)
		_verifier(p.bus == Audio.BUS_EFFETS, "il sort sur le bus Effets")

	# Un nom absent ne doit rien casser : c'est le cas normal d'un mecanisme
	# pas encore sonorise.
	var n := _lecteurs_de(_audio).size()
	_audio.bruit("ce_son_n_existe_pas")
	_verifier(_lecteurs_de(_audio).size() == n,
			"un nom inconnu ne cree rien, et ne plante pas")


# Le signal de pas est le maillon qu'on ne voit pas. Il se compte : on fait
# marcher une silhouette sur une distance connue et on verifie la cadence.
func _les_pas() -> void:
	print("\n--- la cadence des pas ---")
	var reglages := ResourceLoader.load("res://systemes/reglages.tres") as Reglages
	var s := Silhouette.new(reglages)
	var comptes := [0]
	s.pas.connect(func() -> void: comptes[0] += 1)

	# Dix metres a 3 m/s, par pas de 1/60 s. Une demi-foulee par pas pose,
	# donc 10 / (foulee / 2) contacts attendus.
	var vitesse := 3.0
	var delta := 1.0 / 60.0
	var distance := 0.0
	while distance < 10.0:
		s.avancer(vitesse, delta)
		distance += vitesse * delta

	var attendu := int(10.0 / (reglages.foulee * 0.5))
	var ecart: int = absi(comptes[0] - attendu)
	print("       %d pas sur 10 m, attendu %d (foulee %.2f m)"
			% [comptes[0], attendu, reglages.foulee])
	_verifier(ecart <= 1, "la cadence suit la distance parcourue")

	# A l'arret, plus aucun pas. Une version comptant le TEMPS continuait a en
	# emettre sur place, et Walter marchait sans avancer.
	var fige: int = comptes[0]
	for i in 120:
		s.avancer(0.0, delta)
	_verifier(comptes[0] == fige, "a l'arret, plus un seul pas")


# Le roulement doit se taire a l'arret et monter avec la vitesse. C'est la
# seule couche sonore branchee sur la VITESSE et non sur le regime : une
# erreur ici donne une voiture qui gronde a l'arret, ou muette en roue libre.
func _le_roulement() -> void:
	print("\n--- le roulement des pneus ---")
	var v := _trouver(_monde, "Vehicule")
	if v == null:
		_verifier(false, "vehicule introuvable")
		return
	var m := v.get_node_or_null("MoteurAudio") as MoteurAudio
	if m == null:
		_verifier(false, "MoteurAudio introuvable")
		return
	_verifier(m.roulement != null, "un flux de roulement est assigne")
	_verifier(m.crissement != null, "un flux de crissement est assigne")

	var lecteurs := _lecteurs_de(m).filter(
			func(p: Node) -> bool: return p.stream == m.roulement)
	if lecteurs.is_empty():
		_verifier(false, "aucun lecteur ne porte le roulement")
		return
	var p := lecteurs[0] as AudioStreamPlayer3D
	_verifier((m.roulement as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_DISABLED,
			"le flux est marque en boucle a l'import")
	_verifier(p.playing, "il tourne encore apres %.1f s (duree du flux : %.2f s)"
			% [float(POSE) / 60.0, m.roulement.get_length()])
	# La voiture est a l'arret : il doit etre coupe, pas simplement discret.
	_verifier(p.volume_db < -60.0,
			"a l'arret il est coupe (%.1f dB)" % p.volume_db)


func _lecteurs_de(n: Node) -> Array:
	return n.get_children().filter(
			func(e: Node) -> bool: return e is AudioStreamPlayer \
					or e is AudioStreamPlayer3D)


func _trouver(n: Node, nom: String) -> Node:
	if n.name == nom:
		return n
	for e in n.get_children():
		var t := _trouver(e, nom)
		if t != null:
			return t
	return null


# TOUS LES NOMS DE SON CITES EN CLAIR DANS LE CODE.
#
# On cherche `bruit("...")` et `nappe("...")` dans les scripts du jeu, on garde
# les litteraux, et on rend la liste triee. Ce qui est fabrique a l'execution —
# « objet_%s » — n'y figure pas, et c'est normal : personne ne peut le lire dans
# le source. Ces cas-la restent nommes a la main, juste au-dessus.
#
# ON NE LIT PAS verifs/ : une suite qui joue un son pour se mesurer elle-meme
# n'est pas le jeu, et ses noms n'ont aucune raison d'exister dans la banque.
func _cles_citees_dans_le_code() -> Array:
	var trouvees := {}
	var motif := RegEx.new()
	# CHAINE BRUTE : sans le `r`, GDScript lit `\(` comme un echappement et
	# refuse de charger le fichier entier — « Invalid escape in string », et la
	# suite ne demarre meme pas.
	motif.compile(r'(?:bruit|nappe)\(\s*"([a-z0-9_]+)"')
	for dossier in ["res://systemes", "res://scenes", "res://rendu"]:
		_lire_les_scripts(dossier, motif, trouvees)
	var liste := trouvees.keys()
	liste.sort()
	return liste


func _lire_les_scripts(chemin: String, motif: RegEx, trouvees: Dictionary) -> void:
	var d := DirAccess.open(chemin)
	if d == null:
		return
	d.list_dir_begin()
	var nom := d.get_next()
	while nom != "":
		var complet := "%s/%s" % [chemin, nom]
		if d.current_is_dir():
			if not nom.begins_with("."):
				_lire_les_scripts(complet, motif, trouvees)
		elif nom.ends_with(".gd"):
			var source := FileAccess.get_file_as_string(complet)
			for m in motif.search_all(source):
				trouvees[m.get_string(1)] = true
		nom = d.get_next()
	d.list_dir_end()


# LES FAMILLES DE PORTES DECLAREES PAR LES VEHICULES.
#
# On lit les scenes, pas une liste : c'est le meme choix que pour les noms de
# son cites dans le code, et pour la meme raison. « portiere » y est toujours,
# meme si aucune scene ne la nomme — c'est le repli du controleur quand un
# vehicule ne declare rien.
func _familles_de_portes() -> Array:
	var trouvees := {"portiere": true}
	var motif := RegEx.new()
	motif.compile(r'sons_portes\s*=\s*"([a-z0-9_]+)"')
	for f in DirAccess.get_files_at("res://scenes"):
		if not f.ends_with(".tscn"):
			continue
		var source := FileAccess.get_file_as_string("res://scenes/%s" % f)
		for m in motif.search_all(source):
			trouvees[m.get_string(1)] = true
	var liste := trouvees.keys()
	liste.sort()
	return liste
