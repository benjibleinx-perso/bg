# Comment on travaille sur BG

**Ce fichier se lit au début de chaque session et se met à jour à la fin.**
C'est le seul document que je charge automatiquement : tout ce qui doit
survivre d'une session à l'autre vit ici, ou dans un fichier que celui-ci
désigne.

Il ne remplace pas les docs — il dit ce qu'aucune doc ne dit : ce qui a déjà
raté, ce qui guide un arbitrage, et ce que je dois refuser.

---

## Le projet en trois lignes

Un GTA-like low-poly **PS2** dans l'univers de Breaking Bad, à Albuquerque.
Godot 4.7, GDScript. Benjamin code avec moi ; **Guillaume** livre le son et la
3D et n'est pas développeur. Projet de fan, non commercial — voir
[DISCLAIMER.md](DISCLAIMER.md).

**Ce qui décide, quand deux options se valent :** est-ce que ça donne envie de
rouler dedans ? Le ton de la série avant la fidélité au décor, le décor avant
la technique, et une chose qui tourne avant trois qui attendent.

---

## La direction, en cinq règles

Le détail vit dans [docs/12-direction.md](docs/12-direction.md), qui est le
socle. Ces cinq-là décident de tout et se relisent avant de concevoir quoi que
ce soit :

1. **Aucun chiffre n'est montré au joueur — sauf les trois ressources.**
   **L'argent, la famille et la réputation** s'affichent en permanence, décision
   du 06/08/2026 : ce sont des comptes à rebours qu'on surveille en conduisant.
   Tout le reste se perçoit — la couleur du produit, le ton d'une réplique, la
   lumière d'une pièce. Un chiffre transforme un choix en optimisation, et
   l'exception ne s'étend à rien d'autre.
2. **Un choix sans coût n'est pas un choix.** Si une option est meilleure sur
   tous les plans, il n'y a rien à décider.
3. **L'argent est un compte à rebours, pas un score.** Il doit être prélevé.
4. **Monter retire des options.** Chaque palier donne de l'argent et enlève de
   la liberté.
5. **Le ton ne bouge pas.** Lent, sale, provincial.

**L'ordre de travail** — et il vaut aussi pour moi : *théorie → cœur → boîte à
idées → réglage*. La [boîte à idées](docs/14-boite-a-idees.md) existe pour
qu'on puisse souffler sans bricoler au hasard : on y pioche quand on en a marre
du cœur, et une idée piochée doit tenir en une soirée ou deux.

---

## Ce qui n'est pas négociable

Quarante règles, apprises une par une et toutes payées au moins une fois.
Chacune ouvre un paragraphe en gras — c'est ce qui les rend comptables sans
les compter à la main.
Elles sont rangées **par moment d'usage** et non par date : celle dont j'ai
besoin doit se trouver quand elle sert, pas se lire au début et s'oublier.

L'ordre chronologique a coûté deux règles repayées dans la nuit du 24/08/2026 —
elles étaient écrites ici, l'une depuis trois semaines.

---

### Ce qui vient de Guillaume, et qui fait foi

**Le script de Guillaume se relit AVANT de coder le battement, pas après.** Il est
le seul endroit où l'information existe, et il est plus précis que ma mémoire de
l'avoir lu. Deux exemples payés le 16/08/2026 : le démarrage du camping-car s'est
codé comme un geste ordinaire alors qu'A7 s'appelle *« poste de conduite »* et
qu'A6 se termine par *« cinématique courte : les deux remontent »* ; et la sortie
de zone a été posée sans repère alors qu'A8 demande *« un repère visuel — une
crête, un panneau à moitié enseveli »*. Dans les deux cas la réponse était écrite,
et j'ai pris une liberté à sa place.

> **Quand j'ai une question sur un battement, j'ouvre
> [docs/19](docs/19-mission1-script-complet.md) — et si la réponse n'y est pas,
> je la POSE au lieu de trancher.**

**Et depuis le 23/08/2026, il y a un second texte qui fait foi :
[docs/21](docs/21-mission1-retours-guillaume.md)**, la transcription mot pour
mot de ce que Guillaume demande après avoir joué la mission 1 — cinquante-cinq
points, découpés en onze lots. Quand les deux se contredisent, **c'est le
retour qui gagne** : il a été écrit en jouant, le script en imaginant. Sa
charte graphique — palette, lumière, contraintes PS2 — vit dans
[docs/20](docs/20-charte-graphique.md) et guide tout ce qui s'affiche.

---

### Quand je mesure

**On mesure le fichier PRODUIT, jamais la scène qui l'a produit.** C'est la
règle la plus chère du projet : elle a été apprise quatre fois, toujours de la
même façon — un outil annonce un nombre juste et écrit un fichier faux. Voir
[docs/11-pieges.md](docs/11-pieges.md), qui existe pour ça — et dont l'index
range les soixante-seize pièges par le moment où ils frappent, pas par date.

