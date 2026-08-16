#!/usr/bin/env python3
"""Genere les objets que Walter peut tenir.

    blender -b -P outils/gen_objets.py -- --nom tous

Produit un .glb par objet dans game/assets/objets/. Ce sont des accessoires,
pas des maillages de heros : quelques dizaines de faces chacun, tenus a bout
de bras et vus a 512 pixels de large. Ce qui compte est la silhouette — a
cette taille, on reconnait une forme, jamais un detail.

Chaque objet est modelise dans le repere de la MAIN, pas dans le sien : la
poignee de l'arme est a l'origine, le bord du chapeau aussi. C'est ce qui
permet de les accrocher sans reglage au cas par cas.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import bpy
import bmesh


def arguments() -> argparse.Namespace:
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser(description="Generateur d objets tenus")
    ap.add_argument("--nom", default="tous")
    ap.add_argument("--textures", default=".tmp/textures")
    ap.add_argument("--sortie", default="game/assets/objets")
    return ap.parse_args(argv)


def materiau(nom: str, dossier: Path) -> bpy.types.Material:
    mat = bpy.data.materials.new(nom)
    arbre = mat.node_tree
    principal = arbre.nodes["Principled BSDF"]
    principal.inputs["Roughness"].default_value = 0.85
    principal.inputs["Metallic"].default_value = 0.0

    png = dossier / f"{nom}.png"
    if not png.exists():
        # La palette vit dans .tmp/, hors du projet Godot : elle n est qu une
        # matiere premiere, cuite dans le .glb a l export. Sans elle le modele
        # sortait gris SANS RIEN DIRE, et on cherchait le probleme dans Blender.
        raise SystemExit(
            f"texture absente : {png}\n"
            f"La palette se refabrique : .\\bg.ps1 generer"
        )
    img = bpy.data.images.load(str(png), check_existing=True)
    img.alpha_mode = "NONE"
    tex = arbre.nodes.new("ShaderNodeTexImage")
    tex.image = img
    # Filtrage lineaire : c'est le rendu PS2, pas les texels carres PS1.
    tex.interpolation = "Linear"
    arbre.links.new(principal.inputs["Base Color"], tex.outputs["Color"])
    return mat


class Maillage:
    def __init__(self, nom: str, mat):
        self.mesh = bpy.data.meshes.new(nom)
        self.obj = bpy.data.objects.new(nom, self.mesh)
        bpy.context.collection.objects.link(self.obj)
        self.mesh.materials.append(mat)
        self.bm = bmesh.new()
        self.uv = self.bm.loops.layers.uv.verify()

    def face(self, points, uvs) -> None:
        verts = [self.bm.verts.new(p) for p in points]
        f = self.bm.faces.new(verts)
        for boucle, coord in zip(f.loops, uvs):
            boucle[self.uv].uv = coord

    def boite(self, x0, y0, z0, x1, y1, z1, tuile=1.0) -> None:
        """Pave droit, six faces, UV mis a l'echelle de chaque face."""
        lx, ly, lz = (x1 - x0) / tuile, (y1 - y0) / tuile, (z1 - z0) / tuile
        c = [(x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0),
             (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)]
        for indices, (u, v) in [
            ((0, 3, 2, 1), (lx, ly)),          # dessous
            ((4, 5, 6, 7), (lx, ly)),          # dessus
            ((0, 1, 5, 4), (lx, lz)),
            ((1, 2, 6, 5), (ly, lz)),
            ((2, 3, 7, 6), (lx, lz)),
            ((3, 0, 4, 7), (ly, lz)),
        ]:
            self.face([c[i] for i in indices],
                      [(0, 0), (u, 0), (u, v), (0, v)])

    def finir(self) -> int:
        bmesh.ops.remove_doubles(self.bm, verts=self.bm.verts, dist=1e-5)
        self.bm.normal_update()
        n = len(self.bm.faces)
        self.bm.to_mesh(self.mesh)
        self.bm.free()
        return n


# --------------------------------------------------------------- les objets
#
# Convention : l'objet est construit debout, Z vers le haut, et son point de
# prise est a l'origine. L'orientation finale dans la main est reglee dans
# game/donnees/outils.json — donc modifiable sans regenerer quoi que ce soit.


