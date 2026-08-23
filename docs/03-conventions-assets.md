# Conventions d'assets

Fiche de référence pour Guillaume. Elle répond aussi à la question F8 : plutôt qu'une
spec par asset, une contrainte technique unique, et tu t'organises librement dedans.

---

## Audio

### Quel format, et pourquoi

Godot accepte WAV, Ogg Vorbis et MP3. Il n'y a pas de « meilleur format » dans l'absolu —
le bon choix dépend de la durée et du nombre de sons joués en même temps.

| Usage | Format | Compression à l'import |
|---|---|---|
| **Bruitages courts** — moteur, portes, pas, arme, impacts | **WAV** | **QOA** (défaut Godot) |
| **Musique et ambiances longues** — radio, vent, nappe | **Ogg Vorbis** | — |
| MP3 | **jamais** | — |

**Pourquoi WAV pour les bruitages.** Le décodage est quasi gratuit : Godot encaisse des
centaines de voix simultanées sans broncher. Le seul défaut est la taille disque, et la
compression QOA la réduit nettement pour une perte de qualité bien moins audible que
l'IMA-ADPCM, à un coût CPU qui reste très inférieur au MP3. Dans un jeu de conduite où le
moteur, les pneus, la ville et les pas tournent en permanence, c'est le bon compromis.

**Pourquoi Ogg pour la musique.** Le meilleur rapport taille/qualité disponible. Il coûte
plus de CPU à décoder, mais sur une ou deux pistes simultanées c'est sans importance.

**Pourquoi jamais de MP3.** À qualité égale il est nettement plus gros qu'un Ogg, donc il
perd sur le seul terrain où il pourrait gagner. Et son encodage ajoute du silence en tête
et en queue de fichier, ce qui rend une boucle sans couture peu fiable — rédhibitoire pour
un son de moteur.

### Trois règles qui coûtent cher si on les découvre tard

1. **Tout son positionné en 3D doit être MONO.** Moteur, portes, pas, PNJ : un fichier
   stéréo sur un `AudioStreamPlayer3D` ne se spatialise pas correctement. Seules la musique
   et les nappes d'ambiance non positionnées sont en stéréo.
2. **Les masters arrivent toujours en WAV 48 kHz 16 bits non compressé.** Godot compresse à
   l'import ; on garde la source intacte dans le dépôt. Ne jamais livrer un MP3 comme
   master : on ne peut pas remonter la pente.
3. **Le son du moteur boucle sans couture.** C'est de loin le son le plus entendu du jeu :
   quelques millisecondes de blanc à chaque boucle deviennent insupportables au bout de
   deux minutes. WAV, points de boucle posés à l'échantillon près.

### Taille

Les WAV passent par Git LFS, déjà configuré. Pour situer : une boucle moteur de 3 s en
48 kHz / 16 bits / mono pèse environ 280 Ko. Il n'y a pas de sujet.

---

## 3D

### Budgets de triangles — références PS2 réelles

| Élément | Triangles |
|---|---|
| Personnage jouable | 500 – 1 500 |
| Personnage secondaire | 300 – 800 |
| Véhicule | 800 – 2 000 |
| Immeuble | 50 – 300 |
| Accessoire, mobilier | 20 – 200 |

Ce ne sont pas des plafonds de performance — une machine moderne encaisserait cent fois
plus. Ce sont des **contraintes esthétiques** : au-delà, ça ne ressemble plus à un jeu PS2.

### L'exception des repères — décidée le 07/08/2026

**Un objet qui est le seul point de repère de sa zone a droit à quatre fois son budget.**
Le camping-car du désert est à **8 000 triangles** et une texture **1024**, contre 2 000 et
128 pour la règle générale.

Ce n'est pas un renoncement, c'est une mesure. Le modèle livré par Guillaume en faisait
17 828, et les cinq niveaux ont été comparés **dans le jeu**, côte à côte sur le banc
graphique du désert :

![Les cinq niveaux du camping-car](images/camping-car-niveaux.png)

Ce que la planche montre, et qu'aucun chiffre n'aurait dit :

- à **2 000**, la décimation mange les surfaces planes : le flanc ondule et les montants de
  fenêtre se tordent. Ce n'est plus un camping-car sale, c'est une épave accidentée ;
- à **4 000**, la jupe et le bas de caisse restent bosselés — précisément le côté par lequel
  on entre ;
- à **8 000**, la silhouette est propre et **cesse de bouger** : entre 8 000 et les 17 828
  d'origine, on ne distingue plus la géométrie. Tout ce qui reste se joue sur la texture,
  et elle coûte huit fois moins cher (2,1 Mo contre 16,2).

**La règle qu'on en tire :** le saut de qualité se trouve, il ne se devine pas. Avant de
choisir un budget pour un asset qui compte, produire trois niveaux et les regarder — c'est
à ça que sert le banc, et ça coûte une soirée de moins qu'un mauvais choix.