**Une image ou un nombre, jamais une conviction.** Un rendu se juge sur
`.\bg.ps1 capture -Scenario <nom>`. Une géométrie se juge sur des centimètres
imprimés. J'ai conclu trois fois de suite « la voiture est dans le bon sens »
sur une image ambiguë ; elle était à l'envers.

**Un point de mesure décrit le symptôme ; c'est le SECOND qui désigne la
réparation.** Les chevilles de Walter à dix-huit centimètres sous le sol
collaient aussi bien à des jambes fléchies par les animations — dix clips à
reprendre — qu'à un corps posé trop bas — une ligne. Ce qui a tranché : mesurer
le **bassin** en même temps, enfoncé d'autant, donc des jambes droites. Devant un
écart, chercher la mesure qui distingue les causes possibles : elle coûte une
ligne dans le diagnostic et elle choisit le chantier. Piège 75.

**Et une vue qui pose sa caméra ne montre pas ce que le joueur voit.** C'est
Guillaume qui l'a désigné le 27/08/2026, sans connaître le code : *« il voit
très mal ce qu'il fait. Genre la cinématique, elle marche juste pas, et il a
aucun moyen de le savoir »*. Les cent onze vues du projet créent leur propre
caméra — elles photographient donc le cadrage **recopié dans leur scénario**,
jamais l'image que le jeu rend. Une vue **sans champ `camera`** rend exactement
ce qui sort à l'écran ; le projet croyait la chose impossible et l'avait écrit.
Pour tout ce qui se met en scène tout seul — cinématiques, filtres, interface —
c'est celle-là qu'il faut. Piège 69.

**Ce qui ne se joue jamais dans une suite ne se vérifie pas.** Les cinématiques
étaient contrôlées sur la *forme* de leurs données : les noms de nœuds existent,
les champs sont bien écrits. Une cinématique dont pas un plan ne s'affiche
passait ce contrôle sans une remarque. Avant d'écrire un contrôle qui relit une
donnée, se demander ce qui l'exécute — et si la réponse est « personne », c'est
ça qu'il faut écrire.

**Et son revers : un nombre n'est une preuve que si j'ai lu le code qui le
produit.** Un relevé de performance a annoncé un effondrement du jeu ; il
mesurait sa propre synchro verticale. Avant de corriger ce qu'un instrument
dénonce, vérifier l'instrument — voir le piège 18.

**Un nombre lu après coup mesure l'état d'après, pas la cause.** « Walter est
mort en chemin. Sa vie : 100 » — donc ce n'est pas une blessure, avais-je
conclu, et je l'ai publié. La reprise appelle `ressusciter()`, qui remet la vie
à cent : je mesurais un homme qu'on venait de remettre debout. Un `print` dans
`perdre()` a répondu en une ligne — pv = 0, c'était le feu. **La mesure se place
au moment où la chose se produit**, pas là où c'est commode de la lire. Le
chiffre était exact ; c'est son sens qui était faux, et c'est pour ça que les
deux formulations voisines n'ont pas suffi. Piège 64.

**Quand une valeur est traduite avant d'être utilisée, mesurer ce qui SORT de la
traduction.** La montée de la sirène était juste dans le JSON et inaudible à
l'écran : convertie en décibels par une droite, elle valait −51 dB au premier
palier. Les vérifications lisaient les valeurs écrites et avaient raison d'être
vertes — le défaut était dans la fonction qui les traduit. Vaut pour tout ce qui
a une unité perceptive : décibels, gamma, énergie lumineuse. Piège 42.

**Une durée de gameplay ne se calcule pas, elle se joue et se chronomètre.** Le
seul chiffre que Guillaume ait donné — « la tractation complète doit bien
prendre au moins 20 secondes » — était à vingt et une secondes sur le papier et
à **seize** en jeu : le corps se traîne 1,15 m derrière Walter et se dépose dès
que *lui* arrive, donc Walter s'arrêtait quatre mètres avant la portière. Le
trajet réel n'est jamais la distance entre deux points ; la laisse d'un objet
tiré, le rayon d'une zone d'arrivée et l'accélération au départ coûtent chacun
moins d'un mètre, et ensemble un quart du total. Piège 58.

**Et un diagnostic chiffré inspire une confiance qu'un raisonnement n'obtient
jamais.** Trois commentaires et un message de commit avaient été écrits autour
de « 113,6 mètres » avant qu'on découvre que le nombre ne mesurait pas ce qu'on
croyait. C'est le `print()` des deux positions BRUTES — pas seulement de
l'écart — qui a fini par trahir l'erreur. Un contrôle imprime ce qu'il compare,
pas seulement son verdict.

