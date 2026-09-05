#!/usr/bin/env python3
"""Reporte UN clip livre sur un autre squelette, os par os, par l'ecart au repos.

    blender -b -P outils/reporter_clip.py -- \\
        --modele game/assets/personnages/jesse.glb \\
        --clip   livraisons/modeles/animations/jesse_idle.fbx \\
        --nom    Repos \\
        --sortie game/assets/personnages/jesse.glb

POURQUOI CET OUTIL EXISTE.

Guillaume livre ses animations depuis Mixamo : un clip sur le squelette Y-Bot,
soixante-cinq os prefixes « mixamorig: », en pose en T. Nos personnages sont
rigges par Meshy : vingt-quatre os aux noms voisins, en pose DETENDUE — les bras
le long du corps, pas a l'horizontale. fusionner_clips.py exige des squelettes
identiques ; ici rien ne l'est, ni le nombre d'os, ni les noms, ni le repos.

CE QU'ON REPORTE, ET CE QU'ON NE REPORTE PAS.

On ne recopie ni les rotations locales (les axes d'un os different d'un rig a
l'autre) ni l'orientation absolue (le repos differe : recopier « bras a
l'horizontale » sur un rig aux bras baisses donne un epouvantail — c'est le
mur sur lequel retarget_figurants.py s'est arrete le 31/07/2026).

On reporte L'ECART AU REPOS, en espace monde. Pour chaque image et chaque os :

    ecart  = R_pose_source . R_repos_source^-1      (ce que le clip FAIT)
    cible  = ecart . R_repos_cible                   (applique a NOTRE repos)

Un bras qui s'ecarte de dix degres dans le clip s'ecarte de dix degres chez
nous, depuis SA position de repos. Une attente, une respiration, un
balancement : tout ce qui est un ecart passe. Ce qui ne passerait pas, c'est un
clip dont la pose de repos fait partie du sens — on n'en a pas.

LA REFERENCE N'EST PAS LE REPOS DU CLIP, C'EST SA PREMIERE IMAGE. Mesure le
06/09/2026 : le repos Mixamo est une pose en T, et l'attente livree commence
bras baisses — l'ecart au repos des deux bras valait 89 degres des la premiere
image. Applique a notre repos, deja bras baisses, ca pliait les bras de
quatre-vingt-dix degres de plus, dans le corps. On mesure donc l'ecart a la
PREMIERE IMAGE du clip : a l'image 1, Jesse est exactement dans son repos a
lui, et tout ce qui suit est ce que le clip fait a partir de la. Pour une
attente, une respiration, un balancement, c'est le sens meme du clip. Un clip
qui COMMENCE loin de la station debout — un saut, une chute — demande l'autre
reference, `--reference repos`, et un rig au meme repos que le sien.

LA POSITION DU BASSIN N'EST PAS REPORTEE. Un clip d'attente ne se deplace pas,
et le jeu deplace le personnage lui-meme. Le bassin garde sa place de repos.

LES DOIGTS, LES BOUTS D'OS : ignores. Notre rig n'en a pas.

CE QUI EST MESURE APRES ECRITURE, parce qu'un export peut mentir : on relit le
fichier produit, on compte ses clips et ses os, et on imprime, pour la
premiere image du clip reporte, l'ecart en degres entre la pose et le repos sur
le bassin et les deux bras — un « attente » dont le bassin tourne de 90 degres
est un report rate, et il se lit ici sans ouvrir Blender.
"""
from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix

# Nom Meshy -> nom Mixamo (sans prefixe). Ce qui n'est pas ici porte le meme nom
# des deux cotes. Verifie sur le fichier : la colonne Meshy monte
# Hips -> Spine02 -> Spine01 -> Spine -> (neck, epaules), celle de Mixamo
# Hips -> Spine -> Spine1 -> Spine2 -> (Neck, epaules).
CORRESPONDANCE = {
    "Spine02": "Spine",
    "Spine01": "Spine1",
    "Spine": "Spine2",
    "neck": "Neck",
    "head_end": "HeadTop_End",
}
# Les bouts d'os sans longueur utile : on ne les anime pas.
IGNORES = {"head_end", "headfront"}


