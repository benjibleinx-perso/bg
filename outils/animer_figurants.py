"""Donne aux figurants du pack les clips d'animation de Walter.

*** CE SCRIPT NE DONNE PAS UN RESULTAT UTILISABLE. NE PAS LE RELANCER SANS ***
*** AVOIR LU LA SECTION « CE QUI RATE » PLUS BAS.                          ***

    blender -b -P outils/animer_figurants.py
    blender -b -P outils/animer_figurants.py -- --un figurant_casual_male_k

CE QUI RATE, ET C'EST LA DEUXIEME FOIS.

Le transfert marche techniquement : les quatre clips arrivent, le squelette
reste unique, le maillage et la texture sont intacts, le poids passe de 0,29 a
0,36 Mo. Huit fichiers sur huit annonçaient « conforme ».

A l'image, le corps se disloque : membres en etoile, bassin de travers. Le meme
defaut, exactement, que outils/retarget_figurants.py au 31/07/2026 — qui, lui,
passait par l'espace monde. Deux methodes opposees, un seul resultat.

LA CAUSE. Les deux squelettes partagent 22 noms d'os sur 24, mais PAS leurs
orientations de repos. Une rotation enregistree pour l'os « LeftUpLeg » de
Walter suppose l'axe de repos de Walter ; posee telle quelle sur le
« LeftUpLeg » d'un figurant, dont l'axe pointe ailleurs, elle envoie la cuisse
n'importe ou. Copier une courbe n'est pas retargeter.

CE QU'IL FAUDRAIT. Composer avec l'ecart de repos, os par os :

    rotation_cible = repos_cible^-1 * repos_source * rotation_source

C'est un vrai travail de retargeting, et deux tentatives naives ont echoue.
La troisieme doit partir de cette formule, ou ne pas avoir lieu.

LA LEÇON, ET ELLE EST PLUS LARGE QUE CE FICHIER. J'ai mesure le nombre de
squelettes, de maillages, d'images, d'animations et le poids — cinq nombres
justes, aucun qui reponde a « est-ce que le corps tient debout ». Cette
question-la n'a qu'un instrument, outils/apercu_modele.py, et il existait
depuis le 31/07 precisement pour ca. Voir docs/11-pieges.md, piege 30.

POURQUOI CE SCRIPT EST QUAND MEME GARDE.

Pour qu'une troisieme tentative sache ce qui a deja ete essaye. Il contient
aussi trois corrections qui resservent a qui touchera aux .glb : la nouvelle
API d'actions de Blender 4.4+, la selection par difference plutot que par
descendance, et le menage des actions avant export.

POURQUOI CE SCRIPT EXISTE.

Les huit figurants du pack sont rigges, poses au sol, et dorment dans le depot
depuis une livraison. Le code les attend : pieton.gd choisit deja Demarche
plutot que Silhouette des qu'un modele porte un squelette, et son commentaire
dit que « c'etait la condition pour que les vrais modeles entrent dans la rue ».

Il leur manque UNE chose, et elle est bloquante : ils n'ont qu'un seul clip,
nomme « Repos ». Demarche cherche « Marche » ou « Walking » pour avancer. Les
brancher tels quels donnerait des passants qui GLISSENT DEBOUT, immobiles —
strictement pire que les mannequins actuels, qui marchent grace a la
silhouette procedurale.

CE QUI REND LE TRANSFERT POSSIBLE : walt.glb et les figurants partagent 22 os
sur 24, avec les memes noms standards — Hips, LeftUpLeg, LeftForeArm, Head. Une
courbe d'animation glTF cible un os PAR SON NOM ; elle s'applique donc telle
quelle sur l'autre squelette, sans retargeting.

CE QUI NE PASSE PAS, ET C'EST ASSUME : walt a « Spine » la ou les figurants ont
« Spine01 » et « Spine02 ». Le torse restera donc a sa pose de repos. Sur un
passant vu a dix metres qui traverse un trottoir, un buste qui ne se balance
pas ne se remarque pas ; des jambes qui ne bougent pas, si.

ON NE TOUCHE PAS AU MAILLAGE NI AUX POIDS. Le script importe, ajoute des pistes
d'animation, et reexporte. Toute autre modification serait un risque pour rien.
"""
import os
import sys

import bpy

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PERSOS = os.path.join(RACINE, "game", "assets", "personnages")

# Le donneur. Ses clips ont ete fabriques pour ce projet et sont deja regles.
SOURCE = "walt"