**Une absence ne prouve rien tant que la recherche n'est pas complète.** J'ai
ouvert un bug « on ne peut pas courir » sur une liste d'actions tronquée par ma
propre commande : `sprint` venait quatre lignes après la coupure. Et je cherchais
« courir », le mot du README, alors que le code dit `sprint` — que j'avais lu dix
minutes plus tôt sans faire le lien. **Avant de conclure qu'une chose n'existe
pas : vérifier que la liste est entière, et chercher le mot du CODE, pas celui de
la doc.**

---

### Quand j'écris ou je lis un test

**Un test peut avoir raison de crier et tort sur la cause.** « 12 passants sous
la carte » : aucun n'était tombé, ils marchaient sur la chaussée. Le seuil
agrégeait deux sols différents sous le nom d'un troisième défaut. **Un compteur
nomme UNE cause** — si deux problèmes qui se corrigent à des endroits différents
peuvent l'incrémenter, son nom tranchera à ma place, et une fois sur deux dans le
mauvais sens. Piège 31.

**Une vérification qui se place elle-même au bon endroit valide toujours.** Un
test téléportait la voiture sur la sortie du désert avant de vérifier qu'on peut
repartir ; la sortie était introuvable depuis une semaine, et il était au vert.
Devant un test qui passe, demander **quel geste du joueur il reproduit** — s'il
commence par placer quelque chose à la main, il ne vérifie pas qu'on peut y
arriver, et c'est presque toujours la question. Piège 19.

**Et pour un branchement, la question est plus courte : qu'est-ce qui, dans ce
test, ne pourrait PAS arriver si le fil était coupé ?** Si la réponse est
« rien », il ne surveille rien. Deux mesures d'affilée ont validé le son des
passants **débranché** — l'une lisait un bus partagé, l'autre appelait elle-même
la méthode qu'elle voulait voir appelée. **Le seul geste qui tranche : commenter
la ligne qui branche, relancer, exiger le rouge.** Il coûte une minute. Piège 32.

**Un contrôle qui vérifie que tout ce qui est attendu existe ne dit rien de ce
qui existe sans être attendu.** Trois séries de répliques sont devenues muettes
en une soirée — leurs étapes avaient quitté le déroulé — et le contrôle qui les
surveillait était vert : il partait des étapes vers le fichier, et dans ce
sens-là une clé orpheline est invisible. **Les deux sens sont deux contrôles**,
et c'est celui qu'on n'écrit pas qui trouve les choses mortes. Piège 56.

**Une suite qui joue vaut dix qui mesurent, et elle se juge autrement.**
`test -Suite parcours` traverse la mission en marchant et en appuyant sur E. Elle
s'interdit ce qui rend un test complaisant — aucune téléportation, aucun
`aller_a`, aucun déclenchement direct : elle pose le **cap**, jamais la
**position**. Elle a trouvé en dix minutes d'existence ce qu'aucune des
trente-deux autres ne pouvait voir : un marqueur d'objectif qui pointait à neuf
cents mètres, invisible depuis toujours parce que rien n'était bloqué. Deux
conséquences : **une suite qui joue tourne à pas de temps fixe** (sans quoi elle
rend deux verdicts sur le même dépôt), et **elle a le droit de rester rouge**
tant qu'on n'a pas tranché ce qu'elle accuse — la neutraliser pour qu'elle se
taise en ferait un test qu'on ne relit plus. Pièges 43 et 44.

**Un mécanisme nouveau ressemble toujours à un blocage pour la suite qui joue.**
Trois fois : le cadran du démarreur, les trois secondes de roulage, la traction
des corps — et les trois fois le jeu allait bien, c'est le pilote qui ne
connaissait que le verbe « appuyer ». **Il doit apprendre chaque geste nouveau.**
Ce qui a tranché les trois fois : son message d'échec imprime *ce que le jeu
propose*, donc « Maintenir pour attraper les pieds » désigne le coupable sans
discussion. Piège 59.

**Un parcours qui recule n'est pas un parcours lent : c'est une partie qui a
recommencé.** La suite qui joue a rendu deux verts en ne jouant pas ce qu'elle
prétendait jouer — une étape sans marqueur comptée « fin de mission », et une
boucle qui rejouait les mêmes étapes après une mort. Elle annonçait **« 25
étapes jouées »** sur une mission qui en a vingt et une : la preuve était
imprimée à chaque lancement. Piège 61.

---

### Quand je pose du décor, ou du code qui le relie

