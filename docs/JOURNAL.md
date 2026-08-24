# Journal

**Une entrée par session, avec son début et sa fin.** Chaque entrée dit quatre
choses et pas une de plus : ce qu'on voulait, ce qu'on a livré, ce qu'on a
appris, et où on reprend.

La ligne « surprise » est la plus utile des quatre : c'est celle qu'on relit
dans trois semaines, et c'est elle qui évite de repayer un piège.

Le détail technique vit dans les messages de commit ; ce qu'on peut essayer,
dans `NOTES-DE-VERSION.md` ; ce qui reste à faire, dans les tickets. Ici, on
raconte la session.

---
## Soirée du 24 août 2026 — le lot D, et deux étapes qui se mordaient la queue

**Début** : sur `v0.58.29`, trois lots terminés sur onze. **Fin** : sur
`v0.58.31`, le lot D bouclé sauf une animation.

### Ce qu'on voulait

Continuer le retour de Guillaume par ce qui reste le plus payant : le **lot D**,
la scène du fossé. Cinq points sur neuf n'étaient pas faits, et c'est la scène
la plus longue de la mission.

### Ce qu'on a livré

**Le suivi de mission a maigri de trois lignes.** Les corps sortent du déroulé —
c'est Jesse qui pousse à aller les voir, une phrase à la seconde où le masque
tombe. Le pantalon aussi, et il est passé de onze à vingt-six mètres : hors du
cercle qu'on parcourt en ramassant. Et « Écouter » n'est plus une action : la
conversation part toute seule au troisième objet, sans figer personne.

**Jesse répond selon le moment**, et il demande « vous avez bien tout pris ?
Genre, TOUT ? » — avec un choix, sauf si le pantalon est déjà sous le bras,
auquel cas il fait une remarque à la place.

**Et le camping-car brûle.** Cinq foyers qui blessent, qu'on contourne pour
ramasser, et qu'on n'éteindra jamais : Walter s'avance, recule de deux pas sans
quitter le feu des yeux, tousse, et le feu brûle pareil. Aucun texte ne dit que
c'est impossible — c'est la seule règle du lot, et c'est celle que tout dans le
projet poussait à trahir.

### Ce qu'on a appris

**Le plus grave ne se voyait pas à l'écran.** Rebrancher une étape sur « monter
au volant » a ouvert une course : mettre le contact au moment où l'étape
basculait faisait tomber l'événement du démarrage dans une étape qui ne
l'attendait pas. Le moteur tournait, la mission était morte, et l'objectif
affiché ne bougeait pas d'un pixel. **Un événement perdu ne revient jamais** —
et le remède n'était pas d'ordonner la course, c'était de supprimer l'étape qui
la créait. Piège 55.

**Trois séries de répliques se sont tues d'un coup, et le contrôle était vert.**
Il vérifiait que chaque temps fort a ses phrases : il partait des étapes vers le
fichier, donc une clé qui vise une étape disparue lui était invisible. **Les
deux sens sont deux contrôles**, et c'est celui qu'on n'écrit pas qui trouve les
choses mortes. Quinze lignes, et il aurait crié trois fois ce soir. Piège 56.

**Le placement des foyers s'est réglé au chiffre, pas à l'œil.** Le retour dit
« en essayant de ne pas marcher dans les flammes » : gêner, pas empêcher. À
vue, les cinq foyers semblaient parfaits ; trois mordaient dans la portée de
ramassage d'un objet — il fallait donc brûler pour tendre le bras. La suite
imprime chaque écart, et c'est elle qui a placé les trois derniers.

**Le rendu du feu a demandé trois passes, toutes jugées sur une capture.** La
première rendait un nuage de poussière dorée. Ce qui a fini par le régler n'est
aucune des choses évidentes : c'est **l'opacité montée bien au-dessus de 1**,
parce que le mélange est additif et que c'est l'empilement des bouffées qui
fabrique le cœur clair. Sans lui, tout le panache a la même valeur — donc pas
de cœur, donc un nuage.

**Et un `git stash pop` muet a failli coûter la soirée.** Sa sortie envoyée
dans `Out-Null`, son échec invisible, un dépôt annoncé propre juste après deux
heures de travail. Corollaire retenu : **après un stash pop, le dépôt doit être
SALE**. Piège 57.

### Fin de soirée — le lot E, et vingt secondes qui n'en faisaient que seize

**Fin réelle** : sur `v0.58.32`, les deux corps s'embarquent.

Le premier tour de clé ne démarre plus rien : le moteur tousse, Jesse attrape le
tableau de bord, Walter descend. Puis il faut **traîner** les deux morts jusqu'à
la portière — le premier geste du jeu qui se **tient** au lieu de se presser. La
touche reste enfoncée une vingtaine de secondes ; la lâcher repose le corps là
où il est.

**Le chiffre de Guillaume ne tenait pas, et seule la mesure l'a dit.** « La
tractation complète doit bien prendre au moins 20 secondes. » Le calcul de coin
de table en annonçait vingt et une ; la suite en a rendu **seize**. L'écart vient
d'un détail qui ne se voit qu'en jouant : le corps se traîne 1,15 m derrière
Walter et se dépose dès qu'*il* arrive — donc Walter s'arrêtait trois mètres
avant la portière, et ces trois mètres n'étaient dans aucune estimation.
Vitesse à 0,55 m/s, pause à 4 s, dépôt à 2 m : vingt-deux secondes.

> **Un chiffre demandé par Guillaume se mesure, sinon il se perd au premier
> réglage.** Celui-là tenait à lui seul le diagnostic central du retour — « la
> mission est trop rapide ».

**Le pilote de la suite qui joue a appris son troisième geste**, après le cadran
du démarreur et les trois secondes de roulage. Il appuyait soixante fois pendant
que le jeu lui disait, en toutes lettres, « Maintenir pour attraper les pieds ».
C'est **son propre message d'échec** qui a servi à le réparer — le format qui
imprime ce que le jeu propose a payé pour la troisième fois.

**Et une chose n'a pas été vérifiée, elle est écrite partout.** Jesse traînant
son corps n'a été vu sur **aucune capture** : trop rapide, ou hors champ à
chaque cadrage essayé. Le mécanisme est mesuré et vert ; l'image, non. C'est dit
dans les notes de version, dans le message de commit et ici — plutôt que
d'affirmer que la démonstration fonctionne parce qu'un test est vert.

### Nuit — le lot C, et deux faux verts dans la suite qui joue

**Fin réelle** : sur `v0.58.33`. Le jeu s'ouvre sur une voix.

On se réveille sous le masque, on n'y voit presque rien, et Jesse appelle :
« Par ici ! » puis « À droite ! » puis « L'AUTRE DROITE ! ». Trois jalons,
aucun marqueur sur la minimap, et le trajet ramène **face au camping-car** sans
qu'on l'ait vu venir.

**La géométrie s'est mesurée avant de se jouer.** Le signe du produit vectoriel
dit de quel côté part chaque virage : mon premier placement donnait un virage à
gauche là où Jesse dit droite, et le contrôle l'a dit avant qu'on lance le jeu.
Une consigne écrite d'un côté et un jalon posé de l'autre, c'est quelqu'un qui
tourne dans le noir en croyant s'être trompé — et il n'a aucun moyen de vérifier.

**Un seuil inventé contre une image, et c'est l'image qui a gagné.** J'avais
écrit « le dernier jalon à moins de seize mètres » ; le trajet en rendait
dix-huit et demi. La tentation était de déplacer un jalon. La capture a montré
la caisse occupant la moitié du cadre, flammes autour, Jesse debout à côté :
c'est le plan que Guillaume demande, et un seuil sorti de ma tête l'aurait
refusé.

**Et un bug qui n'arrivait qu'une fois sur deux.** Le décor du fossé est
instancié à l'exécution ; le scénario branche donc ses signaux en retard. Le
guidage est le premier mécanisme du jeu dont on a besoin **dès la première
étape** : selon la vitesse de la machine, le joueur finissait son trajet avant
que quiconque n'écoute. Le signal partait dans le vide. Le trajet fini est
devenu un **état** qu'on constate, comme « volant ».

### Les deux faux verts, et ce qu'ils cachaient

**Le premier**, sur l'étape guidée : elle n'a pas de marqueur — c'est le sujet —
donc son champ `ou` est vide, exactement comme celui de la dernière étape de la
mission. Le pilote la comptait « jouée, aucun lieu » et passait. Il annonçait
**vingt-cinq étapes jouées sur une mission qui en a vingt et une**, et se
déclarait vert. Le compte était là, sous les yeux, à chaque lancement.

**Le second**, plus grave : il bouclait sans le voir quand la partie
**recommence**. Il sait maintenant qu'un index qui recule est une mort, et il le
dit avec ce qu'il reste de vie.

Et c'est ce second contrôle qui a révélé un défaut réel, laissé rouge parce
qu'il n'est pas de ce lot : **la mission monte jusqu'à `sortir_du_fosse` puis
repart à zéro**, avec Walter à cent points de vie. Ce n'est donc pas le feu.
C'est à regarder en premier la prochaine fois.

### Où on reprend

`v0.58.36`. **Sept lots terminés (A, B, C, D, E, H, I)** sur onze, et G a moitié, et la mission se traverse sans recommencer.

### Et le rouge a été traité dans la foulée — c'était le feu

**`v0.58.34`.** La mission ne repart plus au début.

**Ma première conclusion était fausse, et publiée.** Le test disait « Walter est
mort en chemin. Sa vie : 100 », j'en ai tiré « ce n'est donc pas une blessure »
et je l'ai écrit dans le ticket. La reprise appelle `ressusciter()`, qui remet la
vie à cent : **je mesurais un homme qu'on venait de remettre debout.** Un `print`
dans `perdre()` a répondu en une ligne — *« Vous êtes mort », pv = 0*.

Le chiffre était exact ; c'est son sens qui était faux. C'est pour ça que les
deux formulations déjà présentes dans `CLAUDE.md` n'ont pas suffi à m'arrêter.

**Deux foyers bloquaient des passages obligés.** L'un à trente-six centimètres
de la ligne qu'on parcourt en tirant un cadavre — trois mètres de flammes à
0,55 m/s, quatre-vingt-quatorze points sur cent. L'autre à quatre-vingts
centimètres de la tôle, du côté par lequel on revient : le jeu ne force aucune
porte, on monte par où l'on arrive.

**Et rien ne le voyait**, parce que la vérification mesurait le dégagement
*autour* des endroits, jamais *entre* eux. Le contrôle ajouté a rendu **−0,3 m**
sur le côté conducteur au premier lancement : la porte par laquelle on monte
était dans le feu.

**La règle enfreinte était écrite trente lignes plus haut, dans le même
fichier** : « faire passer ce trajet dans les flammes serait ajouter une punition
à une corvée ». Je l'avais écrite en posant les foyers, et je l'ai enfreinte au
lot suivant.

**Trois positions calculées de tête, trois fois faux.** Les coordonnées de la
scène sont relatives au fond du fossé, la portière suit un camping-car incliné,
et `pose_au_sol` déplace tout à la verticale. Le contrôle imprime maintenant les
positions du monde réel — c'est ce qui a donné la direction.

### Enfin le lot I — la mission 1 a une fin

**`v0.58.35`.** Sept lots sur onze.

Le jeu s'ouvrait sur deux cadavres qu'on ne peut pas identifier — c'est voulu,
le joueur découvre avec Walter — et il se terminait sans jamais y revenir. On
cuisinait, on regardait la couleur, on rentrait, et les deux morts du début
restaient un décor.

Jesse nomme **Emilio** et parle de son cousin. Le nom de Krazy-8 n'est pas
prononcé : Jesse ne l'a jamais rencontré, et un nom entendu pour la première
fois ne fait aucun lien. Ce qui fera le lien, c'est le **visage**, à la mission
suivante.

**On rentre en voiture**, plus à pied. Le passage l'exige, et un champ d'étape
amène la voiture à la clairière — hors de la zone de retour, sinon la mission se
termine à la seconde où l'on s'assoit dedans.

**Et deux des quatre points du ticket étaient déjà faits depuis la 0.58.26.** Le
double camping-car et la relance du dialogue des pompiers. Mon tableau de bord
les comptait « rien de fait » : je les ai **vérifiés** avant d'écrire quoi que
ce soit, plutôt que de recoder par-dessus quelque chose qui marchait.

> Une demi-heure de lecture a remplacé une soirée de travail. C'est la
> quatrième fois que ce projet paie l'inverse — le piège 41 dit exactement ça,
> et il commence par « avant d'estimer un chantier, chercher ce qui existe ».

### Puis le lot G, moitie faite — la clairiere

**`v0.58.36`.** Les trois defauts que Guillaume avait releves d'un coup apres le
carton « Trois semaines plus tot » : le camping-car a cheval sur un caillou,
Jesse dans la pierre, et le vehicule traversable.

**Un metre quarante d'ecart entre les quatre roues**, mesure. Il pose maintenant
a plat sur du sable, cinq metres plus loin, et le massif le cache toujours de la
route — c'est la seule chose que Guillaume demandait de *garder*.

**Le detour vaut d'etre ecrit.** J'ai d'abord recule le camping-car de cinq
metres en pensant faire mieux : le denivele est passe a **1,73 m**. Pire
qu'avant, en croyant corriger. Le desert est genere, ses rochers ne se lisent
dans aucun fichier, et trois placements de tete se sont deja trompes sur ce
projet.

La suite balaie donc une grille de quinze metres et imprime les cinq endroits
les plus plats. J'ai pris le plus **proche** des bons, pas le meilleur absolu :
celui-la etait a vingt metres et aurait deplace tout le decor.

**Et le controle s'est piege lui-meme dans le meme commit.** Des la coque posee,
son rayon vertical a touche le TOIT du vehicule et annonce « sol a 2,90 m,
caisse a 0,00 » — un camping-car enterre de trois metres dans un sol
parfaitement plat. Les deux chiffres etaient exacts et le second mesurait le
premier. C'est mot pour mot ce que `pose_au_sol` avait appris sur le semis de
debris du fosse, reapparu a la seconde ou sa cause est revenue.

> **Un rayon qui cherche le sol doit exclure ce qu'on est en train de poser.**
> Ca semble evident ecrit comme ca ; ca ne l'etait ni la premiere fois, ni
> celle-ci.

**Ce qui reste du lot G** : la cinematique du reservoir perce et le camion de
pompiers. Sur l'hesitation de Guillaume — continuer la cinematique ou rendre la
main entre les deux moities — je prendrai la premiere, et je le lui ai dit.
**Par quoi commencer la prochaine fois :**

- **Le reste du rouge de `parcours`** : le camping-car s'arrête à 19,6 m de la
  sortie (c'était 3 939 m avant). C'est le lot G, connu depuis le 17/08 — mais
  il n'a jamais été aussi près.
- **G — la fuite** : la cinématique du réservoir percé, le camion de pompiers.
- **J — l'habillage** : l'intro avant l'écran-titre, l'icône de Walter.

**Trois dettes, toutes du côté du son et de l'image** : les voix du guidage ne
sont pas doublées (or la scène repose sur le fait d'entendre quelqu'un), Jesse
traînant son corps n'a jamais été vu à l'image, et l'animation de toux devant
les flammes n'existe pas.

**Un défaut d'affichage repéré au passage** : le bandeau de dialogue passe
**sous** le bloc argent/famille/rue du HUD, en haut à gauche — la phrase de
Jesse était illisible sur la capture du masque qui tombe. C'est le lot J.

**Deux rouges connus, et aucun des deux n'est de ce soir** : `parcours` bute
toujours sur `sortir_du_fosse` (lot G), et `sens de conduite` échoue — vérifié
en remettant le dépôt à l'état d'avant la session, il échouait déjà.

**Ce qui attend Guillaume**, à ouvrir aux heures ouvrables : l'**animation de
toux** (« se couvrir la bouche de son coude »), que le lot D réclame et que
Walter n'a pas.

### Le bilan de la soirée

**Deux versions, cinq points de retour, et trois pièges écrits.** Les trois ont
la même forme : quelque chose qui ne se voit pas. Un événement qui tombe dans
le vide, une phrase qui ne sortira plus, une commande qui a raté en silence.
Aucun des trois n'aurait été trouvé en jouant.

**Ce qui a marché** : écrire la suite du feu AVANT de trouver les foyers beaux.
Elle a corrigé trois placements que l'œil validait.

---
## Nuit du 23 au 24 août 2026 — Guillaume joue pendant qu'on livre

**Début** : sur `v0.58.27`, session close et bilan écrit. **Fin** : sur
`v0.58.29`, rouverte par un message à 23 h 24.

> « J'arrive pas à déclencher les pompiers. Je vais sur la piste mais ça
> déclenche rien. »

### Le premier réflexe était le bon, et la première hypothèse était fausse

J'avais touché cette zone deux heures plus tôt — une borne haute sur le
passage, une arrivée à pied. Premier suspect : moi.

Ce n'était pas ça, et il a fallu trois mesures pour le voir.

**L'hypothèse la plus plausible portait sur la vitesse.** La sortie demande de
rouler trois secondes au-dessus de huit km/h, et le camping-car remonte la
pente « en peinant » — s'il passait sous le seuil, le compteur retomberait à
zéro en permanence. Mesure : **74,2 km/h**, 857 images sur 901 au-dessus du
seuil. L'hypothèse est morte, et c'est tout ce qu'on lui demandait.

**Écrire cette mesure a coûté deux erreurs, toutes deux dans le test.** La
première version allait droit à l'étape et poussait les gaz : zéro km/h en
quinze secondes. Le coupable était le contrôle — l'épave est **gelée** tant que
le moteur n'a pas pris, ce que le jeu fait exprès. La seconde exigeait que la
sortie s'ouvre, alors que le compteur n'avance que pour le véhicule **conduit**
par le contrôleur : elle poussait la caisse sans conducteur et accusait le jeu
de ce qu'elle ne faisait pas. C'est écrit dans le fichier plutôt que laissé en
rouge.

**Et `test -Suite roulage` était verte sans rien pouvoir voir** : elle appelle
`Passage.rouler()` en direct, donc elle vérifie le compteur et jamais le
franchissement. Piège 19, encore.

### Ce que Guillaume a réellement vécu, et pourquoi c'est notre faute

Ça marchait. Il ne roulait simplement pas trois secondes **d'affilée**, et rien
ne le lui disait.

Le défaut est le même qu'avant, déplacé d'un cran. Sa demande d'origine était
« on ne devrait pas sortir pour déclencher la suite, on ne comprend pas » — on
a remplacé une **ligne invisible** par un **compteur invisible**. Le code
l'assumait même par écrit : *« rien ne s'affiche, parce qu'il n'y a rien à
corriger »*.

> Il y avait quelque chose à corriger : **le joueur ne savait pas qu'il était
> en train de réussir.**

Pas de compte à rebours à l'écran — Guillaume en veut moins, du texte de
mission. C'est Jesse qui réagit quand on commence à rouler, et quand on
s'arrête avant le bout.

### Et il ne parlait pas du tout du reste de la scène

En allant écrire ces deux répliques, le vrai manque est apparu : Jesse se
taisait pendant **toute** la séquence du fossé. On ramasse ses affaires à côté
d'un homme qui vient d'en voir mourir deux, et il ne dit rien.

Guillaume le demande explicitement — « il faut que Jesse fasse davantage de
dialogues, qui ne figent ni le jeu ni le joueur » — et **le mécanisme existait
déjà**. Les marmonnements affichent des phrases par étape, sans rien figer, et
cette mission les avait coupées avec cette note :

> « Le silence n'est pas la bonne réponse définitive. Ces trajets ont besoin de
> pensées, et elles restent à écrire. »

Dix-neuf répliques sur huit temps forts. Le ton est l'exact opposé de celui de
Walter : lui rationalise et ne dit jamais ce qu'il ressent ; Jesse dit tout,
tout de suite, et se répète quand il a peur. Et l'intervalle est devenu une
**donnée de mission** — quarante-deux secondes pour un homme au volant qui
rumine, treize au fond d'un fossé avec une sirène qui approche.

### Où on reprend

`v0.58.29`. **Trois lots terminés (A, B, H)**, six entamés, deux à peine —
et le lot D vient de démarrer par ses dialogues.

**Ce qui reste ouvert, par ordre de ce qu'il apporte :**

- **D — le fossé** : les flammes qu'on ne peut jamais éteindre (le gros
  morceau, il demande un décor), le pantalon vraiment facultatif, « écouter »
  qui devient automatique au troisième objet, la sirène qui monte par paliers.
- **E — traîner les corps** : rien de commencé, et c'est vingt secondes de jeu
  par corps. L'animation d'essoufflement est livrée.
- **C — le guidage vocal de Jesse** sous le masque, et le trajet à l'aveugle.

**Une dette de méthode, et elle est ancienne** : `test -Suite parcours` est
rouge sur `sortir_du_fosse` depuis le 17/08, avec une note qui dit « c'est sans
doute le pilote ». Guillaume a buté exactement là. On sait maintenant que le
jeu répond — 74 km/h, la zone détecte, les signaux partent — donc c'était
probablement bien le pilote. **Mais on ne le réaffirmera pas sans l'avoir
mesuré**, parce qu'on l'a déjà affirmé une fois et qu'un joueur est venu dire
le contraire.

### Le bilan de la nuit

**Deux versions pour un bug qui n'en était pas un.** Le temps n'a pas été perdu
— ce que le joueur a vécu était réel, et la réponse « ça marchait, il fallait
insister » aurait laissé le prochain joueur buter au même endroit.

**Ce qui a marché** : ne pas croire le premier suspect, même quand c'est soi.
J'avais touché cette zone deux heures plus tôt et j'étais prêt à me
désigner ; la mesure a dit non.

**Ce qui revient pour la troisième fois de la journée** : un test vert qui ne
surveille rien, et un test rouge qui accuse le jeu de sa propre faute. Les deux
se soignent avec le même geste — demander ce que le test ferait si le fil était
coupé, et ce qu'il fait que le joueur ne fait pas.

---


## 23 août 2026 — trois parades pour un défaut qu'aucune n'attaquait

**Début** : sur `v0.58.13`, avec un retour de Guillaume de cinquante-cinq
demandes dans `livraisons/`. **Fin** : sur `v0.58.14`, lot des contrôles livré.

### Ce qu'on voulait

Guillaume a joué la mission 1 de bout en bout et écrit un document de neuf
pages. Le premier travail était de le **lire en entier et de le ranger** :
il est transcrit mot pour mot dans
[docs/21](21-mission1-retours-guillaume.md), sa charte graphique promue en
[docs/20](20-charte-graphique.md), et ses modèles rangés sous
`livraisons/modeles/`.

Le retour se découpe en onze lots. Benjamin a choisi de commencer par les
**contrôles** : c'est court, ça se voit tout de suite, et juger les dix autres
lots avec une caméra qui se conduit mal n'a pas de sens.

### Ce qu'on a livré

**Les quatre touches sont relatives à la caméra**, et le personnage se tourne
vers la direction qu'il prend. **La caméra ne se recentre plus** : elle n'obéit
qu'à la souris. **La verticale de la souris**, inversée depuis le premier jour,
est remise à l'endroit. **F devient E** partout, et les invites lisent la
touche au lieu de la réciter. **Un menu Commandes** dans la pause, qui
consulte et remappe les treize commandes du jeu, refuse les doublons et se
souvient. **Le retour du désert** dépose à l'entrée de la ville.

### Ce qu'on a appris

**Trois parades avaient été payées pour un défaut qu'aucune n'attaquait.** La
caméra se replaçait dans le dos du personnage pendant qu'il lisait sa direction
sur elle : les deux se poursuivaient. On a répondu en bloquant la caméra, puis
en figeant le repère à l'appui, puis — la plus chère — en retirant au
personnage le droit de se déplacer latéralement. Le jeu s'est retrouvé avec les
commandes d'un char, et **le commentaire du code disait que c'était un choix
d'époque**. Il ne l'était pas : c'était une rustine, promue en intention à
force d'être expliquée. Supprimer le recentrage a coûté huit lignes.

**Ce que ça dit pour la suite** : quand une contrainte du jeu s'explique par
trois lignes d'histoire technique dans un commentaire, ce n'est pas une
décision de conception. C'est une cicatrice, et la cause vit ailleurs.

**Un test peut certifier exactement le contraire de ce qu'on veut.**
`test_camera.gd` vérifiait que gauche et droite pivotent sans déplacer et que
la caméra finit dans le dos du personnage. Il était vert, complet, argumenté —
et il gardait les deux symptômes comme s'ils étaient le contrat. Il a été
réécrit sur ce que le joueur attend, et sa version d'avant l'aurait refusé.

**Une invite écrite en dur ne rougit jamais.** Onze « F   Descendre » dans cinq
fichiers : le jour où la touche change, le texte reste parfaitement lisible et
ment. Elles passent maintenant par `Touches`, qui lit l'InputMap — c'était de
toute façon la seule façon de tenir un menu de remappage.

**Et la verticale de la souris était inversée depuis toujours** sans que
personne l'écrive. Ce n'est pas une régression : c'est le sens qui a été choisi
au premier jour, jamais mesuré, et le test qui la couvrait vérifiait que
l'angle *changeait*.

### Reprise à 6 h — le corps géant, diagnostiqué mais pas réparé

Le premier point du lot K (« le cadavre est énorme ») a été **cherché,
mesuré, prouvé, et laissé ouvert** — c'est délibéré et voilà pourquoi.

La mesure sur les os ne voit rien : 1,72 m debout, 1,72 m couché. Une suite
`mort` a été écrite pour ça et elle est verte. **C'est l'image qui montre le
défaut**, et le scénario `corps_effondre` la rejoue à la demande.

La cause est dans la chaîne d'import : `importer_perso.py` ramène le
personnage à 1,78 m en posant l'échelle sur l'armature **sans l'appliquer aux
données**, le `Skeleton3D` hérite d'une échelle de 0,01, et le moteur physique
la normalise dès que le ragdoll démarre — le maillage repart alors à sa taille
native, en centimètres lus comme des mètres. Piège 48.

**Réparer, c'est réimporter Walter, Jesse et Tuco**, puis revérifier tout ce
qui se mesure sur eux : foulée, hauteur des yeux, points d'accroche de
l'équipement, poses. Un chantier d'assets, à faire d'un bloc et à tête
reposée — pas à six heures du matin après une nuit blanche, où on laisserait
trois personnages dans trois états différents.

Ce qui reste du lot K pour la prochaine fois : le game over qui doit montrer
**celui qui meurt** au ralenti, et les répliques coupées qui doivent
s'enchaîner sans attendre le joueur.

### Reprise à 12 h 30 — le corps réparé, et ce que le chantier a révélé