# Ce qu'on transfere, et rien d'autre. Un passant n'a pas besoin de « Lire »
# ni de « Coiffer » : ces clips pesent et ne seront jamais joues dans la rue.
CLIPS = ["Repos", "Marche", "Walking", "Running"]

FIGURANTS = [
    "figurant_casual_male_g",
    "figurant_casual_male_k",
    "figurant_casual_female_g",
    "figurant_casual_female_k",
    "figurant_elder_female_a",
    "figurant_police_female_a",
    "figurant_doctor_male_b",
    "figurant_little_boy_b",
]


def vider():
    """Repart d'une scene propre. Un import laisse tout derriere lui."""
    bpy.ops.wm.read_factory_settings(use_empty=True)


def importer(nom):
    chemin = os.path.join(PERSOS, nom + ".glb")
    if not os.path.exists(chemin):
        return None
    bpy.ops.import_scene.gltf(filepath=chemin)
    for o in bpy.context.scene.objects:
        if o.type == "ARMATURE":
            return o
    return None


def actions_de(armature):
    """Les actions que porte cette armature, par nom de clip.

    Blender range les clips importes d'un glTF dans des pistes NLA. On les
    ramasse la ET dans l'action active : selon la version de l'importeur, un
    modele a un seul clip peut n'avoir aucune piste.
    """
    trouvees = {}
    ad = armature.animation_data
    if ad is None:
        return trouvees
    if ad.action is not None:
        trouvees[ad.action.name] = ad.action
    for piste in ad.nla_tracks:
        for bande in piste.strips:
            if bande.action is not None:
                trouvees[bande.name] = bande.action
                trouvees.setdefault(bande.action.name, bande.action)
    return trouvees


def courbes_de(action):
    """Les F-curves d'une action, quelle que soit la version de Blender.

    Depuis Blender 4.4 une action range ses courbes dans des couches
    (layers > strips > channelbags) et `action.fcurves` n'existe plus. Le
    premier jet de ce script est mort dessus sur Blender 5.2 : AttributeError
    au premier figurant, apres avoir lu les dix clips sans probleme.
    """
    if hasattr(action, "fcurves"):
        return list(action.fcurves)
    sortie = []
    for couche in getattr(action, "layers", []):
        for bande in getattr(couche, "strips", []):
            for sac in getattr(bande, "channelbags", []):
                sortie.extend(sac.fcurves)
    return sortie