**Un nom de nœud n'est pas une adresse — compter combien de nœuds le portent.**
Payé **deux fois dans la même soirée**, le 23/08/2026. Une mesure comparait la
sortie du camping-car à `PorteCampingCar` et annonçait 113,6 m d'écart : il en
existe deux, dans deux missions, à cent mètres l'une de l'autre, et `find_child`
rend le premier. L'écart réel était de trois mètres — et la correction, qui
visait ce même nom, **reproduisait le défaut qu'elle prétendait réparer**.
Deux heures plus tard, le calque du filtre d'écran s'appelait comme le système
qui le crée : le contrôle du retrait ne pouvait pas passer, et son jumeau était
vert pour la même mauvaise raison. **Un vert et un rouge, tous deux faux, sur
la même ligne de recherche.** Le jeu contient deux `PorteCampingCar`, deux
`Sortie` et plusieurs `Porte`. Corollaire : **un nœud créé par du code porte un
nom qui dit ce qu'il est, pas celui de qui l'a créé.** Pièges 54 et 54 bis.

**Ce qui compte n'est pas seulement où l'on s'arrête, c'est par où l'on passe.**
Un décor se vérifie le long des TRAJETS, pas seulement autour des points
d'arrivée : deux foyers ont bloqué des passages obligés — l'un à 36 cm de la
ligne que l'on parcourt en tirant un cadavre, l'autre à 80 cm de la tôle du côté
par lequel on remonte — pendant que tous les dégagements mesurés étaient bons.
Et la règle interdisant l'un des deux était déjà écrite trente lignes plus haut
dans le même fichier. Piège 63.

> **Corollaire, payé deux fois :** un rayon qui cherche le sol doit **exclure ce
> qu'on est en train de poser**. Sinon il touche son toit et rend l'altitude de
> l'objet au lieu de celle du sable — le semis de débris s'est posé sur le toit
> du camping-car, et le contrôle de la clairière a annoncé un véhicule enterré
> de trois mètres dans un sol parfaitement plat.

**Un événement émis pendant une étape qui ne l'attend pas est perdu, et il ne
revient jamais.** `mission.evenement()` compare au `valide_par` de l'étape
COURANTE, rend `false`, et personne ne le rattrape. Deux étapes qui se
franchissent au même endroit dans la même seconde sont une course : le
24/08/2026, mettre le contact au moment où « remonter » basculait faisait
tourner le moteur pendant que la mission mourait — objectif affiché intact,
commandes qui répondent, **rien à l'écran pour le dire**. Le remède n'est pas
d'ordonner la course, c'est de ne pas en créer : **une étape qui ne demande
aucun geste que la suivante ne demande déjà n'est pas une étape.** Piège 55.

**Un signal ne rattrape jamais ce qui s'est passé avant qu'on l'écoute.** Le
décor du fossé est instancié à l'exécution, donc le scénario branche ses signaux
en retard — et le guidage est le premier mécanisme dont le jeu a besoin **dès sa
première étape**. Selon la vitesse de la machine, le joueur finissait son trajet
avant que quiconque n'écoute : le même jeu marchait une fois sur deux. Quand
l'émetteur peut exister avant le récepteur, **le signal ne peut pas être le seul
chemin — il faut un état que quelqu'un puisse constater**. C'est la parade déjà
écrite pour « volant », relue trois fois sans qu'on fasse le lien. Piège 60.

**Un asset raté est presque toujours une image ratée.** Avant de changer de
moteur, de budget de faces ou de qualité de texture, regarder ce qu'on a donné à
voir au générateur : il suppose toujours qu'on lui montre la **face** d'un objet
**debout**. Un pantalon photographié à plat vu du dessus ressort en quille
verticale de 1,10 m. Et un objet se **dimensionne sur sa capture en jeu**, pas
sur sa taille réelle — le ballon de verrerie était illisible à 24 cm, lu à 42.
Piège 45.

**Une contrainte de gameplay justifiée par une histoire technique est une
cicatrice, pas une décision.** Le personnage a passé trois versions à pivoter
sur place comme un char, avec trois commentaires expliquant que c'était « les
commandes des jeux de l'époque ». C'était la troisième parade à une caméra qui
se recentrait toute seule ; la supprimer a coûté huit lignes. **Et le test
gardait le symptôme** — il vérifiait que gauche et droite pivotent. Piège 46.

**Une table écrite à la main qui décrit un contenu vivant périme sans rien
dire.** La liste « aller à une phase de la mission » du menu de test nommait les
étapes de la mission de rodage pendant que le jeu en jouait une autre depuis des
semaines : l'outil ouvrait une page dont chaque ligne échouait en silence, et il
a fallu être bloqué à la première étape du jeu, manette en main, pour s'en
apercevoir. Quand une liste peut se **déduire** de ce qu'elle décrit, la
déduire. Et **quand un test doit changer l'état du jeu pour que sa mesure ait un
sens, ce n'est pas le jeu qui est dans le mauvais état** — celui-ci rechargeait
l'ancienne mission pour se mettre d'accord avec la table qu'il mesurait, et il
était vert tous les soirs. Piège 65.