**Ce que l'exception ne couvre pas :** le décor ordinaire. Une maison reste entre 50 et 300
triangles. Un camping-car à 8 000 au milieu de maisons à 200 se remarque, et c'est voulu —
c'est le seul objet du désert, on roule vingt secondes pour l'atteindre et on s'en approche
à pied. Étendre ça au mobilier de rue ferait perdre le grain du jeu sans que personne y
gagne.

### Textures

- **128 × 128** par défaut, **256 × 256** pour un asset héros qu'on regarde de près,
  **64 × 64** pour les petits accessoires.
- Toujours en puissance de deux.
- Le filtrage bilinéaire est actif : la texture sera **floue à l'écran**, c'est voulu. Ne
  pas compenser en montant la résolution, ça casserait le rendu.
- Une seule texture par objet quand c'est possible — un atlas plutôt que six matériaux.

### Tessellation : pas de contrainte, contrairement à ce qui était écrit ici

Correction d'une affirmation initialement fausse.

Un grand quadrilatère éclairé **par sommet** ne reçoit la lumière qu'à ses quatre coins,
donc apparaît noir. C'est ce qu'on a observé en montant le rendu, et on en avait conclu
qu'il fallait tesseller toutes les grandes surfaces.

**Sauf que le projet utilise l'ombrage par pixel.** À 512 × 384 la différence avec le
par-sommet est invisible, et le par-pixel est plus prévisible — c'est donc lui qu'on garde.
Avec lui, un sol de quatre sommets s'éclaire correctement. La vraie cause du sol noir était
ailleurs : **aucun lampadaire ne couvrait le premier plan.**

Il n'y a donc **aucune obligation de tesseller**. Modélise au plus simple. Un découpage
grossier reste utile sur les très grandes surfaces pour d'autres raisons — culling, futur
passage en éclairage par sommet — mais ce n'est pas un prérequis d'éclairage.

**Ce qu'il faut retenir à la place :** une zone sans source lumineuse est noire, point.
L'éclairage se pense en couverture, pas en géométrie.

### Échelle, orientation, pivots

- **1 unité = 1 mètre.** Blender est déjà en mètres ; appliquer l'échelle avant export
  (`Ctrl+A` → Scale), sinon Godot hérite d'un facteur parasite.
- **Export en glTF (`.glb`).** L'exportateur gère la conversion Z-up de Blender vers le
  Y-up de Godot ; ne rien compenser à la main.
- **Pivots** : à la base et au centre pour un personnage ou un immeuble, au centre de
  l'essieu pour une roue, au centre de gravité pour une caisse de véhicule. Un pivot mal
  placé fait tourner une roue de travers et ça se voit immédiatement.
- **Faces** : normales vers l'extérieur, pas de faces internes inutiles.

### Nommage et emplacement

```
livraisons/     ce qu on DEPOSE, pas ce que le jeu lit
  sons/         WAV mono pour le 3D, stereo pour la musique
  voix/         prises de dialogue, avant decoupage
  modeles/      .obj, .fbx, .blend livres a la main
  LICENCES.md   origine et licence de tout asset externe
```

Un fichier posé dans `livraisons/sons/` ou `livraisons/voix/` est **rangé tout seul** dans
`game/assets/` au prochain `.\go.ps1`. Personne n'a à retenir où Godot les lit.

Côté jeu, les sons sont classés par mécanisme, pas par auteur :

```
game/assets/sons/
  vehicule/     moteur, portieres, klaxon, chocs, pneus
  pas/          selon la surface
  maison/       portes et ambiances interieures
  interface/    roue des outils, objets equipes
  telephone/    sonnerie
  ambiance/     nappes exterieures
```

Fichiers en minuscules avec des underscores : `imm_commercial_a.blend`,
`walter_tete.png`, `moteur_boucle.wav`. **Un fichier `.blend` par asset** — jamais un gros
fichier de scène partagé, qui garantirait un conflit dès qu'on travaille en même temps.

### Les références visuelles — décidé le 16/08/2026

`livraisons/references/` porte les images qui servent à FABRIQUER : captures, photos de
repérage, rendus trouvés ailleurs. Elles ne sont jamais lues par le jeu.

Elles sont rangées **par sujet, jamais par mission**. C'est la leçon d'une livraison où les
mêmes six photos de camping-car existaient en trois exemplaires, sous `Mission 1/`, sous
`RV/` et à la racine : une photo rangée sous une mission est recopiée à la mission
suivante, et personne ne sait plus laquelle fait foi.

```
livraisons/references/
  camping-car/    exterieur/ et interieur/
  desert/         paysages, pistes, vegetation
  personnages/    un dossier par personnage
  qg-tuco/
```

Le nom dit **ce que l'image montre**, en minuscules avec des tirets, sans accents :
`corps-au-sol-gros-plan.jpg`, `sans-pantalon-de-dos-sur-la-piste.jpg`. Une référence qu'on
ne retrouve pas dans une liste de trente ne sert à rien — et c'est le cas de tout nom qui
est un numéro.