def arme(mats) -> int:
    """Un revolver court. Deux volumes suffisent a le rendre reconnaissable :
    une crosse inclinee et un canon horizontal."""
    total = 0
    m = Maillage("Arme", mats["metal"])
    m.boite(-0.018, -0.030, -0.105, 0.018, 0.028, 0.010)   # crosse
    m.boite(-0.016, 0.020, 0.012, 0.016, 0.170, 0.048)     # canon
    m.boite(-0.020, -0.005, 0.006, 0.020, 0.045, 0.052)    # barillet
    total += m.finir()

    d = Maillage("Detente", mats["metal_sombre"])
    d.boite(-0.006, 0.004, -0.030, 0.006, 0.030, 0.006)    # pontet
    total += d.finir()
    return total


def meth(mats) -> int:
    """Un sachet de cristaux bleus. Une poche plate, et quelques eclats qui
    depassent : c'est ce qui la distingue d'un simple rectangle."""
    total = 0
    m = Maillage("Sachet", mats["cristal"])
    m.boite(-0.055, -0.018, 0.0, 0.055, 0.018, 0.130)
    total += m.finir()

    e = Maillage("Cristaux", mats["cristal_clair"])
    for x, z, t in [(-0.028, 0.045, 0.020), (0.010, 0.075, 0.026),
                    (0.034, 0.038, 0.017), (-0.006, 0.104, 0.014)]:
        e.boite(x - t / 2, -0.021, z - t / 2, x + t / 2, 0.021, z + t / 2)
    total += e.finir()
    return total


def botte(mats) -> int:
    """La « botte secrete » : un gros cristal blanc, isole, sans sachet.

    Volontairement DIFFERENT de la meth — plus gros, plus clair, et nu au
    creux de la main au lieu d'etre en poche. Toute la scene finale tient sur
    le fait que Tuco croit reconnaitre l'un en voyant l'autre, mais il faut
    que le joueur, lui, ne s'y trompe jamais.
    """
    total = 0
    m = Maillage("Cristal", mats["cristal_blanc"])
    m.boite(-0.030, -0.026, 0.0, 0.030, 0.026, 0.052)
    m.boite(-0.020, -0.017, 0.050, 0.020, 0.017, 0.082)
    total += m.finir()

    e = Maillage("Eclats", mats["cristal_blanc_vif"])
    for x, y, z, t in [(-0.022, 0.0, 0.030, 0.016), (0.024, 0.008, 0.018, 0.013),
                       (0.004, -0.024, 0.044, 0.012)]:
        e.boite(x - t / 2, y - t / 2, z - t / 2, x + t / 2, y + t / 2, z + t / 2)
    total += e.finir()
    return total


def pantalon(mats) -> int:
    """Le pantalon de Walter, tombe dans le sable.

    C'est le seul objet du jeu qui traverse quinze missions : il s'envole en
    sequence A et ressort plie sur la banquette arriere au generique. Il etait
    represente par blouse.glb — une blouse de laboratoire jaune — donc par un
    vetement qui n'a rien a voir, dans une scene ou l'on ne sait deja pas trop
    ce qu'on cherche.

    IL DOIT SE LIRE COMME UN PANTALON TOMBE, PAS COMME UN PANTALON PLIE. Deux
    jambes qui partent en V depuis une ceinture, a plat, l'une un peu repliee :
    c'est la silhouette d'un vetement qu'on a jete, et c'est ce qui le distingue
    d'une serpilliere a trois metres et de nuit.
    """
    total = 0
    m = Maillage("Pantalon", mats["pantalon"])
    # La ceinture, plus epaisse : c'est la partie qui garde sa forme.
    m.boite(-0.145, -0.075, 0.0, 0.145, 0.075, 0.055)

    # La jambe gauche, dans l'axe. Trois troncons de moins en moins larges —
    # un tissu vide s'affaisse en s'eloignant de la ceinture.
    m.boite(-0.140, -0.290, 0.0, -0.010, -0.075, 0.042)
    m.boite(-0.135, -0.470, 0.0, -0.020, -0.290, 0.034)

    # La droite, repliee vers l'exterieur. C'est elle qui fait lire « tombe » :
    # deux jambes paralleles se liraient comme un vetement pose.
    m.boite(0.010, -0.250, 0.0, 0.140, -0.075, 0.042)
    m.boite(0.120, -0.360, 0.0, 0.330, -0.245, 0.034)
    total += m.finir()

    # La ceinture de cuir, un ton plus sombre. Elle ne sert qu'a casser
    # l'aplat : un rectangle d'une seule couleur, de nuit, n'est qu'une tache.
    c = Maillage("Ceinture", mats["cuir_sombre"])
    c.boite(-0.148, -0.030, 0.048, 0.148, 0.030, 0.070)
    total += c.finir()
    return total