**Une note d'arbitrage n'est pas une réponse à une objection.** Le shader du
masque refusait le vrai flou, mesure à l'appui : `hint_screen_texture` coûte
+4,3 ms par image. Le chiffre était juste, et il ne répondait pas à ce que
Guillaume disait — *« tu as surtout plus opacifié le filtre vert »*. Opacifier
n'est pas flouter. Ce qu'un coût change, c'est **où on le paie** : ce filtre ne
vit que pendant la première minute du jeu. Un budget d'image se défend à
l'échelle de la scène, pas du shader.

**Avant d'estimer un chantier, chercher ce qui existe — et ne jamais croire une
note qui explique pourquoi c'est impossible.** Deux « gros morceaux » de la
mission 1 ont été faits dans la même soirée parce que l'essentiel était déjà
écrit : l'intérieur du camping-car existait, posé au large du monde et même pas
masqué, il attendait une porte ; la conduite ne demandait qu'un groupe et une
ligne. Les deux excuses étaient dans le code, datées et argumentées — *« pas
d'intérieur à lui »*, *« on ne le conduit pas »* — et fausses toutes les deux.
**Une note d'arbitrage vieille de trois jours se lit comme une loi**, et le coût
ne se voit jamais : on ne mesure pas le temps passé à ne pas faire une chose
qu'on croyait chère. Piège 41. *Repayé le 25/08 : deux des quatre points d'un
ticket étaient déjà livrés depuis trois jours, et le tableau disait « rien de
fait ». Une demi-heure de lecture contre une soirée de code.*

**Tout nombre de ressenti vit dans `reglages.tres`.** Une constante de feeling
cachée dans un script est un bug de méthode, même si le résultat est bon.

---

### Quand je livre

**On ne fait jamais taire une commande qui modifie l'état du dépôt.** Le
silence d'un `git push`, d'un `git stash pop` ou d'un `git checkout` est
indiscernable de leur succès. Un `pop` raté, sa sortie envoyée dans `Out-Null`,
a rendu un dépôt annoncé **propre** juste après deux heures de travail — et un
commit à cet instant l'aurait livré amputé. Corollaire qui tranche :
**après un stash pop, le dépôt doit être SALE.** Piège 57.

**`print` et `printerr` n'arrivent pas dans l'ordre où on les écrit.** Deux flux,
deux tampons ; leur ordre relatif change d'un lancement à l'autre, et la sortie
standard peut être **perdue** au `quit()`. Une demi-heure passée à chercher
pourquoi un diagnostic contredisait un échec qu'il suivait en réalité. Quand
l'ordre compte — et il compte toujours dans un diagnostic — **même canal, ou
horodatage**. Voir « Tester » plus bas pour la commande qui rend tout. Piège 62.

**Ce que seul le CI exerce n'est pas vérifié.** `.\bg.ps1 exporter` était cassé
sur nos deux machines : PowerShell 5.1 refuse d'ouvrir une archive qui ne
s'appelle pas `.zip`, et le workflow de release fait le même appel sans broncher
parce qu'il tourne en PowerShell 7. **Deux interpréteurs qui portent le même nom
ne sont pas le même interpréteur** — et tout ce qu'on lance depuis Windows,
`JOUER.bat` compris, passe par le 5.1. Piège 74.

**Un lot livré est un CORRECTIF, pas un mineur.** `0.53.1`, pas `0.54.0`. Le
mineur est réservé à un morceau entier du jeu qui arrive — une mission de plus,
l'économie, la famille. La règle est dans `NOTES-DE-VERSION.md` depuis le
06/08/2026 et je l'ai quand même enfreinte deux fois le 08/08, sur deux lots
d'affilée : le numéro a pris deux mineurs en une soirée pour des voix et des
filtres audio. **À ce rythme on atteint 1.0 avant que le jeu tienne debout, et
le numéro ne veut plus rien dire.** Dans le doute, c'est un correctif.

**Guillaume ne bumpe pas et n'écrit pas les notes de version.** À chaque bump,
une entrée dans `NOTES-DE-VERSION.md` écrite pour celui qui teste : ce qu'on
peut essayer, et les bugs qui gênaient vraiment.

**Ce que je n'ai pas vérifié se dit, il ne se tait pas.** Une mécanique mesurée
et verte dont je n'ai jamais vu l'image n'est pas « faite » : elle est faite et
non vue. Ça s'écrit dans la note de version, dans le message de commit et dans
le ticket — trois endroits, parce que celui qui teste ne lit pas les deux autres.

**Aucune mention de l'assistant** dans les commits, le code, la documentation
ou les tickets.

