"""Les plans de l'ouverture tiennent-ils debout ?

    python outils/verifier_cinematique.py

TROIS FAÇONS DE RATER UN PLAN, ET AUCUNE NE LEVE D'ERREUR :

  1. une voix declaree qui ne correspond a aucun fichier — le plan reste muet,
     et un plan muet ressemble a un plan qu'on a voulu silencieux ;
  2. un mouvement dont le cadre d'arrivee est identique au depart — le plan
     annonce qu'il bouge et ne bouge pas ;
  3. une camera posee AU MEME ENDROIT que ce qu'elle vise — look_at() ne sait
     alors pas ou regarder, et le plan part de travers.

On les cherche ici, sur les donnees, sans lancer le jeu.
"""
import hashlib
import io
import json
import os
import sys

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PLANS = os.path.join(RACINE, "game", "donnees", "cinematique.json")
VOIX = os.path.join(RACINE, "game", "assets", "voix")


def simplifier(nom):
    return "".join(c for c in nom.lower() if c.isalnum() and c.isascii())


def prononce(dit, jeu):
    """Doit produire exactement la meme chaine que Dialogue._prononce()."""
    if not dit:
        return ""
    return "[%s] %s" % (jeu, dit) if jeu else dit


def vec(a):
    return tuple(float(x) for x in a)


d = json.load(io.open(PLANS, encoding="utf-8-sig"))
plans = d.get("plans", [])
fautes = []

print("")
print("--- les plans de l'ouverture ---")
for i, p in enumerate(plans):
    cam = vec(p.get("camera", [0, 0, 0]))
    vise = vec(p.get("vise", [0, 0, 0]))
    cam_fin = vec(p.get("camera_fin", p.get("camera", [0, 0, 0])))
    vise_fin = vec(p.get("vise_fin", p.get("vise", [0, 0, 0])))

    bouge = cam != cam_fin or vise != vise_fin
    course = max(
        sum((a - b) ** 2 for a, b in zip(cam, cam_fin)) ** 0.5,
        sum((a - b) ** 2 for a, b in zip(vise, vise_fin)) ** 0.5,
    )

    if cam == vise:
        fautes.append("plan %d : la camera vise sa propre position" % i)

    # Un mouvement declare mais nul : quelqu'un a recopie camera dans
    # camera_fin sans le changer.
    if ("camera_fin" in p or "vise_fin" in p) and not bouge:
        fautes.append("plan %d : camera_fin egale camera, il ne bouge pas" % i)

    voix = ""
    qui = str(p.get("qui", ""))
    dit = str(p.get("dit", ""))
    if qui and dit:
        nom = "%s_%s.wav" % (
            simplifier(qui),
            hashlib.md5(prononce(dit, str(p.get("jeu", ""))).encode("utf-8"))
            .hexdigest()[:10],
        )
        if os.path.exists(os.path.join(VOIX, nom)):
            voix = "%s : %s" % (qui, dit[:34])
        else:
            fautes.append("plan %d : aucune voix pour %s « %s »" % (i, qui, dit))
            voix = "VOIX ABSENTE"

    print("  %d  %4.1fs  %-9s %-22s %s" % (
        i, float(p.get("duree", 0)),
        ("bouge %.0fm" % course) if bouge else "fixe",
        str(p.get("carton", ""))[:22], voix))

print("")
print("  %d plan(s), %.1f s au total"
      % (len(plans), sum(float(p.get("duree", 0)) for p in plans)))

musique = str(d.get("musique", ""))
if musique:
    rel = musique.replace("res://", "")
    if not os.path.exists(os.path.join(RACINE, "game", rel)):
        fautes.append("la musique %s est introuvable" % musique)
    else:
        print("  musique : %s" % os.path.basename(rel))

if fautes:
    print("")
    for f in fautes:
        print("  ECHEC " + f)
    sys.exit(1)
print("OK  aucun plan muet, aucun mouvement nul")
