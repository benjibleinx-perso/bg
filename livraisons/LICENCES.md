# Origine des assets

**Ce fichier répond à une seule question : d'où vient chaque fichier que l'exe
embarque ?** Il est prévu par [docs/03-conventions-assets.md](../docs/03-conventions-assets.md)
depuis le début du projet et n'avait jamais été écrit — établi le 16/08/2026.

Il existe parce que `DISCLAIMER.md` promet un **retrait immédiat à la première
demande d'un ayant droit**, et qu'on ne peut pas tenir un engagement qu'on n'est
pas capable de mesurer : « retrait immédiat » suppose de savoir quoi retirer.

**Comment il a été établi**, et ce que ça vaut : chaque fichier a été remonté à
son commit d'ajout, avec `git log --follow` pour traverser les rangements. La
preuve est donc l'historique du dépôt, pas un souvenir. Ce que ça ne prouve
pas : ce qu'il y a *dans* un fichier son. Un fichier livré sous un nom de banque
reste un fichier qu'on n'a pas écouté — voir la dernière section.

---

## Le compte, au 16/08/2026

**289 fichiers, 109,7 Mo** dans `game/assets/`.

| Origine | Fichiers | Ce que ça veut dire |
|---|---|---|
| **Généré par nos scripts** | 79 | Reproductible par `.\bg.ps1 generer`. Aucune question de droit. |
| **Livré par Guillaume — sons** | 75 | Banques de sons qu'il fournit. |
| **Généré par IA — voix** | 126 | Synthèse vocale. Aucun acteur de la série n'est enregistré. |
| **Livré par Guillaume — modèles** | 6 | Modélisés à la main, pas extraits. |
| **Généré par IA — modèles 3D** | 2 | `verrerie.glb`, `bidons_chimie.glb` — Magnific/tripo. |
| **Généré par IA — musique** | 1 | `theme_ouverture.ogg`. |

**Aucun visuel de la série n'est embarqué dans l'exe.** C'est le point qui
comptait, et il est mesuré : les 87 fichiers d'image et de géométrie sortent
tous soit de nos générateurs Blender, soit de la main de Guillaume.

---

## Le détail, par famille

### Généré par nos scripts — 79 fichiers

`decor/` (37 sur 39), `desert/` (2 sur 3), `lieux/` (3), `maisons/` (4),
`objets/` (6 sur 7), `personnages/` (16 sur 19), `vehicules/` (7 sur 8),
`ville/` (2), `images/` (2).

Produits par `outils/gen_*.py` sous Blender. Le fichier peut être supprimé et
refabriqué à l'identique : **la source est le script, pas le `.glb`.**

Inclut tous les figurants et les passants, Skyler, et les textures de ville.

### Livré par Guillaume — 6 modèles

| Fichier | Commit d'ajout |
|---|---|
| `personnages/walt.glb` | `0acca97` — Walter passe au squelette : le modèle riggé de Guillaume |
| `personnages/jesse.glb` | `ca111a8` — Jesse et Tuco intégrés |
| `personnages/tuco.glb` | `ca111a8` — idem |
| `desert/camping_car.glb` | `1d22dba` — le camping-car de Guillaume entre dans le jeu |
| `vehicules/aztek.glb` | `7aef972` — le QG accessible, la nuit habitable, et l'Aztek |
| `objets/chapeau.glb` | livré, intégré par la chaîne |

**Ce sont des modèles construits, pas des captures ni des scans de la série.**
Ils représentent des personnages et des véhicules de la série — c'est le sujet
même d'un fan game, et c'est ce que le `DISCLAIMER` couvre.

### Livré par Guillaume — 75 sons

| Dossier | Nb | Commit d'origine |
|---|---|---|
| `sons/pas/` | 23 | `05f9180` (Guillaume, « 28 son(s) ») et suivants |
| `sons/vehicule/` | 19 | `05f9180`, `3fc5ed4`, `140e2e3`, `6c5b12d` |
| `sons/mission/` | 13 | `c94eb79`, `d61374a`, `bb66091` |
| `sons/interface/` | 11 | `05f9180` |
| `sons/ambiance/` | 4 | `7a2f081`, `5dfedcd`, `2981da1` |
| `sons/maison/` | 3 | `05f9180` |
| `sons/telephone/` | 1 | `4e3ae54` |
| `sons/` (racine) | 1 | `7a2f081` |