def arguments() -> argparse.Namespace:
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser(description="Reporte un clip livre sur un rig")
    ap.add_argument("--modele", required=True, help="le .glb du personnage")
    ap.add_argument("--clip", required=True, help="le .fbx ou .glb du clip")
    ap.add_argument("--nom", required=True, help="nom du clip dans le jeu")
    ap.add_argument("--prefixe", default="mixamorig:",
                    help="prefixe des os du clip source")
    ap.add_argument("--sortie", required=True)
    ap.add_argument("--pas", type=int, default=1,
                    help="une image sur N (1 = toutes)")
    ap.add_argument("--reference", default="premiere",
                    choices=("premiere", "repos"),
                    help="a quoi on mesure l'ecart : la premiere image du "
                         "clip (attentes, gestes sur place) ou son repos")
    return ap.parse_args(argv)


def importer(chemin: Path) -> None:
    if chemin.suffix.lower() == ".fbx":
        bpy.ops.import_scene.fbx(filepath=str(chemin))
    else:
        bpy.ops.import_scene.gltf(filepath=str(chemin))


def rotation_monde(arm, matrice_locale: Matrix) -> Matrix:
    """La rotation pure, en espace monde, d'une matrice d'os (repos ou pose)."""
    return (arm.matrix_world @ matrice_locale).to_3x3().normalized()


def ordre_parents_d_abord(arm) -> list:
    """Les os du plus haut de la hierarchie vers le bas : un enfant se pose
    toujours apres son parent, sinon sa matrice se calcule sur un parent
    encore au repos."""
    resultat = []

    def descendre(b):
        resultat.append(b)
        for e in b.children:
            descendre(e)

    for b in arm.data.bones:
        if b.parent is None:
            descendre(b)
    return resultat


def angle_deg(r_a: Matrix, r_b: Matrix) -> float:
    """L'angle, en degres, qui separe deux rotations."""
    return math.degrees((r_a @ r_b.inverted()).to_quaternion().angle)


