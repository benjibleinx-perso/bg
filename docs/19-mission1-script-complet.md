# Mission 1 · DEUX CORPS, UN CAMPING-CAR — Script complet

> **Écrit par Guillaume le 14/08/2026, promu ici sans une virgule de changée.**
> Ce qui suit ce bloc est son texte. Les arbitrages rendus le 16/08/2026 (issue
> #67) sont écrits ici plutôt que fondus dans le corps.
>
> **La tenue de Walt — ce n'était pas une contradiction, mais deux moments.**
> §2 le décrit retirant chemise et pantalon pour cuisiner ; la fiche parlait
> d'une « chemise verte trempée ». Les deux ont raison :
>
> | | Tenue | Référence |
> |---|---|---|
> | **Séquence A** (le crash) | chemise verte, **sans pantalon** | `personnages/walter/sans-pantalon-de-dos-sur-la-piste.jpg` |
> | **Séquence B** (la cuisine, 3 semaines plus tôt) | sous-vêtements, gants, tablier | `personnages/walter/sous-vetements-devant-le-camping-car.jpg` |
>
> Le battement **A2** doit donc montrer Walt en chemise verte et sans pantalon
> dès la reprise en main. Ça ne s'explique pas à l'écran : le joueur comprendra
> trois semaines plus tard, en B2, en le voyant l'enlever.
>
> **Le pantalon est un OBJET, pas un gag de costume.** Il s'envole en séquence A,
> reste récupérable en monde ouvert, et ressort **plié sur la banquette arrière
> au générique** — `docs/15-missions.md`, fiche de la mission 15. C'est le seul
> objet du jeu qui traverse quinze missions, et il n'est mentionné nulle part
> dans le script ci-dessous. **À ajouter à la séquence A**, distinct des trois
> objets à ramasser : celui-là se voit partir, on ne le ramasse pas tout de suite.
>
> **L'échec existe** — voir l'en-tête de
> [18-palier1-scripts-gameplay.md](18-palier1-scripts-gameplay.md). Si les
> sirènes arrivent avant la sortie de zone : cinématique de rattrapage, la
> verrerie est perdue, et la première cuisine en monde ouvert coûtera son
> remplacement. Aucun chiffre affiché, aucun game over.
>
> **Le cahier d'implémentation** auquel ce document renvoie quatre fois n'existe
> dans aucun commit du dépôt — question posée à Guillaume, issue #72.

Ce document décrit la mission 1 dans le détail maximal : décor, personnages,
mise en scène, dialogues. Tout ce qui est utile est décrit ici. Il remplace la section
correspondante de `palier1-cahier-implementation.md`, qui reste valable pour
les missions 2 à 4.

---

## 1. Fidélité à l'œuvre — ce qu'on adapte, ce qu'on tait

Cette mission adapte deux moments du pilote de *Breaking Bad* (S1E1) :

- **La fin de l'épisode** : la fuite en camping-car, l'accident dans le
  fossé, les sirènes au loin.
- **Un moment plus tôt dans l'épisode, rejoué ici en flashback** : la toute
  première cuisine de Walter et Jesse, dans le désert.

**Entre les deux, dans la série, il se passe quelque chose que cette mission
ne joue jamais** : une confrontation armée avec deux hommes qui menacent de
tuer Walter et Jesse, et un geste de Walter — une réaction chimique toxique
qu'il déclenche en cachette pour les neutraliser — qui les rend tous les deux
inconscients. C'est un choix volontaire, pas un oubli : le joueur hérite des
conséquences (deux corps, une fuite panique) avant de savoir qui ils sont.
Krazy-8, l'un des deux, redevient un personnage à part entière — conscient,
parlant — à la mission 3. **Ne pas mettre en scène cette confrontation
maintenant : elle reste hors-champ, comme dans le montage du pilote
lui-même, qui commence déjà par des bribes de la fuite avant de revenir en
arrière.**

**Aucune réplique ci-dessous n'est tirée de la série.** Tout le dialogue est
écrit pour le jeu, dans la voix de chaque personnage telle que la série
l'établit, jamais recopié. Pour la même raison, cette mission ne décrit
jamais la chimie réelle en jeu : ce qui compte à l'écran, c'est verser,
chauffer, surveiller une couleur — jamais un produit, un dosage ou une
étape réelle de synthèse.

---

## 2. Personnages présents

### Walter White
Cinquante ans, professeur de chimie au lycée. Corpulence moyenne,
légèrement voûté, moustache, lunettes. Habillé avec un soin presque
incongru pour un homme dans sa situation — chemise boutonnée jusqu'au bout,
pantalon de toile — parce qu'à ce stade de l'histoire, il n'a pas encore
basculé dans l'homme que le joueur va devenir. Il n'a pas encore la tête
rasée ni la moustache "Heisenberg" (cheveux normaux, court, poivre et sel) —
c'est délibérément **avant** le personnage qu'on connaît.

- **Dans la séquence A (le crash)** : hagard, encore sous le choc, la voix
  qui tremble légèrement, mais capable de sursauts de sang-froid — c'est déjà
  lui qui pense à récupérer les objets compromettants pendant que Jesse
  panique.
- **Dans la séquence B (le flashback)** : mal à l'aise physiquement (il
  retire chemise et pantalon pour ne pas les tacher, reste en sous-vêtements
  et gants sous un tablier improvisé — moment volontairement gênant, à jouer
  sans le souligner ni le commenter à l'écran), mais déjà dans son élément
  intellectuel : c'est le seul moment de la mission où il est à l'aise.

### Jesse Pinkman
Milieu vingtaine. Vêtements amples, casquette, plus à l'aise physiquement
que Walt. Ancien élève de Walt au lycée (une réplique peut le rappeler, sans
s'y attarder). Dans la séquence A, c'est lui qui conduit et qui panique le
plus visiblement. Dans la séquence B, il est chez lui — c'est son
camping-car, son terrain — mais il perd l'ascendant dès que la discussion
tourne à la chimie, où Walt reprend systématiquement le dessus.

### Emilio Koyama et Krazy-8 (Domingo Molina)
Présents uniquement comme **corps inertes** à l'arrière du camping-car,
pendant toute la séquence A. Aucune ligne de dialogue, aucun nom affiché à
l'écran — le joueur ne sait pas qui ils sont. Krazy-8 redevient un
personnage parlant à la mission 3 ; Emilio ne reparle jamais.

> **Assets à prévoir, à vérifier avant de commencer** : ces deux personnages
> ne figurent pas dans la liste des habitants déjà modélisés du README
> (Skyler, Jesse, Tuco et ses hommes, le garde). Il faudra donc les créer —
> au minimum une pose "inerte" pour cette mission, un modèle complet et
> animé pour Krazy-8 avant la mission 3. Suivre `docs/07-ajouter-du-contenu.md`
> §2 : entrée dans `VISAGES` et `TENUES` (`outils/gen_textures.py`) et dans
> `PERSONNAGES` (`outils/gen_personnage.py`) — c'est une tâche de données,
> pas de code.

---

## 3. Décors

### Le camping-car — deux états du même véhicule
- **État « accidenté » (séquence A)** : penché sur le flanc dans un fossé,
  une roue dans le vide, phares encore allumés qui éclairent la poussière en
  suspension, portière arrière grande ouverte. Fumée légère du moteur.
- **État « en service » (séquence B)** : à plat, stable, garé à l'écart
  d'une piste. Bâches tendues à l'intérieur des fenêtres (pour ne rien
  laisser voir de dehors).

> **Question pour Benjamin/Claude Code** : un seul maillage avec un état
> d'inclinaison + bâches togglables suffit-il, ou faut-il deux variantes de
> scène ? Le plus économique est probablement une seule géométrie, une
> inclinaison de la caisse posée en `Transform`, et une texture de bâche
> qu'on active ou non — mais c'est un arbitrage technique, pas narratif.

### Extérieur — désert, nuit (séquence A)
Le fossé est en bordure de piste, désert du Nouveau-Mexique, nuit, ciel
dégagé. À l'horizon, les lumières de la ville existante du jeu sont
visibles au loin — ça ancre le joueur : on n'est pas nulle part, on est
tout près de chez soi. Le brouillard de nuit déjà en place dans le rendu du
jeu s'applique normalement. Pas d'autre élément de décor que la piste, le
fossé, et le désert alentour — la scène doit se sentir isolée et vide.

### Extérieur — désert, jour (séquence B)
Une clairière à l'écart d'une piste, hors de vue depuis la route. Chaleur,
lumière crue, pas d'ombre portée disponible à proximité du camping-car —
ça inscrit physiquement l'inconfort de la scène (Walt qui transpire dans
son tablier improvisé n'est pas qu'une posture d'écriture).

### Intérieur du camping-car
Une paillasse de fortune : deux plaques chauffantes, de la verrerie, des
bidons, des bâches de protection au sol. Dans la séquence A, tout est en
désordre — un tabouret renversé, un masque à gaz au sol, les deux corps.
Dans la séquence B (trois semaines plus tôt), tout est encore net, presque
neuf : c'est la toute première fois qu'ils s'en servent.

---

## 4. Séquence A — L'ouverture, battement par battement

| # | Ce qu'on voit / entend | Ce que fait le joueur | Dialogue | Fin du battement |
| - | --- | --- | --- | --- |
| A1 | Caméra fixe, plan large sur le camping-car dans le fossé. Fumée légère, phares allumés, portière ouverte. Musique : une nappe tendue, minimale. | Rien | — | Fondu vers la prise en main, à l'intérieur |
| A2 | Le joueur reprend la main à l'intérieur, assis, masque à gaz sur le visage. Vision légèrement filtrée (teinte, respiration amplifiée dans le son) tant que le masque est porté. | Appuie **F** pour retirer le masque | Walt (voix étouffée par le masque, avant de le retirer) : *"...Jesse ?"* — pas de réponse, Jesse n'est pas dans le champ | Masque retiré, filtre visuel/sonore levé |
| A3 | Walt se redresse, découvre les deux corps allongés à l'arrière. Un temps. | Rien — cinématique courte | Walt *(bas, pour lui-même)* : *"Non, non, non..."* | Se lève, sort par la portière ouverte |
| A4 | Extérieur. Jesse est déjà dehors, fait les cent pas, terrifié. Sirène au loin — un son continu, faible, qui va monter en intensité réelle au fil des battements suivants (pas un minuteur affiché). | Rien | Jesse *(paniqué)* : *"Faut y aller, faut y aller MAINTENANT."* Walt : *"Il faut d'abord..."* Jesse *(coupe)* : *"Y'a pas de "d'abord" !"* | Le joueur reprend le contrôle |
| A5 | Trois objets au sol, repérables par surbrillance au survol : un sac de matériel entrouvert, un bidon renversé, un éclat de verrerie cassée. | **F** sur chacun des trois, dans l'ordre de son choix | Walt *(en ramassant, essoufflé)* : *"Rien. On ne laisse rien."* | Les trois objets en poche |
| A6 | Le volume de la sirène a nettement monté depuis A4. Jesse regarde vers l'horizon, nerveux. | Rien | Jesse : *"Ils arrivent. Je les entends, ils arrivent."* Walt : *"Ce ne sont peut-être pas..."* Jesse : *"On y va !"* | Cinématique courte : les deux remontent |
| A7 | Poste de conduite. Le moteur tousse à la première tentative. | 2 à 3 appuis, jamais plus (réussite forcée au 3ᵉ) | Jesse *(tape le tableau de bord)* : *"Allez, allez, ALLEZ—"* | Moteur démarré |
| A8 | Conduite libre sur la piste jusqu'à un repère visuel (une crête, un panneau à moitié enseveli). Pas de HUD directionnel. | Conduite (WASD) | Pas de dialogue pendant la conduite — seulement le moteur, le vent, la sirène en fond | Repère franchi |
| A9 | Le joueur ralentit naturellement en franchissant le repère — la sirène, qu'on suivait depuis cinq battements, change de rythme et de tonalité : ce n'est plus une sirène de police, c'est un camion de pompiers, qui passe au loin sans s'arrêter. Un battement de silence. | Rien | Jesse *(la voix qui retombe d'un coup)* : *"C'est... c'est pas eux."* Walt *(après un silence)* : *"Non. Des pompiers."* Jesse : *"On a couru pour des pompiers."* | Fondu au noir, texte à l'écran : **« Trois semaines plus tôt »** |

> **Note de son, pour Guillaume** : le battement A9 ne fonctionne que si la
> sirène de police (montée en tension) et la sirène de pompiers (la
> résolution) sont deux sons clairement différents dans leur timbre — sinon
> le joueur ne perçoit pas le twist, il faut juste lire le texte de Jesse.
> C'est le seul endroit de toute la mission où le son porte à lui seul un
> retournement.

---

## 5. Séquence B — Le flashback, battement par battement

*Le joueur reprend la main directement ici — pas de menu, pas de
chargement visible, juste le fondu depuis A9.*

| # | Ce qu'on voit / entend | Ce que fait le joueur | Dialogue | Fin du battement |
| - | --- | --- | --- | --- |
| B1 | Extérieur, jour, la clairière. Jesse ouvre la portière du camping-car, fier, presque cérémonieux. Walt regarde l'intérieur avec un mélange de dégoût et de curiosité. | Rien — cinématique | Jesse : *"Bienvenue dans le bureau, professeur."* Walt *(regardant l'équipement)* : *"C'est... rudimentaire."* Jesse : *"C'est fonctionnel. C'est tout ce qui compte."* | Passage à l'intérieur |
| B2 | Walt pose sa sacoche, commence à retirer sa chemise et son pantalon, ne garde que ses sous-vêtements et des gants, enfile un tablier improvisé. Jesse le regarde faire, un sourire qu'il retient mal. | Rien — cinématique | Jesse *(amusé)* : *"Sérieux ?"* Walt *(sans le regarder, concentré)* : *"Je n'ai qu'une chemise correcte. Elle n'a pas à finir comme le reste de cette pièce."* | Walt en position de travail |
| B3 | Premier geste guidé : verser un liquide d'un contenant à un autre (icône de geste à l'écran, pas de minuteur). | Interaction simple (F ou glisser, selon ce que le système de cuisson existant permet déjà) | Walt : *"Lentement. Toujours lentement. La vitesse est l'ennemie de la précision."* Jesse *(en versant trop vite)* : *"C'est bon, c'est bon—"* Walt *(le coupant, ferme)* : *"Non. Recommence."* | Le joueur reprend le geste, cette fois correctement |
| B4 | Deuxième geste : allumer et régler une plaque chauffante. | Interaction simple | Jesse : *"Et donc, ça sert à quoi, tout ce speech sur la précision ?"* Walt : *"À la différence entre un produit qu'on peut vendre, et un produit qui tue quelqu'un."* | La plaque est réglée |
| B5 | **Micro-choix.** Jesse propose de sauter une étape pour aller plus vite. | Choix de dialogue : suivre la suggestion de Jesse, ou insister sur la méthode de Walt | Jesse : *"On peut sauter cette étape. Ça change rien au résultat, je l'ai fait mille fois comme ça."* — **Option A** *(suivre Jesse)* : Walt hausse les épaules, cède. — **Option B** *(insister)* : Walt : *"On ne saute rien. Pas aujourd'hui."* | Cuisson terminée — teinte du cristal légèrement différente selon l'option, jamais commentée à l'écran |
| B6 | Troisième geste : surveiller la couleur du produit final à travers la verrerie (le système de cuisson existant, réutilisé, décide ici de la pureté — voir §2 du cahier d'implémentation). | Observation, pas d'input actif requis au-delà de regarder | *(silence — juste le bruit de la plaque qui refroidit)* | La fournée est prête |
| B7 | Les deux se penchent sur le résultat. Premier vrai moment de calme de toute la mission. | Rien — cinématique | Jesse *(impressionné malgré lui)* : *"Ça... ça a une sacrée gueule."* Walt *(un sourire fugace, presque malgré lui)* : *"Oui. En effet."* | Fondu au noir |
| B8 | Retour au monde ouvert, devant chez Walter, en plein jour, temps présent. Aucune transition expliquée à l'écran — le joueur comprend qu'on est revenu au fil normal du temps. | Le joueur reprend le contrôle librement | — | Mission terminée |

---

## 6. Table de dialogue complète (prête pour `dialogues.json`)

Regroupée par personnage, dans l'ordre de la mission — à éclater en
`conversations` selon la structure déjà en place dans le fichier existant.

**Walter**
1. *"...Jesse ?"*
2. *"Non, non, non..."*
3. *"Il faut d'abord..."*
4. *"Rien. On ne laisse rien."*
5. *"Ce ne sont peut-être pas..."*
6. *"Non. Des pompiers."*
7. *"C'est... rudimentaire."*
8. *"Je n'ai qu'une chemise correcte. Elle n'a pas à finir comme le reste de cette pièce."*
9. *"Lentement. Toujours lentement. La vitesse est l'ennemie de la précision."*
10. *"Non. Recommence."*
11. *"À la différence entre un produit qu'on peut vendre, et un produit qui tue quelqu'un."*
12. *"On ne saute rien. Pas aujourd'hui."* (branche B seulement)
13. *"Oui. En effet."*

**Jesse**
1. *"Faut y aller, faut y aller MAINTENANT."*
2. *"Y'a pas de "d'abord" !"*
3. *"Ils arrivent. Je les entends, ils arrivent."*
4. *"On y va !"*
5. *"Allez, allez, ALLEZ—"*
6. *"C'est... c'est pas eux."*
7. *"On a couru pour des pompiers."*
8. *"Bienvenue dans le bureau, professeur."*
9. *"C'est fonctionnel. C'est tout ce qui compte."*
10. *"Sérieux ?"*
11. *"C'est bon, c'est bon—"*
12. *"Et donc, ça sert à quoi, tout ce speech sur la précision ?"*
13. *"On peut sauter cette étape. Ça change rien au résultat, je l'ai fait mille fois comme ça."*
14. *"Ça... ça a une sacrée gueule."*

Toutes les répliques sont courtes (cohérent avec la limite de trois lignes
affichées à l'écran notée dans `docs/07-ajouter-du-contenu.md`).

---

## 7. Son et musique — pour Guillaume

- **A1-A3** : nappe tendue et minimale, presque un bourdonnement. Respiration
  amplifiée tant que le masque est porté (A2).
- **A4-A8** : la sirène est le vrai instrument de la scène — elle doit
  pouvoir monter en volume de façon continue et crédible, pas juste passer
  d'un état "faible" à un état "fort" en un seul cran.
- **A9** : bascule sonore nette vers la sirène de pompiers — timbre
  différent, pas juste plus fort. C'est le seul jump scare sonore inversé
  de la mission (la tension retombe, pas l'inverse).
- **B1-B2** : ambiance désertique de jour, cigales/vent, aucune musique —
  le silence relatif souligne l'aspect artisanal, presque domestique, du
  moment.
- **B3-B6** : légers sons de verrerie, de liquide versé, de plaque
  chauffante — pas de musique non plus, cohérent avec « le ton ne bouge
  pas : lent, sale, provincial » (`CLAUDE.md`).
- **B7** : un très léger motif musical peut apparaître ici, discret — le
  seul moment de la mission qui a le droit d'être presque chaleureux.

---

## 8. Ce qui doit exister avant de coder cette mission

- Modèles de personnages : Emilio et Krazy-8 (pose inerte suffit pour cette
  mission — voir §2).
- Deux configurations du camping-car (accidenté / en service) — voir §3,
  question ouverte sur mesh unique vs variantes.
- Système de ramassage d'objet au sol (§2 du cahier d'implémentation,
  [CODE NOUVEAU]).
- Système de cuisson jouable : **déjà existant** dans la mission test —
  vérifier qu'il accepte un habillage différent (flashback, sans les
  enjeux de la cuisson spéciale de la mission 4) avant d'écrire quoi que ce
  soit de neuf.
- Deux sons de sirène distincts (police en tension, pompiers en résolution).

*Projet de fan, non commercial. Complément à `palier1-cahier-implementation.md`.*