**`livraisons/` se range dès qu'on y touche.** Et `assets-ref/` n'entre jamais
dans git.

**Le français, sans accents dans le code** — commentaires compris. Les accents
sont réservés aux fichiers `.md` et aux textes affichés à l'écran.

---

## Recevoir un asset livré

Ils arrivent à des échelles, des orientations et des résolutions sans rapport
les uns avec les autres. **C'est normal et ça ne se corrige pas à la main** :
un modèle importé sans passer par la chaîne est une incohérence qui se
découvrira trois sessions plus tard, à l'écran.

```powershell
.\bg.ps1 integrer -Fichier livraisons/modeles/x.glb -Vers game/assets/... -Hauteur 1.78
```

La commande mesure, met à l'échelle, pose au sol, oriente, **relit le fichier
écrit**, et refuse d'écrire si le résultat ne correspond pas à la demande.

La charte graphique — budgets de triangles, tailles de texture, pivots — est
dans [docs/03-conventions-assets.md](docs/03-conventions-assets.md). Les deux
règles qu'on oublie : **128 px de texture par défaut** et **une seule texture
par objet**. Un modèle livré avec une texture 2048 est plus net que tout ce qui
l'entoure, et ça se voit plus qu'un modèle raté.

**Un modèle livré ne doit jamais figurer dans la table d'un générateur.** Le
Jesse de Guillaume a été écrasé par un `generer` lancé pour une autre raison.
Vérifier `gen_personnage.py`, `gen_objets.py`, `gen_lieux.py` avant d'intégrer.

**Le nom d'un maillage est une INSTRUCTION pour Godot, pas une étiquette.**
Appeler le col d'un vêtement `Col` a rendu le jeu injouable : Godot y a lu une
consigne de collision, a greffé un corps solide sur le torse de Walter, et il
s'est mis à se repousser lui-même — coincé au départ, à travers les murs, puis
hors de la carte. **Jamais `Col`, ni rien finissant par `-col`, `-colonly`,
`-convcol`.** Piège 34.

---

## Fabriquer un asset au lieu de l'attendre

Depuis le 08/08/2026, un asset peut être **généré** : Magnific pour les images,
les textures et la 3D, ElevenLabs pour les bruitages et la musique. La chaîne
complète est dans [docs/17-assets-ia.md](docs/17-assets-ia.md), **à relire avant
d'en produire un**. Les quatre choses à savoir sans ouvrir le document :

1. **Rien ne se génère sans passer par le manifeste.** `outils/assets-ia.json`
   porte le prompt, le moteur, les paramètres et l'empreinte de chaque fichier.
   Il est versionné ; les originaux, eux, vont dans `livraisons/ia/` qui est hors
   de git. **C'est le manifeste la source, pas le `.glb`.**
2. **Une référence de style par décor**, jamais par objet. Dix objets générés
   séparément sortent de dix univers différents, et ça se voit immédiatement.
3. **Aucun des deux outils ne sait rigger.** Walt, Jesse et Tuco portent un
   squelette et tout ce qui les anime en dépend : **ils ne se remplacent pas.**
   On leur donne une texture plus fine, c'est tout. Les personnages sans
   squelette se régénèrent librement.
4. **Magnific fait la voix et la musique, pas le bruitage.** `audio_tts` pour
   les répliques, `audio_music_generate` pour une nappe — le thème d'ouverture
   en vient. Pour un bruitage, c'est ElevenLabs.
5. **Les dialogues se jouent en anglais, sous-titrés français.** Dans
   `dialogues.json`, `vo` est ce qui se dit et `texte` ce qui s'affiche. Le nom
   du fichier son est l'empreinte de **`vo`** : il suit ce qui est enregistré,
   jamais ce qui est lu à l'écran. Les voix générées entrent par
   `outils/voix_ia.ps1`, le casting vit dans `donnees/casting.json`, et
   `.\bg.ps1 test -Suite dialogue` mesure qu'on les **entend** — pas qu'elles
   existent.

Le reste ne change pas : un asset généré entre par `.\bg.ps1 integrer` comme les
autres, il tient les budgets de la charte, et il se juge sur une capture.

---

## Tester

`.\bg.ps1 test -Suite <nom>` — la suite nommée, et rien d'autre. Le jeu est
petit, il n'y a pas grand-chose à casser, et le temps passé à tester n'est pas
du temps passé à livrer.

- **`-Modifies` n'est pas ciblé sur ce projet.** Dès qu'un fichier partagé
  bouge — c'est-à-dire presque toujours — il relance les 48 suites.
- **La suite complète est réservée aux grosses releases.** Pas à chaque bump.
- Si je ne sais pas quelle suite couvre un changement, je lis `couvre` dans
  `bg.ps1`.