Les noms d'arrivée — `Gun Shot 1.wav`, `Desert_Air_ODC-0006-421.wav`,
`open_menu_item.wav` — sont des noms de **banques de sons**, pas d'extraits de
série.

### Généré par IA — 129 fichiers

- **`voix/` (126)** : synthèse vocale, entrée par `outils/voix_ia.ps1`, casting
  dans `game/donnees/casting.json`. Les répliques sont **écrites pour le jeu** —
  le script de la mission 1 le dit explicitement : « aucune réplique n'est tirée
  de la série ». Aucun enregistrement d'acteur n'est utilisé.
- **`decor/verrerie.glb`** et **`decor/bidons_chimie.glb`** : Magnific/tripo-p1,
  déclarés dans `outils/assets-ia.json` avec leur prompt et leur empreinte.
- **`sons/musique/theme_ouverture.ogg`** : composé par `audio_music_generate`,
  commit `335c7c0`.

Les **textures** générées par IA ne sont pas comptées ici : elles vivent dans
`outils/textures-ia/` et sont **cuites dans les `.glb`**, pas embarquées comme
fichiers. Le manifeste `outils/assets-ia.json` en porte 4 — `lino`, `paillasse`,
`crepi`, `lambris` — avec prompt, moteur, empreinte et licence.

> **Le manifeste ne couvre pas tout ce qui est généré.** `CLAUDE.md` pose que
> « rien ne se génère sans passer par le manifeste », mais ses 6 entrées ne
> comptent que les 4 textures et les 2 modèles 3D. **Le thème d'ouverture n'y
> est pas** — son original est pourtant dans `livraisons/ia/musique/`. Le prompt
> qui l'a produit n'est donc écrit nulle part, et il faudra le retrouver le jour
> où on voudra une seconde piste dans le même esprit (la musique de conduite,
> #38). Les voix, elles, ont leur propre traçabilité — `voix_ia.ps1`,
> `casting.json`, `livraisons/voix/enregistrees.json` — et n'ont pas à entrer
> dans le manifeste.

---

## Ce qui reste à vérifier, et qui demande une oreille

**Trois fichiers ne peuvent pas être tranchés par l'historique.** Ils sont
classés « livré par Guillaume » parce que c'est ce que dit le dépôt, mais leur
contenu n'a pas été écouté :

- **`sons/mission/this_is_not_meth.wav`** — 2,5 s, 48 kHz, mono. Le commit
  `c94eb79` l'appelle « la réplique », et son nom est une réplique de la série.
  **C'est le candidat le plus sérieux d'un extrait direct.** À écouter : voix
  d'acteur avec fond de scène, ou refaite ?
- **`sons/telephone/phone_ring.wav`** et **`sons/vehicule/sit_car.wav`** — les
  deux seuls sons dont `--follow` ne remonte pas plus haut que le rangement
  `4e3ae54`. Probablement des banques, mais rien ne le prouve ici.

**Ce n'est pas un blocage.** Trois fichiers sur 289, dont un seul vraiment
douteux, et le `DISCLAIMER` couvre exactement ce cas — aucune vente, aucune
promotion, retrait immédiat. Mais la question est maintenant *posée*, ce qu'elle
n'était pas.

---

## Tenir ce fichier

Une ligne à ajouter **quand un asset entre dans `game/assets/`**, pas trois mois
après. La colonne qui compte est la dernière : d'où il vient, pas ce qu'il fait.

Et la question à se poser à ce moment-là, la seule : **est-ce que ce fichier
finit dans l'exe qu'on donne à télécharger ?** Une image de référence qui reste
dans `livraisons/` n'a pas le même statut qu'une texture embarquée dans le jeu.

*Projet de fan, non commercial. Voir [DISCLAIMER.md](../DISCLAIMER.md).*