def main() -> None:
    a = arguments()
    racine = Path.cwd()
    modele = Path(a.modele)
    clip = Path(a.clip)
    sortie = Path(a.sortie)
    for p in (modele, clip):
        if not p.exists():
            raise SystemExit("introuvable : %s" % p)
    if not sortie.is_absolute():
        sortie = racine / sortie

    bpy.ops.wm.read_factory_settings(use_empty=True)

    # --- le personnage -------------------------------------------------------
    importer(modele)
    cible = next((o for o in bpy.data.objects if o.type == "ARMATURE"), None)
    if cible is None:
        raise SystemExit("%s n'a pas de squelette" % modele.name)
    objets_perso = set(bpy.data.objects)
    actions_perso = set(bpy.data.actions)

    # --- le clip ---------------------------------------------------------------
    importer(clip)
    source = next((o for o in bpy.data.objects
                   if o.type == "ARMATURE" and o not in objets_perso), None)
    if source is None:
        raise SystemExit("%s n'a pas de squelette" % clip.name)
    if source.animation_data is None or source.animation_data.action is None:
        raise SystemExit("%s n'apporte aucune animation" % clip.name)
    action_source = source.animation_data.action
    debut, fin = (int(round(x)) for x in action_source.frame_range)

    # --- la table des os ---------------------------------------------------------
    paires = []      # (os cible, os source)
    absents = []
    for b in cible.data.bones:
        if b.name in IGNORES:
            continue
        nom_source = a.prefixe + CORRESPONDANCE.get(b.name, b.name)
        s = source.data.bones.get(nom_source)
        if s is None:
            absents.append("%s -> %s" % (b.name, nom_source))
            continue
        paires.append((b.name, s.name))
    if absents:
        print("  %-12s %s" % ("sans source", ", ".join(absents)))
    if len(paires) < 15:
        raise SystemExit("trop peu d'os en commun (%d) : ce clip n'est pas "
                         "pour ce squelette" % len(paires))

    # --- les repos, en monde -----------------------------------------------------
    repos_cible = {c: rotation_monde(cible, cible.data.bones[c].matrix_local)
                   for c, _ in paires}
    vers_source = dict(paires)
    scene = bpy.context.scene
    if a.reference == "premiere":
        scene.frame_set(debut)
        repos_source = {s: rotation_monde(source, source.pose.bones[s].matrix)
                        for _, s in paires}
    else:
        repos_source = {s: rotation_monde(source,
                                          source.data.bones[s].matrix_local)
                        for _, s in paires}

    # --- un clip neuf sur la cible -----------------------------------------------
    # Un clip homonyme deja present est REMPLACE : Blender renommerait le neuf
    # en « Repos.001 » et le jeu ne le trouverait plus.
    for act in list(bpy.data.actions):
        if act in actions_perso and act.name == a.nom:
            bpy.data.actions.remove(act)
    if cible.animation_data is None:
        cible.animation_data_create()
    cible.animation_data.action = None
    for pb in cible.pose.bones:
        pb.rotation_mode = "QUATERNION"
        pb.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)
        pb.location = (0.0, 0.0, 0.0)

    ordre = [b.name for b in ordre_parents_d_abord(cible) if b.name in vers_source]
    images = list(range(debut, fin + 1, max(1, a.pas)))
    premier_ecart = {}
    for f in images:
        scene.frame_set(f)
        # Les poses du clip source, lues en monde, AVANT de toucher la cible.
        pose_source = {s: rotation_monde(source, source.pose.bones[s].matrix)
                       for _, s in paires}
        for nom in ordre:
            s = vers_source[nom]
            ecart = pose_source[s] @ repos_source[s].inverted()
            voulu = ecart @ repos_cible[nom]
            pb = cible.pose.bones[nom]
            # On garde la position courante de l'os (celle que lui donne son
            # parent deja pose) et on ne change que son orientation.
            bpy.context.view_layer.update()
            actuel = cible.matrix_world @ pb.matrix
            m = voulu.to_4x4()
            m.translation = actuel.translation
            pb.matrix = cible.matrix_world.inverted() @ m
            bpy.context.view_layer.update()
            pb.keyframe_insert("rotation_quaternion", frame=f)
            if f == images[0]:
                premier_ecart[nom] = math.degrees(ecart.to_quaternion().angle)

    action = cible.animation_data.action
    if action is None:
        raise SystemExit("aucune cle inseree : le report n'a rien produit")
    action.name = a.nom
    action.use_fake_user = True
    # Un clip d'attente boucle : sa derniere image doit rejoindre la premiere.
    # Mixamo livre deja ses attentes en boucle ; on ne fait que le constater.
    # L'AMPLITUDE DU CLIP, relue sur les cles posees : le plus grand ecart a la
    # reference sur toute la duree, os par os. C'est ce qui distingue une
    # attente (quelques degres) d'un report rate (un bras a 90).
    amplitude = {}
    for f in images:
        scene.frame_set(f)
        for nom in ("Hips", "Spine02", "LeftArm", "RightArm", "Head"):
            if nom not in vers_source:
                continue
            r = rotation_monde(cible, cible.pose.bones[nom].matrix)
            amplitude[nom] = max(amplitude.get(nom, 0.0),
                                 angle_deg(r, repos_cible[nom]))
    print("")
    print("  %-12s %s" % ("clip", clip.name))
    print("  %-12s %s : %d image(s), %d os sur %d, reference = %s"
          % ("reporte", a.nom, len(images), len(paires),
             len(cible.data.bones), a.reference))
    for nom, amp in amplitude.items():
        print("  %-12s %-8s s'ecarte au plus de %.1f deg de notre repos"
              % ("", nom, amp))

    # --- on jette la source, actions comprises ------------------------------------
    for o in [o for o in bpy.data.objects if o not in objets_perso]:
        bpy.data.objects.remove(o, do_unlink=True)
    for act in [x for x in bpy.data.actions
                if x not in actions_perso and x != action]:
        bpy.data.actions.remove(act)
    cible.animation_data.action = None
    scene.frame_set(debut)
    for pb in cible.pose.bones:
        pb.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)

    # --- export, puis relecture du fichier ecrit ------------------------------------
    sortie.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=str(sortie),
        export_format="GLB",
        use_selection=True,
        export_apply=False,
        export_yup=True,
        export_animations=True,
        export_cameras=False,
        export_lights=False,
    )
    sys.path.insert(0, str(racine / "outils"))
    import lire_glb  # noqa: E402
    print("  %-12s %s" % ("sortie", sortie))
    lire_glb.imprimer(sortie)


if __name__ == "__main__":
    main()
