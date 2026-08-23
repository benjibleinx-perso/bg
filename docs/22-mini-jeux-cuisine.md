# Les mini-jeux de cuisine

> « C'est un ajustement très important car ça constituera une des mécaniques
> principales du jeu. Je te laisse travailler sérieusement là-dessus. »
> — retour de Guillaume, 23/08/2026

Ce document dit **ce qui a été fait**, **la règle qui les tient ensemble**, et
**la réserve** pour les labos suivants. Guillaume demande explicitement cette
réserve : « Réserve des idées de mini jeu pour de futures étapes de cuisine
aussi (avec les différents labos qui vont débloquer de nouvelles méthodes de
cuisine). »

---

## La règle, en cinq points

Elle vaut pour tout mini-jeu de cuisine à venir. Elle n'a pas été décidée à
l'avance : elle est ce qui restait quand les trois premiers ont été écrits.

1. **Aucun chiffre, aucune jauge.** C'est la première règle du projet et elle
   ne souffre pas d'exception ici. Ce qui informe le joueur est une **matière
   qui change** : un filet qui tombe à côté, des bulles qui s'emballent, une
   mousse qui monte, une couleur qui vire.

2. **Une seule chose à comprendre par mini-jeu**, et elle s'apprend en la
   ratant une fois. Verser, c'est *la fiole se vide donc il faut accompagner*.
   La plaque, c'est *le liquide répond en retard*. La fournée, c'est *il
   attend un ingrédient précis à un moment précis*.

3. **Tenir une touche, c'est avoir la main dessus.** On lâche, on repose, rien
   n'est cassé. Sans cette soupape, un mini-jeu de précision devient un piège
   dont on ne peut pas sortir. La seule exception justifiée est la plaque : on
   n'éteint pas un bec de gaz en retirant la main, et c'est **vrai**.

4. **Un geste par mini-jeu, et jamais deux fois le même.** C'est le reproche
   central du retour : « on ne fait que cliquer ». Le vocabulaire disponible
   est petit — souris, molette, une touche d'action — et il se recombine plutôt
   qu'il ne s'étend. La fournée ne demande aucune touche nouvelle : elle est la
   molette de la plaque plus la touche du démarreur.

5. **L'échec doit exister, et il ne doit pas punir deux fois.** Soit on
   recommence sur place (verser, la plaque), soit on paie en **pureté** (la
   fournée). Jamais un renvoi à l'autre bout de la pièce, jamais une
   progression remise à zéro.

---

## Les trois qui existent

| Battement | Ce qu'on fait | Ce qui décide | L'échec |
| --- | --- | --- | --- |
| **B3 — Verser** | La souris incline la fiole ; on regarde **où le filet tombe** | Précision et dose. La fiole se vide, donc le geste juste au début devient trop court à la fin | Trop court, trop loin, ou fiole vidée pour rien → on recommence |
| **B4 — La plaque** | La molette règle le gaz ; le liquide **rattrape** avec du retard | Timing et inertie. La fenêtre juste **descend** pendant la cuisson | Trop chaud trop longtemps → ça déborde, et on reprend un peu en arrière |
| **B6 — La fournée** | Le ballon réclame un flacon par une auréole qui **pâlit** ; molette pour choisir, touche de gauche pour verser | Ordre et moment | Mauvais flacon, trop tôt, trop tard → la **pureté** tombe, la mission continue |

C'est la fournée qui décide désormais de la couleur du cristal qu'on emporte,
donc de ce qu'il vaudra. `cuisson.gd` — le curseur qui balayait une barre — ne
sert plus qu'à la mission de rodage.

---

## La réserve, pour les labos suivants

Rien ici n'est décidé. Ce sont des mécaniques qui tiennent la règle des cinq
points et qui n'ont pas encore été prises. Elles sont classées par **ce
qu'elles demandent au joueur**, parce que c'est le seul critère qui compte : un
labo qui ajoute trois mini-jeux du même axe n'ajoute rien.

### Précision d'un geste tenu

- **Le filtre.** On verse à travers un filtre qui se colmate : le débit tombe
  tout seul, il faut relâcher pour le laisser s'écouler, puis reprendre. Le
  contraire exact de la fiole qui se vide — ici c'est l'attente qui est le
  geste.
- **La pesée.** Deux plateaux, on ajoute par petites touches et le fléau
  oscille longtemps après qu'on a arrêté. On ne peut pas corriger vite : il
  faut attendre de voir.

### Ordre et mémoire

- **La recette apprise.** Walter énonce l'ordre **une fois**, au début, et le
  ballon ne réclame plus rien. Variante directe de la fournée, sans l'auréole —
  réservée à un labo tardif, quand le joueur est censé savoir.
- **Le mauvais flacon.** Deux flacons portent la même couleur et se
  distinguent à l'étiquette, qu'il faut approcher pour lire. Coûte une lecture,
  donc du temps, donc un choix.

### Tenue et surveillance

- **Deux plaques à la fois.** La même mécanique que B4, en double, avec des
  inerties différentes. Ne demande aucun code neuf et double la charge — le
  candidat le plus évident pour un labo « industriel ».
- **La pression.** Un manomètre sans chiffre : une aiguille et une zone rouge.
  On purge en tenant une touche, mais purger refroidit, et refroidir arrête la
  réaction.

### Ce qui coûterait cher et qu'il faut discuter avant

- **Une cuisine à deux mains** — Jesse fait une chose pendant que le joueur en
  fait une autre, et il faut lui dire quoi. Demande un système d'ordres et une
  IA de PNJ qui n'existent pas.
- **Un montage de verrerie** à assembler pièce par pièce. Demande des modèles
  séparés, des points d'accroche et une manipulation en 3D — c'est un chantier
  d'assets autant que de code.

---

## Ce qui manque, et qui n'est pas du code

- **Les bruitages.** Aucun son de liquide, de gaz ou de verre dans la banque.
  Les trois mini-jeux empruntent `roue_cran` et `choc_leger`, ce qui s'entend.
  Guillaume a proposé de fournir ceux du démarrage — ceux-ci sont à demander.
- **Une posture de travail pour Jesse.** Il est face à sa verrerie, debout,
  bras le long du corps. Le retour dit « en train de manipuler des fioles » :
  il faudrait une animation, donc un passage par le rig, donc un vrai chantier.
- **Un plan sur la paillasse.** Les gestes se dessinent dans un encart pendant
  que la caméra reste derrière Walter. Le vrai cadrage demande une caméra de
  cinématique — la même que réclame le plan de mort du lot K. Un chantier, pas
  un réglage.