**Une suite qui attend des images fait son travail dans `_initialize`.** Un
`_process` de `SceneTree` doit rendre un booléen ; dès qu'il contient un
`await`, c'est une coroutine qui remonte, et Godot la lit comme « arrête la
boucle ». La suite se termine **proprement**, au milieu de sa première mesure,
**avec un code de sortie 0** — donc annoncée verte. Payé deux fois le
27/08/2026, à une heure d'intervalle, sur deux fichiers neufs. Le symptôme :
un rapport qui s'interrompt au milieu d'une phrase alors que tout est vert.
Piège 68.

**Une seule instance de Godot à la fois sur ce dépôt.** Deux suites lancées en
parallèle — l'une au premier plan, l'autre en tâche de fond — réimportent les
mêmes ressources dans le même `.godot`, et l'une meurt : **code 255, aucun
message, un rapport tronqué**. Vingt minutes passées à chercher lequel de mes
changements avait cassé une suite qui repassait au vert toute seule. Piège 67.

**Mais `jouer` n'est pas une suite, et son code de sortie ne veut rien dire.**
Il appelle le Godot **sans console**, qui se relance détaché sous Windows :
l'appelant reçoit un **0 en deux secondes**, avec pour toute sortie l'en-tête de
Vulkan, pendant que la fenêtre s'ouvre. J'en ai conclu deux fois que le jeu
avait planté au démarrage. Devant un `0` immédiat sur une commande qui devrait
durer, **chercher le processus avant de conclure sur le programme** — et se
souvenir que le fichier de sortie continue de se remplir après. Piège 76.

**Et un `255` muet a un deuxième coupable : du code qui cherche dans l'arbre
pendant `_draw`.** Même symptôme exactement — tous les contrôles au vert, la
dernière ligne imprimée, puis plus rien. Un `_draw` dessine ce qui a déjà été
relevé dans `_process` ; il ne fait pas de `get_first_node_in_group`. Piège 66.

**Ce que j'affiche n'est PAS ce que la suite a dit.** Deux mécanismes mangent
la sortie, et ils ont coûté trois diagnostics perdus dans la nuit du
24/08/2026 :

- PowerShell 5.1 transforme chaque ligne d'**erreur** d'un exe en ErrorRecord.
  Dès la première, l'affichage se remplit de la trace de l'appelant et tout ce
  qui suit devient illisible — une suite qui imprime dix mesures après son
  premier échec n'en montre aucune ;
- et Godot ne vide pas toujours le tampon de la sortie standard avant
  `quit()` : un `print` placé juste après un `printerr` peut disparaître.

> **La sortie complète de chaque suite est écrite dans
> `.tmp/tests/<suite>.txt`**, les deux flux dans l'ordre. Son chemin s'affiche
> dès qu'une suite échoue. **C'est la première chose à lire** — avant de
> supposer quoi que ce soit sur la cause.

Corollaire pour qui écrit une suite : **un diagnostic long sort par
`printerr`.** Ce n'est pas une erreur, c'est le seul flux qui arrive à coup sûr.

---

## Ce que je dois refuser

**Ne pas toujours aller dans leur sens.** Une idée qui coûte trois sessions
pour un gain qu'on ne verra pas à l'écran doit être discutée avant d'être
faite, pas après. Ce qui mérite une objection :

- une fonctionnalité qui n'a pas d'image — si je ne sais pas quelle capture la
  montrerait, elle n'est probablement pas prête à être codée ;
- du code custom là où une donnée suffirait ;
- un ajout qui contredit le ton de la série — le jeu est lent, sale et
  provincial, pas nerveux et clinquant ;
- une demande formulée comme une solution alors que le problème n'est pas
  posé. Demander « lequel des deux problèmes tu veux régler » coûte une phrase.

**Et livrer quand même** si la réponse est « fais-le ». L'objection tient en
deux phrases, pas en trois paragraphes, et elle ne se répète pas.

**Ne pas créer de dépendance.** Quand j'écris du code non trivial, un
walkthrough court : ce que ça fait, où c'est, pourquoi comme ça.

---

## Le rituel de fin de session

1. `livraisons/` rangé, `.tmp/` vidé de ce qui n'est pas régénérable.
2. Un bump si quelque chose de jouable a changé, avec sa note de version — **et
   son tag poussé**. Onze versions ont été bumpées sans jamais être taguées :
   Guillaume a téléchargé pendant deux jours un jeu sans écran-titre ni
   sauvegarde, et trois de ses tickets 🔥 attendaient qu'il voie ce qui existait
   déjà. Un bump sans tag ne livre rien, et ça ne se voit pas du côté qui bumpe.
