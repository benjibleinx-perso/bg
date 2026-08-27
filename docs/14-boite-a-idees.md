# La boîte à idées

**Ce qu'on fera peut-être, et qu'on n'a pas à justifier.**

Ce fichier existe pour une raison précise : développer le cœur d'un jeu est
long, et il arrive qu'on en ait assez. Plutôt que de s'y forcer ou de bricoler
quelque chose au hasard, **on pioche ici**. Une idée de la boîte peut être
intégrée à n'importe quel moment, y compris au milieu du développement du
cœur — c'est même l'usage prévu.

**La seule règle :** une idée piochée doit pouvoir se livrer en une soirée ou
deux. Si elle en demande dix, c'est qu'elle appartient au cœur et il faut la
discuter.

Une idée n'a pas besoin d'être défendue pour entrer ici. Elle a besoin d'être
défendue pour en sortir.

---

## Ambiance et présentation

- **L'écran de chargement à la tortue.** La tortue du désert qui avance, tête
  en avant. Personne ne l'oubliera. Peu cher, très haut rendement.
- **Le générique de fin**, façon série : cartons noirs, ce que sont devenus les
  personnages.
- **La radio de la voiture**, avec des stations qui changent selon le quartier.
- **Les cartons de chapitre** entre deux actes.

## Conduite et ville

- **Les contrôles routiers.** La police arrête au hasard, et la méfiance grandit
  avec ce qu'on transporte et avec ce qu'on a fait avant. Le contrôle est un
  dialogue, pas un combat : on parle, on montre, on transpire.
- **Les courses de nuit** dans le désert — la conduite pure, pour l'argent et
  pour le plaisir de conduire.
- **La météo.** Un orage de sable qui ferme la route du désert.
- **Les embouteillages aux heures de pointe**, qui rendent un rendez-vous
  tendu.

## Économie et gestion

- **Le lavage de voitures** comme commerce à faire tourner, avec un plafond de
  blanchiment qui monte si on s'en occupe. *(Note : l'arc du car wash lui-même
  — employé puis propriétaire — est dans le cœur, pas ici. Ce qui est ici,
  c'est la gestion fine du commerce.)*
- **La chasse au précurseur** : repérer, voler, ou acheter cher.
- **Le cosmétique** : vêtements, voiture, maison. De l'argent qui ne sert à
  rien d'utile, et c'est exactement pour ça que c'est intéressant.

## Missions et situations

- **Le ménage** : faire disparaître ce qui traîne avant une visite. Court,
  tendu, sans combat.
- **Les photos** de lieux de la série — la collecte qui fait visiter la carte.
- **Un concurrent** qui vend sur notre zone. Négocier, écraser, ignorer.
- **Le rendez-vous qui tourne mal** : une livraison où l'acheteur ne se
  présente pas seul.

---


## Micro-scènes et clins d'œil

Des scènes d'une minute, souvent sans mécanique. Elles viennent de la session
missions du 31/07/2026 et sont volontairement laissées en vrac : chacune tient
en une soirée, aucune n'a besoin d'être défendue.