def transferer(nom_figurant, clips_source, deja_la):
    """Pose les clips sur le figurant et reexporte par-dessus son fichier.

    `deja_la` est l'ensemble des objets presents AVANT l'import : tout ce qui
    apparait ensuite appartient au figurant. C'est le seul repere fiable — les
    maillages skinnes d'un glTF ne sont PAS forcement enfants de leur armature,
    et selectionner l'armature et sa descendance a produit un fichier a zero
    maillage, donc un passant invisible.
    """
    cible = importer(nom_figurant)
    if cible is None:
        return "pas d'armature"

    os_cible = {b.name for b in cible.pose.bones}
    if cible.animation_data is None:
        cible.animation_data_create()

    # On efface les pistes existantes : le figurant n'a que « Repos », et on le
    # remet nous-memes. Sans ce nettoyage, l'export sortirait deux clips du
    # meme nom et Godot en choisirait un au hasard.
    for piste in list(cible.animation_data.nla_tracks):
        cible.animation_data.nla_tracks.remove(piste)
    cible.animation_data.action = None

    # ON NE GARDE QUE LES QUATRE CLIPS VOULUS, et c'est une correction de poids
    # autant que de proprete.
    #
    # L'export en mode ACTIONS sort TOUTE action presente dans le fichier, pas
    # seulement celles posees sur des pistes. Le figurant repartait donc avec
    # les onze clips de Walter — « Lire », « Coiffer », « Assis », dont un
    # passant de trottoir n'a aucun usage — et pesait 0,65 Mo au lieu de 0,29.
    #
    # Le « Repos » d'origine du figurant est supprime avec le reste : sans ca
    # il cohabitait avec celui de Walter sous le nom « Repos.001 », et Godot
    # aurait choisi l'un des deux sans qu'on sache lequel.
    voulus = set(clips_source.keys())
    for act in list(bpy.data.actions):
        if act.name not in voulus:
            bpy.data.actions.remove(act)

    poses = []
    manques = set()
    for nom_clip in CLIPS:
        action = clips_source.get(nom_clip)
        if action is None:
            continue
        # Les courbes ciblent pose.bones["X"] : on releve celles dont l'os
        # n'existe pas chez la cible, pour le DIRE plutot que de le decouvrir
        # a l'ecran.
        for fc in courbes_de(action):
            chemin = fc.data_path
            if 'pose.bones["' in chemin:
                nom_os = chemin.split('pose.bones["')[1].split('"]')[0]
                if nom_os not in os_cible:
                    manques.add(nom_os)
        piste = cible.animation_data.nla_tracks.new()
        piste.name = nom_clip
        bande = piste.strips.new(nom_clip, 0, action)
        # UNE ACTION A SLOT DOIT ETRE RELIEE AU BON SLOT.
        #
        # Depuis Blender 4.4, une action porte des « slots » et une bande NLA
        # qui n'en designe aucun n'anime rien : l'export sortait alors le seul
        # clip d'origine du figurant, alors que les quatre pistes existaient
        # bien. Le nombre de courbes ci-dessous le dit tout de suite.
        if hasattr(bande, "action_slot") and getattr(action, "slots", None):
            for slot in action.slots:
                try:
                    bande.action_slot = slot
                    break
                except (TypeError, AttributeError):
                    continue
        poses.append("%s(%d)" % (nom_clip, len(courbes_de(action))))

    if not poses:
        return "aucun clip a poser"

    # ON N'EXPORTE QUE LA CIBLE, et c'est une correction d'apres mesure.
    #
    # Le donneur reste dans la scene : c'est lui qui porte les actions, le
    # retirer les libererait. Sans use_selection, l'export emportait donc les
    # DEUX armatures — le fichier produit annonçait « skins=2 » la ou il en
    # fallait un, et le figurant sortait avec Walter greffe dedans.
    #
    # C'est exactement la regle du projet : on mesure le fichier PRODUIT. Le
    # transfert paraissait reussi, les quatre clips etaient bien la, et le
    # defaut ne se voyait que dans le nombre de squelettes.
    bpy.ops.object.select_all(action="DESELECT")
    for o in bpy.context.scene.objects:
        if o not in deja_la:
            o.select_set(True)
    bpy.context.view_layer.objects.active = cible

    sortie = os.path.join(PERSOS, nom_figurant + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=sortie,
        export_format="GLB",
        use_selection=True,
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_skins=True,
        export_yup=True,
    )
    reste = ", ".join(sorted(manques)) if manques else "-"
    return "%s   os absents : %s" % (", ".join(poses), reste)


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    seulement = None
    if "--un" in args:
        seulement = args[args.index("--un") + 1]

    # On lit les clips du donneur UNE fois, et on garde le fichier .blend en
    # memoire : recharger walt pour chaque figurant couterait huit imports.
    print("")
    print("--- clips de %s ---" % SOURCE)
    vider()
    source = importer(SOURCE)
    if source is None:
        print("ECHEC %s introuvable ou sans armature" % SOURCE)
        return
    dispo = actions_de(source)
    print("  %d action(s) : %s" % (len(dispo), ", ".join(sorted(dispo))))
    a_transferer = [c for c in CLIPS if c in dispo]
    print("  a transferer : %s" % ", ".join(a_transferer))
    if not a_transferer:
        print("ECHEC aucun des clips demandes n'est dans %s" % SOURCE)
        return

    # Les actions survivent au vidage de la scene tant qu'on garde une
    # reference : Blender ne libere que ce qui n'a plus d'utilisateur.
    gardees = {}
    for nom in a_transferer:
        act = dispo[nom]
        act.use_fake_user = True
        gardees[nom] = act

    print("")
    print("--- transfert ---")
    liste = [seulement] if seulement else FIGURANTS
    faits = 0
    for nom in liste:
        # On repart du .blend courant : les actions y sont deja, il suffit
        # d'importer la cible a cote.
        for o in list(bpy.context.scene.objects):
            if o != source:
                bpy.data.objects.remove(o, do_unlink=True)
        deja_la = set(bpy.context.scene.objects)
        clips = {n: bpy.data.actions.get(a.name) for n, a in gardees.items()}
        res = transferer(nom, clips, deja_la)
        print("  %-28s %s" % (nom, res))
        if "os absents" in res:
            faits += 1

    print("")
    print("%d figurant(s) animes" % faits)


main()