3. **Une entrée dans [docs/JOURNAL.md](docs/JOURNAL.md)** : début, fin, ce
   qu'on voulait, ce qu'on a livré, les surprises, et où on reprend. Les
   surprises sont le cœur — c'est ce qu'on relit dans trois semaines.
4. **Relire ce fichier et [docs/11-pieges.md](docs/11-pieges.md)** : est-ce
   qu'un piège nouveau est apparu ? une règle s'est-elle révélée fausse ? Un
   piège qui entre se range **dans une famille de l'index**, sinon il ne sera
   jamais retrouvé.
5. Le bilan : effort, apprentissages, ressenti.

## Les tickets

Trois familles d'étiquettes : **ce que c'est** (🔨 chantier, ✅ à faire,
🐛 bug, 💡 idée), **qui doit agir** (🤖 Claude, 🎨 Guillaume, 🎮 Benjamin), et
**quand** (🔥 maintenant, 🧊 plus tard).

Chaque ticket **commence par une ligne qui dit à qui il appartient**. Personne
ne doit avoir à lire un ticket en entier pour savoir s'il l'attend. Les titres
portent leurs accents ; la règle « pas d'accents » ne vaut que pour le code.

**L'étiquette d'acteur dit qui doit agir MAINTENANT, pas qui a ouvert le
ticket.** Un ticket fini côté code, qui n'attend plus qu'un modèle ou une
animation de Guillaume, passe 🎨 Guillaume — même si tout le travail écrit
dedans était le mien. Sinon la liste 🤖 se remplit de choses que je ne peux pas
faire, et personne ne sait plus ce qui bloque vraiment.

**Le titre suit une forme, et une seule** — décidé le 07/08/2026, après une
passe où vingt-deux titres sur vingt-quatre ont été refaits :

> `Domaine — ce qui existera quand ce sera fini`

Les domaines : **Économie, Ville, Intérieurs, Monde, Son, Personnages, Missions,
Famille, Réglage**. Le titre dit le **résultat**, jamais la raison — celle-ci
est dans le corps, c'est sa place. Ni question, ni jugement, ni formule : un
titre n'a pas à être joli, il a à être trouvable dans une liste de trente.

**Sauf pour un bug, qui dit le SYMPTÔME** : quand on cherche un bug, on cherche
ce qu'on a vu, pas ce qu'on obtiendra en le réparant.

Ce que la forme libre coûtait : des titres qui posaient une question déjà
tranchée depuis dix jours, d'autres qui argumentaient contre leur propre version
précédente, et aucun moyen de grouper la liste à l'œil.

**Le corps suit quatre temps, et je les tiens.** Les formulaires
(`.github/ISSUE_TEMPLATE/`) cadrent ce que Benjamin et Guillaume écrivent ;
ils ne s'appliquent pas quand j'ouvre un ticket en ligne de commande, donc
c'est ici que ma forme est écrite :

1. **À qui c'est**, en une ligne, avant tout le reste ;
2. **le constat, avec sa preuve** — un chiffre mesuré, une capture, un extrait
   de test. Jamais « il semble que » ;
3. **ce qu'on demande**, en cases à cocher ;
4. **comment on voit que c'est fait** — la question qui manque le plus souvent,
   et celle qui m'oblige à savoir ce que je cherche.

Un ticket qui ne dit pas comment on le vérifie se ferme sur une impression.

**Les tickets s'écrivent aux heures ouvrables.** Chaque création, chaque
commentaire, chaque fermeture envoie un mail à Guillaume. Dix tickets ouverts
d'affilée à deux heures du matin, c'est dix mails qu'il découvre au réveil — et
la prochaine fois il ne les ouvre plus. Le travail, lui, se fait quand on veut :
c'est la **notification** qui a un horaire, pas le code.

Vaut aussi pour les messages de commit : un `#NN` dans un message crée une
référence croisée dans le ticket, et donc une notification. La nuit, on décrit ce
qu'on a fait sans citer le numéro.

**Mais éditer le corps d'un ticket ne notifie personne** — seuls les
commentaires, les fermetures et les créations envoient un mail. Mettre un
tableau de bord à jour à trois heures du matin est donc gratuit, à condition de
le faire **dans le corps** et non en commentaire. C'est le geste par défaut pour
tout ce qui est un état plutôt qu'une nouvelle.

**Et un corps de ticket s'écrit avec `--body-file`, jamais autrement.**
`Set-Content` a mangé les sauts de ligne de #77 le 25/08 et l'a rendu illisible
le temps de le réécrire : le fichier se produit en UTF-8 avec des fins de ligne
explicites, puis `gh issue edit --body-file`, puis on **relit** ce qui est en
ligne.

Un piège qui n'est pas écrit sera repayé au prix fort. Les quatre plus chers de
ce projet ont tous été payés deux fois.