---

## La recette d'import de chaque personnage riggé

**Un personnage du jeu est le résultat d'une suite de commandes, et cette suite
doit être écrite ici.** Sans quoi elle se perd : le 23/08/2026, corriger
l'échelle de Walter a demandé de la reconstituer, et celles de Jesse et Tuco
n'ont pas pu l'être — leur réimport sortait un fichier neuf fois plus lourd,
sans les clips que le jeu leur demande.

C'est le même constat que celui qui a fait naître `alleger_textures.py` pour
l'Aztek : *« les valeurs de `--hauteur` et surtout de `--lacet` qui ont donné le
résultat actuel ne sont écrites nulle part »*. La différence, c'est qu'on
l'écrit maintenant.

### Les trois étapes, dans l'ordre

```powershell
# 1. Normaliser : taille, sol, orientation, ECHELLE APPLIQUEE AUX DONNEES
blender -b -P outils/importer_perso.py -- `
        --fichier livraisons/modeles/walt_anim.glb --nom walt --hauteur 1.78

# 2. Ramener la texture au palier du jeu (256 px pour un héros, §3D)
blender -b -P outils/alleger_textures.py -- `
        --fichier game/assets/personnages/walt.glb --texture-max 256

# 3. Fabriquer les clips que le pack livré n'a pas : Repos, Marche, Accroupi
blender -b -P outils/animer_perso.py -- --nom walt
```

**Sauter la 2 coûte cinq fois le poids du fichier** — mesuré : 0,74 Mo → 3,85 Mo.
**Sauter la 3 laisse le personnage figé sur une image de course** : le jeu
cherche `Repos` et `Marche`, le pack ne porte que `Walking` et `Running`.

### Ce qui est connu, et ce qui ne l'est pas

| Personnage | Source | Hauteur | Étapes | État |
|---|---|---|---|---|
| **walt** | `livraisons/modeles/walt_anim.glb` | 1,78 m | 1 + 2 + 3 | recette vérifiée le 23/08/2026 |
| **jesse** | ? — `livraisons/modeles/jesse.glb` ne porte pas `Walking` | ~1,54 m mesurés | inconnues | **à reconstituer** |
| **tuco** | ? | ~1,56 m mesurés | inconnues | **à reconstituer** |

Tant que la ligne d'un personnage n'est pas remplie, **on ne le réimporte
pas** : on ne peut pas rejouer une commande qu'on ne connaît pas, et le fichier
en place est le seul exemplaire du résultat.

### Pourquoi l'échelle DOIT entrer dans les données

`importer_perso.py` applique désormais l'échelle aux données — sommets, os,
pose courante et courbes d'animation — au lieu de la laisser sur le nœud
Armature. Ce n'est pas une préférence de propreté : un `PhysicalBone3D` est un
corps rigide et **le moteur physique normalise l'échelle**. Un squelette à 0,01
donne un ragdoll dispersé sur vingt mètres et un cadavre qui remplit l'écran,
sans qu'aucune mesure de pose ne bronche. Piège 48.

`test -Suite mort` le vérifie à chaque passage, et nomme les personnages qui
portent encore une échelle.

---

## Ce qui n'entre jamais dans le dépôt

**Les fichiers de travail bruts** : projets Blender de scan, textures 4K d'origine, rushes
son non montés, exports intermédiaires. Ils vivent dans `assets-ref/`, ignoré par git. La
raison est technique : ils pèsent, et un binaire commité reste dans l'historique même après
suppression.

**Les médias issus de la série, eux, sont dans le dépôt** — les références visuelles
ci-dessus, et certains substituts temporaires dans le jeu lui-même. Cette page a longtemps
affirmé le contraire ; c'était vrai quand le dépôt était privé, ça ne l'était plus depuis le
05/08/2026 et personne ne l'avait relu. **Une règle qui dit l'inverse de ce qu'on fait ne
protège de rien et fait douter des autres.**

Ce que ça implique, et les engagements qui vont avec, sont dans
[DISCLAIMER.md](../DISCLAIMER.md) — à lire avant d'ajouter un média de la série, et à tenir
à jour quand la distribution change.

**D'où vient chaque fichier que l'exe embarque** est écrit dans
[livraisons/LICENCES.md](../livraisons/LICENCES.md), établi le 16/08/2026 en remontant
chaque asset à son commit d'ajout. Une ligne s'y ajoute **quand l'asset entre dans
`game/assets/`**, pas trois mois après. Le compte au jour de sa création : 289 fichiers,
dont 79 sortis de nos scripts, 80 livrés par Guillaume, et 129 générés par IA. **Aucun
visuel de la série n'est embarqué** — mais **un son l'est**, `this_is_not_meth.wav`, et
c'est le seul.
