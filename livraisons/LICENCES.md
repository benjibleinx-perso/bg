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
| **Livré par Guillaume — sons** | 74 | Banques de sons qu'il fournit. |
| **Généré par IA — voix** | 126 | Synthèse vocale. Aucun acteur de la série n'est enregistré. |
| **Livré par Guillaume — modèles** | 6 | Modélisés à la main, pas extraits. |
| **Généré par IA — modèles 3D** | 2 | `verrerie.glb`, `bidons_chimie.glb` — Magnific/tripo. |
| **Généré par IA — musique** | 1 | `theme_ouverture.ogg`. |
| **⚠️ Extrait de la série** | **1** | `sons/mission/this_is_not_meth.wav` — voir ci-dessous. |

**Aucun visuel de la série n'est embarqué dans l'exe.** Les 87 fichiers d'image
et de géométrie sortent tous soit de nos générateurs Blender, soit de la main de
Guillaume : les personnages et les véhicules sont *modélisés*, pas extraits.

**Un son l'est.** Un seul, identifié et nommé — c'est tout l'objet de la section
suivante, et c'est ce qui rend l'engagement de retrait tenable.

---

## Le seul extrait direct de la série : `this_is_not_meth.wav`

`game/assets/sons/mission/this_is_not_meth.wav` — 2,5 s, 48 kHz, mono, 231 Ko.
Ajouté par le commit `c94eb79`, qui l'appelle « la réplique ».

**C'est la vraie voix de la série**, confirmé à l'écoute par Benjamin le
16/08/2026. L'historique ne pouvait pas le dire — il ne renseigne pas ce qu'il y
a *dans* un fichier son — et c'est la seule question de cet inventaire qui a
demandé une oreille plutôt qu'une commande.

**Où il se joue** : à la mission 1, chez Tuco, une seconde avant l'explosion.
Walt annonce ce qu'il tient, puis le lance. C'est le seul endroit du jeu.

**Ce que ça change, et ce que ça ne change pas** :

- Il est **couvert par le `DISCLAIMER`**, qui prévoit explicitement des éléments
  sonores de la série « dans le jeu lui-même », à titre de substitut temporaire.
- Il est **dans l'exe distribué publiquement**. C'est le seul fichier du dépôt
  dont on puisse dire ça aujourd'hui.
- Il est **remplaçable sans rien casser** : la chaîne de voix de synthèse existe
  et sert déjà pour 126 répliques. `sons.json` appelle un nom de mécanisme, pas
  un fichier — déposer un autre son au même nom suffit, il n'y a aucun code à
  toucher.

**La décision appartient à Benjamin** : le garder comme substitut assumé, ou le
refaire en synthèse comme les 126 autres. Rien ne presse, mais la question est
maintenant *posée*, ce qu'elle n'était pas — et surtout, le jour où il faudrait
retirer quelque chose, **on sait quoi**.

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

### Livré par Guillaume — 74 sons

| Dossier | Nb | Commit d'origine |
|---|---|---|
| `sons/pas/` | 23 | `05f9180` (Guillaume, « 28 son(s) ») et suivants |
| `sons/vehicule/` | 19 | `05f9180`, `3fc5ed4`, `140e2e3`, `6c5b12d` |
| `sons/mission/` | 12 | `c94eb79`, `d61374a`, `bb66091` |
| `sons/interface/` | 11 | `05f9180` |
| `sons/ambiance/` | 4 | `7a2f081`, `5dfedcd`, `2981da1` |
| `sons/maison/` | 3 | `05f9180` |
| `sons/telephone/` | 1 | `4e3ae54` |
| `sons/` (racine) | 1 | `7a2f081` |

`sons/mission/` en compte **13 sur le disque** : le treizième est
`this_is_not_meth.wav`, qui a sa propre section — il est arrivé dans le même lot
que les autres, mais ce n'est pas un son de banque.

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

**Deux fichiers ne peuvent pas être tranchés par l'historique.** Ils sont classés
« livré par Guillaume » parce que c'est ce que dit le dépôt, mais leur contenu
n'a pas été écouté :

- **`sons/telephone/phone_ring.wav`** et **`sons/vehicule/sit_car.wav`** — les
  deux seuls sons dont `--follow` ne remonte pas plus haut que le rangement
  `4e3ae54`, où ils apparaissent en ajout net. Ce commit vidait l'ancien
  `assets/` de la racine, c'est-à-dire le sas de livraison d'avant `livraisons/` :
  ils viennent donc très probablement du même lot que les 28 sons de `05f9180`.
  Leurs noms suivent d'ailleurs la même convention anglophone de banque —
  `sit_car`, `phone_ring`, comme `open_menu_item` ou `step_indoors01`.
  **Un indice fort, pas une preuve** : c'est pour ça qu'ils sont ici et pas dans
  le tableau du dessus.

**Ce n'est pas un blocage.** Deux fichiers sur 289, tous deux des bruits — une
sonnerie, un bruit de siège. Le seul qui posait vraiment une question a été
écouté, et il a sa section plus haut.

**La leçon de cette liste** : sur 289 fichiers, l'historique en a tranché 287.
Les deux derniers demandaient dix secondes d'écoute chacun — et c'est
précisément le fichier qu'on aurait le plus facilement classé « probablement une
banque » qui s'est révélé être l'extrait. **Un inventaire qui n'a pas de case
« je ne sais pas » finit par mentir dans cette case-là.**

---

## Tenir ce fichier

Une ligne à ajouter **quand un asset entre dans `game/assets/`**, pas trois mois
après. La colonne qui compte est la dernière : d'où il vient, pas ce qu'il fait.

Et la question à se poser à ce moment-là, la seule : **est-ce que ce fichier
finit dans l'exe qu'on donne à télécharger ?** Une image de référence qui reste
dans `livraisons/` n'a pas le même statut qu'une texture embarquée dans le jeu.

*Projet de fan, non commercial. Voir [DISCLAIMER.md](../DISCLAIMER.md).*

## Polices — SIL Open Font License 1.1

Ajoutées le 27/08/2026. Le jeu n'avait aucune police jusque-là : tout — HUD,
téléphone, menus, écran-titre, dialogues — était écrit avec la police par défaut
de Godot. La charte graphique (`docs/20`) les nommait depuis le 23/08.

| Police | Rôle | Source | Licence |
|---|---|---|---|
| **Barlow** (Medium, SemiBold) | texte courant : HUD, dialogues, menus | Jeremy Tribby, via Google Fonts | SIL OFL 1.1 |
| **Bevan** | titres et moments symboliques — l'alternative libre à Cooper Black que la charte cite nommément | Vernon Adams, via Google Fonts | SIL OFL 1.1 |

La SIL OFL autorise l'usage, la modification et la redistribution, y compris
embarquée dans un exécutable, sans redevance. Elle interdit de vendre les
fichiers de police seuls et impose de conserver la licence — ce que fait ce
tableau.