Le bug est corrigé pour Walter, et il aura fallu défaire trois pièges
empilés dans la chaîne Blender : `transform_apply` ne met à l'échelle ni la
pose courante ni les 144 courbes d'animation ; l'ordre entre application et
calage au sol décide du résultat (inversé, on obtient un personnage enterré
jusqu'aux épaules) ; et Blender 4.4 a supprimé `action.fcurves`, ce qui
arrêtait le script net sous 5.2.

**Ce que le chantier a révélé est plus important que le bug lui-même.** En
voulant traiter Jesse et Tuco de la même façon, on a découvert qu'on ne
pouvait pas : leur recette d'import n'est écrite nulle part. Réimporté depuis
sa source brute, Jesse sortait à 6,8 Mo au lieu de 765 Ko, sans les clips que
le jeu lui demande. Le réimport de Walter avait d'ailleurs le même défaut —
741 Ko devenus 3,85 Mo — jusqu'à ce que l'étape d'allègement soit rejouée.

La recette complète de Walter est maintenant écrite dans
[docs/03](03-conventions-assets.md), avec un tableau qui dit noir sur blanc ce
qu'on sait et ce qu'on ne sait pas. Et `test -Suite mort` nomme à chaque
passage les personnages qui portent encore une échelle — un défaut connu qui
ne s'imprime plus est un défaut oublié.

**Une mesure s'est trompée en cours de route**, et elle mérite d'être notée :
un premier inventaire des échelles annonçait Jesse et Tuco à 1,0000. Le
garde-fou écrit ensuite, lui, les a dénoncés à 0,0100. La différence tenait au
contexte de lecture — instance isolée contre monde chargé. **Devant deux
mesures qui se contredisent, c'est celle qui tourne dans les conditions du jeu
qui a raison.**

### Après-midi — le lot K, fini aux deux tiers

**La parole coupée** (K3) : une réplique de `dialogues.json` peut porter
`coupe`, et la suivante ne l'attend plus. Le cas existait déjà dans la donnée
sans que rien ne le joue — Jesse s'emballe, et le champ `jeu` de la réplique de
Walter dit `cutting in, firm` depuis toujours. L'invite disparaît sur ces
répliques : promettre une commande qui n'aura pas le temps de servir, c'est
faire croire au joueur que c'est son appui qui a fait avancer.

**La mort de quelqu'un d'autre** (K2) : `perdre()` appelait
`effondrer_le_joueur()` quel que soit le mort. Une ligne, et on lisait « Jesse
est mort » sur le corps de Walter. La caméra prend maintenant la victime pour
sujet, le ralenti démarre avant le carton, elle tombe une seconde plus tard, et
l'écran de fin attend qu'elle soit au sol.

**Deux choses apprises, et la seconde n'est pas dans le code** :

Le minutage d'une scène ne s'écrit pas en constantes quand une partie avance au
ralenti et l'autre en temps réel. Le premier essai laissait 0,9 s entre la
chute et le carton — sauf que la chute suit le temps du jeu, donc quatre fois
plus lentement : « GAME OVER » s'écrivait par-dessus quelqu'un encore debout.
**Aucune mesure ne l'a dit ; la capture, si.** Le délai se calcule maintenant à
partir du ralenti en cours, et le test exige l'ORDRE — tombée d'abord, carton
ensuite — pas seulement les deux faits.

**Et le PNJ ne prend pas de ragdoll, délibérément** : les squelettes de Jesse et
Tuco portent encore l'échelle de 0,01, un corps physique y partirait en
morceaux. Il bascule d'un bloc — ce que faisaient les jeux dont celui-ci prend
l'apparence. Le jour où ils seront réimportés, la méthode pourra appeler
Ragdoll comme le joueur.

**Ce qui n'est pas satisfaisant et qui est assumé** : dans une petite pièce, la
caméra de poursuite se colle au corps qui tombe et finit contre un mur. Un
plongeant a été ajouté, il ne suffit pas — le vrai plan demande une caméra de
cinématique. La mécanique est juste, le cadrage non.

### Fin d'après-midi — la zone de mission (lot B)

Livrée en 0.58.17, et c'est la première mécanique de ce retour qui servira à
**toutes** les missions suivantes plutôt qu'à celle-ci seule.

Deux niveaux, comme Guillaume les a décrits, et le premier est le plus
important : **c'est un personnage qui rappelle**, pas une règle qui s'affiche.
Jesse dit qu'on n'a pas fini, rien ne se fige, et le joueur revient sans avoir
vu de barrière. Le second niveau — voile gris, titre, dix secondes — n'arrive
qu'après.

**Ce qui a demandé de réfléchir : où la zone s'arrête.** Une zone déclarée pour
la mission entière rendait la cuisine du flashback immédiatement hors limite,
et l'étape « rejoindre la piste » un échec annoncé. Elle porte donc deux bornes
d'étapes — `depuis` et `jusqu_a` — le même vocabulaire qu'`ancrage.gd`, plutôt
que de recopier la même zone sur dix étapes ou de la couper une par une.

**Deux erreurs commises, l'une trouvée par un test, l'autre par une image** :

`get_tree().current_scene` est **nul** quand une suite instancie le monde à la
main. Le jeu marchait, la vérification plantait — et sans elle, le défaut
serait resté jusqu'à ce qu'une deuxième scène existe. On cherche maintenant
depuis la racine de l'arbre, avec la scène courante comme préférence.

Et le décompte s'affichait **en plein sur le personnage**, au milieu du cadre.
Aucun test ne pouvait le dire : le nombre était juste, le texte lisible. La
capture l'a montré en une seconde, le bloc est remonté au cinquième de l'écran
— ce qui compte ici, c'est de voir où l'on va pour pouvoir revenir.

### Soirée — l'habillage (lot J, en partie)

« Améliorer GRANDEMENT l'écran titre qui est tout moche. Changer notamment la
police. » La demande nommait la police ; **ce n'était pas le problème**. Cet
écran était pauvre parce qu'il ne montrait rien : deux lignes sur du noir.
Télécharger une fonte n'y aurait rien changé — et aurait posé une question de
licence pour un gain nul.

Il montre maintenant le pays du jeu, dessiné aux mêmes formes que le décor :
ciel en bandes, deux plans de mesas, sable, route qui file vers l'horizon.
Toutes les teintes viennent de [docs/20](20-charte-graphique.md), désaturées
comme la charte l'exige.

**Le titre emprunte le principe, jamais le logo** — la charte est explicite
là-dessus, et c'est une question de droit autant que de goût : deux tuiles de
tableau périodique dessinées ici, numéro atomique et nom compris, dans le vert
de chimie qu'elle réserve au titre.

**Deux corrections sont venues de la capture, pas du code** : « Nouvelle
partie » tombait sur la ligne d'horizon — clair sur clair, puis clair sur la
route sombre — et le sous-titre gris se perdait dans le ciel gris-bleu. Un
cadre pour le menu (celui du menu pause, pas un nouveau) et du jaune pâle pour
le sous-titre.

**L'interface en jeu, ensuite.** Les trois ressources étaient de la même
couleur : trois nombres olive alignés se lisent comme un bloc, et il fallait
lire les mots pour savoir lequel était lequel — en conduisant. Chacune a
maintenant sa teinte selon ce qu'elle signifie dans la charte : jaune pour
l'argent, bleu ardoise pour la famille, rouge sourd pour la rue. Et le bloc a
un fond, parce que sur le sable ou un ciel de midi il devenait devinable.

**Ce qui reste du lot J**, et qui n'est pas commencé : l'icône de Walter (une
texture générée, donc un passage par `gen_textures.py`), les écrans de texte,
et l'intro qui doit passer avant l'écran-titre. Plus une question posée à
Guillaume dans le ticket : quels dialogues de Skyler et Jesse retirer
exactement — je ne supprime pas des voix enregistrées sur une supposition.

**Le portrait, enfin.** Il faisait 32 pixels, et une note du générateur
expliquait que c'était « sa taille d'affichage, l'agrandir puis le réduire ne
ferait que le rendre flou ». **La note était fausse** — c'est la troisième de
la journée : l'interface est agrandie 2,8 fois avant l'écran, donc ces
32 pixels s'étalaient sur 90. Il en fait 64.

Et la même erreur a failli être recommise dans l'autre sens : le HUD dessinait
la texture à sa taille *native*, donc le portrait a doublé à l'écran et
recouvert le bandeau d'objectif. Vu à la capture. La taille d'affichage est
maintenant une constante du HUD, indépendante de la définition du fichier.

**Deux faux pas, et le second est le vrai.** `gen_textures.py --sortie
game/assets/images` a écrit **cent sept** textures dans un dossier qui en
contient deux — non suivies par git, `git clean` a suffi.

Mais il a aussi basculé `monde.json` de « nuit » à « jour », parce que le
générateur écrit le moment qu'on lui passe. Le dépôt s'est retrouvé avec un
monde déclaré en plein jour et les textures de nuit installées : **exactement
l'incohérence que l'en-tête de ce fichier décrit** — « un ciel de jour sur des
fenêtres de nuit ». Repéré en relisant le diff du commit, donc après l'avoir
fait.

> **Un générateur lancé pour UNE texture écrit tout ce qu'il sait écrire.**
> Lire `git status` avant de commiter ne suffit pas : il faut savoir ce que
> l'outil touche EN PLUS de ce qu'on lui a demandé.

**Et le carton des sauts de temps** — celui du lot G, mais c'est un écran de
texte, donc il appartenait aussi à celui-ci. « Trois semaines plus tôt »
s'affichait dans le bandeau de tuto : un saut de trois semaines annoncé de la
même façon qu'une consigne de touche.

C'est un `Control` dessiné de plus, comme la pause et la zone : le noir
s'installe, la phrase s'y pose, le noir se lève. Il se déclare sur le
**passage**, pas dans le code — n'importe quel saut de lieu ou de temps pourra
en porter un.

**La moitié du test porte sur la sortie**, pas sur l'entrée : un carton qui
s'installe et ne se lève pas laisse un écran noir dont plus rien ne fait
sortir, et ça ressemble à un jeu qui a planté alors que tout tourne. C'est la
panne la plus coûteuse qu'un écran plein puisse produire.

### Fin de journée — le démarrage devient un geste (lot F, en partie)

« Ne PAS écrire "le moteur tousse" par pitié, il faut le vivre, pas le lire. »
Le démarrage était un compteur d'essais : deux ou trois appuis, un bandeau qui
annonçait le résultat, et ça partait. Le joueur assistait à un tirage au sort.

C'est maintenant le cadran que Guillaume décrit — anneau, zone tirée au sort,
aiguille à vitesse constante, trois validations, sens inversé à chaque fois.
Deux touches : **le contact qu'on tient** et **l'allumage qu'on presse**. Tenir
plutôt que basculer est ce qui permet de renoncer : on lâche, le cadran se
ferme, rien n'est cassé.

**Et ça a levé le rouge qui traînait depuis le 17/08.** `test -Suite parcours`
butait sur `moteur_lance` — soixante appuis sans rien franchir — et la note
disait « je n'ai pas tranché si c'est le jeu ou le pilote ». **C'était le
jeu** : le point demandait des appuis qu'il ne comptait pas comme le pilote les
donnait. Il est remplacé, le pilote joue le mini-jeu comme un humain le
jouerait — il lit où est l'aiguille, où est la zone, et presse quand elles se
croisent — et deux étapes de plus sont tombées.

**Elle bute maintenant sur `sortir_du_fosse`** : au volant, à 28 m de la
sortie, zéro appui en quarante secondes. C'est le battement A8, celui que
Guillaume veut refaire (« c'est assez confusant ici »). Un rouge plus profond
vaut mieux qu'un rouge ancien.

> **Une note qui dit « je ne sais pas si c'est le jeu ou l'outil » vaut mieux
> qu'une conclusion fausse — mais elle se paie tant qu'on ne tranche pas.**
> Celle-ci a tenu six jours, et la réponse est tombée en refaisant l'étape pour
> une tout autre raison.

**Et la sortie du fossé se déclenche en roulant** (lot G, premier point). La
zone couvre la piste au lieu de la barrer, et c'est le temps de conduite qui
ouvre — trois secondes au-dessus de huit km/h.

La vérification qui va avec compare **deux fichiers que rien ne reliait** : la
largeur de la zone, dans la scène, et le temps demandé, dans le passage. Une
bande de trois mètres traversée à trente km/h dure un tiers de seconde — trois
secondes de conduite dedans y auraient été impossibles, et la sortie ne se
serait **jamais** ouverte. C'est le genre de contradiction qu'on ne voit pas en
lisant chaque fichier séparément.

**Ce qui reste ouvert, et je n'ai pas la réponse** : `test -Suite parcours`
bute toujours au même endroit, à 28,4 m de la sortie, sans que la distance
bouge. Or une mesure directe montre que le camping-car **remonte** — 5,4 m en
dix secondes, en gagnant de l'altitude. Le véhicule roule donc, mais le pilote
ne le fait pas avancer vers la cible. Le défaut est entre les deux, et il reste
à trouver : c'est le jeu qui bloque, ou la façon dont le pilote conduit une
masse de onze tonnes dans une pente. Mesuré, pas conclu.

**Et le camping-car sort enfin du fossé.** Trois mesures pour trouver : il
avance quand on pousse (donc pas bloqué), sa vitesse décroît en montant (donc
pas la force), et sa masse en jeu vaut **1 350 kg** alors que sa scène déclare
onze tonnes depuis toujours — écrasées au chargement par les réglages de la
berline. 900 N pour 1 350 kg donnent 1,33 m/s² ; la pente en oppose 2,3. Piège
50.

**La correction évidente était fausse** : lui rendre ses onze tonnes l'a rendu
complètement immobile, sa suspension étant réglée pour une berline. On a
corrigé ce qui bloquait — la poussée — et laissé la masse tranquille.

**Où en est la suite qui joue** : elle allait à 28 m de la sortie sans bouger,
elle va maintenant jusqu'à la sortie, la dépasse et tourne autour à 9,8 m. Le
**jeu** fait ce qu'il doit : le camping-car remonte, et la sortie s'ouvre en
roulant. C'est le pilote automatique qui ne sait pas encore enchaîner « roule
droit et continue » — un problème d'outil, plus de jeu.

### Soirée — la cuisine devient jouable (lot H)

Le plus gros lot du retour, et celui que Guillaume nomme lui-même : « ça
constituera une des mécaniques principales du jeu. Je te laisse travailler
sérieusement là-dessus. »

Les trois étapes de cuisine étaient **trois fois le même geste** — un appui sur
E, puis un texte qui annonçait le résultat. Ce sont maintenant trois mini-jeux
qui ne se ressemblent pas : **verser** demande de la précision et une dose,
**la plaque** demande de tenir une chaleur qui répond en retard, **la fournée**
demande le bon ingrédient au bon moment. Le détail et la réserve pour les labos
suivants sont dans [docs/22](22-mini-jeux-cuisine.md).

**Un arbitrage a été posé avant d'écrire une ligne**, parce que le retour se
contredit lui-même : Guillaume veut qu'on comprenne que *Jesse cuisine et
Walter conseille*, et il veut des mini-jeux joués par le joueur — qui **est**
Walter. Trois lectures étaient possibles ; celle retenue est « Jesse tient, la
caméra le cadre, Walter guide ». Le geste reste au joueur, l'image dit à qui
est l'atelier.

### Ce que la soirée a appris, et rien n'était dans le code

**Une mécanique peut se corriger toute seule, et le mini-jeu n'existe plus.** À
la première mesure, verser à fond ne ratait **jamais** : la fiole se vide, donc
le jet raccourcit, donc il finissait par retomber dans le bécher avant la fin
de la tolérance. La dérive qui devait faire la difficulté annulait l'échec. La
portée a un plancher, et il se **calcule** — il ne se choisit pas à l'œil.

**Un test peut être vert le fil coupé, et c'était le cas trois fois ce soir.**
Le contrôle sur Jesse a été écrit trois fois :

- le premier visait le nœud `PaillasseCuisine`, qui n'est pas le meuble mais le
  porteur des points, posé un mètre **en arrière** de lui. Il criait sur un
  placement juste : le test avait tort, pas le jeu ;
- le second amenait Walter à côté de lui et exigeait que son cap ne bouge pas.
  Vert — et **toujours vert après avoir coupé le fil**. Un PNJ ne pivote que si
  quelqu'un lui a passé le joueur à observer, et seuls les habitants de maisons
  le reçoivent. Jesse ne pivotait jamais : il n'y avait rien à empêcher, et le
  champ écrit pour ça a été **retiré** plutôt que gardé au cas où ;
- le troisième mesure sur le pivot `Corps` et non sur le nœud, parce que les
  modèles riggés sont suspendus à un demi-tour — l'avant du nœud est l'exact
  opposé de l'avant qu'on voit. Il rougit quand on rend à Jesse son ancienne
  orientation, **vérifié en le faisant**.

> Un garde-fou qui ne garde rien est pire que pas de garde-fou : on cesse de
> regarder l'endroit qu'il prétend surveiller.

**Le bleu n'était jamais sorti de la cuisine, et le test ne pouvait pas le
voir.** `poser()` attend un palier de 1 à 5 ; `cuisson.gd` lui passait un index
de 0 à 4 depuis le premier jour. Tout était décalé d'un cran, et une cuisson
parfaite donnait « translucide ». Le contrôle qui l'accompagne imprimait
pourtant une échelle de cinq paliers tous justes : **il recopiait la formule au
lieu de l'appeler**. Il posait donc une valeur et en vérifiait une autre. La
formule est devenue publique, le contrôle pose puis **relit le nom**.

**Et deux défauts ne se sont montrés qu'à la capture** : un encart opaque planté
en plein sur Walter, puis un virage de couleur qui traversait un kaki terne à
mi-cuisson — sur le seul indicateur d'avancement du mini-jeu. La teinte tourne
maintenant au lieu de se mélanger.

**Un vrai bug, trouvé par le test et pas par le jeu** : la verseuse ne reposait
jamais la fiole après une réussite. Elle continuait de dire qu'elle tenait la
souris, le contrôleur continuait de la lui donner, et la caméra ne répondait
plus tant qu'on tenait la touche.

### Soirée, seconde partie — le double camping-car avait trois causes

Le pire bug du retour, et aucune des trois causes n'était celle qu'on croyait.

**Un — le véhicule vous suivait dans le passé.** La crête du flashback se
franchit au volant : c'est sa condition, trois secondes de roulage. Or le
contrôleur téléporte le véhicule avec le joueur. Le camping-car accidenté de la
séquence A arrivait donc dans la clairière et s'y garait à côté de celui du
flashback. Un passage peut désormais exiger qu'on arrive **à pied** ; le
véhicule reste où il était, sans qu'on le fasse disparaître.

**Deux — la crête restait active après avoir été franchie.** Masquer un décor
ne désactive pas ses zones : Godot ne coupe que le rendu, et la boucle des
passages ne regarde pas la visibilité. Repasser dessus rejouait le fondu, la
téléportation, le carton et le dialogue des pompiers — la phrase exacte de
Guillaume. Un passage a maintenant sa borne haute, le pendant de `jusqu_a_etape`
sur les décors.

**Trois — quatre-vingt-seize mètres, pas neuf cents.** Trois commentaires du
dépôt affirmaient que la clairière est à neuf cents mètres du fossé. Personne
ne l'avait mesuré : c'était la distance ville-désert, recopiée au mauvais
endroit. À pied on n'y retourne pas par hasard ; en camping-car, c'est quelques
secondes — et on y arrivait justement au volant.

Les trois se combinaient, et chacune seule n'aurait rien donné de spectaculaire.

### Et je me suis fait prendre par un piège écrit dans ce dépôt

Le premier diagnostic annonçait **113,6 mètres** d'écart entre la sortie du
camping-car et la porte par laquelle on entre. Chiffre mesuré, correction
faite, trois commentaires et un message de commit rédigés autour.

**Il était faux.** `PorteCampingCar` existe deux fois — dans la clairière et
dans la mission de rodage, cent mètres plus loin — et `find_child` rend le
premier. Je comparais la sortie d'une mission avec la porte d'une autre.
L'écart réel : trois mètres. Il n'y avait pas de bug là.

Et la correction visait ce même nom : **elle produisait le défaut qu'elle
prétendait réparer**, et le contrôle l'aurait validée puisqu'il mesurait de
travers.

Ce qui a sauvé la mise est une mesure voisine, faite pour autre chose : un
chiffre en contredisait un autre. C'est le piège 54, et `test_mission.gd`
prévient depuis des semaines qu'« il y a deux Sortie et plusieurs Porte dans le
jeu ».

> **Un diagnostic chiffré inspire une confiance qu'un raisonnement n'obtient
> jamais.** C'est le `print()` des deux positions brutes — pas seulement de
> l'écart — qui a fini par trahir l'erreur.

Les nœuds visés par leur nom depuis une autre scène portent maintenant des noms
uniques, et le contrôle vérifie cette unicité **avant** de mesurer.

### Ce qui reste du ticket, et qui n'est pas un bug

La fin de mission — « à quoi va servir ce que l'on vient de cuisiner ? » — est
une question d'écriture, pas de code. Elle n'a pas été traitée.

### Nuit — l'ouverture au masque (lot C, en partie)

Cinq des sept points du lot, et le plus gros n'est pas fait.

**La mission passe de jour, et c'est un arbitrage contre le script.** Elle
s'ouvrait à 21 h 30 parce que le script demande « désert du Nouveau-Mexique,
NUIT, ciel dégagé » ; le retour dit « la mission doit **impérativement** se
dérouler la journée ». La règle du projet tranche — le retour a été écrit en
jouant, le script en imaginant. On perd les phares dans la poussière, les
lumières de la ville au loin et le brouillard de nuit qui s'appliquait tout
seul ; on gagne la **surprise** du camping-car quand on retire le masque, qui
est tout l'enjeu du lot. Une surprise dans le noir n'en est pas une.

**Le filtre est beaucoup plus fermé**, et le garde-fou a changé avec lui. Il
disait « les deux corps doivent rester visibles, sinon la fermeture est trop
serrée ». Le retour demande l'inverse — « beaucoup plus difficile d'y voir quoi
que ce soit » — et sort les corps du suivi de mission. Ce qui doit rester
possible est de **marcher**, pas de reconnaître un lieu.

**Le « low shutter » n'est pas simulé optiquement, et c'est assumé.** Une vraie
rémanence demanderait de lire le tampon d'écran, relevé à **+4,3 ms par image**
sur ce projet — la mesure est dans `liquide.gdshader`, et elle a déjà fait
retirer une réfraction. L'effet est donc obtenu dans ce qu'il *fait au
spectateur* : on perd l'image par vagues, et les vagues ne tombent jamais en
rythme.

**Et le plan large a disparu.** Il montrait la cuvette, la traînée, la fumée et
les phares : tout ce qu'on découvre une minute plus tard. La caméra est à dix
centimètres du sable. Deux détails valaient d'être vus — ces plans **forçaient
l'heure à 21 h 30**, ce qui aurait ramené la nuit par-dessus une mission passée
de jour.

### Le piège 54, deux heures après l'avoir écrit

Le calque du filtre s'appelait `FiltreEcran` — comme le **système qui le
crée**, dans `monde.tscn`.

Le contrôle écrit pour vérifier que le filtre se *lève* cherchait par nom,
trouvait le système — qui ne disparaît jamais — et ne pouvait pas passer. Son
jumeau, celui qui vérifie que le filtre est *posé*, était **vert pour la même
mauvaise raison**.

> Un vert et un rouge, tous deux faux, sur la même ligne de recherche.

Cette fois l'homonyme n'était pas dans une scène : il était **créé par le
code**. On ne le voit donc dans aucun arbre — il n'existe qu'en jeu. La règle
qui en sort : *un nœud créé par du code porte un nom qui dit ce qu'il est, pas
celui de qui l'a créé.*

### Où on reprend

**Sept lots avancés : A, B et H livrés, C aux cinq septièmes, K aux deux
tiers, J à un point près, F commencé, et le bug du lot I réparé.** Trois lots
n'ont pas été touchés — D, E, G.

Du lot I, il reste la fin de mission, qui est une question d'écriture. Du lot
C, il reste **le morceau principal** : Jesse qui guide à la voix dans un
acouphène — « avancer, à droite, l'autre droite » — et le trajet à l'aveugle
qui doit déposer le joueur face au camping-car sans qu'il l'ait vu venir. Ce
n'est pas un réglage : c'est un système de guidage, des répliques à écrire et
à faire doubler, et un parcours à régler à l'écran.

Le lot H est **fini** : trois mini-jeux qui ne se ressemblent pas, chacun
ratable, l'échec rattrapable, et la pureté décidée par le dernier. Ce qui
manque autour de lui n'est pas du code et c'est écrit dans
[docs/22](22-mini-jeux-cuisine.md) : **les bruitages** — il n'existe aucun son
de liquide, de gaz ni de verre, les trois empruntent des bruitages d'autre
chose — et **une posture de travail pour Jesse**, qui demande une animation
donc un passage par le rig.

Ce qui reste de K est le CADRAGE du plan de mort, pas sa mécanique. Et il
rejoint ce qui manque au lot H : dans les deux cas le vrai plan demande une
**caméra de cinématique**, qui n'existe pas. C'est le même chantier, et il vaut
d'être fait une fois pour les deux.

Du lot J, il reste l'intro qui doit passer avant l'écran-titre : un chantier
structurel — il faut charger le monde avant le titre.

**Trois dettes ouvertes, toutes tracées** :

- **Jesse et Tuco** portent encore une échelle sur leur armature. Leur recette
  d'import est à reconstituer avant de pouvoir les réparer — le tableau de
  [docs/03](03-conventions-assets.md) attend leurs lignes.
- **`test -Suite parcours`** est rouge sur `sortir_du_fosse`. Le jeu fait ce
  qu'il doit ; c'est le pilote automatique qui ne sait pas enchaîner « roule
  droit et continue ». Un problème d'outil, plus de jeu.
- ~~`test -Suite souris`~~ **réglé.** C'était le test : son libellé confondait
  « lever la caméra » et « regarder vers le haut », qui sont opposés.
  `test_camera.gd`, réécrit au lot A, exigeait déjà le bon sens et était vert.
  Deux contrôles se contredisaient sur le même sujet, et c'est le rouge qui
  avait tort.

Le suivi est en tickets : un tableau de bord pour les onze lots, et un ticket
par lot.


### Le bilan de la journée

**Trois versions livrées et taguées** — 0.58.25, 0.58.26, 0.58.27 — pour
quatorze commits. Un lot fini (H), un lot aux cinq septièmes (C), un bug
majeur réparé (I), et un rouge de longue date levé.

**Ce qui a le mieux marché** : refuser de conclure. Cinq défauts sur les huit
trouvés ce soir l'ont été par une mesure qui contredisait une autre mesure —
pas par une relecture, pas par une intuition. Le versement qui ne pouvait pas
rater, le bleu qui n'était jamais sorti de la cuisine, les 113,6 mètres qui
n'existaient pas, le calque qui ne disparaissait pas, le test de la souris qui
gardait l'ancienne verticale : tous auraient survécu à une lecture attentive.

**Ce qui a le plus coûté** : la confiance dans un nombre. « 113,6 mètres »
avait produit un diagnostic, une correction, trois commentaires et un message
de commit avant qu'on découvre que la mesure portait sur le mauvais nœud. Et
la correction reproduisait le défaut. La leçon est montée dans le CLAUDE.md :
**un contrôle imprime ce qu'il compare, pas seulement son verdict**.

**Ce qui revient et qu'il faut surveiller** : trois fois ce soir, un contrôle
était vert sans rien surveiller. Le champ écrit pour empêcher Jesse de pivoter,
le test du filtre posé, le test du filtre levé. Le geste qui tranche —
**couper le fil et exiger le rouge** — a servi quatre fois et a payé à chaque
fois. Il coûte une minute.

**Ce qui n'a pas été fait, et c'est délibéré** : le guidage vocal de Jesse. Ce
n'est pas un réglage mais un système, des répliques à faire doubler et un
parcours à régler à l'écran. Le commencer à vingt-deux heures aurait produit
une moitié de chantier sur le lot qui décide du ton de toute la mission.

**Trois tickets attendent Guillaume** : les bruitages de cuisine (#90), une
animation de Jesse aux fioles (#91), et sa réponse sur l'heure de la mission —
le passage au jour est un arbitrage contre son propre script, et il vaut mieux
qu'il le sache avant de rejouer.

---

## Nuit du 16 au 17 août 2026 — arrêter de corriger, commencer à outiller

**Début** : sur `v0.58.12`, tout au vert. **Fin** : sur `v0.58.13`.

### Ce qu'on voulait

Pas une fonctionnalité. Benjamin a dit être « partiellement satisfait » de la
mission 1 : trop d'allers-retours sur des bugs, trop d'approximations, et des
objets « moyens ». La demande était de **relire le script en entier** et de
proposer une façon de travailler qui coûte moins cher.

### Ce qu'on a livré

**Un audit du script contre le jeu.** Les dix-sept battements existent, mais
**trois choses que le script demande explicitement n'ont jamais été codées** : la
cuisson jouable de B6 — alors que le mini-jeu existe et qu'il est même désigné
nommément —, la facture d'échec arbitrée en #67, et les deux tenues de Walter.
Aucune n'est un oubli d'écriture : les trois sont en fin de ligne de tableau ou
dans le bloc d'arbitrage de l'en-tête, c'est-à-dire aux deux endroits qu'on lit
en diagonale.

**Les quatre objets du fossé, générés.** Le sac, le bidon, la verrerie, le
pantalon — mesurés, intégrés par la chaîne, réglés à la capture, inscrits au
manifeste. Un scénario de contrôle par objet.

**Une suite qui joue au lieu de mesurer.** `test_parcours.gd` traverse la mission
en marchant et en appuyant sur F, sans jamais se téléporter ni appeler
`aller_a`. Elle est **rouge** et on la laisse rouge.

**Une passe sur les tickets.** Trois étiquettes réalignées ; huit commentaires
écrits et **non postés** — il était minuit passé, et chaque commentaire envoie
un mail à Guillaume.

### Les surprises

**Deux des quatre objets à ramasser n'étaient pas des objets.** « Un bidon
renversé » était le meuble à deux fûts *debout* du laboratoire, couché de force
par une rotation de la scène. « Un éclat de verrerie cassée » était la verrerie
*intacte* de la paillasse. Personne ne l'avait vu parce que personne ne les avait
regardés de près : de loin, dans le sable, deux volumes sombres font l'affaire.

**Le modèle n'est jamais le problème, l'image l'est.** Le pantalon a demandé
trois générations et c'est le cadrage qui décidait à chaque fois. Le plus
instructif : photographié **à plat, vu du dessus**, il ressort en fuseau vertical
de 1,10 m — le générateur suppose toujours qu'on lui montre la face d'un objet
debout. Piège 45.

**Un nom de lieu unique dans sa scène ne l'est pas dans le jeu.**
`PorteCampingCar` existe trois fois ; le marqueur du battement A6 désignait celui
de la mission de rodage, à neuf cents mètres. Invisible depuis toujours parce que
rien n'était bloqué — on retourne au camping-car d'instinct quand on connaît la
scène. Il fallait ne PAS la connaître, c'est-à-dire être le joueur pour qui elle
est écrite. Piège 43.

**La suite qui devait attraper les faux verts en a produit un immédiatement.**
Premier lancement : « OK, 0 étape jouée ». Elle rechargeait la sauvegarde de la
machine, donc une mission déjà finie. Un test qui dépend de l'état du poste ne
mesure pas le jeu.

**Et elle m'a fait chercher un appel téléphonique fantôme pendant vingt
minutes.** Elle annonçait « le jeu ne propose rien » à chaque échec, quelle
qu'en soit la cause : elle lisait `bandeau()`, le message de *refus*, au lieu de
l'invite. Le piège 18 — vérifier l'instrument avant de corriger ce qu'il dénonce
— repayé au prix fort.

**Deux verdicts différents sur le même dépôt à trois minutes d'écart.** En
headless, le delta suit la charge de la machine, donc la physique aussi. Une
suite qui *joue* a besoin d'un pas de temps fixe. Piège 44.

### Où on reprend

**Le parcours bute sur `moteur_lance`** et la cause n'est pas tranchée — jeu ou
pilote. C'est une mesure qui manque, pas une hypothèse.

**Deux des trois outils validés ne sont pas commencés** : la planche des
dix-sept battements, et la vérification de conformité du JSON au script.

**Les huit commentaires de tickets attendent les heures ouvrables**, avec le
ticket à créer sur les trois battements manquants.

**Début** : sur `v0.57.0`. **Fin** : sur `v0.58.12`, taguée et poussée.
**Vingt-deux versions**, dont dix-neuf nées d'un défaut vu en jouant.

### Ce qui était demandé

Traiter tout le script de Guillaume, puis — après un premier passage de test —
corriger ce que Benjamin y a trouvé. La consigne s'est durcie en cours de route :
*« Tu es en train de tout mélanger, c'est pas propre comme tu travailles. »*

### Ce qui a été livré

La mission 1 existe en entier. Les dix-sept battements du script sont là, et les
trois écarts qui restaient — la reprise du versement en B3, l'entrée en
cinématique en B1, les bâches aux fenêtres — ont été fermés en fin de session.

Deux systèmes ont été construits au passage, tous deux pilotés par les données de
la mission et jamais par un nom d'étape : **les filtres d'écran** et **la
surbrillance**. Le jeu a aussi gagné son **premier vrai choix** (B5 n'en était
pas un : les deux répliques s'enchaînaient), la **conduite du camping-car**, et
la possibilité d'avoir **plus d'un véhicule**.

### Les surprises

**Ce que les suites ne voient pas.** Dix-neuf défauts sur vingt-deux ont été
trouvés en jouant, aucun par une suite — et les suites étaient vertes à chaque
fois. Elles mesurent qu'une chose existe, jamais qu'elle est atteignable,
visible, audible ou compréhensible. Le pantalon était un modèle juste posé sur la
tranche ; l'ouverture cadrait la ville ; la sortie de zone tombait à vingt-et-un
mètres de la piste. Tout était « présent ».

**Le pire défaut de la soirée était un cercle.** On ne pouvait pas monter dans le
camping-car parce que le geste de volant était cherché autour du véhicule
*courant*, resté à mille deux cents mètres — et le véhicule courant ne changeait
qu'en montant. Chaque morceau était correct pris à part. Rien, dans aucun
fichier, ne pouvait le signaler.

**Le HUD : deux impasses avant une ligne.** L'interface est agrandie 2,8× quand la
3D ne l'est que d'1,5 — elle était donc deux fois plus grossière que le jeu
qu'elle recouvre, et l'argument écrit en tête du fichier depuis toujours (« le
grain PS2 ») était faux. Deux approches ont été tentées et annulées, chacune
demandant de réécrire 289 valeurs. La solution tenait dans un réglage de projet :
des glyphes en champ de distance signée. **Avant de déplacer trois cents valeurs,
chercher si le moteur sait déjà faire.**

**Les deux « gros chantiers » étaient déjà écrits** — piège 41. L'intérieur du
camping-car existait, posé au large du monde et même pas masqué : il attendait
une porte. La conduite ne demandait qu'un groupe et une ligne.

**Une courbe juste peut ne rien produire** — piège 42. Les niveaux de la sirène
montaient correctement et donnaient −51 dB au premier palier, c'est-à-dire le
silence.

### La leçon de méthode, et c'est la plus chère

**Le script de Guillaume contenait les réponses, et je ne l'ai pas relu.** Le
démarrage du camping-car a été codé comme un geste ordinaire alors qu'A7
s'appelle *« poste de conduite »* ; la sortie de zone a été posée sans repère
alors qu'A8 demande *« un panneau à moitié enseveli »*. Deux allers-retours de
test pour des informations écrites depuis le début, au seul endroit où elles
existaient.

La règle est maintenant dans `CLAUDE.md` : **le script se relit avant de coder le
battement, et si la réponse n'y est pas, on la pose au lieu de trancher.**

### Où on reprend

Une traversée complète, au volant, en écoutant. Trois choses n'ont jamais été
vérifiées autrement que par capture : la sortie du camping-car hors de la cuvette
(24 % de pente, onze tonnes), le déclenchement de la crête en roulant, et les
quatre sons générés que personne n'a entendus.

---

## Session du 16 août 2026 — la mission 1 devient le jeu que Guillaume a écrit

**Début** : sur `v0.57.0`, la mission jouable de bout en bout mais dépouillée.
**Fin** : sur `v0.58.1`, taguée et publiée. Douze versions dans la soirée.

### Ce qui était demandé

Traiter **tout** ce que Guillaume a mis dans son script de mission 1, au plus
près de ce qu'il a écrit, et le plus proprement possible. En cours de route,
Benjamin a précisé le cadre : *« je ne sais même pas ce que Guillaume a écrit,
je veux que ce soit toi qui me dises quoi faire et quoi tester »*, puis
*« avance un max de manière 100 % autonome »*.

### Ce qui a été livré

Les dix-sept battements du script existent maintenant tous, sauf deux détails
notés plus bas.

**Séquence A** — le plan d'ouverture sur le fossé avec sa nappe (A1) ; le filtre
du masque à gaz et la respiration amplifiée (A2) ; la surbrillance des trois
preuves (A5) ; **les sirènes** qui montent sur huit battements puis se révèlent
être des pompiers (A4→A9) ; le moteur qui tousse deux à trois fois (A7) ; et
**le camping-car conduisible** (A8), qui était un décor depuis la naissance du
projet.

**Séquence B** — la cuisine se joue **dans** le camping-car (B1), et le
micro-choix de Jesse en est enfin un (B5) : le jeu n'avait aucun système de
choix, les deux répliques s'enchaînaient et Walter refusait toujours.

Au passage : les débris du crash, le mot de la fin de Tuco qui ne se déclenche
plus sur la mauvaise mission, et deux systèmes nouveaux — filtres d'écran et
surbrillance — pilotés par les données de la mission, jamais par un nom d'étape.

### Les surprises

**Les deux « gros chantiers » étaient déjà écrits.** L'intérieur du camping-car
existait depuis la mission de rodage, posé au large du monde, même pas masqué :
il attendait une porte. Et la conduite ne demandait qu'un groupe et une ligne,
parce que la caméra savait déjà changer de cible et que le moteur audio vivait
déjà sur son véhicule. Les deux excuses écrites dans le code — *« pas
d'intérieur à lui »*, *« on ne le conduit pas »* — étaient fausses toutes les
deux. **Piège 41**, et c'est le plus cher de la soirée : on ne mesure jamais le
temps passé à ne pas faire une chose qu'on croyait impossible.

**Une courbe juste peut ne rien produire.** Les niveaux de la sirène montaient
correctement de 0,18 à 1,00 ; convertis en décibels par une droite, le premier
palier valait −51 dB, c'est-à-dire le silence. Les vérifications lisaient les
valeurs écrites et avaient raison d'être vertes — le défaut était dans la
traduction. **Piège 42.**

**Le troisième fil de la mission de rodage.** Après les tueurs de Tuco et son
décompte, c'est son mot de la fin qui s'est invité dans « Deux corps ». Toujours
la même cause : des branchements écrits quand il n'existait qu'une mission. Un
contrôle refuse désormais qu'un nom d'étape serve dans deux missions.

**Six réglages faux, tous rattrapés par une capture** : le filtre en jumelles de
dessin animé, puis lavant la nuit en gris ; les débris sur le toit du
camping-car, puis en confettis, puis invisibles. Aucun ne se voyait dans le code,
tous sautaient aux yeux sur une image — et deux fois, une capture faite pour
juger un modèle a trouvé un défaut d'interaction sans rapport.

### Ce qui reste

**Les sons sont provisoires et personne ne les a entendus.** Les deux sirènes, la
nappe et la respiration ont été générées et vérifiées sur spectrogramme : ça
prouve qu'elles existent et qu'elles diffèrent, pas qu'elles sonnent juste. Le
ticket #71 devient « remplacer » et non « fabriquer » — si Guillaume livre les
siennes, deux fichiers changent et rien d'autre.

**Rien n'a été joué à la manette depuis 0.57.4.** Huit versions attendent un
passage de test : la conduite du camping-car surtout, qui est neuve et qui doit
sortir d'une cuvette à 24 % de pente.

### Où on reprend

Une traversée complète de la mission, du réveil masqué au retour en plein jour,
en écoutant. Puis les tickets de Guillaume aux heures ouvrables.

---

## Session du 8 août 2026 — le rendu laisse enfin passer le détail

**Début** : sur `v0.50.0`. **Fin** : sur `v0.51.0`, taguée et publiée.

### Ce qui était demandé

Pousser les graphismes — lumières, fluides, détails, textures — avec de vrais
modèles 3D haute définition, en restant dans l'esprit PS2 voire PS3. Et se doter
d'une chaîne de production d'assets par IA, Magnific en tête, pour alimenter tout
ça.

Curseur choisi : **fond PS3, sortie PS2**. On monte la géométrie, les textures et
l'éclairage ; on garde le SubViewport agrandi comme signature.

### Ce qui a été livré

Le socle de rendu, en entier : rendu à **960×720**, post-traitement allumé
(filmique, halo, occlusion de contact), **huit lampadaires sur 526 qui projettent**,
la lune qui porte ses ombres, les phares, le brouillard volumétrique. Plus la
cohérence des textures — l'Aztek passe de 10,1 Mo à 0,59 — et les décors de la
mission 1 qui montent de 32 px à 256, dont quatre textures générées par Magnific.

Trois outils neufs : `magnific.ps1`, `lire_glb.py`, `alleger_textures.py`.

### Les surprises, et elles sont nombreuses

**1. La 3D de Magnific n'est pas dans son API.** Douze chemins sondés, tous en
404, et le `llms.txt` de leur documentation n'en mentionne aucun. Elle n'existe
que dans le MCP — qui refuse la clé d'API : 401 en `x-magnific-api-key`, en
`Bearer` et sans en-tête. Les textures se produisent donc en ligne de commande,
mais les modèles demandent une session OAuth. **La moitié de ce qui était prévu
est bloquée par une porte différente de celle qu'on avait ouverte.**

**2. `generer` a détruit la ville, sans une seule erreur.** 519 m et 526
lampadaires sont devenus 137 m et 32, parce que `bg.ps1` a `-Blocs 2` par défaut
et que la ville du dépôt n'a jamais été générée comme ça. Le seul symptôme est
arrivé après, et de biais : un ancrage introuvable. Sauvé par `git checkout`, et
écrit en **piège 23**. Le vrai nombre de blocs n'est écrit nulle part — c'est ce
qu'il faut retrouver en premier la prochaine fois.

**3. Le jeu mélangeait du 2048 px et du 32 px.** L'Aztek et le chapeau
embarquaient des cartes de 2048 — 27 Mo à eux quatre avec les personnages —
pendant que l'intérieur du QG était texturé en 32. La charte prévenait mot pour
mot ; rien ne l'appliquait, parce que `--texture-max` valait 0 par défaut,
c'est-à-dire « ne touche à rien ». C'est maintenant 256.

**4. Un défaut qui détruit est pire qu'une erreur.** C'est le lien entre les deux
surprises précédentes, et la leçon de la session : `-Blocs 2` et `--texture-max 0`
sont tous les deux des valeurs par défaut qui font silencieusement le contraire
de ce qu'on veut.

**5. `use_nodes` ne servait plus à rien, sauf à casser la chaîne.** Onze
occurrences, un `DeprecationWarning` sur la sortie d'erreur, et `generer` qui
s'arrête. Mesuré : Blender 5.2 crée déjà le `node_tree` et son BSDF. La ligne ne
faisait plus que se plaindre. **Avant de contourner une dépréciation, vérifier si
la ligne fait encore quelque chose.**

**6. Une erreur de shader ne fait pas de bruit.** `INSTANCE_CUSTOM` n'existe que
dans `vertex()` ; le lire dans `fragment()` écrit « Unknown identifier » sur la
sortie d'erreur, et le jeu se charge quand même. Sans `bg.ps1` qui transforme le
moindre stderr en échec, ça passait inaperçu.

**7. Le coût de tout ça est nul.** 0,6 ms par image avant, 0,7 après — pour 3,5
fois plus de pixels, dix sources qui projettent et trois effets d'écran. Le jeu
n'était pas limité par les pixels, il ne l'est toujours pas. **Le budget qu'on
croyait dépenser n'a jamais existé**, et c'est ce qui autorise la suite.

**8. J'ai repayé un piège que je connaissais.** Un `Set-Content` PowerShell sur un
fichier accentué, et les tirets cadratins sont devenus du mojibake. Le piège est
écrit depuis des semaines. La parade : éditer les fichiers avec l'outil d'édition,
jamais avec PowerShell.

---

## Seconde partie — le MCP branché, et quatre instruments qui mentaient

Le MCP Magnific autorisé, la 3D s'est débloquée. Et **chaque objet produit a fait
tomber un bug** — pas dans le modèle, dans la chaîne qui le mesure.

### Ce qui a été livré

Le labo est meublé : **quatre montages de distillation** (ballon, liquide ambré,
pince, statif, condenseur — 3 990 triangles, 48 cm), **un fût et un jerrycan** au
sol, et **du verre** sur les quatorze cylindres du générateur, qui étaient des
blocs blancs opaques.

Coût : **1 660 crédits sur 20 000** pour toute la session — cinq textures, deux
images de référence, deux modèles. Un modèle revient à 655 crédits tout compris.

### Les surprises, et c'est une série

**9. L'échelle était écrasée, pas multipliée.** `obj.scale = (facteur,) * 3`
remplaçait celle que le modèle portait déjà. Invisible depuis toujours — les
modèles livrés à la main arrivent à l'échelle 1 — et fatal au premier modèle
généré, que Tripo livre à 0,4008 : demandé à 0,48 m, il sortait à 1,198.

**10. L'instrument que je venais d'écrire a désigné le mauvais coupable.**
`lire_glb` lisait les min/max des accesseurs sans les transformations de nœuds.
Il annonçait 0,998 m pour un objet de 0,400, et j'ai « corrigé » une chaîne qui
n'avait rien. **Piège 18, avec un instrument de dix minutes d'âge.**

**11. Un modèle bon peut avoir l'air raté.** Le premier montage sortait blanc et
sans détail. J'ai cherché dans le matériau, dans l'émission, dans la texture —
qui contenait bien son ambre. Il était **caché derrière les cylindres du
générateur**, à neuf centimètres près. Déplacé sur la bande avant, il se lit d'un
coup.

**12. `diag` mesurait un endroit différent à chaque appel.** Deux relevés
consécutifs : 0,7 ms et 5,0 ms, 125 et 906 appels de rendu, sans qu'une ligne ait
bougé. `monde.tscn` reprend la sauvegarde, et chaque capture joue puis sauvegarde.
J'en avais conclu qu'un shader coûtait quatre millisecondes — mesuré des deux
côtés, **il ne coûte rien**.

Et la conséquence la plus gênante : **la note de version publiée annonçait un
chiffre faux.** « 0,6 ms avant, 0,7 après » — deux mesures réelles, prises à deux
endroits différents. La conclusion tenait, les chiffres non. Corrigée : au même
point, effets coupés 3,0 ms contre 2,8 pour la 0.51.0 complète.

**13. Le verre transparent ne se génère pas en 3D.** Tripo le rend opaque. Le
ballon ne marche que parce que son liquide lui donne une couleur ; un bécher vide
serait un bloc blanc. C'est au shader de le faire, et pour zéro crédit.

**14. Une image de référence vaut UN objet.** J'en ai mis deux — le fût et le
jerrycan — et Tripo en a fait un bloc unique, impossible à séparer ou répartir.

### Le fil qui relie tout ça

**Quatre défauts sur cinq n'étaient pas dans le jeu, mais dans ce qui le mesure.**
Un outil qui annonce un nombre juste et écrit un fichier faux, un autre qui lit le
bon fichier avec la mauvaise méthode, un troisième qui mesure un endroit au
hasard. Le projet avait déjà écrit la règle — *vérifier l'instrument avant de
corriger ce qu'il dénonce* — et elle a été repayée trois fois dans la même
journée.

Ce qui les a tous attrapés : **relire ce qu'on vient d'écrire**. Le garde-fou de
hauteur dans `integrer`, `verifs/ou_est.gd` qui imprime l'emprise réelle en
coordonnées monde, le point de mesure fixe dans `diag`. Aucun n'existait le matin.

---

## Troisième partie — la minimap, et ce qui manquait n'était pas le dessin

Le ticket **#58** demandait « une minimap et qu'on puisse voir où aller ». Livré
en **0.51.2**, taguée et publiée.

Un disque en bas à droite, le joueur au centre, **les rues tracées par les
lampadaires** — ils les bordent, donc les semer sur le disque dessine le réseau
sans avoir à produire ni resynchroniser une carte. Le plan tourne avec la caméra.
L'objectif est un point jaune qui **se colle au bord en pointe** quand il est hors
de portée : le désert est à neuf cents mètres, trente fois hors du disque, et un
marqueur qui disparaît ne sert qu'à l'endroit où on n'en a plus besoin. Aucun
chiffre nulle part.

### Ce qui a vraiment coûté

**Pas le dessin — la donnée.** Une étape dit ce qui la **valide** : un dialogue,
une zone, un objet ramassé. Aucun de ces évènements ne porte de position, et
`dialogue:mission_jesse_maison` n'a pas à savoir où habite Jesse. Chaque étape a
donc un champ `ou`, **écrit à la main plutôt que déduit** : une table de
correspondance évènement-vers-nœud cachée dans un script serait exactement ce que
`mission1.json` existe pour éviter.

**15. Le symptôme d'une cible fausse est une absence.** Une cible mal nommée ne
casse rien : pas de marqueur — soit exactement ce que fait une étape sans cible.
Deux causes, un seul symptôme, et le symptôme est que rien ne s'affiche. D'où
`test_boussole`, qui vérifie que les quinze étapes visent un nœud existant **et
imprime sa position**. Il a servi tout de suite : `find_child` rend le *premier*
nœud du nom demandé, il y a deux « Sortie » et plusieurs « Porte » dans le jeu, et
l'étape du QG visait une porte du désert à six cents mètres de Tuco.

**16. La sauvegarde du poste est toujours à la dernière étape.** Chaque capture
joue puis sauvegarde : la mission finit inévitablement terminée, donc sans
objectif, donc sans marqueur. Aucune image ne pouvait montrer une mission **en
cours**. `Mission.aller_a()` existe pour ça — la leçon du piège 22 sous une autre
forme : ce qui se mesure et ce qui se joue ont besoin de portes différentes.

**17. Le téléphone se posait pile sur la minimap.** Il s'ouvre tout seul au
changement d'étape et en recouvrait les trois quarts. Elle se cache maintenant
sous tout ce qui passe devant. Vu à la première capture, pas au premier essai en
jeu — et c'est bien pour ça qu'on capture.

---

## Quatrième partie — la tranche verticale, l'ouverture, et les voix en VO

**Décision de séance : le jeu se joue en anglais avec des sous-titres français.**
C'est la convention des jeux de cette époque et ça colle au ton de la série.

### Ce qui a été livré

**L'epic [#59](https://github.com/benjibleinx-perso/bg/issues/59)** — « la tranche
verticale : du titre à la fin de la mission 1 » — écrit avec l'inventaire réel de
chaque maillon, et non avec ce qu'on croyait en place.

**Une cinématique d'ouverture** : cinq plans fixes pris dans le monde déjà chargé,
avec leur heure, leurs cartons, un thème de 30 s et un fondu. Tout le déroulé est
dans `donnees/cinematique.json`. Elle ne se joue qu'au démarrage d'une nouvelle
partie et se saute à la première touche.

**Le compteur de vitesse est retiré.** Il gênait la minimap, mais surtout c'était
un chiffre affiché : la règle 1 ne l'autorise que pour l'argent, la famille et la
réputation.

**93 répliques ont leur version anglaise.** `texte` reste le sous-titre français,
`vo` porte ce qui se dit. Rétrocompatible : sans `vo`, rien ne change.

**Le casting est dans `donnees/casting.json`**, avec la raison de chaque choix.

### Les surprises

**18. Quatre défauts pour une seule cinématique, tous invisibles au raisonnement.**
Le HUD s'affichait par-dessus les cartons. Elle écrasait l'heure de la mission —
six heures du matin contre les neuf qu'impose `mission1.json`, dit par la suite
`jour` en une ligne. Elle démarrait sous les outils, et mon premier correctif
coupait sur le mode *headless* : sans effet, puisque `bg.ps1` lance les suites
**avec** une fenêtre. C'est `--script` qu'il fallait regarder.

**19. Et le dernier : elle jouait dans le mauvais viewport.** Symptôme rapporté
par Benjamin — « un plan fixe de Walter de dos, sans changement ». Tout
fonctionnait pourtant : les cartons défilaient, le fondu passait, les plans
s'enchaînaient. **Tout marchait sauf ce qu'on voyait.**

La cause : `Cinematique` vit sous `Monde`, pas sous `Rendu`. `get_viewport()` y
rend donc la **fenêtre** et non le SubViewport où tout le 3D est rendu ; la caméra
était créée à côté de la scène et `make_current()` la rendait active pour un
viewport que personne ne regarde. Le SubViewport est maintenant nommé en export,
comme le fait `capture.gd` qui met aussi la sienne dedans.

**J'avais conclu de la capture que c'était `capture.gd` qui écrasait ma caméra.**
C'était vrai, et c'était à côté : la bonne question était « pourquoi la mienne n'a
jamais pris ».

### Où on reprend, précisément

1. **Générer les 93 répliques** avec le casting de `donnees/casting.json`, via le
   MCP Magnific (`audio_tts`). Compter ~1 100 crédits. Walter, Jesse et Tuco sont
   **validés à l'écoute** ; Skyler, le garde et l'inconnu au téléphone sont des
   propositions à faire écouter.
2. **Brancher VO + sous-titres** : `dialogue.gd` doit jouer le son de `vo` et
   afficher `texte`. C'est le seul travail de code qui reste sur l'audio.
3. **Faire valider le cadrage de la cinématique en jouant.** Une capture ne peut
   pas le montrer — `capture.gd` impose sa propre caméra.
4. Le **QG de Tuco** : un homme sur trois, un bloc blanc sur le bureau, et Tuco
   lui-même à 8,77 Mo / 2048 px dans un jeu qui est en 256.

### Le bilan

Session très longue, et une constante : **presque tous les défauts trouvés
n'étaient pas là où le symptôme les désignait.** Un shader accusé de coûter quatre
millisecondes qui n'en coûte aucune, un import accusé d'écrire faux dont
l'instrument mentait, une cinématique « qui ne se lance pas » et qui se déroulait
parfaitement dans un viewport invisible. Ce qui a marché à chaque fois : mesurer
les deux côtés au lieu de choisir l'explication qui arrange.

---

## Cinquième partie — le jeu parle, et ce n'était pas le travail annoncé

**Livré** : `0.53.0`. Les **125 répliques** du jeu sont doublées en anglais,
sous-titrées français.

### Ce qui était prévu, et ce que c'était vraiment

Le plan disait : générer 93 répliques, puis **brancher `dialogue.gd`** pour
qu'il joue la VO. Le branchement n'était pas à faire — **il existait depuis des
mois**. `dialogue.gd` cherchait déjà `assets/voix/<qui>_<md5>.wav`, un
`gen_voix.ps1` de 570 lignes savait déjà découper une prise de comédien sur ses
silences et la reconnaître à la voix, et 93 fichiers étaient déjà là.

Le travail réel n'était donc pas *brancher* mais **remplacer** — et la seule
décision qui comptait était : **sur quoi porte l'empreinte qui nomme le
fichier ?**

Le code répondait lui-même. Son commentaire disait : *« le nom du fichier est
déduit du TEXTE, pas d'un index — réécrire une réplique change son empreinte,
donc son fichier »*. La règle n'était pas « le français » : c'était **ce qui est
enregistré**. Ce qui est enregistré est passé de `texte` à `vo`, donc
l'empreinte suit. Aucune exception à écrire, et un effet secondaire utile : les
93 voix françaises deviennent introuvables d'elles-mêmes.

### Ce que la vérification a trouvé, et que je ne cherchais pas

Il n'y avait pas 93 répliques mais **125**, dont 32 sans VO. Et ces 32 ne
formaient pas un groupe mais **trois, qui demandaient trois traitements
opposés** :

| Combien | Ce que c'est | Ce qu'on en fait |
|---|---|---|
| **19** | La confession de Walter et la dispute avec Skyler — **de vraies prises**, dont une de 11 Mo enregistrée d'une traite | **Ne jamais régénérer** |
| **11** | Les œufs, le téléphone — du français jamais traduit | Écrire la VO, générer |
| **2** | Une pensée entre parenthèses, un silence | **Ne jamais doubler** |

Les 19 étaient déjà en anglais dans `texte`, ce qui les rendait invisibles à un
comptage naïf — et c'est **exactement ce qui les protège** : pas de champ `vo`,
donc empreinte inchangée, donc réclamées par le jeu, donc épargnées par le
nettoyage. Le garde-fou n'est pas une liste d'exceptions à maintenir, c'est une
conséquence.

### Les surprises

**20. J'ai écrasé un test, et le remplaçant était moins exigeant.**
`verifs/test_voix.gd` existait. Je l'ai écrit en croyant le créer, et seul le
`M` de `git status` — au lieu de `??` — l'a signalé, au moment de commiter.
L'ancien mesurait **la crête du bus audio** ; le mien comptait des fichiers. Un
WAV valide de zéro seconde se charge sans erreur et ne s'entend pas. Pire :
l'ancien appelait `Dialogue.VOIX` et `Dialogue._simplifier()` *plutôt que de les
recopier*, et son commentaire disait pourquoi — j'ai fait exactement ce qu'il
interdisait. Le test livré est la fusion des deux. **Piège 27.**

**21. Passer en VO a rendu 92 fichiers orphelins d'un coup, en silence.** Pas
une erreur : simplement plus personne pour les demander. 12,7 Mo qui laissaient
croire que les personnages étaient doublés. Et `gen_voix.ps1` les aurait
**refabriqués à chaque passage** — il saute désormais toute réplique qui a une
VO, parce que lui faire lire de l'anglais avec la voix française de Windows, ou
nommer du français d'après de l'anglais, sont deux façons de mentir.

**22. `ConvertFrom-Json` rend un tableau comme un seul objet.** Trois voix
fusionnées sous le nom `Jesse Walter Tuco`, sans erreur. **Piège 28.**

**23. Et le tiret cadratin dans un `.ps1`, encore.** Le piège est écrit, je le
connais, je l'ai refait dans les vingt premières lignes de `voix_ia.ps1`.

### Ce que ça a coûté

**~560 crédits** pour 97 voix — 4 à 12 par réplique selon la longueur, contre
les 1 100 estimés pour 93. Le dédoublonnage y a aidé : « Eggs. » revient trois
fois chez Walter, et un nom de fichier vaut une seule génération.

**Reste ~17 500 crédits sur 20 000.**

### La preuve

```
  qui               ont   sans a importer
  Jesse              26      0          0
  Tuco               23      0          0
  Walter             51      0          0
       125 replique(s), dont 21 sans VO anglaise
  ok   toutes ont un enregistrement (0 manquant(s))
       crete bus Interface  -6.5 dB
  ok   on entend la voix
```

Les 21 sans VO sont les 19 vraies prises et les 2 répliques non parlées. Le
compte tombe juste.

---

## Sixième partie — l'appareil, et la direction d'acteur

**Livré** : `0.54.0`. Deux retours à l'écoute, deux natures de problème.

### « Si c'est du téléphone, le son doit être cohérent »

Le sous-titre français disait déjà **« (interphone) »** devant trois répliques
de Tuco. La scène le savait ; le son l'ignorait. On entendait le patron aussi
présent que l'homme qui garde la porte.

Deux bus dans `default_bus_layout.tres`, et **le traitement se fait en jeu, pas
à la génération**. Trois raisons, et la troisième est celle qui compte : le
fichier reste la **voix pure**. Un filtre cuit dans le `.wav` serait invisible —
dans six mois, personne ne saurait si une voix est sourde à cause de l'appareil
ou parce que la prise était mauvaise.

Mesuré, l'énergie sous 300 Hz : **−13,9 dB** sur le téléphone de Jesse,
**−17,5 dB** sur l'interphone de Tuco. Le filtre agit, et l'interphone coupe
plus fort que la ligne — conforme à l'intention.

**La règle qui décide seule : seul le correspondant est filtré.** Walter est le
joueur, il est dans la pièce, sa voix ne traverse rien même quand c'est lui qui
tient le combiné. Les deux erreurs possibles — un canal oublié, un canal posé
sur Walter — sont **muettes** toutes les deux, d'où `verifier_canaux.py`.

### « Ça manque un peu de vie »

Deux leviers, et un seul suffisait rarement. La **stabilité** a baissé pour tous
les rôles — une stabilité haute ne rend pas une voix plus sûre, elle la rend
monocorde. Et surtout un champ **`jeu`** par réplique, la direction d'acteur :
`furious`, `exasperated`, `quiet, tense`. Le moteur l'interprète sans la
prononcer.

**Elle compte dans l'empreinte**, et c'est le point d'architecture de la
session : la même phrase dite calmement ou en hurlant sont deux prises
différentes, elles ne peuvent pas partager un nom de fichier. Conséquence
voulue — rediriger une réplique la fait régénérer toute seule, et laisser `jeu`
vide rend exactement l'empreinte d'avant. Rétrocompatible sans rien déclarer.

**Walter n'a pas été dirigé partout, et c'est délibéré.** Lui coller une
intention sur chaque phrase le rendrait emphatique, le contraire de ce qu'il est
au début. Il n'en a que là où la scène lui en donne une : quand il ment, quand
il tient tête, quand il cède.

71 répliques régénérées, ~640 crédits. **Reste ~16 300.**

### Les surprises

**24. Deux erreurs de virgule dans le même script.** Poser `"jeu"` après `"vo"`
demandait de savoir si un champ suivait : la virgule se **déplace**, elle ne se
duplique pas. Le premier jet a produit `"jeu": "..."` suivi de `"canal"` sans
séparateur — 74 insertions, un JSON cassé, et la seule alerte était le
`json.load` de contrôle en fin de script. **Écrire ce contrôle valait tout le
reste** : sans lui, le fichier partait cassé et tout le monde devenait muet.

**25. Une mesure fausse publiée, puis corrigée.** J'ai affiché « 1 » comme
énergie dans les graves pour les quatre paires : ma regex attrapait le *1* de
« RMS level dB » au lieu de la valeur qui suit les deux-points. Le chiffre était
absurde et je l'ai montré avant de le relire.

---

## Septième partie — onze versions, et un motif qui revient six fois

**Livré** : de `0.54.0` à `0.55.1`. Casting validé, QG fermé, ville en 256,
passants dans la rue, ouverture qui bouge, cuisson jouable, marmonnements.

### LE MOTIF DE LA SESSION, et il vaut plus que la liste

**Six fois sur onze, le mécanisme existait déjà et n'était pas branché.**

| Ce qu'on croyait à faire | Ce qu'il fallait vraiment |
|---|---|
| Brancher `dialogue.gd` sur les voix | Le branchement datait de mois — il fallait **remplacer** |
| Donner une ambiance au désert | La convention `amb_zone_<zone>.ogg` avait été écrite **pour ça** |
| Remplacer le bloc blanc du bureau | Le shader de verre existait, il ne tournait **que dans le camping-car** |
| Mettre des passants | La foule était complète, réglée sur **zéro** |
| Passer les textures en 256 | Le générateur les faisait déjà — `ville.glb` n'avait **jamais été refait** |
| Prévenir de la fouille | La scène entière était écrite, il manquait **deux tutos** |

Et le cas symétrique, une fois : les trois hommes de Tuco étaient **décrits à
trois endroits et posés nulle part**.

**La règle qui en sort : avant de construire, chercher si la chose existe déjà
à moitié.** Ce n'est pas de la prudence, c'est du rendement — cinq de ces six
lots ont coûté moins d'une heure chacun.

### Les surprises

**26. Une recherche tronquée m'a fait ajouter trois personnages qui
existaient.** Le `[limit: 25]` est tombé quatre lignes avant `Homme1`. J'ai
conclu à une absence, écrit dans le commit qu'ils n'existaient pas, et posé
trois doublons — cinq gardes en jeu, dont deux à soixante centimètres. C'est
Benjamin qui l'a vu. **Piège 29.**

**27. Cinq nombres justes, aucun ne mesurait la bonne chose.** Transfert des
clips de marche vers les figurants : `skins=1`, 2 maillages, 4 animations,
0,36 Mo, « 8/8 conformes ». À l'image, les corps sont **disloqués** — le même
résultat qu'une tentative de juillet, par une méthode opposée. Deux squelettes
partagent 22 noms d'os sur 24 sans partager leurs **orientations de repos**.
`apercu_modele.py` existait depuis le 31/07, écrit exactement pour cette
question. **Piège 30.**

**28. `git mv` force le suivi, et mon « 13,4 Mo de moins » était faux.**
`.gitignore` ne s'applique pas à un fichier déjà suivi : le WAV n'avait pas
quitté le dépôt, il avait changé de dossier — en créant à la racine le dossier
que `.gitignore` existe pour tenir dehors.

**29. J'ai enfreint la règle de bump deux fois le même soir.** Elle est dans
`NOTES-DE-VERSION.md` depuis le 06/08 ; elle est maintenant aussi dans
`CLAUDE.md`, que je relis à chaque session.

### Ce qui a coûté, et ce qui n'a rien coûté

**Une minute de musique = 1 200 crédits**, cent fois une réplique doublée. J'ai
lancé deux ambiances sans vérifier : 2 400 crédits, **quatre fois le doublage
entier du jeu**. `simulate_cost` existe pour ça.

À l'inverse, les trois défauts audio signalés en jouant — pas trop forts,
crissements trop faciles, klaxon inaudible — étaient **des niveaux et des
seuils**, pas des sons à générer. Le pas d'intérieur était unique et sortait
4,7 dB au-dessus de l'extérieur.

**Crédits : ~14 000 sur 20 000.**

---

## Huitième partie — l'instrument mentait deux fois, et la cause tenait en un paramètre

**Voulu** : fermer les quatre tickets faits mais ouverts, puis attaquer le lot 4.
**Livré** : `0.55.2`. Les quatre tickets fermés sur mesure, un défaut de placement
vieux de plusieurs mois corrigé, et le test qui le surveillait réparé.

### Ce que le test disait, et ce qui était vrai

`test -Suite foule` échouait sur **« 12 passants sous la carte »**. Personne
n'était tombé. Le seuil valait `y < 0,05` quand le trottoir est à **0,18 m** et la
chaussée à **0,01 m** : le compteur mettait dans le même sac une chute au travers
du décor et une marche sur la route, qui n'ont ni la même cause ni la même
correction.

Relevé des vingt-six passants : 14 à 18 cm, 9 à 1–3 cm, 3 à −5 cm. Et **les
mêmes hauteurs avant et après deux secondes de marche** — donc pas une chute en
cours, mais des sols différents.

Le second compteur mentait aussi : `PAS = 54` et `ROUTE = 8`, déclarés « devant
correspondre à gen_ville.py », qui dit **57 et 11** — et depuis la trame
irrégulière du 31/07, **aucun pas fixe ne peut décrire cette ville**.

### La cause, et pourquoi elle a tenu si longtemps

Les trajets du générateur portent tous `y = 0,20`. C'est une **intention** : elle
prouve seulement ce que le générateur croyait faire. Mesure au rayon sur les 231
trajets — pas sur les 26 posés, qui n'en sont qu'un échantillon :

```
  sur le trottoir :  139  (60 %)
  sur la chaussee :   76  (33 %)
  ailleurs        :   16  (7 %)
```

`pietons_de_cote` recevait **un seul paramètre pour deux dimensions** : la
longueur qu'on parcourt le long d'un côté, et l'épaisseur qu'il faut franchir
pour atteindre le côté opposé. Tant que les îlots étaient carrés, les deux
nombres étaient égaux et l'erreur était invisible. La trame irrégulière les a
séparés : **sud et ouest restaient justes** — leur position ne dépend d'aucune
taille — **nord et est prenaient l'autre dimension**. Deux côtés sur quatre,
exactement ce que la mesure montrait.

`voitures_de_cote` et `mobilier_de_cote` avaient le même défaut, à la ligne près.
Les voitures garées et les poubelles étaient décalées pareil.

Après correction : **231 sur 231 sur le trottoir**, une seule hauteur dans tout le
relevé.

### Les surprises

**30. Un test rouge peut désigner le mauvais coupable sans se tromper de
verdict.** Il avait raison de crier — 12 passants étaient mal placés — et tort
sur tout le reste. Avoir corrigé « ils tombent » aurait cherché un trou dans le
sol qui n'existe pas. **Un compteur qui agrège deux causes est un compteur qui
oriente vers la mauvaise.**

**31. Corriger un placement a changé la géométrie de la ville.** 14 objets de
décor en plus, donc 14 tirages de plus sur le `rng` partagé, donc tout le flux
suivant décalé : **+72 faces**. Vérifié en régénérant avec le code d'origine —
hash identique au bit près, donc la comparaison valait. **Le plan des îlots, lui,
n'a pas bougé** : 15 bâti, 3 parc, 6 parking, 13 pavillonnaire, 5 strip mall, 16
terrain vague, avant comme après. La protection écrite dans `plan_des_ilots` tient
exactement ce qu'elle promet.

**32. Deux versions livrées sans aucune note.** `0.55.0` et `0.55.1` étaient
taguées et poussées, et absentes de `NOTES-DE-VERSION.md`. Guillaume avait donc
la cuisson jouable et les 47 marmonnements sans savoir qu'ils existaient — le
même défaut qu'en juillet, par l'autre bout : le tag était là, la note manquait.
Les trois notes sont écrites.

**33. `test -Suite trafic` est instable.** Un échec sur douze lancements : la
voiture suivie n'emprunte qu'un axe au lieu de deux quand le tirage la fait aller
tout droit. Ce n'est pas une régression — mesuré des deux côtés du changement.

### Ce qui n'a pas été fait, et pourquoi

Le lot 4 n'est pas fini : les passants **traversent toujours les murs**, ne
s'arrêtent pas et ne se parlent pas. Le son de leurs pas (#13) est prêt à être
branché — le signal `pas()` existe dans `demarche.gd`, les quinze sons de béton
sont là — mais il demande une distance d'écoute et un volume pour vingt-six
marcheurs simultanés. Ce sont des nombres de ressenti : ils vont dans
`reglages.tres` et se règlent à l'oreille, pas au jugé.

---

## Neuvième partie — la rue s'entend, et deux tests ont menti avant d'y arriver

**Voulu** : continuer le lot 4 par le son des pas (#13).
**Livré** : `0.55.3`. Les passants font du bruit en marchant, #13 fermé.

### Le travail réel a duré dix minutes

Encore le motif du 08/08 : **le mécanisme existait à moitié.** Le ticket
demandait 3 ou 4 variantes de pas à Guillaume ; il y en avait **quinze** dans
`assets/sons/pas/`. Le signal `pas()` était dans `demarche.gd` depuis que Walter
est passé au squelette, `bruit_ici` gérait déjà la position, la portée et
l'atténuation. Les passants étaient les seuls à ne pas écouter.

Il manquait deux lignes de branchement et **un décibel** : `-8 dB` de plus que le
joueur, dans `reglages.tres`. Le reste — les fichiers, l'atténuation 3D, le tirage
sans répétition — était déjà là.

Un seul choix de conception : un `gain_sup` optionnel sur `bruit_ici` plutôt
qu'un mécanisme `pas_passant` dupliquant les quinze fichiers dans `sons.json`.
Dupliquer aurait piégé Guillaume — une variante ajoutée plus tard aurait dû
l'être à deux endroits.

### La surprise, et elle vaut la partie entière

**34. Deux mesures d'affilée ont validé le son des passants alors que le signal
était débranché.** Chacune pour sa propre raison, et aucune n'était visible en
lisant le test :

| La mesure | Débranché, elle disait | Pourquoi |
|---|---|---|
| Crête du bus « Effets » > −60 dB | **−14,3 dB, au vert** | le bus est partagé, jamais silencieux |
| Appeler `_poser_le_pied()` puis regarder | **au vert** | l'appel court-circuite le signal testé |

Le second est le **piège 19 sous un autre déguisement** : une vérification qui
produit elle-même la condition qu'elle observe. On téléportait la voiture sur la
sortie avant de vérifier qu'on peut sortir ; ici on déclenchait le pas avant de
vérifier qu'il se déclenche.

Ce qui les a démasqués n'est pas une intuition : **commenter la ligne qui branche,
relancer, exiger le rouge.** Trois fois. Le geste coûte une minute et il est la
seule chose qui distingue un test d'une décoration.

La version retenue ne demande rien à personne — les passants marchent, on compte
les lecteurs qu'`Audio` a fabriqués. Débranché : `0 pas joue(s)`, rouge.

**Écrire la mesure a pris trois fois plus longtemps que le mécanisme mesuré.**
C'est le bon ratio, et il faut s'en souvenir avant de croire qu'un branchement
est « fait ». Piège 32.

### Et une affirmation du journal qui ne tient pas

**« Les passants traversent les murs » est écrit depuis la septième partie et
n'avait jamais été mesuré.** Vérification faite, quatre rayons horizontaux depuis
chacun des 231 trajets :

```
  un obstacle solide a moins de 4 m : 143
  rien du tout autour               :  88
  ce qui arrete : crepi 28, Decor 47, Foule 17, Benne 7, facade_c 6, Paroi 3
```

Les façades sont **solides** — `crepi` et `facade_c` sont bien des murs de
bâtiments — la ville leur fabrique un corps statique à la volée, et un piéton
masque la couche 1. Les 88 sans rien autour sont les trajets qui longent un
terrain vague, un parc ou un parking : il n'y a pas de bâtiment à toucher.

Ça ne prouve pas qu'aucun passant ne traverse jamais rien. Ça prouve que **le
chantier tel qu'il était écrit n'existe pas** : il n'y a pas de collision
manquante à ajouter. S'il reste un défaut, il faut un cas reproductible — quel
passant, quel mur, vu où — avant d'écrire une ligne.

Le reste du lot 4 est intact : ils ne s'arrêtent devant rien et ne se parlent
pas.

---

## Dixième partie — la rue se remarque elle-même

**Voulu** : finir le lot 4 par « ils ne s'arrêtent devant rien et ne se parlent
pas ».
**Livré** : `0.55.4`. Deux passants qui se croisent s'arrêtent et se font face.

### Ce qui existait déjà, encore une fois

`pieton.gd` avait **déjà** un champ `pause` de 1,2 s : ils s'arrêtent à chaque
carrefour depuis des versions. « Ils ne s'arrêtent devant rien » était donc faux
aussi — ils s'arrêtaient, simplement **pour rien**. Ce qui manquait n'était pas
l'arrêt, c'était une **raison** de s'arrêter.

Et `pnj.gd` portait la phrase qui a décidé de la forme : « *à ce stade du projet,
se tourner suffit à faire la différence entre un décor et quelqu'un.* » Les
habitants immobiles se tournent vers le joueur depuis longtemps. Les passants
font maintenant la même chose entre eux — aucune parole, aucun dialogue, aucune
bulle. Ils s'arrêtent et se regardent.

### Les trois refus

- **Pas de dialogue.** Des figurants qui parlent demanderaient des voix, donc du
  casting, donc des crédits — pour du bruit de fond qu'on n'écoutera jamais.
- **Pas tous.** Un sur cinq. Une rue où chaque paire s'arrête devient un village
  où tout le monde se connaît, et le procédé se voit en trente secondes.
- **Pas dans le dos.** Leurs vitesses doivent s'opposer. Sans cette condition, un
  passant qui en rattrape un autre s'arrête pour lui parler dans le dos.

La détection vit dans `foule.gd`, pas dans `pieton.gd` : un passant ne voit pas
ses voisins — ils partagent la couche du joueur et se traversent. Vingt-six
passants font 325 paires examinées une fois par seconde, moins cher qu'une seule
des cinq cent quarante distances que le recyclage mesure déjà au même rythme.

Un recul de six secondes après chaque salut, sinon deux passants arrêtés côte à
côte restent à portée quand le salut finit, se resaluent la seconde d'après et ne
repartent jamais.

### La surprise

**35. Le piège 32 a servi le jour même où il a été écrit.** La règle — *commenter
la ligne qui branche, relancer, exiger le rouge* — a été appliquée à la détection
des rencontres : `#_rencontres()`, et le test affiche `rencontres detectees : 0`
et vire au rouge. Il surveille donc bien la chaîne entière, du `_process` de la
foule jusqu'à l'orientation du passant.

Le test construit la rencontre — deux passants face à face, probabilité montée à
1 — mais **n'appelle jamais `_rencontres()`**. C'est exactement la distinction que
le piège 32 a coûté trois essais à comprendre : on a le droit de créer la
situation, jamais de déclencher le mécanisme qu'on prétend observer.

### Ce qui reste du lot 4

Ils se remarquent entre eux, mais **rien dans la ville ne les intéresse encore** :
pas de vitrine devant laquelle s'arrêter, aucune porte où entrer. C'est le
prochain morceau, et il n'a pas d'image évidente pour l'instant — donc il se
discute avant de se coder.

---

## Onzième partie — deux suites rouges en permanence, et aucune ne parlait du jeu

**Voulu** : éteindre les bugs #56 et #57, deux suites au rouge depuis le 08/08.
**Livré** : les deux fermées, aucun bump — rien de jouable n'a changé.

### #56 : « 0 km/h » cachait trois choses, aucune n'était le moteur

**Elle mesurait la chute.** Déposée à 0,6 m du sol, la voiture tombe, rebondit et
recule : la distance au départ passait de 1,20 m à 0,86 m entre la deuxième et la
troisième seconde. Deux secondes perdues sur sept.

**Elle percutait une montagne.** Visible seulement en allongeant le roulage et en
imprimant la courbe : montée régulière jusqu'à 37,2 km/h, puis arrêt net à
27,7 m. Les crêtes sont passées de 300 et 420 m à **230 et 360 m** des bords ; le
circuit, à x = −260, s'est retrouvé derrière la crête ouest. **C'est le même
incident que le cactus du 31/07**, à l'identique.

**Et le remplacement était pire.** Nouvelle position plein sud, mesurée dégagée
sur 160 m dans les quatre directions : le test est passé au vert en annonçant
**282,5 km/h** pour un plafond réglé à 130. Il n'y a pas de sol là-bas.
`vitesse_kmh()` renvoie la norme du vecteur, chute comprise — la voiture tombait.

### La surprise

**36. Un test qui passe avec un chiffre impossible n'est pas un test qui passe.**
282 km/h pour une vitesse maximale de 130 aurait dû arrêter la lecture net. Ce
qui a failli le faire avaler : les trois autres mesures étaient irréprochables —
écart latéral 0,00 m, dérive de cap 0,0°. **Une chute verticale ne dérive pas.**
Des indicateurs parfaits parce que rien ne se passait.

C'est le pendant exact du piège 32 d'hier soir. Là-bas, un test au vert
surveillait un mécanisme débranché ; ici, un test au vert mesurait une voiture en
chute libre. Dans les deux cas le vert était l'anomalie, pas le repos.

### Ce qui rend la chose durable

Pas la nouvelle position — elle sera rattrapée un jour comme les deux
précédentes. Mais le banc **valide maintenant son terrain avant de mesurer** :
un sol dessous, la distance libre devant sur la largeur du véhicule — trois
rayons parallèles, parce qu'un rayon seul passe entre deux cactus par lesquels la
voiture ne passe pas — et le nom de ce qu'il heurte. Piège 33.

### #57 : ne se reproduit pas, et le ticket se trompait de piste

Huit lancements sur huit au vert, valeurs identiques au centimètre. L'hypothèse
du ticket — « le message est écrit à l'envers » — est **fausse** : « rien entre le
sujet et la caméra » est bien la condition attendue sur une rue dégagée.

Ce qui l'a corrigé n'est pas identifié. Ce n'est **pas** la correction du
placement de la 0.55.2 : vérifié en régénérant la ville avec le générateur
d'avant, le test passe aussi. La cause probable est le passage de la ville à huit
blocs (`112c8fc`), postérieur au ticket.

Le relevé dit désormais **qui** obstrue, pas seulement qu'il y a obstruction —
c'est ce manque qui avait fait ouvrir le ticket sur une mauvaise hypothèse.

---

## Douzième partie — reprendre au volant reposait Walter à 760 mètres de sa voiture

**Voulu** : #55, le dernier bug marqué 🔥 pour moi.
**Livré** : `0.55.5`. La reprise rend la voiture et dit ce qu'elle reprend.

### Le point qui n'avait jamais été testé était le bon

Le ticket listait trois choses, et disait lui-même que **la troisième était la
seule qui pouvait être un vrai défaut** : « vérifier qu'une partie reprise au
volant repose bien Walter dans sa voiture ». Elle n'avait jamais été vérifiée —
la sauvegarde ne restaurait ni position ni inventaire avant le 07/08, donc la
question ne se posait pas.

Mesure faite en écrivant le cas manquant dans la suite :

```
       etat apres reprise : 0 (1 = au volant)
       la voiture est a 760.3 m de l'endroit quitte
```

On reprenait **à pied**, et la voiture était restée là où la scène l'avait posée
au lancement. La sauvegarde ne gardait que `position` — celle du **joueur**, qui
au volant est désactivé et retiré du monde physique, donc sa position ne veut
plus rien dire.

Corrigé en sauvant la voiture et l'état du volant. **Deux détails qui auraient
mordu :** la voiture doit être reposée *avant* de remonter dedans — monter
déplace le joueur vers la portière — et il faut annuler sa vitesse, sinon elle
repart toute seule à la reprise.

C'est le **contrôleur** qu'on branche, pas le véhicule : lui seul sait faire
monter quelqu'un proprement — désactiver le personnage, rendre la main à la
voiture, déplacer la caméra. Réécrire ces trois gestes ici les aurait dupliqués.

### Les deux autres points

Le bandeau à l'arrivée existait déjà comme mécanisme — c'est le canal des tutos
et des pensées de Walter. Une ligne : *« Reprise — Rejoindre le labo dans le
désert »*, et elle s'efface toute seule.

Le premier point du ticket demandait de vérifier **quel bouton avait été choisi**
ce soir-là. Il n'a plus d'objet : c'était un préalable de diagnostic, et le
défaut a été trouvé par la mesure. La question reste posée à Benjamin par
curiosité, elle ne bloque rien.

### Rien de neuf côté méthode, et c'est une bonne nouvelle

Le protocole du piège 32 a été appliqué sans y penser : débrancher
`_annoncer_la_reprise()` et le remontage au volant, relancer, obtenir trois
échecs, rebrancher. Écrit hier soir, devenu réflexe aujourd'hui.

---

## Treizième partie — la blouse est prête, et je ne peux pas la regarder

**Voulu** : commencer le lot 5 par la combinaison du labo.
**Livré** : le socle, **sans bump ni note de version** — le rendu n'a pas pu être
jugé.

### Ce qui existait déjà, une fois de plus

Le mécanisme de vêtement porté était **entier** : le chapeau s'enfile par la roue
depuis des versions, et `OS_DU_RIG` contenait `"Torse": "Spine02"` sans que rien
ne s'en serve. Il manquait une texture, trente faces et une fiche.

```
  EQUIPEMENT : 7 objet(s) accroches sur 7      (6 avant)
  ok   l'os 'Spine02' existe pour l'ancrage 'Torse'
```

La vérification de cet os manquait au test des outils, qui ne contrôlait que
`MainD` et `Tete`. Un ancrage qui ne résout aucun os laisse l'objet invisible
sans que rien n'échoue.

### Pourquoi je ne livre pas

**Un vêtement se juge sur le personnage debout.** Trois cadrages essayés, Walter
dans aucun. Ce n'est pas le scénario qui est mal écrit : **`purete_1`, inchangé
depuis des semaines, ne montre plus son cristal non plus** — le HUD l'annonce, et
l'image cadre une butte de sable.

Trois causes, toutes vérifiées, toutes dans le ticket **#61** :

1. `placer` vers le désert est **refusé** par le garde-fou du passage — « Vous
   devez être en voiture pour vous rendre ici ». Les cinq `purete_*` visent cette
   zone.
2. La mission **vide l'inventaire** après le don, même à l'image 240.
3. Le dialogue d'ouverture **masque la moitié basse** de l'image, exactement où
   se tient un personnage cadré de près.

C'est la pire forme de panne d'outil : elle produit des images qui **ressemblent**
à des captures réussies — décor net, HUD correct, aucune erreur — mais où le
sujet est absent. On valide alors sur une image qui ne montre rien.

### La surprise

**37. J'ai basculé tout le jeu en plein jour sans le vouloir.** `gen_textures.py`
écrit le moment dans `monde.json` — le fichier le dit lui-même, « ne pas modifier
à la main ». Lancé avec `--moment jour` pour fabriquer une texture, il a effacé
un choix pris en 0.51.0 (« la nuit a des ombres »).

Ce qui l'a rattrapé : lire le `git status` avant de conclure, et le diff après
coup — deux lignes, `"moment": "nuit"` → `"jour"`. Vérifié aussi que la texture
de la combinaison est **identique en jour et en nuit** (matière unie, seules les
façades ont des vitres cuites), donc le modèle n'avait pas à être refait.

**La leçon : `bg.ps1` a des valeurs par défaut qui sont des DÉCISIONS.**
`-Moment` vaut « nuit ». Appeler l'outil Python directement court-circuite ce
choix sans rien signaler.

### À surveiller

La mesure des pas de passants est passée de 6-7 à **1 pas en 2 s** après la
régénération, stable sur six lancements. Le seuil est « au moins un » : la marge
est mince. Si cette ligne devient rouge, ce n'est pas forcément le son qui est
cassé — c'est peut-être qu'aucun passant n'est à portée d'oreille du point où le
test dépose le joueur.

---

## Quatorzième partie — trois lettres, et Walt était injouable

**Voulu** : réparer la planche de captures (#61).
**Livré** : `0.55.6`, et ce n'était pas du tout le sujet.

### Le retour qui a tout retourné

Benjamin lance la 0.55.5 et ne peut pas jouer : « **Walt est injouable, il est
bloqué dans un mur au spawn, il traverse la maison, il va trop vite et fini par
tomber dans le vide** ».

Quatre symptômes. **Une cause, et je venais de l'introduire une heure plus tôt** :
le col de la combinaison s'appelait `Col`. Godot lit ce nom à l'import d'un glTF
comme une consigne de **collision** et fabrique un `StaticBody3D` dedans. Le
vêtement étant accroché à l'os du torse, le corps solide était greffé sur le
joueur :

```
.../Joueur/Corps/Walter/Armature/Skeleton3D/Attache_Spine02/blouse/Col/StaticBody3D
```

Walt entrait en collision avec ses propres habits, à chaque image.

### La surprise, et elle est sévère

**38. J'avais mesuré ce bug toute la soirée sans le voir, et je l'avais classé
« défaut d'outillage ».** La dérive du joueur, je l'ai relevée cinq fois. J'ai
éliminé les entrées, la foule, les murs, le trafic, les passages — chaque fois
avec une vraie mesure, chaque fois à côté. J'ai ouvert un ticket sur les captures
qui ne montraient plus leur sujet, alors que le sujet était **poussé hors du
cadre par le vêtement que je venais de fabriquer**.

Ce qui m'a fait passer à côté : **le déplacement ne passe pas par la vélocité.**
Le relevé affichait `vitesse 0.0` pendant qu'il parcourait deux mètres toutes les
vingt images, et j'ai cherché qui le *commandait* au lieu de chercher ce qu'il
*touchait*.

La mesure qui a tranché en un coup :

```gdscript
q.shape = forme.shape ; q.exclude = [joueur.get_rid()]
espace.intersect_shape(q)   # puis str(collider.get_path())
```

Le NOM disait `Col/StaticBody3D` et n'apprenait rien. Le **chemin** commençait par
`Joueur/` — le coupable se désignait tout seul. Et `exclude = [joueur]` n'exclut
pas ce que le joueur PORTE : ces corps ont leur propre RID.

### Ce que ça referme au passage

**#61 est résolu du même coup.** `purete_1`, qui photographiait une butte de
sable depuis des heures, montre à nouveau Walter. La planche n'a jamais été
cassée : son sujet était éjecté entre le placement et le déclic.

Le ticket restera utile : le relevé « ce qui devait être dans le cadre » ajouté
au moteur de capture est ce qui a permis de voir la dérive en chiffres.

### Ce que j'en retiens, au-delà du nom

Deux règles dans `CLAUDE.md` et le piège 34 :

- **Le nom d'un maillage est une instruction, pas une étiquette.**
- **Un corps qui bouge sans vélocité est poussé par quelqu'un** : ne pas chercher
  qui le commande, chercher ce qu'il touche.

Et une leçon de méthode plus large : j'ai livré un asset sans pouvoir le
regarder, en disant que je ne le validais pas. **C'était insuffisant.** Ne pas
pouvoir juger un modèle aurait dû être une raison de vérifier qu'il ne casse
rien, pas seulement de s'abstenir de le vanter.

---

## Quinzième partie — Walter raconte son ouverture

**Voulu** : le retour de Benjamin sur l'ouverture — « j'aime pas trop le texte,
fais plus narratif, plus sympa, un peu dramatique un peu d'humour ».
**Livré** : `0.55.7`. Cinq répliques neuves, doublées, une par plan.

### Ce que les cartons ne pouvaient pas faire

L'ouverture disait : *« Un professeur de chimie. Cinquante ans. »*, *« Un
diagnostic. Deux ans, peut-être. »* C'est juste, c'est court, et c'est **une
fiche de personnage** — le joueur lit un résumé au lieu de rencontrer quelqu'un.

Les cartons sont remplacés par sa voix, et la règle des marmonnements s'applique
telle quelle : **il énonce des faits, jamais ce qu'il ressent.** Le drame et
l'humour viennent de l'écart entre les faits, pas d'un adjectif :

- *« Il n'y a rien, ici. Ce n'est pas une plainte. C'est un prérequis. »* — il
  justifie un choix de lieu comme un protocole.
- *« Et un spécialiste qui me donne deux ans. Il en était navré. »* — la phrase
  la plus grave se termine par une politesse absurde.
- *« Je ne suis pas un criminel. Je suis un chimiste. La nuance compte. Pour
  moi. »* — le mensonge fondateur, et le « pour moi » dit tout.

Un seul carton reste, celui du lieu : il ne dit pas la même chose que la voix.
La dernière ligne est celle qui existait déjà — *« It has to work. »* — déplacée
à la fin, là où il n'explique plus rien. **Elle était déjà doublée : zéro
crédit.**

Coût total : **74 crédits** sur 14 246. Les plans ont été rallongés au cas par
cas, sur la durée mesurée de chaque prise, pas au jugé.

### La surprise

**39. Cinq voix générées, cinq voix rangées, et le jeu muet.** `voix_ia.ps1`
nomme les fichiers comme le jeu les cherchera — c'est tout son objet, et son
en-tête promet exactement d'éviter ce cas. Mais l'empreinte porte sur `[jeu] vo`
quand la réplique est **dirigée**, et le script hachait `vo` seul.

La direction d'acteur avait été ajoutée à l'empreinte **d'un côté seulement**.
Tant qu'aucune réplique doublée n'était dirigée, les deux formules coïncidaient
et rien ne se voyait. Mes cinq répliques sont toutes dirigées.

**Un outil qui reproduit un calcul du jeu est un miroir, et un miroir se casse en
silence.** Les deux fonctions portent maintenant le même nom des deux côtés.

Ce qui a rattrapé le coup : la suite `voix` ne compte pas les fichiers, elle
vérifie que **chaque réplique a le sien**. Piège 35.

---

## Seizième partie — le dépôt disait des choses qui n'étaient plus vraies

**Voulu** : une passe de cohérence sur tout — fichiers, docs, tickets, code.
**Livré** : `0.55.8` (la fin de mission), puis quinze corrections et trois
tickets neufs.

### La fin de la mission — encore une chose écrite et débranchée

`mission_fin` existait dans `dialogues.json`, doublée, et **appelée de nulle
part**. La mission s'arrêtait sur un bandeau en capitales.

> *« Il ne faut pas que Skyler trouve ça. »*

Elle vient après le bandeau, jamais par-dessus. Ce qu'elle dit fait tout le
travail : il vient de vendre pour la première fois, et sa première pensée est de
**cacher**. Ça conclut et ça ouvre, dans la même phrase.

**Ce que je n'ai pas tranché** : le texte du bandeau. « MISSION ACCOMPLIE » en
capitales n'est pas le ton du jeu, mais le remplacer est une décision de ton —
elle est posée dans #62 avec trois options.

### Ce que la passe de cohérence a trouvé

**Six chiffres sur six étaient faux dans le README** : 32 suites annoncées 27,
71 scénarios annoncés 32, 35 pièges annoncés 16, 7 objets annoncés 5, 213
réglages annoncés « ~80 », une ville de 8×8 et 526 lampadaires annoncée 2×2 et
32.

Aucun ne l'était par négligence. **Un état des lieux écrit en dur vieillit sans
prévenir**, et il vieillit toujours au même endroit : les lignes qui portent un
nombre.

### La surprise

**40. L'outil chargé de détecter les modèles orphelins en inventait sept.**
`bilan_modeles.py` ne lisait que `assets/ville/*.json` ; les sept modèles du banc
graphique, que `desert.gd` pose à chaque partie depuis
`assets/decor/banc_graphique.json`, ressortaient « jamais posés ».

**Un audit qui accuse à tort finit par être ignoré, ce qui est pire que pas
d'audit.** C'est la même famille que les pièges 31 à 33 : un instrument qui
affirme sans surveiller. Corrigé en lui faisant lire `assets/` en entier plutôt
qu'en ajoutant les fichiers un par un à mesure qu'ils font un faux positif.

Restent **huit vrais orphelins**, 2,3 Mo en LFS : les figurants du retargeting
abandonné. Pas supprimés — c'est une décision, elle est dans **#63**.

### Deux canaux documentés qui ne menaient nulle part

`livraisons/LISEZ-MOI.md` disait à Guillaume de filtrer sur l'étiquette
`a-faire`, et `docs/09-communiquer.md` décrivait `decision` et `a-faire`. **Ces
trois labels n'existent plus** — ce sont 🎨 Guillaume, 🎮 Benjamin, ✅ à faire.

Guillaume lisait donc un mode d'emploi qui pointait vers un filtre vide.

### Ce qui était sain, et qui méritait d'être vérifié

126 fichiers de voix pour 126 répliques, **zéro orphelin** — empreintes
recalculées une par une. Aucun script `.gd` mort. Aucun TODO en suspens. Aucun
lien markdown cassé après correction. Cinq tickets 🔥 pour un plafond de cinq.
Tous les titres sous un domaine officiel.

`.tmp` allégé de 51 à 25 Mo : essais audio dont la décision est prise, planche de
captures périmée — celle dont le sujet était hors cadre.

---

## Dix-septième partie — Guillaume a livré, et une règle disait le contraire de ce qu'on fait

**Voulu** : recenser ce que Guillaume a poussé pendant la séance de test, en
faire un plan, ouvrir les tickets pour tout couvrir, puis exécuter le premier
lot — celui qui ne demande aucune décision.
**Livré** : dix tickets, quatre commits, trois tickets fermés. **Aucun bump** :
rien de jouable n'a changé, et `NOTES-DE-VERSION.md` dit que le remaniement n'y a
pas sa place.

### Ce que Guillaume a livré, et que personne n'avait ouvert

Trois commits entre le 12 et le 14/08, aux messages laconiques — « 1 modele(s)
3D », « 4 fichier(s) ». Derrière :

- **`Rv v2.glb`**, la réponse à #52. Mesuré : plus un scan, un vrai modèle
  Blender, 1 737 triangles, une seule texture — mais **2048 px** là où la charte
  dit 1024. La question de #52 (est-ce que la tôle ondule encore ?) ne se juge
  pas sur ces nombres : elle attend une capture, c'est **#69**.
- **Deux documents d'écriture**, 466 lignes. La séquence de jeu et les interdits
  actifs des missions 1 à 4, et le script complet de la mission 1 avec sa table
  de dialogue. Du travail utilisable tel quel, qui respecte la règle 1 partout —
  jauges non affichées, minuteurs sonores, pas de HUD directionnel.
- **41 images de référence**, dont quatorze doublons exacts.

**Il n'a pas suivi le circuit de #37** — pas d'issue « Mission N », pas de
formulaire, des `.md` poussés directement. Et ce qu'il a produit est meilleur que
ce que le formulaire demandait. Le ticket décrit un circuit qui n'existe plus ;
c'est lui qu'il faut réécrire, pas la livraison qu'il faut refaire.

### Le lot 0 — sauver l'information avant de la corriger

Les deux scripts sont montés dans `docs/18-` et `docs/19-`, **par `git mv`** :
les empreintes de blobs sont inchangées, `e71ef63` et `f903f57`. Pas une virgule.
C'était le point — les six écarts avec les fiches sont dans **#67**, et se
traitent APRÈS, pour qu'on puisse toujours lire ce que Guillaume avait écrit.

Les 51 lignes de commentaires des bus audio sont revenues, vérifiées avant :
65 lignes fonctionnelles avant, 65 après, aucun réglage touché.

Les 41 images sont devenues 35, rangées par sujet et nommées d'après ce qu'elles
montrent.

### La surprise, et c'est la suite directe de la seizième partie

La passe de cohérence du 09/08 avait trouvé six chiffres faux dans le README et
deux canaux qui ne menaient nulle part. Elle n'a pas pu voir que **trois fichiers
affirmaient qu'aucun média de la série n'entre dans git**, alors qu'il y en a 39
— dont huit commitées le 26/07 par celui qui avait écrit la règle.

Elle ne pouvait pas : ces trois phrases étaient parfaitement cohérentes **entre
elles**. Une passe de cohérence cherche des contradictions, et il n'y en avait
aucune. Plus la règle était répétée, plus elle avait l'air vérifiée.

**Une règle recopiée à trois endroits ne devient pas vraie, elle devient
crédible.** C'est le **piège 37**. Le geste qui manquait ne comparait aucun
document à un autre : `git ls-files 'livraisons/*.jpg'` → 39.

Le `DISCLAIMER` affirmait aussi que le jeu n'est pas distribué publiquement,
alors que les exe sortent en releases ouvertes depuis le 05/08. Les deux phrases
de l'engagement le plus sensible du fichier étaient fausses.

**Ce qui a été décidé** : les références restent versionnées — les sortir aurait
cassé le canal de travail avec Guillaume sans rien changer à l'exposition réelle,
puisque l'exe public embarque déjà des médias de la série. C'est la règle qui est
corrigée, pas la pratique. Ce qui reste à mesurer est en **#74** : personne ne
sait quels assets de l'exe viennent de la série, et `livraisons/LICENCES.md`,
prévu par la charte depuis le début, n'a jamais été créé.

### Deuxième surprise — les images sans nom cachaient ce qu'on cherchait

Les 27 captures s'appelaient `23063581.jpg`. Il a fallu les ouvrir une par une
pour les nommer. Trois choses en sont sorties :

- **Emilio et Krazy-8 ont leurs références de modélisation** — quatre images, en
  pied et en gros plan. **#70** venait d'être ouvert en disant qu'ils
  n'existaient nulle part et qu'il faudrait les créer ; les références étaient
  dans le dépôt depuis deux jours.
- **Le pantalon a son image** — Walt de dos sur la piste, chemise verte, sans
  pantalon. C'est l'objet qui doit ressortir plié sur la banquette arrière à la
  mission 15, et le script de Guillaume ne le mentionne nulle part.
- **La chemise verte aussi**, portée pendant toute la séquence du désert. Les
  deux ensemble suggèrent que Walt garde le haut et perd le bas — ce qui
  dissoudrait l'écart n°3 de #67.

**Un fichier mal nommé n'est pas mal rangé, il est invisible.** Ces quatre images
étaient à trois clics, et un ticket a été ouvert pour créer ce qu'elles
documentaient déjà.

### Ce que Benjamin a tranché en séance

Il y a **deux missions 1**, et elles n'ont jamais été en concurrence.
`mission1.json` — « Un client impatient » — est un **assemblage** : la mission
Tuco d'abord, puis la mini-mission de l'appel de Skyler et des œufs, puis tout
rassemblé dans la mission 1, et c'est là que l'appel a été incorporé. Ce n'est
pas une adaptation de « DEUX CORPS, UN CAMPING-CAR », qui reste à écrire.

---

## Dix-huitième partie — le camping-car v2, et l'instrument qui ne mesurait pas

**Voulu** : intégrer la v2 livrée par Guillaume, trancher en image si la tôle
ondule encore, fermer le dernier maillon du vertical slice qui dépendait de lui.
**Livré** : la mesure, une planche de trois images, un défaut renvoyé à la
source, un instrument réparé. **La v1 est restée dans le jeu.**

### Ce que la v2 règle, et ce qu'elle casse

Les ondulations ont disparu — c'était tout l'objet du ticket, et ça se voit au
premier coup d'œil. Plus de scan, un maillage propre, une texture, 0,24 Mo contre
2,12.

Puis la suite `desert` a parlé :

```
ECHEC   Jesse est DEHORS (-0.12 m de la tole)
```

**Le modèle est proportionnellement trop large** — rapport largeur/hauteur de
1,129, contre 0,835 pour la version en place et 0,718 pour le véhicule réel. À
hauteur égale il gagne 53 cm de chaque côté, et Jesse comme la porte n'avaient
que 40 et 24 cm de marge. Ce n'est pas l'échelle, que la chaîne cale toute seule :
c'est la proportion, et ça se corrige à la source.

Renvoyé à Guillaume avec le chiffre à viser et trois images. **La v1 est remise,
la suite repasse au vert.** Un modèle qui n'apporte encore rien ne vaut pas un
test rouge dans le dépôt.

### La comparaison a été refaite, et pas reprise

La planche de référence datait du 07/08, en `0.48.12` — avant le socle de rendu
`0.51.0`. La confronter à une capture d'aujourd'hui aurait mélangé deux
variables : le modèle **et** le moteur de rendu. Les deux images de la planche
ont donc été prises le même jour, au même cadrage, sur la même version.

Le ticket disait « au cadrage de la planche ». Ce cadrage n'était pas celui qu'il
désignait : `camping_car` est en plongée et à distance, **les ondulations n'y
sont pas jugeables**. C'est `camping_car_porte` qui montre le flanc.

### La surprise, et elle vaut la partie entière

**`camping_car_porte` ne pouvait pas répondre à la question qu'elle pose.**

Elle annonce trancher « si la porte du jeu tombe sur la porte du modèle », et
elle posait Walter sur `pos: [1.75, 0.4, 1.27]` — une copie en dur de la position
que `PorteCampingCar` avait le jour où on l'a recopiée. Découvert en essayant de
recaler le point d'entrée : le nœud déplacé de deux mètres dans `mission1.tscn`,
la capture relancée, **et la même image, empreinte pour empreinte**.

C'est le piège 19, sur l'outil écrit pour l'éviter. Et il descend d'une
correction qui avait été **la bonne** : `autour` ancre la caméra sur ce qu'elle
photographie, ce qui a réglé la version précédente du défaut — la vue qui
photographiait du sable à vingt-neuf mètres. Seulement le joueur, lui, est resté
sur sa coordonnée.

**Une correction à moitié faite ne laisse pas un défaut visible à moitié : elle
le rend invisible en entier.** La vue avait été corrigée, le commit était écrit,
le récit était dans `capture.gd` — plus personne n'allait regarder. C'est le
**piège 38**.

Réparé : les étapes acceptent `sur: "<noeud>"`, la position vient de la scène, et
`pos` ne sert plus qu'à décoller du sol. Mesuré après coup — nœud à 1,27 →
`EEE6845D`, nœud à 3,27 → `785409FE`. L'image change.

**Les 31 autres étapes qui posent sur une coordonnée n'ont pas été touchées**, et
la plupart ont raison de le faire : `walt_face` ou `blouse` posent Walter quelque
part pour le photographier, rien ne dépend de l'endroit exact. Le piège porte la
question qui trie plutôt qu'une réécriture de trente scénarios sans mesure : *ce
scénario affirme-t-il que deux choses coïncident ?*

### Ce qui n'a pas été fait, et pourquoi

Le décalage de la porte de la v2 — environ deux mètres — n'a pas été corrigé.
Aucune coordonnée n'a été touchée : régler un nombre avec un instrument dont on
venait de découvrir qu'il ne mesure pas, c'est le piège 18. L'instrument est
réparé maintenant ; la question reviendra avec la v2 corrigée.

---

## Dix-neuvième partie — savoir ce que l'exe contient, et un test qui mesurait le hasard

**Voulu** : avancer sur ce qui ne dépend d'aucune décision, pendant que les
arbitrages du palier 1 attendent.
**Livré** : `livraisons/LICENCES.md`, prévu par la charte depuis le début du
projet et jamais écrit, et le test du trafic qui ne tombe plus une fois sur
douze.

### On sait enfin ce que l'exe contient

Le `DISCLAIMER` promet un **retrait immédiat à la première demande d'un ayant
droit**. On ne peut pas tenir un engagement qu'on n'est pas capable de mesurer :
« retrait immédiat » suppose de savoir quoi retirer. Personne ne pouvait le dire.

Chaque fichier de `game/assets/` a été remonté à son commit d'ajout, avec
`--follow` pour traverser les rangements. Sur **289 fichiers** :

| | |
|---|---|
| Nos scripts Blender, refabricables à l'identique | **79** |
| Livré par Guillaume — 6 modèles construits, 74 sons de banques | **80** |
| Généré par IA — 126 voix, 2 modèles 3D, 1 musique | **129** |
| **Extrait direct de la série** | **1** |

**Aucun visuel de la série n'est embarqué.** Les 87 fichiers d'image et de
géométrie sortent tous d'un générateur ou de la main de Guillaume. Les
personnages sont *modélisés*, pas extraits ; les voix sont synthétiques et disent
des répliques écrites pour le jeu.

**Un son l'est** : `this_is_not_meth.wav`, 2,5 s, la réplique que Walt lance chez
Tuco une seconde avant l'explosion. L'historique ne pouvait pas le dire — il ne
renseigne pas ce qu'il y a *dans* un fichier son — et c'est la seule question de
tout l'inventaire qui a demandé une oreille. Benjamin a écouté le soir même :
**c'est la vraie voix de la série.**

Il est couvert par le `DISCLAIMER`, qui prévoit exactement ce cas, et il est
remplaçable sans toucher au code : `sons.json` appelle un nom de mécanisme, pas
un fichier, et la chaîne de synthèse sert déjà pour 126 répliques. La décision —
substitut assumé ou refait en synthèse — est posée, pas urgente.

**Ce que ça vaut** : sur 289 fichiers, l'historique en a tranché 287. Et c'est
précisément celui qu'on aurait le plus facilement classé « probablement une
banque » qui s'est révélé être l'extrait. **Un inventaire sans case « je ne sais
pas » finit par mentir dans cette case-là.** L'engagement de retrait immédiat est
tenable pour la première fois : le jour où il faudrait retirer quelque chose, on
sait quoi.

### La surprise : l'inventaire s'est corrigé lui-même

Premier jet : 81 fichiers sortis de nos scripts. Faux. `verrerie.glb` et
`bidons_chimie.glb` sont dans `game/assets/decor/` mais viennent de
**Magnific/tripo** — ils sont déclarés dans `outils/assets-ia.json`, avec leur
prompt et leur empreinte.

J'avais classé **par dossier**, sans confronter le résultat au manifeste qui est
la source pour cette famille. **Le piège 37, appliqué à l'objet même qui venait
de le documenter** : une règle appliquée sans être vérifiée contre la source.
Trouvé en vérifiant une phrase que j'avais écrite sur la musique.

Et cette vérification-là a trouvé autre chose. `CLAUDE.md` pose que « rien ne se
génère sans passer par le manifeste ». **Le thème d'ouverture n'y est pas**, alors
que son original est dans `livraisons/ia/musique/`. Le prompt qui l'a produit
n'est écrit nulle part — à retrouver le jour où on voudra la musique de conduite
(#38), qui est précisément la décision en attente.

### Le test du trafic mesurait le tirage

Il suivait `agents[0]` et exigeait qu'elle change d'axe en quatre secondes. Si le
tirage la faisait aller tout droit au carrefour, il tombait — **alors que le
trafic marchait parfaitement**.

Il suit maintenant toutes les voitures et exige que la majorité ait tourné,
exactement comme le contrôle « elles avancent » juste au-dessus, qui portait déjà
la bonne forme. Le relevé imprime le compte.

```
17 lancements d'affilee, 17 verts
voitures qui tournent   min 7   max 10   moyenne 9.2   sur 10
seuil exige             5
```

Le pire cas observé est deux voitures au-dessus du seuil. **Le seuil n'a pas été
choisi puis vérifié : il a été choisi sur la mesure**, et la marge est écrite pour
qu'on puisse la rediscuter si la ville change.

Aucun autre test ne suit un agent tiré au sort — vérifié, les seuls `[0]`
restants indexent des cas de test.

---

## Où on reprend

**État à la fin de la session du 16/08/2026, sur `v0.55.8`.** Treize commits,
`main` synchronisée, arbre propre, aucun bump — rien de jouable n'a changé de
toute la session, et `NOTES-DE-VERSION.md` exclut les remaniements.

### La première chose à faire demain : trois tickets à fermer

**#64, #74 et #75 sont faits et poussés**, ils n'attendent qu'une fermeture.
Décidé de ne pas y toucher le soir même : chaque écriture sur un ticket envoie un
mail à Guillaume, et il était deux heures du matin. **Les tickets se ferment aux
heures ouvrables** — c'est une règle qui manquait, et elle vaut aussi pour les
commentaires.

Rien n'a donc été écrit sur GitHub après la première salve, et les messages de
commit de la fin de session ne portent plus de `#NN` : une référence croisée dans
un ticket est aussi une notification.

### Ce qui attend Benjamin, par ordre de coût

| | Ticket | Coût |
|---|---|---|
| Fermer ce qui est fait | #64, #74, #75 | une minute |
| **Les cinq écarts du palier 1** | **#67** | le vrai blocage |
| `this_is_not_meth.wav` : substitut assumé, ou refait en synthèse ? | inventaire | une décision, pas urgente |
| Le ton du bandeau de fin | #62 | |
| Jeter ou garder les huit figurants | #63 | |
| La musique de conduite — 1 200 crédits/min | #38 | |
| Les six réglages de ressenti | #41 | |

### Ce qui attend Guillaume

**#52** — la largeur du camping-car v2, avec le chiffre à viser : 4,40 m → ~3,25 m
sur son fichier tel que livré, sans toucher à la longueur ni à la hauteur. Tout
le reste de sa v2 est bon, et c'est écrit dans le ticket.

**#72** (le cahier d'implémentation fantôme, une réponse de trente secondes),
**#71** (les deux sirènes) et **#60** (l'ambiance du désert, toujours pas arrivée
après trois commits — le piège LFS l'attend aussi sur les sirènes).

### Ce qui bloque, et qui n'attend que des décisions

| Ce qu'il faut trancher | Ticket | Qui |
|---|---|---|
| **Les six écarts** fiches / scripts du palier 1 | **#67** | Benjamin |
| Le cahier d'implémentation qui n'existe nulle part | **#72** | Guillaume |
| Le ton du bandeau de fin | #62 | Benjamin |
| Jeter ou garder les huit figurants | #63 | Benjamin |
| La musique de conduite — 1 200 crédits/min | #38 | Benjamin |
| Les six réglages de ressenti | #41 | Benjamin |

L'écart n°6 de #67 est levé depuis la séance (voir ci-dessus) ; les cinq autres
restent. Deux d'entre eux ont maintenant leur image de référence.

### Ce qui peut se prendre sans attendre personne

- **#73** — les deux états du camping-car, avec la réponse à la question que
  Guillaume a posée dans son script et qui attend.
- **#70** — Emilio et Krazy-8, maintenant que les références sont trouvées.

Les deux construisent pour la mission 1 **narrative**, que **#67** n'a pas encore
tranchée. Les prendre avant l'arbitrage, c'est bâtir sur une décision qui
appartient à Benjamin.

**#64 et #74 sont faits**, ainsi que **#75** : ils attendent seulement d'être
fermés. Deux bruits de l'inventaire demandent une **écoute**, pas du code — une
sonnerie et un bruit de siège. Le troisième, `this_is_not_meth.wav`, a été écouté
le soir même : c'est la vraie voix de la série, et il a sa section dans
l'inventaire.

**#69 est suspendu à Guillaume**, pas à nous : la v2 est mesurée, le défaut de
largeur est renvoyé en #52 avec le chiffre à viser. À la réception, réintégrer
avec `-Lacet 90 -Hauteur 3.59 -TextureMax 1024` — le lacet a demandé deux
essais, `-90` aligne l'axe mais présente le côté sans porte.

**#75 est fait** et attend seulement d'être fermé : la vue lit désormais le point
qu'elle vérifie. Le reste du ticket — passer les autres scénarios en revue — est
volontairement réduit à la question qui trie, écrite dans le piège 38.

### Ce qui attend Guillaume

**#72** (le cahier fantôme, une réponse de trente secondes), **#71** (les deux
sirènes), et **#60** — l'ambiance du désert, toujours pas arrivée après trois
commits. Le même piège LFS l'attend sur les sirènes : `git lfs install` avant de
pousser, sans quoi `git add` prend la fiche et laisse le son.

### Ce qui attend l'oreille ou l'œil de Benjamin

Six nombres de ressenti sont posés à une valeur **mesurée**, aucun n'a été
**jugé**. Tous dans `reglages.tres`, une ligne chacun. Recensés sur **#41**.

| Réglage | Valeur | La question |
|---|---|---|
| `pas_passant_gain` | −8 dB | trop présents, ou inaudibles ? |
| `salut_proba` | 0,2 | trop souvent, ou jamais ? |
| `salut_duree` | 2,5 s | assez long pour qu'on le remarque ? |
| `salut_distance` | 2,2 m | ils s'arrêtent trop loin ? |
| zone de cuisson | 16 % de la barre | trop dur, trop facile ? |
| marmonnements | un / 42 s | trop bavard, ou on l'oublie ? |

Et **l'ouverture réécrite** (0.55.7) : cinq répliques de Walter, une par plan.
Se juge en lançant une **nouvelle partie**, jamais en capture.

### Le vertical slice : onze cases sur quinze

Le tableau d'état de **#59** est à jour au 09/08. Ce qui reste :

| Ce qui manque | Ticket | Qui |
|---|---|---|
| Le camping-car extérieur — *la v2 est livrée, elle attend sa capture* | **#52** → **#69** | à nous |
| La musique de conduite | **#38** | Benjamin — 1 200 crédits/min |
| **Le rythme de la mission** | #59, lot 4 | personne ne l'a encore fait |
| Une fin qui conclut — *la réplique est faite* | **#62** | le **ton du bandeau** revient à Benjamin |

**Le premier a changé de camp le 12/08** : ce n'est plus Guillaume qu'on attend,
c'est une capture à produire. Le vrai reste tient dans le lot 4 : personne n'a
encore joué la mission 1 d'un bout à l'autre en notant où elle traîne.

### Deux choses qui traînent et qu'aucun ticket ne porte

- La **combinaison** : elle existe et ne casse plus rien, mais elle n'a toujours
  pas été regardée. Le cintre du camping-car attend ce verdict.
- Il reste **14 172 crédits** de génération.

### Les décisions qui appartiennent à Benjamin

- **L'embranchement « cacher la botte »** (G4 complet). La botte doit finir sur
  le bureau pour la scène finale : la cacher demande d'écrire **une branche de
  scène entière**. C'est un lot, pas un ajout.
- **Le retargeting des figurants**. Deux tentatives ont échoué. La troisième
  devrait partir de `rotation_cible = repos_cible⁻¹ · repos_source ·
  rotation_source`, et ne pas avoir lieu autrement.
- **La musique de conduite** (#38) — 1 200 crédits la minute.
- **Les ambiances par plan de cinématique** : l'ouverture pilote-t-elle
  l'ambiance, ou la laisse-t-elle tranquille ?

### Les tickets ouverts le 16/08

Dix d'un coup, pour couvrir la livraison de Guillaume sans rien en perdre :
**#65** à **#74**. Trois sont déjà fermés — les bus audio, la promotion des
scripts, le rangement des références.

Commentés plutôt que doublés : **#52** (la v2 mesurée), **#60** (relance),
**#37** (le circuit décrit n'est plus celui qui se passe), **#43** (le déroulé du
palier existe maintenant), **#67** et **#70**.

### Les tickets, remis d'aplomb le 09/08

**Fermés cette session, chacun sur une mesure** : #5, #10, #13, #14, #16
(passants et son), #55, #56, #57 (les trois bugs), #61 (les captures).

**Ouvert cette session** : **#62** — la mission 1 se termine sur une conclusion.
C'était le seul maillon du vertical slice sans ticket. Et **#60**, chez
Guillaume : il a poussé la fiche d'import de son ambiance désert sans le fichier
son, LFS probablement non activé chez lui.

**Mis à jour** : **#59** (tableau d'état réécrit, il datait de la `0.51.2`),
**#38** (les pas et les ambiances sont faits ; la décision musique est chiffrée),
**#27** (trois cases sur cinq faites depuis la cuisson jouable), **#41** (les six
réglages en attente y sont recensés).

**Aucun ticket supprimé.** Un seul aurait pu l'être — #16, dont les deux voies
proposées étaient toutes deux fausses — mais il portait la mesure qui l'a montré,
et cette mesure vaut plus que le ticket.

### Le lot 4 est terminé, sauf un point qui se discute

- **« Ils traversent les murs » était faux, et c'est mesuré.** Les façades sont
  solides : un rayon lancé depuis les 231 trajets bute sur `crepi` ou `facade_c`
  dans 34 cas, sur du décor dans 47, sur un autre passant dans 17.
- **Ils s'arrêtent et se saluent** (0.55.4), un croisement sur cinq.
- **On les entend marcher** (0.55.3).
- **Reste** : rien dans la ville ne les intéresse — aucune vitrine, aucune porte.
  **Pas d'image évidente**, donc ça se discute avant de se coder.

### Le lot 5, commencé — et il a coûté cher

La **combinaison du labo** existe : texture, modèle, fiche, ancrage au torse
vérifié. Elle a rendu le jeu **injouable** pendant une heure (piège 34) parce
qu'un de ses maillages s'appelait `Col`. Corrigé.

Elle n'est **toujours pas jugée à l'image**. Le chemin le plus court est
maintenant le jeu lui-même : Échap → Outils → « Donner tous les outils », puis
Tab → « Combinaison ». Le **cintre** du camping-car attend ce verdict — quatre
lignes et un `Point`, mais poser une poignée sur une porte qu'on n'a pas regardée
n'a pas de sens.

### Ce dont il faut se méfier

- Le **relevé de coût varie de 2,4 à 4,2 ms** au même point. Le bruit est plus
  grand que la plupart des effets qu'on mesure.
- **`test -Suite trafic` échoue une fois sur douze** sans rien de cassé : la
  voiture suivie ne tourne pas toujours dans les quatre secondes. Le relancer
  avant de chercher une cause.
- **Le circuit de `test -Suite conduite` sera rattrapé une quatrième fois** le
  jour où une bande de décor s'élargira. Il le dira lui-même maintenant — « il y
  a un sol », « le circuit est dégagé », « ELLE A HEURTE : … » — mais penser à
  lui quand on déplace quelque chose dans le désert coûte moins cher.

### Le bilan de la session du 8 au 9 août

**Six versions livrées** — `0.55.2` à `0.55.7` — **neuf tickets fermés**, deux
ouverts, quatre mis à jour. Cinq pièges écrits (31 à 35).

**Ce qui a le mieux marché : mesurer avant de construire.** Cinq affirmations du
journal se sont révélées fausses une fois vérifiées — les passants ne traversaient
pas les murs, ils s'arrêtaient déjà aux carrefours, le son des pas existait à
90 %, le bandeau de reprise aussi, l'assertion du test caméra n'était pas à
l'envers. **Le travail annoncé n'était presque jamais le travail réel.**

**Ce qui a coûté le plus cher : avoir livré un asset sans pouvoir le regarder.**
La combinaison a rendu Walt injouable pendant une heure, et j'ai passé cette
heure à mesurer le symptôme sans voir la cause — en le classant même « défaut
d'outillage » alors que c'était le bug de jeu le plus grave de la journée. Dire
« je ne le valide pas » ne suffisait pas : **ne pas pouvoir juger un modèle aurait
dû être une raison de vérifier qu'il ne casse rien.**

**Le fil rouge des trois derniers pièges est le même** : un vert n'est pas un
repos. Un test qui passe débranché, un banc d'essai qui mesure une chute libre,
un outil qui range des fichiers sous un nom que personne ne cherche — les trois
annonçaient « tout va bien » en ne surveillant rien. La question qui les tue
tient en une ligne, et elle est désormais dans `CLAUDE.md` : **qu'est-ce qui, dans
ce test, ne pourrait pas arriver si le fil était coupé ?**

**Ce qui reste devant nous n'est plus du code.** Onze cases sur quinze du vertical
slice sont faites ; deux des quatre restantes appartiennent à Benjamin et à
Guillaume. Le dernier morceau qui m'incombe — une fin de mission qui conclut
(#62) — ne se mesure pas : il se joue.

---

## Session du 7 aout 2026, deuxieme partie — la premiere fois qu'on JOUE

**Début** : sur `v0.48.13`. **Fin** : sur `v0.50.0`, trois releases plus loin.

### Ce qui était demandé

Tester la mission 1 manette en main, puis fusionner deux choses qui existaient
séparément : l'appel de Skyler, éprouvé dans une mission de test, et la boucle
des courses, livrée le soir même.

### Ce qui est livré

| Version | Quoi |
|---|---|
| **0.48.14** | La cachette se voit et se trouve ; le klaxon s'entend |
| **0.49.0** | **#53** — Skyler appelle pendant qu'on roule vers le désert. `F` décroche, `T` raccroche, laisser sonner coûte cinq points. Arriver avec les courses coûte une réputation, et Jesse comme Tuco le remarquent |
| — | **#47** — la sauvegarde ne gardait que l'argent et l'heure. Trois liens manquaient dans la scène |
| **0.50.0** | **#20** — le puits économique : cuisiner, livrer, être payé, recommencer. Le prix suit la pureté |

Les formulaires de tickets ont aussi été remis d'aplomb, et tous les liens du
dépôt corrigés — ils pointaient encore vers le dépôt **pro** d'avant le
transfert, y compris le corps de chaque release publiée.

### Les surprises

**Trois parcours de test sur trois, sans un défaut.** Tout ce qui avait été livré
à l'aveugle dans la journée s'est révélé juste manette en main. C'est la première
fois de ce projet.

**Le seul blocage n'était pas une régression : la cachette n'avait jamais été
trouvable.** Aucune planche à l'écran, posée au milieu du vide, dans un salon de
quatorze mètres sur dix — alors que le tuto annonce « une latte du mur n'est pas
comme les autres ». Troisième fois cette semaine que la même leçon se paie :
**une adresse exacte que rien ne signale n'est pas une adresse.**

**La sauvegarde ne gardait que la moitié depuis quinze versions.** L'argent et
l'heure revenaient ; ni l'inventaire, ni la position, ni l'avancement. Ce qui a
masqué le trou pendant si longtemps : **la moitié qui marchait était la moitié
qu'on regarde** en relançant.

**Le klaxon ne s'entendait pas, et ce n'était pas le code.** Le fichier est
enregistré six fois plus bas que les autres. Mesuré, pas deviné — et quatorze
sons sur soixante-quatre sont dans le même cas.

**Un faux diagnostic, et il était de moi.** Un bug « on ne peut pas courir »
ouvert sur une liste d'actions que ma propre commande avait tronquée. On court
très bien. **Une absence ne prouve rien tant que la recherche n'est pas
complète** — c'est passé dans `CLAUDE.md`.

### Où on reprend

**#55** : reprendre une partie ne dit pas où l'on arrive — revers de la
sauvegarde réparée. À vérifier en premier : reprend-on **dans** sa voiture ou à
côté ?

**La passe d'organisation, demandée et pas faite.** Le classement était prêt
— trois « maintenant », cinq « ensuite », le reste en feuille de route — et mis
de côté pour traiter des tickets plutôt que les archiver. Restent à écrire : la
feuille de route, la méthode et la fiche de test.

**Les sept chantiers de code restants n'attendent aucun code**, mais des choix :
les précurseurs, où vivent Junior et Hank, ce que voient les témoins, les quatre
missions du palier 2. Les trancher seul, c'est livrer un jeu que Benjamin
découvrirait.

**Et les nombres de ressenti n'ont jamais été joués** : vingt secondes avant
l'appel, cinq points pour le retard, trois cents dollars la livraison.

---

## Session du 7 aout 2026, premiere partie — un remede qui dormait a cote du malade

**Début** : 07/08, sur `v0.48.10`. **Fin** : sur `v0.48.13`, trois releases
publiées après deux jours de silence.

### Ce qui était demandé

Reprendre par #48, comme le journal de la veille le disait : la mission de Tuco
est cassée depuis l'ouverture du désert. Puis, une fois #48 clos, finir #51 — le
camping-car de Guillaume, jamais intégré.

### Ce qui est livré

**0.48.11**, en deux lots, et un ticket ouvert exprès pour ne pas mélanger les
deux :

| Lot | Quoi |
|---|---|
| **#48** | `Pnj` a un garde-fou de mission. Jesse se tait tant que rien ne l'a amené au camping-car |
| **#50** | Jesse, la porte et la sortie du désert s'ancrent sur les lieux publiés au lieu de les recopier. Trois distances mesurées par le test |
| — | Les situations de capture du camping-car se posent **autour** du véhicule (`autour` dans `scenarios.json`) |
| — | **Release `v0.48.11` publiée**. La dernière datait du 5 août en 0.40.0 : Guillaume téléchargeait un jeu sans les trois compteurs, sans écran-titre et sans sauvegarde |
| **#51** | **0.48.12** — le camping-car de Guillaume entre dans le jeu, dégraissé à 8 000 triangles ; `integrer` sait désormais dégraisser ; le générateur ne fabrique plus de camping-car |
| **#49** | **0.48.13** — l'épicerie vend (4 $, un son, une boîte d'œufs) et la cuisine compte : les points de famille ne tombent qu'en posant la boîte sur le plan de travail, et Skyler répond dans les deux cas |

Côté tickets : **#48, #49, #50 et #51 fermés**, **#52 ouvert** pour Guillaume
(la tôle du camping-car ondule à la source).

### Les surprises

**Un ticket peut décrire cinq pannes et n'en contenir qu'une.** #48 en listait
cinq. Un seul symptôme venait de l'ouverture du désert ; trois avaient une cause
commune vieille de huit jours, et le cinquième n'était pas une panne mais un
travail jamais fait. **Vingt minutes de diagnostic ont évité de refermer le
désert pour rien.**

**Le code annonçait sa propre panne, en majuscules.** Deux fichiers écrivaient
noir sur blanc que ces coordonnées ne devaient jamais être recopiées, et ce qui
arriverait si on le faisait. C'est arrivé : Jesse est resté vingt-neuf mètres
derrière le camping-car, au milieu de la piste. Deuxième session d'affilée où un
commentaire prédit une panne et se lit comme une décoration.

**Le remède dormait à côté du malade.** `ancrage.gd` faisait déjà exactement ce
qui manquait, pour la ville, et son en-tête racontait la même histoire payée
deux fois. Le désert avait la maladie et pas le remède, à un champ près.

**Trois vérifications regardaient à côté, et elles étaient au vert.** Un test qui
se téléportait sur la sortie avant de vérifier qu'on peut sortir. Une capture qui
photographiait du sable à vingt-neuf mètres de son sujet. Et la même, recalée,
posée à la verticale exacte — une image sans haut ni bas. Troisième soirée
d'affilée qu'un instrument de ce projet se révèle aveugle.

**Le camping-car de Guillaume n'avait jamais été dans le jeu.** Il dormait dans
`livraisons/` depuis des semaines pendant que deux commentaires du code
affirmaient le contraire. **Un commentaire qui décrit un asset se périme sans
bruit** : personne ne le relit pour vérifier qu'il est encore vrai.

**Guillaume attendait un exe qui n'existait pas.** Onze versions bumpées sans
jamais être taguées : il téléchargeait un jeu sans écran-titre ni sauvegarde,
pendant que trois de ses tickets 🔥 attendaient qu'il voie ce qui existait déjà.

**Le budget d'un asset se mesure, il ne se décide pas.** 17 828 triangles livrés
pour un budget de 2 000, et aucune bonne réponse sur le papier. Cinq niveaux
posés côte à côte sur le banc graphique — un outil qui existait et n'avait jamais
servi à ça — ont tranché en une image : sous 4 000 la carrosserie se froisse, et
**à partir de 8 000 la silhouette cesse de bouger**. Huit fois le poids pour rien
au-delà. Aucun des trois faits n'était devinable.

**Une image et un test se sont contredits, et les deux avaient raison.** La
capture montrait Walter dehors ; le test le disait dans la tôle. La physique
l'avait éjecté avant la prise de vue — **l'image montrait où il finit, pas où on
l'avait mis.** Quand les deux se contredisent, ils ne répondent pas à la même
question, et il faut trouver laquelle avant de corriger.

### Où on reprend

**Une manette, d'abord.** Rien de ce qui a été livré n'a été joué : la mission de
bout en bout, le trajet épicerie → maison, le refus quand on n'a pas les quatre
dollars. Les tests couvrent la mécanique, jamais le plaisir qu'il y a — ou pas —
à faire ce détour.

**À surveiller :** la chaîne d'intégration ne dégraisse que si on le lui demande,
et le prochain modèle livré passera au budget de son auteur si personne n'y
pense. Les deux réactions de Skyler n'ont pas de voix — la maison est le seul
endroit du jeu où l'on parle sans entendre personne. Et `bg.ps1 generer` est
inutilisable sur cette machine faute de Python : le contournement est connu, pas
câblé.

---

## Session du 6 au 7 aout 2026 — les trois compteurs, et cinq instruments qui mentaient

**Début** : 06/08, sur `v0.43.0`. **Fin** : sur `v0.48.10`, onze versions plus tard.

### Ce qui était demandé

Reprendre les tickets un par un, comme la veille. En cours de route, la session
a changé de nature deux fois : d'abord des outils, puis une décision de
direction qui renverse la règle numéro un du projet.

### Ce qui est livré

| Version | Quoi |
|---|---|
| **0.44.0** | L'écran-titre passe par le rendu du jeu — il était plus net que sa propre première image |
| **0.45.0** | Un menu d'**outils de test** dans la pause : onze gestes qui évitent une relance |
| **0.46.0** | Aller à un lieu nommé (45 destinations), traverser les murs et voler |
| **0.47.0** | Relevé de performance en direct, densités foule/trafic, collisions et repères visibles |
| **0.48.0** | La **pureté** : cinq paliers, une couleur dans la main, aucun chiffre |
| **0.48.1** | Les **points de famille**, affichés en permanence |
| **0.48.2** | La **réputation de rue** — les trois compteurs sont à l'écran |
| **0.48.3** | Une épicerie, première façon de faire remonter la famille |
| **0.48.4** | « Un simple service » : la mission de test des appels |
| **0.48.5 → .10** | Cinq corrections successives sur cette mission, chacune revelant un vrai défaut du jeu |

Côté tickets : **#33 fermé** (fausse alerte), **#46 créé et fermé** (les outils),
**#30 fermé** (les trois ressources), **#21, #22 et #28 supprimés**, **#47, #48
et #49 ouverts**. Et deux tickets sortis de 🔥 parce qu'ils attendaient autre
chose qu'eux-mêmes.

### Les surprises

**Un instrument peut mentir avec l'aplomb d'un chiffre.** Le relevé de coût
annonçait un effondrement du jeu : pire cas tombé à 7 images/seconde, 16,5 ms de
scripts par image. Le jeu tournait en réalité avec **vingt-six fois la marge
nécessaire**, zéro image ratée sur quinze mille. Trois compteurs mal lus, aucun
bug : le compteur d'images du moteur ne se rafraîchit qu'une fois par seconde,
`TIME_PROCESS` est un **maximum de la seconde écoulée** et pas un temps de
scripts, et une seconde de chauffe laissait la compilation des shaders dans la
mesure. C'est le piège 18, et il donne son revers à la règle d'or du projet :
*une image ou un nombre, jamais une conviction* — **mais un nombre n'est une
preuve que si on a lu le code qui le produit.**

**Cinq tickets décrivaient un travail déjà fait.** L'Aztek amélioré était
intégré depuis le 5 août. Les voix de la mission 1 existent (113 fichiers de
synthèse). Les sons de pas des piétons aussi (17 fichiers) — ce qui manque,
c'est que `pieton.gd` ne les joue jamais. Un ticket ouvert n'est pas un travail
à faire ; c'est parfois un travail déjà fait que personne n'a coché, et on l'a
repayé cinq fois en une soirée.

**Deux vérifications avaient cessé de vérifier.** Depuis que l'écran-titre est
devenu la scène d'entrée en 0.43, `verif` validait `monde.tscn` en dur — la
vraie porte du jeu n'était contrôlée par personne — et `capture` photographiait
le menu au lieu de sa situation, en écrivant un PNG parfaitement valide. Rien ne
le signalait. **Une vérification qui ne suit pas un réglage rassure à côté.**

**La règle numéro un a été renversée, et c'est écrit.** Le projet disait
qu'aucun chiffre ne se montre au joueur. Les trois ressources — argent, famille,
réputation — s'affichent désormais en permanence, parce que ce sont des comptes
à rebours qu'on surveille en conduisant. `docs/12-direction.md` et `CLAUDE.md`
portent l'exception, sa raison et sa borne : la pureté reste une couleur dans la
main. Une règle qu'on change sans l'écrire devient une règle qu'on enfreint sans
le savoir.

**Le premier appel pris au volant a révélé un trou de quatre ans.** Le
contrôleur fait capter la touche d'interaction par une conversation en cours
dans trois états — à pied, dans une maison, au téléphone — et **pas au volant**.
Personne ne l'avait vu parce qu'aucun dialogue ne se déclenchait en conduisant.
Le premier est resté bloqué sur sa première réplique, pendant que le même `F`
essayait de faire descendre Walter de sa voiture.

**Cinq allers-retours sur la même mission, et pas un pour rien.** Chaque essai a
sorti un défaut du jeu et pas de la mission : l'appel comptait depuis le début
de la mission au lieu de la conduite ; `F` éjectait de la voiture ; aucun
dialogue ne pouvait avancer au volant ; `Audio.bruit()` ne rend pas de poignée,
donc **un son ne peut pas être coupé** — le téléphone continuait de sonner après
qu'on avait décroché ; et une parcelle du générateur n'est pas une adresse — sans
enseigne, l'épicerie était introuvable. **Jouer trouve ce que tester ne trouve
pas.**

**Un garde-fou retiré en le citant.** Le passage vers le désert était fermé tant
que la mission 1 n'y envoyait pas, et son commentaire disait mot pour mot ce qui
arriverait sans lui : *« on pouvait filer au camping-car dès la première minute,
y trouver un Jesse qui reproche un retard à une mission pas encore commencée »*.
Il a été retiré à la demande, en recopiant cette phrase, sans en tirer la
conséquence. Elle est arrivée dans la minute. **Un commentaire qui prédit une
panne mérite d'être lu comme un avertissement, pas comme une décoration.**

**Deux fausses manœuvres, dites plutôt que tues.** Un `git stash pop` non abouti
a laissé une heure de travail dans le stash le temps d'un tour — récupérée
intégralement. Et un commentaire de ticket posté sous le **compte pro** sur un
dépôt perso public : supprimé, reposté du bon côté, et le remote est passé sur
l'alias SSH perso pour que ça ne se reproduise pas.

**Un board se lit, ou ne se lit pas.** En fin de session, passe complète sur les
vingt-sept tickets : trois fermés (l'Aztek était livré depuis deux jours, la
sauvegarde et la finition étaient finies pour ce qu'elles pouvaient être), et
**vingt-deux titres refaits**. Ils mélangeaient quatre formes — un nom, une
question, une phrase, une opinion — et se lisaient bien une fois, jamais deux.
La forme est désormais fixée dans `CLAUDE.md`. Ce que la passe a montré, et
qu'aucun ticket ne disait : **neuf tickets sur vingt-quatre attendent Guillaume,
trois attendent une décision de Benjamin.** La moitié du board n'attend pas du
code, et les deux chantiers qui débloqueraient le plus — #36 et #43 — n'ont
jamais été ouverts.

### Où on reprend

**#48 d'abord** : la mission de Tuco est cassée depuis l'ouverture du désert.
Jesse parle hors contexte, il est mal placé, on n'entre plus dans le camping-car,
le modèle affiché n'est peut-être pas le bon, et la sortie du désert pose
problème. La correction n'est pas de refermer la porte — c'est de donner à `Pnj`
le garde-fou de mission que `Point` a déjà, et de faire taire Jesse tant que rien
ne l'a amené là. Les quatre autres symptômes sont peut-être antérieurs : à
vérifier avant de conclure.

**Puis #49** : l'épicerie est encore un bouton qu'on peut marteler. Elle doit
devenir une vraie course — quatre dollars, une boîte d'œufs dans l'inventaire,
les points donnés **en rentrant**, et Skyler qui réagit selon qu'on a pensé à
elle ou non.

**En attente ailleurs** : #47 (l'objet tenu ne revient plus après une reprise —
régression pré-existante, la moitié du critère de fin de #32), un système de
**dialogue à choix** qui n'existe pas et que réclament #31, #35 et #29, et dix
tickets jamais passés en revue (#34 à #45). Guillaume : les rigs de passants, les
voix, le formulaire de mission.

---

## Session du 6 aout 2026 — sauvegarder, reprendre, et un ecran-titre

**Début** : 06/08, sur `v0.40.0`, dépôt propre et outillage enfin en place.
**Fin** : sur `v0.43.0`, trois versions livrées et un verbe d'outil de plus.

### Ce qui était demandé

Reprendre le traitement des tickets, cette fois du vrai code de jeu — et le
faire un par un, chaque ticket validé avant d'être démarré.

### Ce qui est livré

| Version | Quoi |
|---|---|
| **0.41.0** | On peut **sauvegarder et reprendre** (#32 lot 1) : heure, argent, inventaire, position, mission. On sauve en quittant et à la fin d'une mission ; au lancement, une partie existante reprend seule |
| — | Le jeu s'ouvre sur le **second écran** (`bg.ps1 jouer`), pour ne pas recouvrir l'éditeur |
| **0.42.0** | **Mourir recharge le dernier point** (#32 lot 2) au lieu de repartir de zéro ; l'argent gagné depuis est perdu |
| **0.43.0** | Un **écran-titre** (#40 lot 1) : Nouvelle partie / Reprendre / Quitter, avec confirmation avant d'écraser |
| — | Un verbe **`bg.ps1 diag`** pour relever le coût de la ville (#33) |

### Les surprises

**Le pre-flight a évité deux fausses routes.** Avant de coder chaque ticket, on
a cadré — et deux se sont révélés déjà faits : **#18** (Tuco est assis depuis un
moment, vérifié à la capture) et **#33** (la règle « plafonner et recycler » est
déjà appliquée, l'outil de diag existe déjà). Un ticket ouvert n'est pas un
travail à faire ; parfois c'est un travail déjà fait que personne n'a coché.

**Recharger une partie n'est pas refaire les gestes.** Le premier test de
sauvegarde a échoué sur une seule chose : le chapeau ne revenait pas sur la
tête. `_demander_le_port` pose le port après un **délai** — c'est une animation,
juste pour le geste joué. À la restauration on écrit l'état directement : on
retrouve le chapeau dessus, on ne le remet pas cran par cran.

**Le relevé frais a fait exactement son travail.** `bg.ps1 diag` sur la 0.43 a
sorti un chiffre qui prévient : **7 images/seconde au pire, 8 images ratées sur
180, 16,5 ms de scripts par image — et zéro passant.** La moyenne (58) allait
bien ; c'est le pire cas qui s'est effondré depuis le décor d'Albuquerque. C'est
tout l'intérêt d'un instrument : il dit ce que la moyenne cache.

**Un type non inférable plante tout, en silence jusqu'à ce qu'on regarde.**
`var etiquette := ... if ... else liste[i]` — `liste[i]` est un Variant, donc le
type ne s'infère pas, et GDScript refuse de compiler le fichier ET tous ceux qui
en dépendent. Le lanceur ne montrait qu'une bannière ; il a fallu lancer le
script en direct pour lire l'erreur. Type explicite, et c'est réglé.

### Où on reprend

**L'à-coup perf est le premier fil à tirer** : 7 im/s au pire, 16,5 ms de
scripts par image avec 0 passant — documenté sur #33, à profiler (décor
d'Albuquerque ? rafraîchissement jour/nuit ?). À part ça : les lots suivants de
#40 (écran de chargement, cartons de chapitre, générique, bilan d'acte) et de
#32 (dormir pour sauver ; pureté/famille/réputation quand elles existeront).
Décisions toujours en attente de Benjamin : **#30** (comment on gagne la
réputation) et **#38** (musique). Guillaume : rig des passants (#16), voix (#5),
formulaire de mission (#37). Et un fil ancien : les suites `tenue de route` et
`sons` échouent sur ce poste **même sur le code propre** — pré-existant, à
creuser.

---

## Session du 5 au 6 aout 2026 — le depot demenage, l'outillage arrive, et le suivi se remet d'aplomb

**Début** : 05/08 au soir, sur `v0.40.0`. **Fin** : 06/08 au petit matin, même
version — c'est une session d'infrastructure, d'outillage et de tickets, pas de
game code. Rien de jouable n'a changé, donc pas de bump.

### Ce qui était demandé

Reprendre le projet côté perso, donner aux gens un lien propre pour télécharger
l'exe, puis remettre les tickets d'aplomb — et en traiter.

### Ce qui est livré

| | |
|---|---|
| **Le dépôt** | Transféré sur le compte perso `benjibleinx-perso/bg`, public. L'ancienne URL redirige, les liens existants tiennent |
| **La release** | `v0.40.0` publiée — les versions 0.37→0.40 étaient codées mais jamais sorties. Le lien de download est enfin celui du code actuel |
| **Les docs** | Journal rattrapé jusqu'à 0.40, doublon 0.37.0 des notes retiré, cadrage corrigé (dépôt public assumé) |
| **Les tickets** | #23/#24/#25 soldés (déjà faits à 0.28→0.40), #44 et #45 pour les vrais résidus, quatre décisions consignées, et un grooming complet : trois familles d'étiquettes, un seul *qui* par ticket, et un label **🤖 Claude** pour ce sur quoi j'avance seul |
| **L'outillage** | Godot 4.7.1 et Blender 5.2.0 installés sur cette machine, chaîne vérifiée |
| **#18** | Tuco assis : vérifié à l'image, il l'était déjà. Fermé |
| **#19** | `project.godot` ne relance plus les 27 suites quand seule sa carte d'entrées change — 9 au lieu de 27. Plus un `-Lister` pour voir la sélection sans jouer |

### Les surprises

**Le dépôt vivait sur le compte GitHub pro.** Un projet perso hébergé du mauvais
côté de la séparation. Le transfert l'a remis où il faut, et comme il préserve
tout — historique, issues, releases, LFS — et redirige l'ancienne URL, personne
ne casse un lien au passage.

**Les retours de test étaient faits, mais jamais fermés.** #23, #24, #25
listaient soixante points ; la quasi-totalité avait été livrée entre la 0.28 et
la 0.40, sans que le ticket bouge. *Un ticket ouvert n'est pas un travail à
faire — c'est parfois un travail déjà fait que personne n'a coché.* On les a
soldés en croisant chaque point avec sa version.

**Cette machine n'avait pas le toolchain.** Godot et Blender nulle part : c'est
la machine miroir, celle qui sert au git et à l'admin. Tout ce qu'on a fait ce
soir avant l'install ne demandait pas le jeu — et c'est justement pour coder
ET vérifier qu'on l'a posé ici.

**#18 était périmé.** Tuco est assis depuis un moment : le clip `Assis` est
fabriqué par le solveur, présent dans `tuco.glb`, branché. La règle d'or a
tranché — capture `qg_bureau`, il est bien calé dans son fauteuil — là où une
conviction aurait laissé le ticket ouvert ou l'aurait fermé à tort.

**Le correctif de #19 a failli être défait par sa propre mesure.** On compare
`project.godot` à HEAD, section `[input]` retirée, pour savoir si seule la carte
d'entrées a bougé. Sauf que `Get-Content -Raw` lit le fichier en CP-1252 et
`git show` sort de l'UTF-8 : les tirets cadratins des commentaires, *hors*
`[input]`, cassaient l'égalité à tous les coups, et `project.godot` aurait
continué de relancer les 27 suites en silence. C'est le piège UTF-8 de
PowerShell 5.1, encore lui. Trouvé parce qu'on a mesuré « identiques ? » au lieu
de le croire.

**`tir.gd` n'était couvert par aucune suite.** Trouvé en vérifiant #19 : modifier
le système de visée et de tir ne déclenchait aucun test. Rattaché à la suite
`mission`, qui charge et câble le signal du tir. Le comportement du tir
lui-même — viser, toucher, la riposte — n'a toujours pas de test qui tire
vraiment : c'est un cran au-dessus, noté.

### Où on reprend

Deux décisions attendent, et elles débloquent le socle : **#30** — comment on
gagne la réputation (Benjamin + Guillaume) — et **#38** — la musique (Benjamin).
Guillaume a trois choses en 🔥 : le rig des passants (#16), les voix (#5), le
formulaire de mission (#37). Côté code autonome, le prochain chantier propre et
sans dépendance est **#32** (sauvegarder et reprendre) ; le puits économique
(#20) reprendra une fois #30 tranchée. La page Issues, elle, dit maintenant d'un
coup d'œil quoi, pour qui, et quand.

---

## Session du 31 juillet au 2 aout 2026 — de 0.36.0 a 0.40.0

**Début** : 31/07, dans la foulée de la release `v0.36.0`. **Fin** : 02/08 sur
`v0.40.0`. Trois soirées, cinq versions — entrée écrite après coup, à partir des
commits, pour que le journal rejoigne le code.

### Ce qui était demandé

Rapprocher la ville de ses vraies références d'Albuquerque ; casser le damier
trop régulier ; donner une voiture héros à Jesse ; intégrer le nouveau Walter
livré par Benjamin ; et donner à l'interface l'identité de la série. Plusieurs de
ces demandes sont arrivées en cours de route, formulées devant l'écran — « tes
modèles sont très cubiques », « c'est encore trop carré », « pour les voitures,
218 ça va pas, c'est moche ».

### Ce qui est livré

| Version | Quoi |
|---|---|
| **0.37.0** | Albuquerque d'après 56 photos : palette sans gris froid, ouvertures **creusées** dans le bâti, quatre gabarits de pavillon, parapets, maisons de plain-pied à garage, végétation xeriscape, câbles qui traversent les rues, banquette de gravier et caniveau |
| **0.38.0** | La trame n'est plus au cordeau (îlots de 30 à 64 m, carrefours non équidistants, super-îlots), les immeubles ne sont plus des boîtes (devanture, auvent, décrochement, fouillis de toit), et Jesse s'affaisse au lieu d'attendre au garde-à-vous |
| **0.39.0** | Le Walter v2 de Benjamin et ses quatre animations livrées — marcher, courir, sauter, remettre ses lunettes |
| **0.40.0** | L'interface prend l'esthétique de la série : portrait en case de tableau périodique, barre de vie segmentée, cadran de vitesse, rappel de l'objet tenu, trois couleurs |

Hors versions : un **banc de comparaison graphique** dans le désert (trois
niveaux de détail côte à côte), la **Monte Carlo de Jesse** modelée d'après
photo, un outil qui **trace la silhouette d'un véhicule depuis une image**, et
l'analyse complète des références rangée dans `docs/16-albuquerque.md`.

### Les surprises

**Deux instruments faux, l'un derrière l'autre — et cinq conclusions tirées de
leurs images.** Le report de la démarche sur les figurants sortait un corps
disloqué, et j'ai cherché le défaut dans l'animation pendant une soirée. Il était
ailleurs, deux fois : l'aperçu de modèle cadrait sur la boîte englobante du
maillage — la géométrie *avant* déformation par le squelette — donc montrait un
sujet minuscule et décentré ; et l'export du report **embarquait les neuf actions
de Walter**, que Blender écrit toutes qu'elles soient assignées ou non. On
jugeait un report en regardant les rotations brutes de Walter posées sur un autre
rig. Une fois les deux instruments réparés — l'aperçu mesure maintenant la
géométrie réellement rendue et **imprime l'encombrement**, ce qui dit sans image
si un corps est debout — la mesure a désigné le vrai coupable : la pose de
liaison du figurant est **couchée**, 0,21 m de haut pour 1,60 de long. Le défaut
est à l'import, pas dans l'animation. *Aucun report ne réussit sur un modèle dont
la liaison est cassée.*

**« Casser PAS » : essayé, mesuré, annulé le jour même.** Rendre les îlots
irréguliers a sorti une ville juste — mais le jeu n'a pas suivi. Mesure sur
vingt-six passants : quinze sur le trottoir, **six sur la chaussée, trois dans le
désert**. Deux hypothèses éliminées avant de trouver la cause, structurelle et
côté jeu : `foule.gd` publie un seul écart de trottoir pour toute la ville, et
`pieton.gd` borne la ville par une seule étendue carrée — deux raccourcis qui
mentent dès que les rues changent de largeur. Le remède touche `pieton.gd` et
`foule.gd` avec leurs tests : pas un travail de fin de session. On a gardé les
**super-îlots**, qui cassent déjà le damier sans rien demander au jeu — 80 % de
l'effet pour 10 % du risque. Le raisonnement est dans `docs/16-albuquerque.md`,
pour que le prochain parte de la mesure.

**Le « Minecraft » n'était pas le nombre de faces.** « Tes modèles sont très
cubiques » — et la cause n'était pas la géométrie mais que *tout était dans le
même plan* : une porte peinte sur une face plate ne porte aucune ombre. Les
ouvertures sont devenues de vrais trous avec leurs quatre retours, et **la maison
qui a levé l'objection fait moins de faces que celle qu'elle remplace**. Le
réalisme est venu de la profondeur, pas des polygones. La Monte Carlo l'a redit
dans l'autre sens : ses sections étaient des rectangles, donc quatre arêtes vives
couraient sur toute la caisse — et aucune quantité de polygones ne rattrape une
arête. Il a fallu des sections *galbées*, un congé au rayon variable, pour que la
carrosserie cesse d'être une savonnette.

**Identifier un clip livré en le mesurant.** Deux des quatre animations de Walter
v2 arrivaient sans nom, avec des UUID : le bassin qui monte de 116 mm est le
saut, une main à 193 mm de la tête sans que le bassin bouge est les lunettes.
Vérifié ensuite sur planche de contact. Au passage, un piège d'export :
l'exportateur glTF n'écrit que les actions **rattachées** à quelque chose, et un
clip s'était volatilisé sans un mot — une piste NLA par action les retient
toutes. Et une règle posée pour de bon : **un clip livré prime sur un clip
fabriqué**, et une régénération ne peut plus l'écraser en silence — c'est
exactement ce qui était arrivé au Jesse de Guillaume.

**Enfin pouvoir juger une animation.** Une image fixe dit si un corps tient
debout, jamais s'il bouge bien — c'était la raison de fond de mes échecs en
animation, contournée deux sessions durant au lieu d'être réglée.
`outils/planche_animation.py` rend huit poses d'un même cycle côte à côte, comme
les poses extrêmes d'un animateur. Il a tranché en une seconde sur le repos de
Jesse : huit images identiques d'un homme au garde-à-vous.

**Un avertissement qu'on apprend à ignorer.** « Aucune voix pour ? » s'affichait
à chaque lancement — l'appelant inconnu du téléphone, muet depuis toujours,
quatre répliques sans son. Trouvé en lisant le journal de la session de test.
*C'est la troisième fois que le projet paie cette règle :* un avertissement qu'on
ignore est un avertissement qu'on n'ira pas lire le jour où il compte.

### Où on reprend

**Les passants sont à zéro depuis la 0.38.0**, désactivés le temps de casser la
trame — c'est le premier chantier de reprise : publier l'écart de trottoir par
tronçon et remplacer le bornage carré par un test contre la géométrie réelle
(`pieton.gd`, `foule.gd`), tout est écrit dans `docs/16-albuquerque.md`. Ensuite :
mettre Skyler, Jesse et les figurants au niveau du nouveau Walter ; brancher le
traceur de silhouette sur le générateur de véhicules (les accessoires ne suivent
pas encore les repères du profil) ; et, quand Benjamin le décidera, le palier 1
(#43) et le puits économique (#20).

---

## Session du 31 juillet 2026, nuit — de 0.35.0 a 0.36.0

**Début** : 31/07 vers 1 h, sur `v0.35.0`, juste après la publication de la
release. **Fin** : au petit matin, sur `v0.36.0`.

**Séance en autonomie complète**, sans personne pour juger à l'écran. C'est le
premier point à noter, parce qu'il change ce qu'on peut livrer : tout ce qui se
mesure a avancé, tout ce qui se juge à l'œil a été vérifié en capture, et une
chose a été **annulée faute de tenir cet examen**.

### Ce qui était demandé

Reprendre le désert ; mettre les vrais figurants avec la démarche de Walter ;
enrichir la ville en objets et en couleurs ; réparer deux défauts de jeu (les
voitures garées traversables, et le joueur baladé par ce qu'il percute) ; passer
sur les tickets ; publier.

### Ce qui est livré

| | |
|---|---|
| **Les voitures garées** | Elles n'avaient aucune collision : `SOLIDES_PREFIXES` était déclaré dans `ville.gd` et lu nulle part. Elles sont maintenant des corps rigides **gelés** — gratuits tant qu'ils dorment, poussables quand on les percute |
| **Le choc** | Ce qu'on percute cède : une voiture qui roule s'arrête et laisse passer, une voiture garée se fait pousser et se repose de travers |
| **Six objets neufs** | Cabine téléphonique, distributeur de journaux, abri de bus, table de pique-nique, buisson, panneaux publicitaires |
| **Des variantes** | Poubelles et bennes repeintes : une texture de 32 pixels casse la répétition mieux qu'un objet de plus |
| **Le désert** | Quatre-vingt-dix blocs de grès au pied des mesas, et son **ambiance sonore**, livrée le 27 et jamais branchée |
| **La foule** | Vingt-six passants au lieu de seize, plus près, et devant soi |

### Les surprises

**La foule était invisible, et personne ne s'en était aperçu.** Seize passants
répartis dans un anneau de quatre-vingt-quinze mètres : trois captures de rue
d'affilée n'en montraient aucun. Deux causes, toutes deux trouvées en
instrumentant plutôt qu'en réfléchissant — on comparait la distance aux
**carrefours**, distants de 57 m, donc une rue passant à dix mètres devant soi
n'était pas candidate ; et on peuplait aussi bien le dos du joueur que son champ
de vision.

**Le report de la démarche sur les figurants ne marche pas, et je l'ai cru
pendant une heure.** Le pipeline tourne de bout en bout, les clips s'exportent,
le jeu les joue — et le corps est disloqué. Je l'ai annoncé comme fonctionnel
avant de l'avoir regardé. C'est exactement la faute que le dépôt documente
depuis le premier jour : *une image ou un nombre, jamais une conviction.* Les
passants sont donc restés des boîtes, et `outils/apercu_modele.py` existe
maintenant pour rendre un modèle seul dans une pose choisie — l'outil qui
manquait pour que cette vérification coûte trente secondes.

**Deux suites de conduite sont tombées pour une raison étrangère à la
conduite.** Le circuit de tenue de route passait à soixante mètres de la ville,
et la bande de cactus est passée de 75 à 165 m dans la même nuit : la voiture a
tapé un saguaro et le test a annoncé « 0 km/h ». Le circuit de bordure, lui,
longe un trottoir — c'est-à-dire là où se garent les voitures, qui venaient de
recevoir un corps physique. **Un test isolé de son décor ne l'est jamais
vraiment.**

**Une ambiance livrée peut dormir quatre jours** faute d'un endroit où la
déclarer. Les intérieurs sont câblés un par un dans la scène ; une zone n'avait
aucun endroit équivalent. La convention — un fichier nommé d'après la zone —
remplace le câblage, et la prochaine carte n'aura rien à déclarer.

### Où on reprend

Le palier 1 (#43) est la tranche verticale suivante, et le désert a désormais
son relief, ses lieux nommés et son ambiance pour l'accueillir. Trois décisions
attendent Benjamin : les figurants (#16), la musique (#38), et l'équilibrage
(#41) le jour venu.

---

## Session du 30 au 31 juillet 2026 — de 0.30.0 à 0.35.0

**Début** : 30/07 en fin de journée, sur `v0.30.0`, dépôt propre.
**Fin** : 31/07 au petit matin, sur `v0.35.0`, sept commits, rien de poussé.

### Ce qu'on voulait

Reprendre le projet après trois jours d'arrêt, et avancer sur la carte — « je
veux avancer sur la carte, c'est le plan pour ce soir ».

### Ce qu'on a livré

| Version | Quoi |
|---|---|
| **0.31.0** | Le temps passe (une heure de jeu par minute), une mission peut imposer son heure, la ville passe de 131 à 473 m |
| **0.32.0** | Trois types d'îlot : parc, terrain vague, parking |
| **0.33.0** | Trois quartiers en bandes, le pavillonnaire et le strip mall |
| **0.34.0** | Un horizon (les Sandia), une frange clairsemée en bordure, deux routes qui quittent la ville |
| **0.35.0** | Le désert prend du relief : mesas, arroyo, fossé de la mission 1 |

Hors jeu : les quinze missions et les trois ressources rangées en documents
(`docs/15-missions.md`), le formulaire d'écriture de mission, une feuille de
route complète sur GitHub, et les tickets repris de fond en comble —
étiquettes, titres, et une première ligne qui dit à qui chaque ticket appartient.

### Les surprises, et ce qu'elles ont coûté

**La ville de 473 m tournait à 6 images/seconde, et la géométrie n'y était pour
rien.** Ni les 1 682 décors, ni les 512 lampadaires, ni les douze mille faces :
en retirant les seuls passants on remontait à 55. Le générateur en écrivait un
par côté d'îlot — 255 au lieu de 15. **La règle qui en sort : ce qui est écrit
par îlot ET vivant à chaque image finira par tuer le jeu.** La foule a
maintenant un effectif fixe, comme le trafic.

**Trois défauts sont tombés en branchant la foule sur le graphe des rues**, et
le premier dormait depuis six versions : `pieton.gd` calculait l'arrivée depuis
la direction inverse du tronçon, donc les passants traversaient la chaussée en
diagonale. Personne ne l'avait vu parce que `foule.gd` construisait le graphe
**sans jamais poser personne dessus**. Le code mort ne se teste pas.

**Le tirage des types d'îlot partageait son flux aléatoire avec le reste du
générateur.** Changer la densité d'un parking redistribuait la carte entière :
une capture cadrée sur un terrain vague s'est retrouvée nez à nez avec un
immeuble. Chaque îlot tire maintenant depuis sa propre position.

**Un mur de roche en plein centre-ville**, puis deux autres au milieu de la
carte du désert : les crêtes ont été posées du mauvais côté d'un axe, puis du
bon côté mais dans la zone d'une autre carte. Les deux se voyaient sur la
première image et sur aucun test.

**J'ai documenté un muret en parpaing que je n'avais pas écrit.** Trouvé en
regardant la capture. La règle du projet — on mesure le fichier produit, jamais
l'intention — vaut aussi pour les commentaires.

**Une piste qui serpente reprend tout ce qui était posé en supposant une piste
droite.** Le camping-car s'est retrouvé garé sur la chaussée, et le fossé
comblé par le nivellement de la route. Les deux se calculent maintenant à
partir d'elle, et le générateur publie ses lieux au lieu que le jeu en garde
des copies.

### Ce qu'on a mesuré, et qui servira

| | 8×8 (473 m) | 16×16 (929 m) |
|---|---|---|
| Images/seconde, de jour | 55 | 57 |
| Images/seconde, de nuit | — | 55 |
| Mémoire | 117 Mo | 258 Mo |
| Nœuds | 11 900 | 27 600 |

Quatre fois la surface ne coûte rien. Ce qui coûte, c'est ce qui bouge. Et
quinze fois la ville actuelle tout chargé en même temps ne tiendra pas — d'où
le gestionnaire de zones, à écrire quand la troisième zone arrivera.

### Où on reprend

Le désert est en pause à mi-chemin : il a son relief et ses lieux, il lui
manque de quoi jouer la mission 1. Ensuite, au choix : finir le désert, ou
attaquer le puits économique (#20), qui est ce qui répondra vraiment au « ça
fait un peu vide ».

---

## 2026-07-25 — V0 et V1 : le projet tourne et je peux le regarder

**Voulu** : un squelette Godot qui charge, le rendu PS2 en place, et surtout savoir si
Claude peut produire une image de Godot tout seul.

**Obtenu** : les deux. `godot --path game --script res://verifs/capture.gd` rend une image
512×288 via Vulkan et l'enregistre. La boucle « génère, rends, regarde, corrige » est donc
fermée côté Godot aussi, pas seulement côté Blender.

**Surprises** — quatre, toutes utiles pour la suite :

1. **Fausse piste, corrigée le jour même.** J'ai d'abord conclu que l'éclairage par sommet
   imposait de tesseller toutes les grandes surfaces — un sol de 4 sommets n'étant éclairé
   qu'à ses 4 coins. C'était vrai en par-sommet, mais **on a gardé le par-pixel**, et là un
   sol de 4 sommets s'éclaire très bien. La vraie cause du sol noir était le point 4.
   Leçon de méthode : j'ai tiré une règle générale d'une observation faite dans une
   configuration qu'on allait justement abandonner. Les docs ont été corrigées.
2. **Par sommet et par pixel donnent le même rendu à 512×384.** L'écart est invisible à
   cette résolution. On garde le par-pixel : plus prévisible, et le look PS2 vient du
   filtrage, de la basse résolution et du brouillard, pas du mode d'ombrage.
3. **L'ambiante doit être nettement au-dessus de la couleur du brouillard**, sinon tout ce
   qui n'est pas sous un lampadaire est un aplat parfaitement noir. Montée de 0,16 à 0,50.
4. **Le premier plan a besoin de sa propre source.** Le noir de l'avant-plan n'était pas un
   bug d'éclairage mais de composition : le lampadaire le plus proche était à 16 m. Dans le
   jeu réel, ce sont les phares du véhicule qui régleront ça — à ne pas oublier en V3.

**Aussi** : passage en **4/3** (rendu interne 512 × 384, fenêtre 1024 × 768, ratio verrouillé
donc bandes noires sur écran large). Et convention audio arrêtée : WAV+QOA pour les
bruitages, Ogg pour la musique, jamais de MP3, tout son 3D en mono.

**Prochain** : V2, textures 128 px et générateur de ville.

---

## 2026-07-25 (suite) — V2 et V3 : la ville existe, la voiture roule

**Voulu** : une ville générée qu'on puisse parcourir, et un véhicule conduisible.

**Obtenu** : les deux. Chaîne complète Python → Blender → glTF → Godot, sans intervention
humaine. Ville de 2 × 2 îlots, 122 m de côté, 743 faces. Voiture de 54 faces, roue de 30.

**Surprises** :

1. **Une seule travée par texture de façade était une erreur.** Toutes les fenêtres d'un
   immeuble se retrouvaient dans le même état — bâtiment entièrement éteint, mort. Passé à
   2 × 2 travées : le mélange allumé/éteint apparaît, et la répétition se voit moins. C'est
   ce que faisaient les jeux PS2, pour cette raison exacte.
2. **32 lampadaires à énergie 9 saturent tout.** Le premier rendu était un aplat orange.
   Descendu à 2,6 avec 17 m de portée. Leçon : l'éclairage se règle après avoir posé
   *toutes* les sources, jamais sur une seule.
3. **La caméra de capture était écrasée par la caméra de poursuite**, qui réécrit sa
   position à chaque image de physique. L'outil crée maintenant sa propre caméra et la rend
   active — robuste quel que soit le script en place.
4. **Le toit de la voiture était en verre.** Mon test « est-ce la cabine ? » couvrait tout
   le pavillon. Seules les faces réellement inclinées — pare-brise et hayon — sont vitrées.
5. **Une gomme de pneu photométriquement juste est invisible de nuit.** Éclaircie
   arbitrairement de 27 à 46. Le réalisme perd contre la lisibilité, systématiquement.

**Ce que je ne peux pas juger** : si conduire est agréable. Les 150 images de physique
tournent sans erreur, la voiture tient la route, mais le ressenti se teste au clavier.
C'est le seul point où Benjamin est indispensable.

**Deux bugs remontés par Benjamin au premier essai au clavier**, et ils valident la
méthode : je ne pouvais pas les trouver seul.

6. **Le `VehicleBody3D` de Godot pousse vers +Z, pas vers -Z.** Exception à la convention
   du moteur, où tout le reste — caméras, `look_at` — regarde vers -Z. J'ai tranché en
   mesurant plutôt qu'en relisant la documentation : `outils/test_sens.gd` applique une
   poussée et projette le déplacement sur le nez. Verdict sans appel, 9,81 m à l'envers.
   Corrigé par une constante `SENS_POUSSEE`, pas en retournant la scène — mélanger deux
   conventions dans un même projet coûte plus cher qu'un signe documenté.
7. **La marche arrière tremblait parce que je comparais une vitesse NON signée.** Reculer
   fait monter cette vitesse, elle repasse le seuil, le code croit qu'on avance et freine,
   la vitesse retombe, il repart en arrière. Plusieurs fois par seconde. Corrigé en
   projetant la vélocité sur l'axe du nez : le signe distingue enfin « je freine » de
   « je recule ».

Le test de sens est resté dans le dépôt comme non-régression, accessible par
`.\bg.ps1 test`. C'est typiquement le piège qui revient à la première refonte.

**Prochain** : V4, Walter jouable à pied.

---

## V6 — Les maisons de Walter et Jesse

Deux maisons posées sur la rue du haut de la grille, avec un intérieur dans lequel on entre
par la porte. Extérieur et intérieur ne se touchent jamais : l'intérieur est déporté six
cents mètres à l'écart du monde, et le passage est masqué par un fondu au noir. C'est ce que
faisaient GTA III et Vice City, et pour une raison très concrète — la caméra se tient à 3,6 m
derrière le personnage et traverserait les murs en permanence dans une pièce de sept mètres.

**Le repère du seuil n'arrivait pas dans le `.glb`.** Il s'appelait `Porte`, le battant de
la porte porte le matériau `porte`, et l'exportateur glTF de Blender a fusionné les deux :
le fichier exporté contenait un *maillage* nommé `Porte`, à l'origine de la maison, et plus
aucun repère. Côté Godot, `find_child("Porte")` trouvait ce maillage et le prenait pour le
seuil — donc entrer se serait déclenché depuis le milieu du salon, et ressortir aurait déposé
Walter à l'intérieur du mur. Rien n'aurait planté. Renommé en `Seuil`, et `maison.gd` gueule
maintenant si le repère manque, parce que c'est une panne parfaitement silencieuse.

Trouvé en comparant les objets présents en scène côté Blender avec la liste des nœuds du
`.glb` exporté. Le raisonnement seul ne donnait rien : les deux intérieurs exportaient leurs
repères sans problème, seul l'extérieur perdait le sien.

**Le cache d'import de Godot a ensuite fait croire que le correctif ne marchait pas.** Le
`.glb` régénéré sur le disque, mais `.godot/imported` tenait encore l'ancien. Un
`--headless --import` avant de tester, sinon on corrige à l'aveugle.

**La caméra devait sauter, pas suivre.** Elle rattrape sa position en lissage : sur six cents
mètres, elle aurait mis plusieurs secondes à traverser, et on aurait vu défiler le vide.
`recaler()` la repose d'un coup pendant le noir.

**Les façades étaient des silhouettes noires.** Les maisons sont hors de la grille, donc hors
de portée des lampadaires, qui ne sont générés qu'autour des îlots. Une lumière de porche
au-dessus de chaque porte règle la lisibilité et désigne l'endroit où aller — et c'est ce
qu'a n'importe quelle maison de banlieue, donc ça ne coûte rien.

`outils/test_maison.gd` entre et ressort en mesurant les positions, parce que c'est une
téléportation masquée par un écran noir : quand elle se trompe, elle ne plante pas, elle
dépose le joueur dans un mur et personne ne voit rien. Huit suites maintenant.

**Prochain** : V7, les personnages dans les maisons et le dialogue.

---

## V7 — Les habitants et le dialogue

Skyler chez Walter, Jesse chez lui. On leur parle avec la même touche que le reste, et le
texte ne vit nulle part dans le code : il est dans `game/donnees/dialogues.json`, que
Guillaume peut réécrire sans ouvrir Godot. Reparler à quelqu'un donne la conversation
suivante, puis ça recommence — trois par personnage pour l'instant. C'est peu, mais des PNJ
qui radotent est ce qui fait le plus vite sentir qu'un monde est vide.

**Les personnages sortent du même générateur.** Un visage PS2 est une texture sur une boîte —
aucune géométrie ne représente un nez à ce budget de triangles. Tout le personnage tient donc
dans une poignée de traits, et ces traits sont maintenant des paramètres : calvitie, lunettes,
bouc, couleur de peau, couleur de cheveux. Ajouter un habitant coûte une entrée de
dictionnaire dans `gen_textures.py`, pas une fonction de plus. Le maillage, lui, ne change
jamais — ce qui veut dire que l'animation procédurale écrite pour Walter marchera telle
quelle sur n'importe lequel d'entre eux.

**Jesse se tenait à l'intérieur de son plan de travail**, coupé à la taille. Rien ne plantait,
rien ne s'affichait en rouge — il fallait aller le voir. Un habitant est un point, un meuble
est une boîte : la vérification tient en six lignes, elle est maintenant faite à la
génération et refuse d'exporter une pièce mal fichue.

**Les cheveux de Skyler étaient blond doré et son visage ne se lisait plus.** À trente pixels
de haut, cette teinte se confond avec la carnation : on ne voyait qu'un bloc uni. Passé en
blond cendré. À cette résolution le contraste passe avant la justesse de la teinte, et c'est
une règle qui vaudra pour tous les personnages à venir.

**Le personnage se fige sans qu'on suspende sa physique.** Un simple `set_process(false)`
pendant le dialogue l'aurait arrêté net, une jambe en l'air. Un drapeau `bloque` coupe les
commandes, il finit son pas et repose ses pieds normalement.

Un piège de méthode, aussi : ma première lecture des captures concluait « Skyler est de dos ».
Elle était simplement quatre mètres plus loin que Jesse dans le cadre, donc sa tête faisait
vingt pixels. J'ai vérifié de quel côté le générateur pose le visage — en interrogeant les UV
du maillage, pas en relisant le code — avant de toucher à quoi que ce soit. Bien m'en a pris :
l'orientation était juste, le problème était le contraste.

Neuf suites.

**Prochain** : V8, la roue des outils.

---

## V8 — La roue des outils

Revolver, cristal, « Feuilles d'herbe » et le porkpie. On maintient **Tab** (ou le clic
droit), on choisit avec gauche/droite, on relâche pour équiper. Rechoisir ce qu'on tient
déjà le range — sinon il n'y a aucun moyen de revenir aux mains vides une fois qu'on a pris
quelque chose.

**La roue est dessinée, pas assemblée en nœuds.** Le nombre de parts vient de
`donnees/outils.json` : ajouter une entrée ajoute une part, sans toucher à quoi que ce soit.
Une roue faite de nœuds posés à la main devrait être refaite à chaque objet ajouté.

**On valide au relâchement, pas à l'appui.** C'est ce qui fait de la roue un geste continu
plutôt qu'un menu où l'on entre et d'où l'on sort. Et le temps ralentit sans se figer —
`Engine.time_scale` à 0,25 — ce que faisaient les jeux de l'époque : le monde reste vivant
derrière, mais on n'est pas en danger pendant qu'on choisit.

Les objets sont accrochés **une fois pour toutes** au démarrage puis simplement masqués. Les
instancier au changement provoquerait un temps de chargement au moment précis où l'on tourne
la roue, c'est-à-dire au pire moment.

**Les quatre orientations étaient fausses au premier essai** — revolver pointant le sol,
livre à plat comme un plateau. Les objets sont modélisés avec l'axe long vers le haut et le
point de prise à l'origine : après conversion glTF, la rotation nulle donne déjà une prise
correcte. Mes valeurs « corrigeaient » un problème qui n'existait pas. Tout est dans le
fichier de données, donc corrigé sans rien régénérer.

**Un piège de capture, à retenir.** Mon premier gros plan sur la main a photographié
**Skyler**. `find_child("MainD")` depuis la racine descend en profondeur, et les maisons
viennent avant le joueur dans l'arbre — tous les personnages ont les mêmes noms de segments.
Chercher depuis le joueur, jamais depuis la racine.

**Et un piège Godot qui a failli passer.** La première version du test annonçait « le
revolver apparaît » pour les quatre outils, y compris les mains vides : `visible` est
**local** en Godot, un maillage garde `visible = true` sous un parent masqué. C'est
`is_visible_in_tree()` qu'il faut. Un test qui valide toujours est pire que pas de test.

Dix suites.

**Prochain** : V9, HUD, export Windows, et le week-end est bouclé.

---

## V9 — HUD, export Windows, et le jalon est atteint

Un compteur de vitesse en bas à droite, et le nom de l'outil annoncé une seconde et demie
quand on l'équipe. **Rien d'autre.** La règle que je me suis donnée : n'afficher que ce qui
change. Un compteur immobile pendant qu'on marche est du bruit, pas de l'information — donc
il n'apparaît qu'au volant, et le nom de l'outil s'efface puisque l'objet se voit dans la
main.

Le HUD vit **dans** le SubViewport, donc rendu à 512 × 384 comme le reste. Un texte net
superposé à une image basse résolution trahirait immédiatement un jeu moderne : les HUD PS2
partageaient le même tampon que la 3D, et c'est ce qui leur donne ce grain. Chaque chiffre
est cerné de noir, sinon il passe devant un phare et devient illisible une seconde sur trois.

La vitesse est **lissée**. La valeur brute d'un `VehicleBody3D` oscille d'un ou deux km/h à
chaque image ; affichée telle quelle, le compteur papillonne.

**Le HUD interroge le contrôleur au lieu de deviner.** Il aurait été plus court de lire
l'état directement, mais deux sources de vérité finissent toujours par diverger — et celle
qui compte est celle qui décide.

### L'exécutable

`.\bg.ps1 exporter` produit `build\BG.exe`, 113 Mo, qui se lance seul. Les modèles d'export
sont un téléchargement à part de 1,2 Go, absent de l'installation de Godot : sans eux
l'export échoue avec un message qui ne dit pas quoi faire. La commande les installe elle-même
la première fois.

`export_presets.cfg` est **volontairement suivi par git**, contrairement à l'habitude. Godot
l'exclut par défaut parce qu'il peut contenir des mots de passe de signature ; le nôtre ne
contient que des réglages de build, et le partager évite que chacun refasse la configuration
à la main et produise un exécutable différent.

### Le jalon

> « On conduit une voiture dans quatre blocs d'Albuquerque, de nuit, avec le rendu PS2, et
> on peut descendre du véhicule. »

Atteint, et dépassé : les deux maisons, leurs habitants, les conversations et la roue des
outils n'en faisaient pas partie. Dix suites de tests, chacune écrite après un vrai bug.

Ce qui a le plus servi, sur trois jours : **la boucle de capture hors écran**. Pouvoir rendre
une image et la regarder sans déranger personne a trouvé le seuil perdu à l'export glTF,
Jesse planté dans son plan de travail, le visage illisible de Skyler, les quatre orientations
d'objets fausses. Aucune de ces choses ne provoquait d'erreur. Toutes se voyaient.

Ce qui a le plus coûté : **les pannes silencieuses**. Le SubViewport sans écouteur audio, le
repère glTF fusionné avec un matériau, le cache d'import qui sert l'ancienne version, un test
qui validait toujours. Aucune ne plantait. C'est pour ça qu'il y a dix suites plutôt que zéro.

**Reste à décider ensemble** : les blocs A, B, C et F de `00-questions.md`, toujours sans
réponse. Rien de ce qui a été fait n'en dépendait — mais la suite, si.

---

## Correctif — récupérer du travail ne rechargeait pas les nouveaux assets

Trouvé en répondant à la question « comment Guillaume récupère la dernière version ». La
réponse était `.\go.ps1`, et elle était **fausse**.

Godot garde une copie convertie de chaque fichier 3D, image et son dans `.godot\`, qui n'est
pas suivi par git — et ne peut pas l'être, c'est un cache machine. Un fichier qui arrive par
`git pull` sans cette copie **ne se charge pas du tout** :

```
ERROR: Cannot open file 'res://.godot/imported/arme.glb-....scn'
```

`bg.ps1` n'importait qu'au tout premier lancement, quand `.godot\` était absent. Guillaume,
qui l'avait déjà, aurait pullé les maisons, les habitants et les objets — et lancé un jeu où
rien de tout ça n'existe. Le jeu démarre quand même, ce qui est le pire cas : pas de plantage,
juste un monde amputé.

Même piège pour les scripts : les noms déclarés par `class_name` vivent dans un cache du même
dossier. Sans lui, `Pnj`, `Dialogue` ou `Roue` sont introuvables à l'exécution.

Vérifié plutôt que supposé : j'ai mis de côté l'entrée de cache de `arme.glb` et relancé la
suite. Quatre erreurs de chargement, trois tests au rouge. C'est exactement ce qu'il aurait vu.

Corrigé en datant le dernier import et en le refaisant dès que quoi que ce soit a bougé sous
`game\`. Coût mesuré : **10 s la première fois, 1,3 s quand rien n'a changé.** Ça ne se
remarque pas, et ça supprime une classe entière de « chez moi ça marche ».

C'est la troisième fois que ce cache nous coûte du temps — les maisons, puis les personnages,
puis ça. Il est maintenant traité une fois pour toutes, dans la seule commande que tout le
monde utilise.

---

## Correctif — les maisons étaient injouables, et c'est un défaut de conception

Benjamin ne les trouvait pas. Elles étaient au nord, dans le désert au-delà de la dernière
rue, à cent mètres du point de départ. La raison était mécanique : le générateur bâtit les
quatre côtés de chaque îlot, il ne restait **pas un mètre carré libre en bordure de rue**.
Le désert était le seul emplacement possible.

En jeu, ça donnait deux maisons au bout du monde, dans le noir, sans rien pour indiquer d'y
aller. On fait naturellement demi-tour avant de les atteindre. Une explication n'y aurait
rien changé.

**Le générateur accepte maintenant des parcelles réservées.** Un `RESERVES` repéré par îlot
et par côté — pas en mètres, pour que ça survive à un changement de taille d'îlot. Le côté
réservé reçoit un sol en terre au lieu d'immeubles. Walter et Jesse occupent la façade sud
de l'îlot (0, 0), qui donne sur le carrefour de départ.

**Et le point de départ est passé devant chez Walter**, sur le trottoir, porte éclairée à
deux pas. C'est aussi ce qui a du sens narrativement : Walter part de chez lui.

### Deux choses trouvées en déplaçant, qu'aucune n'aurait été trouvée autrement

**La voiture partait vers le bord de la carte.** Garée le long d'une rue horizontale, elle
demandait un quart de tour — et le quart de tour que j'avais écrit l'orientait vers -X, à dix
mètres du vide. Mesuré par `test_sens.gd`, qui applique une poussée et projette le
déplacement, plutôt que déduit du contenu de la matrice.

**Le test de franchissement de bordure s'est mis à échouer sans que le franchissement ait
changé.** Il place la caméra par son cap pour que « avancer » pointe vers le trottoir — mais
la caméra rejoint sa position **en lissage**, et la direction de marche est calculée à partir
de son orientation réelle, pas du cap voulu. Tant qu'elle était en route, le personnage
marchait ailleurs. Le test tenait uniquement parce que le point de départ était à dix mètres
de là ; en l'éloignant, il s'est cassé.

C'est le genre de test qui passe pour de mauvaises raisons, et on ne l'apprend qu'en changeant
autre chose. Il force maintenant la caméra à se placer d'un coup.

Dix suites, toujours.

---

## V10 — Habiller les rues et les jardins

Huit accessoires générés — poubelle, benne, boîte aux lettres, banc, panneau, bouche
d'incendie, saguaro, climatiseur — pour **234 faces au total**. Ce sont des silhouettes vues
de loin dans le brouillard, jamais des maillages de héros : huit côtés suffisent à lire un
cylindre, et coûtent trois fois moins qu'un cercle lisse.

**Rien de tout ça n'est cuit dans le maillage de la ville.** Le générateur écrit seulement
où poser, dans le même JSON que les lampadaires ; le jeu instancie au lancement. Trois cents
poubelles fondues dans le `.glb` pèsent trois cents fois le prix d'une seule. Et chaque type
n'est chargé **qu'une fois** : cent exemplaires d'une `PackedScene` partagent son maillage et
sa texture, là où un `ResourceLoader.load` par exemplaire les rechargerait à chaque appel.

139 éléments posés, 6 modèles.

**Le mobilier va contre les façades, pas au bord du trottoir**, parce que les lampadaires
occupent déjà la bordure. Les deux rangées ne se croisent jamais et le passage reste libre au
milieu — un trottoir infranchissable serait pire que vide.

**Presque rien n'a de collision.** Une poubelle qui arrête une voiture est plus pénible
qu'une poubelle qu'on traverse. Seuls la benne, le banc, le cactus et le panneau sont
solides : ceux-là, on ne pardonne pas de passer au travers.

Les jardins sont meublés **à partir du seuil**, pas de coordonnées écrites en dur : la maison
peut grandir ou déménager, la boîte aux lettres suit. Volontairement peu de choses, et toutes
en retrait de l'allée — ce qui encombre le chemin de la porte se paie à chaque fois qu'on
rentre chez soi.

Et soixante-douze saguaros semés autour de la ville. Le désert est un aplat parfaitement plat
et parfaitement vide : de nuit, il ne se distinguait pas du néant. Quelques silhouettes
suffisent à lui rendre une échelle.

### Ce que le test a trouvé

`test_decor.gd` vérifie qu'aucun élément ne traîne au milieu d'un carrefour — une poubelle
sur la chaussée ne provoque aucune erreur, elle attend juste qu'on lui rentre dedans à
quarante — et que rien ne coince le point de départ.

Il a surtout trouvé autre chose : **133 des 139 nœuds s'appelaient `@Node3D@35`.** Godot
refuse deux frères homonymes et renomme le second. Sur cent trente éléments, l'arbre devenait
illisible et le recensement par type ne voulait plus rien dire. Rien ne cassait — c'est
précisément le genre de chose qu'on ne voit que si on la mesure. Ils sont nommés maintenant,
et le test échoue si un seul redevient anonyme.

Onze suites.

---

## V11 — La roue ne répondait pas, et le jeu passe en journée

### Le bug de la roue

Benjamin : « j'arrive pas à changer d'objet sélectionné ». Diagnostic en une phrase :
**la roue lisait les touches par événement, et toute l'interface vit dans le `SubViewport`
de rendu.** Godot ne propage pas les événements d'entrée dans un `SubViewport` qui n'est pas
sous un `SubViewportContainer` : le `_unhandled_input` y était silencieusement mort.

Rien ne le signalait. La roue s'ouvrait, s'animait, ralentissait le temps, se fermait — et la
sélection ne bougeait jamais. Le reste du jeu scrute déjà les touches (`Input.is_action_...`),
ce qui explique que l'ouverture et la fermeture, elles, marchaient.

Passée en scrutation, comme la convention du projet le voulait depuis le début.

**Le test a d'abord échoué pour une mauvaise raison**, ce qui vaut d'être noté :
`is_action_just_pressed` reste vrai **jusqu'à la fin de la trame** où la touche a été
enfoncée, même après relâchement. Deux appuis dans la même trame comptent tous les deux pour
le premier. Le test concluait que « gauche » ne marchait pas alors que le fautif était le
test. Il s'étale maintenant sur plusieurs trames.

### La journée

Le moment de la journée n'est **pas** un curseur, et c'est le point de conception :
**l'état des vitres est cuit dans les textures de façade**. Un booléen côté jeu pourrait
contredire les textures, et on obtiendrait un ciel de midi sur des fenêtres allumées sans
savoir lequel des deux a tort.

Le générateur de textures écrit donc le moment dans `game/donnees/monde.json` en même temps
qu'il cuit les vitres. Cinq systèmes le relisent : le rendu pour son ciel et son soleil, la
ville pour ses lampadaires, la maison pour son porche, le véhicule pour ses phares.
**Une seule source, écrite par celui qui décide.**

`.\bg.ps1 generer -Moment jour`

Ce qui change de jour, au-delà des couleurs :

- **Un soleil.** De nuit il n'y a aucune source directionnelle, tout vient des lampadaires.
  Sans soleil, la ville de jour est un aplat ambiant sans une seule ombre, et tout paraît plat.
- **Aucun lampadaire créé** — pas éteint, pas créé. Une source coûte même quand son énergie
  est nulle, sur PS2 comme aujourd'hui.
- **Les vitres renvoient le ciel** au lieu d'être allumées. Sinon on obtient des carrés jaunes
  qui brillent en plein soleil, ce qui trahit immédiatement une scène de nuit éclaircie.
- **La brume blanchit le lointain au lieu de l'assombrir**, et on voit à 340 m au lieu de 58.
- **La brume ne mange plus le ciel.** `fog_sky_affect` à 1 convient à la nuit, où le ciel
  *est* le brouillard. De jour, ça donnait un aplat gris pâle au lieu du bleu d'Albuquerque.
  Descendu à 0,25.

`test_jour.gd` vérifie que la bascule est appliquée partout : une bascule à moitié faite ne
plante pas, elle donne une ville de nuit avec un soleil.

Douze suites.

---

## V12 — La caméra, et la vie dans les rues

### La caméra ne traverse plus les murs

Un rayon du sujet vers la caméra, et un rapprochement si quelque chose bloque. Deux
décisions comptent :

**Le clamp est appliqué APRÈS le lissage**, sur la position finale, pas sur la position
visée. Lisser vers une cible déjà corrigée laisserait la caméra traverser le mur pendant
qu'elle rattrape — c'est-à-dire exactement au moment où ça se voit.

**Se rapprocher est instantané, s'éloigner est progressif.** Traverser un mur ne serait-ce
qu'une image se remarque ; un retour progressif au recul nominal, non.

**Mon premier test passait sans rien prouver.** Il collait le joueur au mur et mesurait —
sauf que dans cette configuration la caméra reste dehors toute seule. Il fallait construire
le cas exprès : joueur devant la façade, **cap tourné vers la maison**, pour que la position
idéale tombe à l'intérieur du bâtiment. Contre-épreuve faite en désactivant la parade :
*« recul 4,07 m, obstacle OUI — la caméra est dans le bâtiment »*. Avec la parade, elle est
ramenée à 2,22 m.

Un test qui ne peut pas échouer ne vaut rien. Le vérifier coûte deux minutes.

### La vie

**La marche procédurale a quitté `joueur.gd`** pour `silhouette.gd`. Elle n'avait rien à y
faire de particulier : le maillage est le même pour tout le monde, seules les textures
changent. Un passant mérite exactement la démarche de Walter, et la dupliquer aurait garanti
qu'elles divergent au premier réglage.

**Vingt-et-une voitures garées** le long des trottoirs. Ce sont des `StaticBody3D`, pas des
`VehicleBody3D` endormis : une rue de véhicules physiques coûterait une simulation complète
par voiture, et la moindre d'entre elles se mettrait à glisser.

**Quinze passants**, qui font l'aller-retour sur un segment de trottoir. Aucune recherche de
chemin, aucune décision. C'est volontaire : une foule crédible ne demande pas d'intelligence,
elle demande du **mouvement** et de la **variété**. Trois apparences, trois tailles, des
allures tirées entre 0,55 et 0,95, et des pauses désynchronisées aux extrémités — sinon toute
la rue fait demi-tour en même temps.

Leur voie passe **au milieu du trottoir**, entre les lampadaires côté bordure et le mobilier
côté façade. Sans cette voie centrale, ils passeraient leur temps à buter dans une poubelle.

Ils sont sur la couche de collision du joueur, pas celle du décor : un passant qui croise la
ligne de vue collerait sinon la caméra à la nuque.

`test_foule.gd` mesure un **déplacement réel** entre deux instants. Un passant coincé contre
une poubelle a l'air parfaitement normal sur une capture — debout, bien placé, bien texturé.
Il ne bouge simplement jamais.

Quatorze suites.

---

## V13 — Aller sur le côté, et des tests ciblés

### Le vrai défaut de la caméra à pied

Benjamin : « la caméra est chelou quand je vais à gauche ou à droite, pour faire ce que je
veux je dois faire avancer ».

C'était une dette que j'avais contractée sciemment sans en mesurer le coût. Le personnage
relisait l'orientation de la caméra **à chaque image** pour savoir où est « la gauche ». Si
la caméra tournait pour le suivre, sa direction tournait avec elle, et il marchait en cercle
— le bug des tout premiers jours. Ma parade d'alors : empêcher la caméra de se recentrer
ailleurs que sur une marche avant franche. Le cercle disparaissait ; la caméra restait plantée
dès qu'on allait sur le côté.

**La bonne solution est de figer le repère au moment de l'appui**, et de le garder tant que la
touche est tenue. « À gauche » veut dire à gauche de ce qu'on voyait *quand on a appuyé*. La
direction ne dépend plus d'une caméra mobile, la boucle n'existe plus, et la caméra peut faire
son travail dans les quatre directions.

Mesure après : **6,3 m parcourus en ligne droite, 0° de dérive, caméra à 0° de l'axe** — dans
les quatre directions. Le test vérifie maintenant aussi le CADRAGE, pas seulement l'absence de
rotation : c'est précisément ce que l'ancienne version ne regardait pas.

**Le correctif a immédiatement cassé le test de bordure**, et pour une bonne raison : le
repère est figé à la *première* image d'appui. Si la caméra n'a pas encore pris sa place, on
fige une orientation périmée — et pour toute la durée de l'appui, puisqu'on ne la relit plus.
Le personnage partait à angle droit. Ajout d'un garde : tant que la caméra n'est pas posée, on
ne fige rien.

### Des tests ciblés

Demande de Benjamin, et elle est juste : rejouer quatorze suites pour un changement de trois
lignes coûte deux minutes à chaque commit.

Chaque suite déclare désormais **les fichiers qu'elle couvre**, et deux modes s'ajoutent :

- `.\bg.ps1 test -Modifies` demande à git ce qui a bougé et ne rejoue que le concerné.
- `.\bg.ps1 test -Suite camera` filtre par nom.

Essai réel : modifier `camera_poursuite.gd` et `dialogues.json` sélectionne **4 suites sur
14** — la boucle caméra, les murs, le dialogue, et le franchissement de bordure, qui dépend
de la caméra sans que ce soit évident.

Deux garde-fous, parce qu'une suite oubliée coûte plus cher qu'une suite jouée pour rien :
les motifs de couverture sont **volontairement larges**, et toucher `monde.tscn`,
`reglages.tres` ou `project.godot` relance **tout** — ce sont les trois fichiers que chaque
suite charge.

---

## V14 — La visée à la souris

La caméra était entièrement automatique. Sur PC, un GTA-like se regarde à la souris.

Souris capturée au lancement, **Échap** rend le curseur, un clic le reprend — sans issue,
une souris capturée est un piège. Molette pour le recul.

**À pied**, la souris pose le cap et le recentrage automatique **se suspend** pendant un
délai réglable. Sans ce délai, la caméra ramènerait de force dès qu'on lâche la souris, et
regarder de côté en marchant serait impossible — ce qui est tout l'intérêt.

**Au volant**, elle ne remplace pas le cap : la caméra de conduite est solidaire de la
caisse, c'est ce qui fait qu'elle accompagne les virages. La visée s'ajoute par-dessus et se
résorbe d'elle-même. Le comportement testé de la conduite est intact.

**Le tangage fait pivoter la caméra autour du sujet** — elle monte et se rapproche en même
temps. Se contenter de lever la hauteur donnerait une caméra qui plane sans jamais regarder
d'en haut.

### Le piège, évité cette fois

La souris est lue par le **contrôleur**, pas par la caméra. La caméra vit dans le
`SubViewport` de rendu, où Godot ne propage aucune entrée : un `_input` y serait
silencieusement mort. C'est exactement ce qui avait rendu la roue des outils inutilisable
pendant deux jours.

Le test envoie donc un **vrai événement** dans la boucle d'entrée du moteur, plutôt que
d'appeler la méthode de la caméra. C'est la seule façon de vérifier que la chaîne complète
tient.

**Et il s'est trompé de la même façon que le test de la roue**, ce qui commence à faire une
famille : `Input.parse_input_event` met l'événement dans la file du moteur, il n'est
distribué qu'à la trame suivante. Ma première version envoyait quarante mouvements puis
lisait l'angle dans la même trame, et annonçait une butée à 26° — c'était simplement la
valeur d'avant, aucun des quarante n'ayant encore été traité. Chaque étape envoie
maintenant, la suivante mesure.

**À retenir pour tout test d'entrée : envoyer et mesurer ne peuvent pas être dans la même
trame.**

Quinze suites. Sept jouées pour ce commit.

---

## V15 — Les voix

Chaque réplique de `dialogues.json` a maintenant un fichier audio, et le dialogue le joue en
affichant la ligne. Vingt répliques, mesurées à −6,1 dB sur le bus Interface — le test
vérifie le **volume réellement sorti**, pas la présence du fichier.

**La synthèse est celle de Windows.** Hors ligne, rien à installer, aucune clé, aucun compte.
Ce n'est pas un pis-aller : une voix synthétique de 2005 dans un jeu à l'esthétique PS2 est
cohérente, là où une voix parfaitement naturelle jurerait avec des personnages de quatre-vingt
dix faces. Tout est sorti en **22 kHz mono**, ce que sortait une PS2 — et ça masque au passage
une partie des artefacts.

Une seule voix française est installée par défaut sur Windows, et elle est féminine. Les
personnages se distinguent donc par **transposition** : `donnees/voix.json` donne à chacun sa
hauteur, son débit et son filtrage. En dessous de 0,6 la voix devient caverneuse plutôt que
masculine — les formants descendent avec la hauteur.

**Le nom du fichier est déduit du texte**, par empreinte MD5. Conséquence utile : réécrire une
réplique change son empreinte, donc son fichier. Impossible d'entendre l'ancienne version sur
le nouveau texte, ce qu'un index numéroté aurait permis sans rien signaler.

Le générateur est en PowerShell et le lecteur en GDScript : **ils ne se rejoignent que sur un
nom de fichier**. S'ils calculaient l'empreinte différemment, le dialogue s'afficherait
normalement, personne ne parlerait, et rien ne serait signalé. Le test calcule le nom avec la
fonction *du jeu*, pas avec la sienne — sinon il validerait sa propre convention.

### Le circuit pour enregistrer de vraies voix

Personne ne doit calculer une empreinte à la main. `.\bg.ps1 voix -Script` écrit
`docs/08-script-voix.md` : la liste **numérotée** des répliques, comme un vrai script
d'enregistrement.

On enregistre `001.wav`, `002.wav`, on dépose dans `livraisons/voix/`, et `.\livrer.ps1` convertit,
renomme et range. Le numéro est la première suite de chiffres du nom : `012_jesse_yo.wav`
marche aussi bien que `12.wav`. Un fichier sans numéro est laissé en place avec un
avertissement, jamais deviné.

Une ligne sans enregistrement garde la voix de synthèse. On peut donc en livrer trois
aujourd'hui et le reste plus tard.

### Ce que je n'ai pas fait

Reproduire la voix de Bryan Cranston. Fabriquer de nouvelles phrases dans la voix d'une
personne réelle, c'est produire des propos qu'elle n'a jamais tenus — autre chose que reprendre
des extraits existants. Le circuit ci-dessus accepte n'importe quel enregistrement, y compris
de vraies répliques découpées de la série : ça ne met aucun mot dans la bouche de personne.

Seize suites.

**Correctif immediat, trouve en verifiant l'ordre des etapes** : l'integration **supprimait**
la prise d'origine apres conversion. Ce qui part dans le jeu est ecrase, compresse et ramene a
22 kHz — c'est une impasse, on ne remonte pas de la. Quelqu'un qui depose sa seule copie
l'aurait perdue et aurait du refaire la prise. Les originaux sont maintenant archives dans
`livraisons/voix/originaux/`, suivis par LFS, et le scan les exclut pour ne pas les reintegrer en
boucle a chaque livraison.

---

## V16 — La première vraie voix, et le découpage

Guillaume a livré un fichier de **58 secondes** nommé `1.wav`. L'intégration l'a donc affecté
entièrement à la réplique 001 : en jeu, Skyler disait « Tu rentres tard » et on entendait une
minute de monologue.

Ce n'était pas une erreur de sa part. **On n'arrête pas le micro entre chaque phrase** — une
longue prise est le cas normal. C'est le circuit qui manquait une étape.

### Le découpage

`.\bg.ps1 voix -Decouper <fichier>` cherche les silences et extrait les segments parlés.
Le seuil se règle : `-Pause 0.6` donnait 13 segments, `-Pause 0.3` en donnait 20, `-Pause 0.9`
en donne **9** — exactement les neuf phrases de la confession du pilote.

Rien n'est affecté automatiquement par défaut. Le nombre de segments ne correspond presque
jamais au nombre de lignes : on se reprend, on tousse, on enchaîne deux phrases. Deviner
produirait un doublage où chacun dit le texte du précédent, sans que personne ne voie d'où ça
vient. `-Assigner -Depuis 11` existe pour le cas où l'on a **vérifié** que la prise suit le
script — ici, un monologue lu d'une traite, donc l'ordre était garanti.

### Reconnaître ce qu'il y a dans un fichier

Je ne peux pas écouter. Mais Windows a un moteur de reconnaissance français hors ligne, et je
connais les phrases attendues : les donner comme **grammaire fermée** transforme la
transcription libre en un choix parmi vingt, ce qui est bien plus facile.

Repère mesuré : une phrase de synthèse propre atteint **93 %**. Les segments de Guillaume
plafonnaient à **30 %**, avec la même phrase reconnue trois fois — verdict sans appel, ce
n'était pas le script. Benjamin a confirmé : c'était la confession, en anglais.

Le moteur est resté dans l'outil sous `-Reconnaitre`. Il ne dira pas ce qui est dit hors du
script, mais il répond à une question qui compte : *cette prise correspond-elle à la réplique
qu'on croit ?*

### Deux pièges bouchés au passage

**`-Refaire` aurait écrasé les vraies prises par de la synthèse.** Une soirée
d'enregistrement perdue, et le seul avertissement aurait été le silence de celui qui les
avait faites. Un registre `enregistrees.json` liste les répliques doublées pour de vrai.

**Ce registre est tenu par l'intégration, pas déduit du nom des archives.** Première version :
je lisais le numéro dans le nom du fichier archivé. Sauf qu'une prise unique couvre ici les
répliques 11 à 19, et son nom ne peut en porter qu'un — la 001, précisément celle qu'elle ne
contenait pas.

**État** : neuf répliques en vraie voix, dix en synthèse, dans la même conversation. Le
mélange fonctionne, c'est ce qui permet d'avancer par morceaux.

### Le virage : la caisse raclait vraiment

*« Quand je tourne j'ai l'impression qu'elle touche le sol sur le côté et ça la ralentit. »*
Impression exacte, et mesurée : **garde au sol de −0,008 m** en courbe. Le bas de caisse
passait sous le sol.

Trois causes empilées, trouvées une par une :

**Les corrections précédentes n'étaient pas actives.** `reglages.tres` écrase les valeurs par
défaut du script — l'adhérence y était toujours à 0,85. J'avais corrigé le script en croyant
avoir corrigé le jeu. C'est le fichier de Benjamin, mais des unités fausses ne sont pas un
goût : corrigé là où ça compte.

**La raideur décide de la garde au sol**, ce qui n'est pas évident : plus le ressort est mou,
plus la caisse s'affaisse sur ses roues. À 42 elle ne gardait que 24 cm sous le plancher — et
12° de gîte en mangent 20.

**La boîte de collision descendait jusqu'aux roues.** Ce sont les roues qui portent la
voiture ; la caisse n'a aucune raison d'aller si bas. Son bas est remonté de 0,39 à 0,55.

Résultat : **0,140 m de garde en virage**, contre-roulis de 1,2°, et elle garde sa vitesse.

**Une barre anti-roulis écrite puis mesurée inutile.** Elle réduisait le contre-roulis de
moitié à 1,0 — gardée — mais au-delà elle coûtait dix km/h sans rien gagner sur la gîte. Le
roulis ne venait pas des ressorts mais de la suspension arrivée en butée : aucun couple ne
peut corriger ça.

**Et une leçon de mesure.** Mon premier indicateur d'oscillation annonçait 8 degrés *par
image* — un non-sens physique. Il comparait deux images consécutives mais ne mettait à jour sa
référence qu'après la quarantième, si bien que le premier écart valait quarante images de
mouvement. Le test mesure maintenant la **garde au sol**, pas l'angle : une caisse peut
pencher de quinze degrés sans rien racler si elle est haute, et frotter à huit si elle est
basse. L'angle seul ne dit rien.

Dix-huit suites.

---

## V18 — « I am the one who knocks »

Guillaume a livré la scène de la cuisine, **une piste par comédien** : `dialogue1_Skyler.mp3`
et `dialogue1_Walt.mp3`, plus le texte. Cinq répliques chacun, qui alternent.

C'est la façon normale de doubler un dialogue — chacun lit sa piste de son côté — et le
circuit ne savait pas la traiter. Il sait maintenant : `-Assigner -Depuis 1 -Pas 2` pour le
premier, `-Depuis 2 -Pas 2` pour le second.

**Les seuils de découpage ne sont pas au hasard.** 0,55 s pour Skyler, 1,4 s pour Walt — ce
sont les seuls qui donnent exactement cinq segments par piste. Trouvés en balayant, pas en
devinant : à 0,6 s Skyler tombe à quatre, à 0,45 s elle monte à dix.

Les deux MP3 n'ont pas de numéro en tête de nom, donc l'intégration les a **laissés
tranquilles** au lieu de les affecter en bloc à la réplique 001 — c'est exactement le
garde-fou écrit après la confession de Walter, et il a servi dès la livraison suivante.

Le cadre de dialogue est passé de 90 à 174 pixels : la tirade finale fait 562 caractères.

**Ce que je ne peux pas vérifier** : que chaque segment tombe sur la bonne réplique. Les
durées ne collent pas parfaitement aux longueurs de texte, et je ne peux pas écouter. Un
seul passage en jeu tranche — et si c'est décalé, il suffit de redécouper avec un autre
seuil, les originaux sont archivés.

---

## V19 — Le Walt sculpté devient le personnage jouable

Benjamin a livré `test Walt.obj` : 1088 faces, une seule pièce, **aucune coordonnée de
texture, aucun matériau**. Il se lisait immédiatement comme Walter White, ce que notre
bonhomme en boîtes ne fait pas — mais il ne pouvait ni porter d'image ni marcher.

Trois outils l'ont fait entrer dans le jeu, et ils marchent sur n'importe quel modèle livré.

### Déplier — en prenant le problème à l'envers

Blender sait fabriquer des UV tout seul, mais il place les îlots où il veut : savoir ensuite
*quel morceau de l'image est la tête* est impossible à deviner. Peindre « le visage sur la
tête » semblait donc hors de portée d'un script.

**On classe donc chaque face par sa position dans le corps** — hauteur, distance à l'axe,
orientation — et on peint sa case UV en conséquence. Le dépliage ne sert plus que d'adresse ;
sa lisibilité n'a aucune importance.

Le visage est projeté depuis l'avant, en piochant dans l'atlas que `gen_textures.py` dessine
déjà : le modèle sculpté et les personnages générés partagent la même palette, les mêmes
lunettes, le même bouc.

**Correction en cours de route** : je peignais chaque triangle d'une couleur unique prise en
son centre. Un œil couvrait une facette entière ou disparaissait entre deux. En interpolant la
position 3D **par pixel**, le dessin traverse la géométrie sans s'occuper de son découpage.

### Découper — le pivot compte plus que la coupe

Quinze segments, la hiérarchie exacte qu'attend `silhouette.gd`. Le point délicat n'était pas
la découpe : c'est que **l'origine de chaque segment doit tomber sur son articulation**, sinon
la cuisse tourne autour du genou et la jambe part en hélice.

Les articulations sont **mesurées sur la géométrie réelle**, pas supposées : un modèle plus
large ou plus étroit que le nôtre reste correct.

Résultat : il marche avec le même code, sans une ligne de différence. Le chapeau se pose sur
sa tête, le revolver dans sa main — les points d'ancrage de la roue fonctionnent tels quels.

### Ce que ça coûte, et ce qui reste

- **1088 faces contre 90.** Douze fois plus. Ça reste dans le budget PS2, mais Skyler, Jesse
  et les passants sont toujours en boîtes à côté de lui.
- **Les articulations sont franches.** À l'épaule et à la hanche, la matière se sépare quand
  l'angle est grand. C'était le cas sur PS1 ; à distance de jeu, ça ne se remarque pas.
- **Le découpage est asymétrique** — 105 faces à une main contre 53 à l'autre. Des seuils
  rectilignes sur une pose qui ne l'est pas. Réglable par paramètre, invisible au rendu.

**Un trou dans la carte de couverture des tests, trouvé au passage** : modifier
`scenes/joueur.tscn` ne déclenchait aucune suite. Changer le maillage du personnage — donc
ses segments, ses ancrages, sa taille — ne testait rien. Cinq suites le couvrent maintenant.

Dix-huit suites.

---

## V20 — Ranger, brancher les sons, et deux pannes qui ne se voyaient pas d'ici

**Voulu** : remettre Walter dans la scène, ranger un dépôt devenu confus, brancher les
vingt-huit sons livrés par Guillaume.

**Obtenu** : les trois, plus un numéro de version affiché en jeu, plus la nouvelle prise du
dialogue de la cuisine. Dix-huit commits, `v0.10.0`.

**Surprises** — cinq, et quatre concernent la même chose : *ce qui marche ici ne marche pas
forcément là-bas.*

1. **Walter n'était pas cassé, il ne se chargeait plus.** Godot extrait par défaut les
   images d'un `.glb` dans un PNG posé à côté, et le `.import` se met à en dépendre. Un
   commit précédent avait supprimé ce PNG en croyant nettoyer un doublon : le maillage ne
   se charge plus, la scène se charge quand même, le jeu se lance sans un mot.
   En creusant, mieux : les `.glb` **portent déjà leurs textures**, cuites par les
   générateurs. Les 88 PNG posés à côté ne servaient à rien — retirés, le rendu à froid est
   pixel pour pixel le même. L'extraction est coupée par défaut de projet.

2. **Aucune boucle ne bouclait, depuis le début.** Godot lit « détecter depuis le WAV » et
   nos fichiers n'ont pas de marqueur de boucle : les trois couches moteur repartaient de
   zéro à chaque fin. Personne ne l'avait vu parce que **le test moteur ne durait pas plus
   longtemps que le fichier**. La nouvelle suite dure plus que le plus court des flux, ce
   qui est la seule façon de distinguer « il joue » de « il boucle ».

3. **`bg.ps1` partait fonctionnel et arrivait cassé.** PowerShell 7 lit un `.ps1` en UTF-8
   quoi qu'il arrive ; PowerShell 5.1 — celui de Windows, celui que lance `JOUER.bat` — le
   lit en CP-1252 sans marque d'octets. Un tiret cadratin y devient trois caractères dont un
   guillemet, qui ferme la chaîne et casse tout le fichier à partir de là. L'erreur pointait
   une ligne jamais touchée. Le lanceur est repassé en ASCII, et `livrer.ps1` refuse
   désormais d'envoyer un script qui ne s'exécuterait pas chez l'autre.

4. **Un `git add -A` en plein rebase a ressuscité 28 sons**, dans leur version d'avant
   conversion en PCM — exactement celles que Godot refuse. Le jeu marchait parfaitement
   pendant ce temps, ce qui est tout le problème. Une vérification refuse maintenant qu'un
   fichier traîne à la racine de `sons/`.

5. **J'avais conclu que la nouvelle prise du dialogue était un montage des anciennes**, sur
   la seule foi des durées. Benjamin a entendu que c'était faux. Leçon : une corrélation
   circonstancielle ne vaut pas une écoute. La mesure qui a *ensuite* prouvé l'alignement
   était d'une autre nature — deux cadences de parole distinctes et chacune constante, 13 à
   16 caractères/seconde pour Skyler, 7 à 10 pour Walter. Un décalage d'une réplique aurait
   mélangé les deux.

**Ce qu'on emporte** : le dépôt a une règle unique — `game/` ne contient que ce que le jeu
charge. Le son passe par une banque en données. Et trois garde-fous existent parce que les
trois pannes correspondantes étaient invisibles depuis la machine qui les créait.
---

## 26 juillet 2026 — Walter respire, saute, s'accroupit, et fait sa première livraison

Quatre versions dans la journée : **0.25.0** à **0.27.1**. Le jeu est passé d'un bac à sable
à quelque chose qui a un début et une fin.

**Ce qui a été construit** : les animations que les modèles livrés n'avaient pas (repos avec
respiration et geste des lunettes, marche relâchée, accroupi, saut), le saut et
l'accroupissement, le choc violent au-delà de 50 mph, et **la première mission** — quinze
étapes, quatre décors, argent, barre de vie, tir, ragdoll, écran de fin.

### Ce que la journée a appris, et qui vaut au-delà d'elle

**Une mesure fausse ne prévient jamais.** Trois fois dans la journée, un nombre calculé
proprement décrivait autre chose que ce qu'on croyait :

- la foulée était réglée **à l'œil** à 1,15 m quand le clip en fait 1,76 — l'animation
  tournait 50 % trop vite, et c'est *ça* qui rendait la marche « robotique ». Elle se lit
  maintenant dans le fichier
- `get_bone_global_pose()` rend des unités de squelette, pas des mètres : la respiration
  s'annonçait à **672 mm** pour 16 mm réels. Seule l'invraisemblance du chiffre l'a trahie
- la boîte englobante d'un maillage décrit la géométrie **avant** déformation par
  l'armature. Deux modèles de 1,75 m s'annonçaient à 2,70 puis ressortaient à 3,10 après
  une mise à l'échelle censée les ramener à 1,75

Le remède est le même à chaque fois : **mesurer sur les os**, dans un repère qu'on maîtrise.

**Exister et se jouer sont deux choses.** Le geste des lunettes était dans le fichier,
mesuré à sept centimètres du visage, et invisible en jeu. Entre la pose construite et
l'animation vue, il y a une insertion de clés, un mélange et une interpolation — chacun peut
avaler le geste. On relit donc systématiquement ce qu'on vient d'écrire.

**Une régression peut être muette sur sa cause.** Les corps du ragdoll, créés au chargement
et laissés en collision, poussaient le joueur à travers le sol du salon jusqu'à −75 m.
Quatre suites sont devenues rouges d'un coup et **aucune ne parlait de ragdoll**.

**Un solveur vaut mieux qu'un angle écrit à la main.** L'orientation des os appartient au rig
et ne se devine pas. On cherche donc : l'axe de flexion du coude parmi les six possibles, les
angles qui amènent les doigts aux lunettes, les flexions qui gardent les pieds au sol pendant
que le bassin descend de quarante centimètres. Avec plusieurs points de départ — une descente
par coordonnées s'arrête dans le premier creux venu.

**Le repère de Blender n'est pas celui de Godot**, et l'export `+Y up` envoie la profondeur
`-Y` sur `+Z`. Tout le contenu du camping-car s'est retrouvé derrière sa paroi arrière : la
pièce paraissait vide depuis l'intérieur.

### Le suivi

Le ticketing est passé sur **GitHub Issues** — formulaires à champs obligatoires, étiquettes,
appli mobile. `livraisons/TICKETS.csv` reste, mais **régénéré** par `outils/tickets.ps1` :
une seule source, pas de divergence possible.

`livraisons/` est rangé par type. Deux pièges y décidaient du rangement : `sons/` est un sas
que `livrer.ps1` vide vers le jeu à chaque envoi, et `voix/originaux/` est le seul dossier
que l'intégration ignore.