Le bacon en chiffres sur l'assiette d'anniversaire · Hank et ses minéraux (« c'est des *minéraux*, Marie ») · la Schraderbräu à goûter poliment · Badger qui raconte son scénario de Star Trek pendant un trajet · Skinny Pete au piano, très bien · le distributeur d'essuie-mains de l'hôpital · le violet de Marie et ses petits vols · l'ours en peluche rose dans une piscine, jamais expliqué · Los Pollos Hermanos comme vrai restaurant où l'on peut manger · la cassette de karaoké de Gale à trouver dans son appartement (lié à la mission 14) · le chapeau acheté en magasin, en cinématique, sans un mot · la tarentule dans le bocal (liée à la mission 12).

---

## Comment on s'en sert

1. On y jette une idée sans la discuter, dès qu'elle passe.
2. Quand on veut souffler, on en prend une.
3. Si elle grossit en la faisant, on s'arrête et on la remet dans la boîte —
   une idée de détente qui devient un chantier n'est plus une détente.
4. Ce qui est fait sort de la boîte et entre dans les notes de version.

---

## Le HUD net — ce qui a été essayé, et ce qui reste à essayer

**Le constat, mesuré.** L'interface est dessinée dans un `Control` de 512 × 384,
à l'intérieur d'un viewport de 960 × 720, lui-même agrandi à 1440 × 1080. Chaque
pixel d'interface en devient **2,8** à l'écran, alors que la 3D n'est agrandie
que d'**1,5**. Le HUD est donc deux fois plus grossier que le jeu qu'il recouvre.

Ce n'est pas le grain PS2 : le grain vient du rendu 3D et de son agrandissement.
Un texte illisible n'est pas un parti pris.

**Le coût brut.** Passer le Control à 960 × 720 oblige à multiplier toute la mise
en page par 1,875 : **289 valeurs numériques réparties sur neuf fichiers**
(`hud`, `telephone`, `minimap`, `roue`, `pause`, `cachette`, `fin_de_partie`,
`appel`, `jauge_perf`). Une conversion à la main de cette taille se trompe
quelque part, et l'erreur ne se voit qu'à l'endroit qu'on ne capture jamais.

### Tentative 1 — conversion partielle

Control à 960 × 720, offsets du cadre de dialogue et tailles de police de la
scène multipliés. Abandonnée avant d'aller plus loin : les scripts continuaient
de penser en 512, le résultat aurait été un HUD à moitié converti. **Annulée.**

### Tentative 2 — transformation d'échelle

L'idée : ne toucher à aucune valeur. Chaque `_draw()` pose
`draw_set_transform(scale = 1.875)` ; les positions restent écrites en 512 et
Godot les agrandit. Les formes suivent sans rien perdre. Le texte, lui, est
rendu **hors** de la transformation, à sa taille finale, pour rester net.

Ça a marché pour les formes et pour la netteté — la capture le montre, le texte
était franchement plus fin. **Mais la transformation s'applique aussi au texte**,
en plus de la taille demandée : position et corps multipliés deux fois, HUD 1,9×
trop grand. Ni `draw_set_transform(…, Vector2.ONE)` ni
`draw_set_transform_matrix(Transform2D.IDENTITY)` ne l'annulent pour un
`Font.draw_string()` visant le `canvas_item` du Control. **Annulée.**

### Ce qui reste à essayer, dans cet ordre

1. **Sortir l'interface du SubViewport.** Un `CanvasLayer` frère de `Ecran`,
   dessiné à 1440 × 1080. Le HUD devient net *par construction*, la 3D garde son
   grain. C'est la solution juste ; elle demande de déplacer une dizaine de
   nœuds et de reprendre leurs `NodePath`, et de laisser dans le viewport ce qui
   doit couvrir la 3D — le voile de cinématique et le filtre du masque.
2. **Sinon, la conversion complète**, fichier par fichier, capture à chaque
   étape. Le facteur est 1,875, il n'y a aucune subtilité — seulement du volume.

**Ce qu'il ne faut pas refaire** : une transformation d'échelle. Deux variantes
essayées, deux échecs, pour la même raison.

### Resolu le 16/08/2026 — en une ligne

**`gui/theme/default_font_multichannel_signed_distance_field=true`.**

Un glyphe en champ de distance signee est stocke comme une FORME, pas comme une
image : il reste net quelle que soit l'echelle a laquelle on l'etire. C'est
exactement le cas ici, puisque `rendu_ps2.gd` applique un facteur au Control
d'interface — et c'est ce facteur, jamais identifie comme tel, qui produisait le
flou.

Les deux tentatives ci-dessus s'attaquaient au symptome : elles cherchaient a
faire dessiner l'interface a la bonne resolution. Le vrai probleme n'etait pas la
resolution du dessin, c'etait la **nature** du glyphe.

Ce qu'on en retient : **avant de deplacer trois cents valeurs, chercher si le
moteur sait deja faire.** Deux soirees d'ecart entre les deux idees, pour une
ligne de configuration.
### Correction du 27/08/2026 — la ligne n'avait jamais pris

**La section précédente est fausse depuis le jour où elle a été écrite.**

La ligne annoncée comme la solution était posée **sous la section `[gui]`** de
`project.godot`, qui fournit déjà ce préfixe. Godot l'a enregistrée comme
`gui/gui/theme/default_font_multichannel_signed_distance_field` — une clé
inexistante, acceptée sans un avertissement. Le vrai réglage est resté à `false`
pendant onze jours, et le texte du jeu aussi pixellisé qu'avant.

C'est Benjamin qui l'a redit le 27/08 — *« le texte fait vieux et pixellisé »* —
et il a fallu demander au moteur la liste de ses réglages `gui/` pour le voir :
les deux clés fantômes y apparaissaient l'une sous l'autre.

Écrite correctement (`theme/default_font_...` sous `[gui]`), elle fonctionne, et
la conclusion d'origine tient : le champ de distance signée résout le cas, les
deux cent quatre-vingt-neuf valeurs n'ont pas à bouger.

**Ce qu'il faut en retenir en plus** : un correctif d'une ligne se vérifie comme
les autres. Celui-là n'a jamais eu de contrôle parce qu'il paraissait trop petit
pour se tromper, et sa note de victoire a servi de preuve. Piège 71.

**Et une seconde cause, indépendante** : le jeu n'avait **aucune police**. Tout
était écrit avec celle de Godot. La charte en nommait deux depuis le 23/08 ;
elles sont dans `assets/polices/` depuis le 27/08.