def sac_materiel(mats) -> int:
    """Le sac de materiel du fosse, entrouvert.

    Battement A5 : « un sac de materiel ENTROUVERT » — l'un des trois objets
    qu'on ramasse autour du camping-car accidente. Il etait represente par
    botte.glb, c'est-a-dire par un gros cristal blanc : ca se ramassait, ca se
    voyait, et ca ne ressemblait a rien de ce que le script decrit.

    CE QUI LE REND LISIBLE EST QU'IL EST OUVERT. Un sac ferme, a cette taille et
    de nuit, est une boite sombre posee dans le sable — la meme silhouette qu'un
    caillou. Les deux rabats ecartes et ce qui depasse sont tout ce qui dit
    « quelqu'un a fouille dedans et l'a laisse la ».

    Il est plus grand que les autres objets tenus : c'est un sac de chantier
    pose au sol, pas un accessoire de poche.
    """
    total = 0
    m = Maillage("Sac", mats["toile_abri"])
    # Le corps, legerement evase vers le haut — un sac souple ne tient pas les
    # angles droits, et le fond porte tout le poids.
    m.boite(-0.185, -0.115, 0.0, 0.185, 0.115, 0.150)
    m.boite(-0.170, -0.100, 0.150, 0.170, 0.100, 0.235)
    total += m.finir()

    # LES DEUX RABATS, ECARTES. Ils partent du haut du sac et tombent vers
    # l'exterieur : c'est l'ouverture, et c'est la seule chose qui distingue cet
    # objet d'une caisse.
    r = Maillage("Rabats", mats["toile_abri"])
    for cote in (-1.0, 1.0):
        r.face([
            (cote * 0.170, -0.100, 0.235),
            (cote * 0.170, 0.100, 0.235),
            (cote * 0.255, 0.088, 0.190),
            (cote * 0.255, -0.088, 0.190),
        ][::int(cote)], [(0, 0), (1, 0), (1, 0.6), (0, 0.6)])
    total += r.finir()

    # CE QUI DEPASSE : deux tubes de verrerie et une sangle. Trois volumes
    # menus, mais ce sont eux qui disent que le sac est PLEIN de materiel de
    # chimie et pas de linge.
    c = Maillage("Contenu", mats["inox"])
    c.boite(-0.055, -0.030, 0.200, -0.020, 0.030, 0.330)
    c.boite(0.010, -0.038, 0.200, 0.052, 0.038, 0.295)
    total += c.finir()

    s = Maillage("Sangle", mats["cuir_sombre"])
    s.boite(-0.190, -0.022, 0.055, 0.190, 0.022, 0.075)
    total += s.finir()
    return total


def livre(mats) -> int:
    """« Feuilles d'herbe ». Une couverture et une tranche claire, ce qui
    suffit a lire un livre a cette distance."""
    total = 0
    c = Maillage("Couverture", mats["couverture"])
    c.boite(-0.075, -0.012, 0.0, 0.075, 0.012, 0.210)
    total += c.finir()

    p = Maillage("Pages", mats["pages"])
    p.boite(-0.070, -0.009, 0.006, 0.072, 0.009, 0.204)
    total += p.finir()
    return total


def oeufs(mats) -> int:
    """La boite d'oeufs des courses, fermee.

    Les six alveoles bombees du couvercle sont ce qui la distingue d'une
    brique a cette taille. Sans elles, l'objet tenu en main se lit comme un
    parpaing beige et personne ne comprend ce que Walter rapporte.
    """
    total = 0
    m = Maillage("Boite", mats["carton"])
    m.boite(-0.150, -0.055, 0.0, 0.150, 0.055, 0.038)       # le fond
    m.boite(-0.148, -0.053, 0.036, 0.148, 0.053, 0.060)     # le couvercle
    total += m.finir()

    a = Maillage("Alveoles", mats["carton_clair"])
    for i in range(3):
        x = -0.092 + i * 0.092
        for y in (-0.026, 0.026):
            a.boite(x - 0.030, y - 0.021, 0.058, x + 0.030, y + 0.021, 0.072)
    total += a.finir()
    return total


def chapeau(mats) -> int:
    """Le porkpie. Deux volumes : un bord large et plat, une calotte basse.
    C'est la silhouette la plus reconnaissable de la serie, et elle tient
    en douze faces."""
    total = 0
    m = Maillage("Chapeau", mats["feutre"])
    m.boite(-0.145, -0.155, 0.0, 0.145, 0.155, 0.016)      # bord
    m.boite(-0.105, -0.112, 0.014, 0.105, 0.112, 0.088)    # calotte
    total += m.finir()

    r = Maillage("Ruban", mats["feutre_sombre"])
    r.boite(-0.108, -0.115, 0.016, 0.108, 0.115, 0.034)
    total += r.finir()
    return total


def blouse(mats) -> int:
    """La combinaison du labo, portee sur le torse.

    ELLE ENVELOPPE, ELLE NE SE POSE PAS. Un vetement accroche a l'os du torse
    doit contenir le corps, pas s'appuyer dessus : quelques millimetres de trop
    peu et la chemise ressort par plaques a chaque pas. On prend donc une marge
    franche autour du buste plutot que de viser juste.

    Construit en Z vers le haut comme les autres objets ; l'export glTF s'occupe
    de la conversion. L'origine est au CENTRE du buste, la ou tombe Spine02, et
    la piece descend plus bas qu'elle ne monte — une blouse couvre les cuisses.
    """
    total = 0
    m = Maillage("Blouse", mats["combinaison"])
    # buste : large, peu epais, et qui descend jusqu'a mi-cuisse
    m.boite(-0.215, -0.135, -0.34, 0.215, 0.135, 0.24)
    # manches courtes, une par cote, legerement plus basses que l'epaule
    m.boite(-0.285, -0.115, 0.02, -0.205, 0.115, 0.22)
    m.boite(0.205, -0.115, 0.02, 0.285, 0.115, 0.22)
    total += m.finir()

    # JAMAIS « Col ». A l'import d'un glTF, Godot lit ce nom comme une consigne
    # de COLLISION et fabrique un StaticBody3D dans le maillage. Sur un vetement
    # accroche a l'os du torse, ca donne un corps solide greffe sur le joueur :
    # il entre en collision avec ses propres habits, se fait repousser image
    # apres image, traverse les murs et finit hors de la carte. Quatre symptomes,
    # un nom de trois lettres. Constate manette en main le 09/08/2026.
    c = Maillage("Rabat", mats["combinaison_sombre"])
    # le col, et la fermeture qui descend devant : deux volumes qui suffisent a
    # dire « vetement de travail » plutot que « bloc jaune »
    c.boite(-0.115, -0.14, 0.22, 0.115, 0.14, 0.27)
    c.boite(-0.022, -0.145, -0.30, 0.022, -0.128, 0.22)
    total += c.finir()
    return total


# CE QUE CE GENERATEUR FABRIQUE, et rien de plus.
#
# Le chapeau n'y est PLUS : Guillaume en a livre un, et il est importe depuis
# livraisons/. Le laisser dans cette table ferait ecraser un modele livre par
# douze faces de substitution au premier « generer » venu — c'est exactement ce
# qui est arrive au Jesse livre, remplace par son ancienne version sans que rien
# ne le signale.
#
# La fonction chapeau() reste, elle : elle documente la silhouette et sert de
# repli si le modele livre disparait.
OBJETS = {
    "arme": (arme, ["metal", "metal_sombre"]),
    "meth": (meth, ["cristal", "cristal_clair"]),
    "botte": (botte, ["cristal_blanc", "cristal_blanc_vif"]),
    "livre": (livre, ["couverture", "pages"]),
    "sac_materiel": (sac_materiel, ["toile_abri", "inox", "cuir_sombre"]),
    "pantalon": (pantalon, ["pantalon", "cuir_sombre"]),
    "oeufs": (oeufs, ["carton", "carton_clair"]),
    "blouse": (blouse, ["combinaison", "combinaison_sombre"]),
}


def main() -> None:
    a = arguments()
    racine = Path.cwd()
    textures = Path(a.textures)
    if not textures.is_absolute():
        textures = racine / textures
    sortie = Path(a.sortie)
    if not sortie.is_absolute():
        sortie = racine / sortie
    sortie.mkdir(parents=True, exist_ok=True)

    noms = list(OBJETS) if a.nom == "tous" else [a.nom]
    for nom in noms:
        if nom not in OBJETS:
            raise SystemExit("objet inconnu : %s" % nom)
        batir, besoins = OBJETS[nom]

        bpy.ops.wm.read_factory_settings(use_empty=True)
        mats = {m: materiau(m, textures) for m in besoins}
        faces = batir(mats)

        fichier = sortie / f"{nom}.glb"
        bpy.ops.object.select_all(action="SELECT")
        bpy.ops.export_scene.gltf(
            filepath=str(fichier),
            export_format="GLB",
            use_selection=True,
            export_apply=True,
            export_yup=True,
            export_cameras=False,
            export_lights=False,
        )
        print("objet %-9s %3d faces  -> %s" % (nom, faces, fichier.name))

    print("sortie     %s" % sortie)


if __name__ == "__main__":
    main()
