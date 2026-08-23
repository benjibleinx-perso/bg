# Notes de version

**Ce fichier s'adresse à celui qui va tester**, pas à celui qui a codé.

Une entrée dit deux choses, et rien d'autre :

- **ce qu'on peut essayer** qui n'existait pas avant, et comment y accéder
- **les bugs qui gênaient vraiment** et qui sont réparés

Les ajustements internes, les remaniements, les corrections de tests n'y sont pas.
Le détail technique vit dans les messages de commit et dans [docs/JOURNAL.md](docs/JOURNAL.md).

Le numéro s'affiche en haut à droite de l'écran. `MAJEUR.MINEUR.CORRECTIF` : **MAJEUR**
passera à 1 le jour où le jeu se tient de bout en bout, **MINEUR** quand un morceau
entier du jeu arrive, **CORRECTIF** pour un lot ou une réparation.

**Le mineur monte lentement, et c'est voulu** (décidé le 06/08/2026). Il montait
à chaque lot ; à ce rythme on atteignait 1.0 avant que le jeu tienne debout, et
le numéro ne voulait plus rien dire. Un lot livré est désormais un correctif.

**Une longue session tient dans une seule entrée** (décidé le 16/08/2026). Trente
versions en une soirée faisaient trente titres à lire, dont vingt-cinq ne
concernaient plus personne le lendemain — la moitié corrigeait ce que l'autre
moitié venait de casser. Ce qui compte, une fois la session finie, c'est ce qu'on
peut jouer et ce qui reste ouvert, pas l'ordre dans lequel on y est arrivé.

---

## 0.58.25 — la cuisine se joue

**C'était le reproche principal du retour, et c'est le gros morceau.** Les
trois étapes de cuisine étaient trois fois la même chose : on appuyait sur une
touche et un texte disait ce qui venait de se passer. Ce sont maintenant trois
mini-jeux différents, qu'on peut rater.

**Verser** (Guillaume, mot pour mot) : la souris descend, la fiole s'incline,
et on regarde **où le filet tombe**. Pas assez, il tombe avant le bécher ;
trop, il passe au-delà et éclabousse la paillasse. Il n'y a rien à lire — et
la fiole se vide, donc il faut accompagner : le geste juste au début devient
trop court à la fin.

**La plaque** : on tient le robinet, la molette fait le gaz. Le liquide ne
suit pas, il **rattrape** — pousser à fond pour aller plus vite fait déborder
dix secondes plus tard. La flamme dit le gaz, les bulles la chaleur, la mousse
qui monte dans le col est l'avertissement. Et le produit vire lentement au
bleu : c'est ça, l'avancement, pas une barre.

**La fournée** : le ballon réclame un flacon par une auréole de sa couleur,
qui pâlit. Molette pour choisir, la touche de gauche pour verser. Trois
ajouts, et c'est celui-là qui décide de la **pureté** — donc de la couleur du
cristal qu'on emporte et de ce qu'il vaudra. On peut le rater sans bloquer la
mission : ça fait du produit brun.

**Et on voit qui cuisine.** Jesse était planté au milieu du couloir, tourné
vers le mur du fond. Il est maintenant à sa verrerie, et on arrive derrière
lui.

*Deux réparations au passage.* La plus vieille : **le bleu n'était jamais
sorti** de la cuisine. Le mini-jeu comptait les paliers à partir de zéro alors
que l'échelle commence à un, donc une cuisson parfaite donnait « translucide »
et jamais « bleue ». Et l'écran de démarrage du camping-car pouvait laisser la
souris bloquée après un geste réussi.

**Ce qui manque et qui se voit** : il n'y a pas de son de liquide, de gaz ni
de verre — les trois mini-jeux empruntent des bruitages d'autre chose.

---

## 0.58.24 — le camping-car sort enfin du fossé

**Il n'en avait pas la force.** Il montait cinq mètres, ralentissait, et
calait — sans que rien ne le dise : le moteur tournait, les roues tournaient,
et on croyait mal s'y prendre.

La cause, mesurée : il pousse comme la berline, alors qu'une pente à 24 %
demande trois fois plus. Il a maintenant son propre couple, et il remonte en
peinant — ce qui est exactement ce qu'on veut voir.

*Au passage, une chose écrite depuis toujours et fausse depuis toujours* : la
scène du camping-car déclare onze tonnes, et le jeu les remplaçait par les
1 350 kg de la voiture au premier chargement. Lui rendre sa masse demande de
refaire sa suspension — essayé, il ne bouge plus du tout — donc c'est noté et
remis à plus tard.

---

## 0.58.23 — on sort du fossé en roulant, pas en trouvant la ligne

Il fallait franchir une bande de trois mètres posée en travers de la piste :
une ligne invisible, que rien n'annonce et qu'on peut manquer. « On ne devrait
pas sortir pour déclencher la suite, on ne comprend pas. »

Maintenant, la zone couvre la piste sur vingt-six mètres et c'est **le temps
de conduite** qui déclenche : on monte, on roule trois secondes, la scène part.
S'arrêter remet le compte à zéro — rouler veut dire rouler.

---

## 0.58.22 — le camping-car se démarre en le jouant

**« Le moteur tousse et cale » n'est plus écrit nulle part.** À la place, un
cadran : on tient le contact, une aiguille tourne, et il faut la cueillir dans
la zone jaune. Trois fois — et à chaque réussite la zone rétrécit et
**l'aiguille repart dans l'autre sens**, pour qu'on ne puisse pas apprendre le
rythme par cœur.

Rater ne bloque rien : le démarreur se noie, Jesse lâche un « Mr. White,
seriously ! », et on recommence en tenant le contact.

**Ce que ça change au-delà du démarrage** : la vérification qui joue la mission
de bout en bout butait sur cette étape depuis une semaine. Elle la franchit
maintenant, et deux étapes de plus avec — elle bute désormais sur la remontée
du fossé, qui est justement le prochain morceau à refaire.

*Il manque les bruitages propres* : le démarreur joue son propre son en plus
grave, ce qui s'entend comme un moteur qui se noie mais reste un pis-aller.
Guillaume propose d'en fournir.

---

## 0.58.21 — « Trois semaines plus tôt » est une vraie pause

Le saut de trois semaines était annoncé dans le bandeau de tuto, en haut à
gauche, **de la même forme que « E pour interagir »** — c'est-à-dire de la même
forme qu'une consigne de touche.

C'est maintenant un carton plein écran : le noir s'installe, la phrase s'y
pose avec un filet ambre, une note sourde l'accompagne, puis le noir se lève
sur la clairière. On ne voit jamais le décor d'arrivée avant la phrase qui
doit le cadrer.

Le mécanisme est celui de n'importe quel passage : un champ dans la scène, et
n'importe quel saut de temps ou de lieu pourra en porter un.

---

## 0.58.20 — le portrait de Walter est deux fois plus fin

Il faisait 32 pixels, et une note du générateur expliquait que c'était « sa
taille d'affichage ». C'était faux : l'interface entière est agrandie 2,8 fois
avant d'atteindre l'écran, donc ces 32 pixels s'étalaient sur 90. D'où l'aspect
grossier.

Il en fait 64, dessinés dans le même carré qu'avant. Et il montre un peu plus :
le crâne dégarni, les lunettes avec leur reflet, le bouc, et **le col de sa
chemise olive** — une tête qui flotte sur du noir ressemble à une photo
d'identité découpée.

---

## 0.58.19 — les trois ressources ne se ressemblent plus

**Elles étaient toutes olive**, alignées sur la même ligne : trois nombres de
la même couleur se lisent comme un seul bloc, et il fallait lire les mots pour
savoir lequel était lequel. Or on les regarde en conduisant.

Chacune a maintenant sa teinte, prise dans la charte et selon ce qu'elle y
signifie : **l'argent en jaune sécurité**, **la famille en bleu ardoise** — la
couleur de Skyler, celle d'un foyer qui tient — et **la rue en rouge sourd**.
La famille vire à l'ambre puis au rouge quand elle se fissure, la rue vers le
jaune quand elle devient dangereuse.

**Et le bloc a un fond.** Sur le sable, l'adobe ou un ciel de midi, le texte
passait du lisible au devinable selon l'endroit où l'on se tenait.

---

## 0.58.18 — l'écran-titre montre le pays du jeu

Il était deux lignes de texte sur du noir. Il montre maintenant ce dans quoi
on va rouler : un ciel délavé, des mesas, du sable, une route qui file vers
l'horizon — dans les teintes de la charte que Guillaume a livrée.

**Le titre est fait de deux tuiles de tableau périodique**, Br et Ba, dans le
vert de chimie que la charte réserve au titre et aux menus. C'est le principe
qu'elle autorise — la tuile et le jeu de mots — et le dessin est le nôtre.

Le menu est posé dans un cadre, comme le menu pause et la roue : c'est déjà la
forme du jeu. Et il annonce la touche de validation **telle qu'elle est
réglée**, pas celle d'usine.

*Ce qui reste du même lot* : l'interface en jeu, l'icône de Walter, les écrans
de texte, et l'intro qui doit passer avant l'écran-titre.

---

## 0.58.17 — on ne part plus faire sa vie au milieu d'une scène

**La zone de mission existe, en deux avertissements.**

Autour du camping-car accidenté, s'éloigner de trente-cinq mètres fait réagir
**Jesse** : « M. White, où est-ce que vous allez ? On n'a pas fini. » Rien ne
se fige, il le dit, c'est tout.

Si on continue jusqu'à soixante mètres, l'écran grisonne, « Vous quittez la
zone de mission » s'affiche et **dix secondes** se comptent. Revenir les
annule — il suffit de rentrer, pas besoin d'aller plus loin que là où on est
sorti. Au bout du décompte, la partie se termine sur « Vous vous êtes enfui ».

**Elle ne vaut que là où c'est logique**, et ça se déclare dans la mission :
la séquence du fossé l'a, l'étape où l'on rejoint la piste ne l'a pas — elle
consiste justement à partir — et la cuisine du flashback non plus, à neuf
cents mètres de là.

---

## 0.58.16 — on regarde mourir celui qui meurt

**Tirer sur Jesse faisait s'effondrer Walter.** Le carton annonçait « Jesse est
mort » pendant qu'on regardait le corps de quelqu'un d'autre.

Maintenant, la caméra prend celui qui meurt pour sujet, le temps ralentit, on
le voit debout une seconde — puis il bascule. Le « GAME OVER » n'arrive
qu'après, une fois le corps au sol.

**Et quand quelqu'un se fait couper la parole, la réplique suivante ne
l'attend plus.** Dans le camping-car, Jesse s'emballe — « C'est bon, c'est
bon— » — et Walter lui passe dessus sans laisser au joueur le temps
d'appuyer. L'invite disparaît d'ailleurs sur ces répliques-là : il n'y a rien
à presser.

*Ce qui n'est pas encore bon* : le plan sur le mourant, dans une petite pièce,
se retrouve collé contre un mur. La mécanique est juste, le cadrage non — ça
demande une caméra de cinématique, et c'est noté.

---

## 0.58.15 — le corps garde sa taille en tombant

**Le cadavre de Walter faisait quatre mètres.** Il fait maintenant la taille
d'un homme, couché là où il est tombé.

La cause n'était ni dans le ragdoll ni dans le code du jeu : le modèle de
Walter arrivait en centimètres, et l'échelle qui le ramenait à 1,78 m était
posée sur un nœud au lieu d'entrer dans le fichier. Le moteur physique, lui,
ignore ce genre d'échelle — d'où un corps rendu cent fois trop grand dès que
la simulation démarrait.

**Jesse et Tuco portent encore ce défaut**, et n'ont pas pu être réparés dans
la foulée : la suite de commandes qui les a fabriqués n'était écrite nulle
part, et les réimporter à l'aveugle sortait un fichier neuf fois plus lourd
sans leurs animations. Celle de Walter est maintenant écrite, et le jeu
signale à chaque vérification qui reste à traiter.

Rien d'autre ne bouge : Walter marche, court, saute, s'accroupit et porte ses
outils exactement comme avant — c'est vérifié clip par clip.

---

## 0.58.14 — le jeu se conduit comme les autres jeux

**Les touches sont enfin relatives à la caméra.** Avancer veut dire « vers le
haut de l'écran », et gauche et droite déplacent au lieu de faire pivoter sur
place. Walter se tourne vers la direction qu'il prend, et reculer, c'est faire
demi-tour et marcher vers la caméra — comme partout ailleurs.

**Et la caméra n'obéit plus qu'à la souris.** Elle ne se replace plus toute
seule dans le dos du personnage : elle reste où on la met. C'était la cause de
tout le reste — tant qu'elle cherchait son dos pendant qu'il lisait sa
direction sur elle, aller sur le côté les faisait tourner tous les deux.

**La verticale de la souris était inversée**, comme dans un simulateur de vol.
Pousser la souris vers l'avant regarde maintenant vers le haut. Ceux qui
préféraient l'ancien comportement ont toujours l'option « souris inversée ».

**La touche d'action passe de F à E**, partout — et les invites à l'écran
lisent désormais la vraie touche au lieu de la réciter.

**Un menu « Commandes » dans la pause.** Treize commandes, la touche de
chacune en face, et on en change en la choisissant puis en appuyant sur la
nouvelle. Une touche déjà prise est refusée avec le nom de ce qui l'occupe,
« Tout remettre par défaut » revient à l'état d'origine, et le choix survit à
la fermeture du jeu.

**On revient du désert à l'entrée de la ville**, devant le panneau, au lieu
d'apparaître quatre cents mètres plus loin au milieu d'une chaussée.

---

## 0.58.13 — les objets du fossé ressemblent enfin à ce qu'ils sont

**Les quatre choses à ramasser autour du camping-car ont été refaites.** Deux
d'entre elles n'étaient pas des objets : c'était du mobilier de laboratoire posé
dans le sable. « Un bidon renversé » était le meuble à deux fûts **debout** du
labo, couché de force par la scène ; « un éclat de verrerie cassée » était la
verrerie **intacte** de la paillasse.

Maintenant : un sac de toile entrouvert avec sa poignée de cuir, un jerrican sur
le flanc dont le bouchon dévissé pend, un ballon de laboratoire brisé au milieu
de ses éclats.

**Et le pantalon est un pantalon.** C'est le quatrième essai — il a été
successivement une blouse de laboratoire, un modèle taillé en boîtes, le même
posé sur la tranche, puis un tas de tissu trop compact. Il a désormais sa
ceinture de cuir en travers, ses deux jambes, et il fait 85 cm au sol.

**Le marqueur du retour au camping-car pointait à neuf cents mètres.** Au
battement où la sirène monte et où Jesse s'affole, « Retourner au camping-car »
posait son repère sur le camping-car de l'autre mission, à l'autre bout du
désert. Ça ne bloquait rien — le geste se déclenche à la portière — mais
quiconque suivait sa minimap partait traverser le désert.

> Trouvé par une nouveauté d'atelier : une vérification qui **joue** la mission
> en marchant et en appuyant sur F, au lieu de mesurer que les choses existent.
> Elle ne connaît pas la scène, donc elle suit le marqueur — comme quelqu'un qui
> découvre le jeu.

---

## 📌 La session du 16 août 2026 — de la 0.56.0 à la 0.58.12

**Trente-deux versions, et le jeu a changé de mission.** « Deux corps, un
camping-car » — le script que Guillaume a écrit le 14 — a pris la place de la
mission de rodage, puis elle est passée d'un enchaînement d'étapes qui tenaient
debout à quelque chose qu'on peut jouer.

Presque toutes ces versions sont nées d'un défaut vu en **jouant**. Pas une seule
d'un test au rouge.

---

### Ce que tu peux jouer ce soir et que tu ne pouvais pas hier

**La mission a une ouverture.** Un plan fixe sur le fossé, la fumée du moteur,
les phares restés allumés, une nappe sourde par-dessus. Puis le fondu, et tu
reprends la main sous le masque à gaz — l'écran teinté, les bords qui se
referment, ta propre respiration qui revient par le filtre. Tu appuies, le masque
tombe, et tout se lève d'un coup.

**Une sirène monte pendant que tu ramasses.** Elle est faible quand Jesse
paniqua, nette quand tu remontes vers le camping-car, au maximum pendant que le
moteur refuse de partir. Aucun chiffre, aucun compte à rebours affiché : c'est le
son qui te presse. Puis tu franchis la crête, elle se coupe net, un silence — et
c'est un camion de pompiers qui passe au loin sans s'arrêter.

> Jesse : *« On a couru pour des pompiers. »*

Ces trois répliques existaient depuis le début, doublées, et rien dans le jeu ne
pouvait les déclencher.

**Le camping-car se conduit.** Il était un décor depuis la naissance du projet ;
on quittait le fossé à pied et l'objectif avait fini par être réécrit pour ne plus
promettre ce qu'il ne pouvait pas tenir. Il pèse onze tonnes, il se balance, il
plonge au freinage, et il reste couché dans sa cuvette jusqu'à ce que le moteur
prenne — le démarrage se fait assis au volant, Jesse tape le tableau de bord à
côté de toi.

**La cuisine se joue dans le camping-car.** L'intérieur existait depuis la mission
de rodage, posé au large du monde avec ses paillasses et sa verrerie ; personne ne
pouvait y entrer. Jesse t'y fait entrer après son « bienvenue dans le bureau,
professeur », et tu y verses, tu règles la plaque, tu te fais reprendre, tu
recommences.

**Et le jeu a son premier vrai choix.** Jesse propose de sauter une étape. Deux
réponses, W/S pour choisir, F pour répondre. Aucune n'est punie et rien ne te dira
laquelle était la bonne : seule la teinte du cristal change, et personne ne la
commente. C'est le premier indice de la règle couleur du jeu.

**Le texte est net.** Tout ce qui est écrit à l'écran — HUD, objectifs, dialogues,
téléphone, écran-titre — ne fait plus ses lettres en escalier. Le grain du jeu
vient du rendu 3D et il n'a pas bougé.

---

### Ce qui s'est cassé, et ce que ça a appris

**Dix-neuf défauts trouvés en jouant, zéro par une suite** — et les suites étaient
vertes à chaque fois. Elles mesurent qu'une chose existe, jamais qu'elle est
atteignable, visible, audible ou compréhensible. Le pantalon était un modèle juste
posé sur la tranche ; l'ouverture cadrait un trottoir d'Albuquerque ; le point de
sortie tombait à vingt-et-un mètres de la piste. Tout était « présent ».

**Le pire défaut était un cercle.** On ne pouvait pas monter dans le camping-car
parce que le geste de démarrage était cherché autour du véhicule *courant*, resté
en ville à mille deux cents mètres — et le véhicule courant ne changeait qu'en
montant. Chaque morceau était correct pris à part, et rien ne pouvait le signaler.

**Trois morceaux de l'ancienne mission se sont invités dans la nouvelle** : les
tueurs de Tuco, son décompte, puis son mot de la fin joué après la première
cuisine. Toujours la même cause — des branchements écrits quand il n'existait
qu'une seule mission, qui reconnaissent une étape à son nom sans demander de
quelle mission elle vient. Une vérification refuse désormais qu'un nom serve deux
fois.

**Deux « gros chantiers » étaient déjà écrits.** L'intérieur du camping-car
attendait une porte ; la conduite ne demandait qu'un groupe et une ligne. Les deux
excuses inscrites dans le code — *« pas d'intérieur à lui »*, *« on ne le conduit
pas »* — étaient fausses, datées et argumentées. Une note d'arbitrage vieille de
trois jours se lit comme une loi.

**Le HUD : deux impasses avant une ligne.** L'interface était agrandie 2,8 fois
quand la 3D ne l'est qu'1,5 — deux fois plus grossière que le jeu qu'elle
recouvre, alors que l'argument écrit en tête du fichier invoquait le grain PS2.
Deux approches ont été tentées et annulées, chacune demandant de réécrire deux
cent quatre-vingt-neuf valeurs. La bonne réponse tenait dans un réglage de projet.

**Et la leçon la plus chère n'est pas technique.** Le script de Guillaume
contenait les réponses, et il n'a pas été relu : le démarrage a été codé comme un
geste ordinaire alors qu'A7 s'appelle *« poste de conduite »*, et la sortie de
zone posée sans repère alors qu'A8 demande *« un panneau à moitié enseveli »*.
Deux allers-retours de test pour des informations écrites depuis le début, au seul
endroit où elles existaient.

---

### Où en est la mission 1

**Les dix-sept battements du script existent**, du réveil masqué dans le fossé au
retour en plein jour devant chez Walter. Ce qui reste n'est pas de l'écriture,
c'est de la vérification et du son.

| | Séquence A — le fossé, la nuit | |
|---|---|---|
| A1 | Plan d'ouverture, fumée, phares, nappe | ✅ *musique provisoire* |
| A2 | Masque à gaz : vision filtrée, respiration | ✅ *son provisoire* |
| A3 | Les deux corps à l'arrière | ✅ |
| A4 | Jesse panique, la sirène commence | ✅ *son provisoire* |
| A5 | Trois objets à ramasser + le pantalon | ✅ |
| A6 | La sirène a nettement monté | ✅ *son provisoire* |
| A7 | Le moteur tousse, au poste de conduite | ✅ |
| A8 | **Conduite libre jusqu'à la crête** | ⚠️ **jamais joué** |
| A9 | Le retournement : ce sont des pompiers | ✅ *son provisoire* |

| | Séquence B — la clairière, trois semaines plus tôt | |
|---|---|---|
| B1 | Jesse fait entrer Walt dans le camping-car | ✅ |
| B2 | Le tablier | ✅ |
| B3 | Verser, se faire reprendre, recommencer | ✅ |
| B4 | Régler la plaque | ✅ |
| B5 | Le micro-choix de Jesse | ✅ |
| B6 | Surveiller la couleur | ✅ |
| B7 | Le premier moment de calme | ✅ |
| B8 | Retour au monde ouvert, en plein jour | ✅ |

**Seize battements sur dix-sept ont été joués au moins une fois.** Le
dix-septième — la conduite du camping-car hors du fossé — est le seul qui n'ait
jamais été essayé par personne : il est arrivé en fin de session, et ni un test
ni une capture ne peuvent dire si onze tonnes remontent une pente à 24 %.

---

### Ce qu'on te demande de regarder en priorité

Trois choses, et elles ne peuvent être tranchées qu'en jouant.

**1. Est-ce que le camping-car sort du fossé ?** Tu montes dedans après avoir
parlé à Jesse, tu démarres au volant — le moteur tousse deux ou trois fois — et
tu roules vers les deux panneaux à moitié ensevelis qui marquent la crête. S'il
patine, s'il se met sur le flanc, ou si tu franchis les panneaux sans que rien ne
se passe : dis-le tel quel, avec de quel côté tu es passé.

**2. Est-ce qu'on entend que ce ne sont pas les flics ?** C'est le seul endroit de
toute la mission où le son porte un retournement à lui seul — tu l'as écrit
toi-même dans le script. La sirène de police monte pendant cinq battements, puis
se coupe net à la crête, un silence, et le camion de pompiers passe. **Les deux
doivent s'entendre différentes sans lire le sous-titre de Jesse.**

**3. Les quatre sons, en général.** La nappe de l'ouverture, la respiration sous
le masque, les deux sirènes. Ils ont été fabriqués faute de mieux pour que la
séquence soit jouable et réglable ; personne ne les a encore entendus. Si tu fais
les tiens, on remplace quatre fichiers et rien d'autre ne bouge.

---

### Ce qui t'attend, et ce qui attend une décision

| Ticket | Ce que c'est | Où ça en est |
|---|---|---|
| **#71** | Les deux sirènes | Passé de « fabriquer » à **« remplacer »** — il y en a des provisoires |
| **#60** | L'ambiance du désert | Toujours en attente, rien n'a été fabriqué à la place |
| **#52** | Le camping-car v2 trop large | 4,40 m livrés contre 3,00 m en jeu — **à trancher** |
| **#72** | Le cahier d'implémentation | Il est cité quatre fois dans ton script et n'existe dans aucun commit |

**Et une question d'écriture, pas de son** : les pensées de Walter sont coupées
pendant cette mission. Les soixante-et-une qui existent parlent d'un homme qui
n'a encore rien fait — son diagnostic, Skyler, l'argent qui manque — et elles
s'affichaient au-dessus d'un camping-car retourné avec deux cadavres dedans.
Cette mission a besoin des siennes.

---

## 📌 La session du 8 au 9 août 2026 — de la 0.55.1 à la 0.55.7

**Six versions.** La rue s'est mise à vivre, et un bug d'une heure a rendu Walt
injouable. Le détail est en dessous ; voilà ce qu'il faut en retenir.

---

### Ce que tu peux voir ce soir et que tu ne voyais pas hier

**La rue est vivante.** Trois choses s'y sont ajoutées, dans cet ordre :

- **Les passants marchent enfin sur le trottoir.** Quatre sur dix longeaient la
  chaussée au milieu de la route, ou s'éloignaient sur le sable. Mesuré : 92
  trajets sur 231 tombaient à côté. Maintenant, **231 sur 231**.
- **On les entend.** Ils partagent les quinze sons de pas de Walter, nettement
  plus discrets — à volume égal, vingt-six marcheurs couvrent tout le reste.
- **Ils se reconnaissent.** Quand deux passants se croisent en sens inverse, il
  arrive qu'ils **s'arrêtent et se fassent face** deux secondes et demie. Un
  croisement sur cinq, et jamais celui qui en rattrape un autre par derrière.

**Walter raconte son ouverture.** Elle ne pose plus des cartons qui listaient sa
fiche de personnage. Il parle sur les six plans, et il n'énonce que des faits :

> *« Et un spécialiste qui me donne deux ans. Il en était navré. »*

**Reprendre une partie fait ce qu'elle annonce.** Si tu quittes au volant, tu
repars **dans la voiture**, à l'endroit exact — avant, tu repartais à pied et ta
voiture était restée 760 mètres plus loin. Et une ligne te rappelle ce que tu
étais en train de faire.

---

### Ce qui s'est cassé, et ce que ça a appris

**Walt est devenu injouable pendant une heure**, entre la 0.55.5 et la 0.55.6 :
coincé dans un mur au départ, à travers la maison, de plus en plus vite, puis
hors de la carte.

Une seule cause aux quatre symptômes, et elle tient en trois lettres : un
morceau du modèle de combinaison s'appelait **`Col`**. Le moteur lit ce nom comme
une consigne de collision et fabrique un bloc solide dedans — accroché au torse
de Walter, il le repoussait à chaque image. **Il entrait en collision avec ses
propres vêtements.**

Trois autres pièges écrits dans la foulée, et ils disent tous la même chose :
**un test au vert n'est pas un test qui surveille.** L'un passait avec le
mécanisme débranché, un autre mesurait une voiture en chute libre à 282 km/h, un
troisième rangeait des voix sous un nom que le jeu ne cherchait jamais. Les trois
annonçaient que tout allait bien.

---

### Où en est le jeu

**Le vertical slice est à onze cases sur quinze.** Il reste : le camping-car
extérieur (Guillaume), la musique de conduite (une décision, 1 200 crédits la
minute), le **rythme de la mission** — que personne n'a jamais mesuré en jouant —
et une **fin qui conclue** au lieu de s'arrêter.

**Plus aucun bug ouvert.** Les trois qui traînaient sont fermés, et aucun ne
parlait du jeu : deux étaient des tests qui mentaient, le troisième ne se
reproduisait plus.

---

## 0.55.7 — Walter raconte lui-même son ouverture

> **À essayer :** **Nouvelle partie**, et laisse tourner sans toucher à rien.

L'ouverture ne se contente plus de poser des cartons. **Walter parle**, sur les
six plans, et il ne raconte pas une histoire : il énonce des faits, et c'est
l'écart entre eux qui fait le reste.

> *« Il n'y a rien, ici. Ce n'est pas une plainte. C'est un prérequis. »*
>
> *« Vingt-trois ans que j'enseigne le tableau périodique à des enfants
> endormis. »*
>
> *« En bas, j'ai un crédit, un fils, et une femme enceinte. »*
>
> *« Et un spécialiste qui me donne deux ans. Il en était navré. »*
>
> *« Je ne suis pas un criminel. Je suis un chimiste. La nuance compte. Pour
> moi. »*

La dernière ligne est celle qui était déjà là — *« Ça doit marcher »* — et elle
tombe maintenant à la fin, quand il n'explique plus rien.

Les plans ont été rallongés pour laisser les phrases finir. **Elle se saute
toujours à la première touche.**

## 0.55.6 — Walt redevient jouable

> **À essayer :** lance une partie et marche. C'est tout.

**Bug corrigé, et il rendait le jeu injouable** : Walt démarrait coincé dans un
mur, traversait la maison, filait de plus en plus vite et finissait par tomber
hors de la carte.

Une seule cause aux quatre symptômes : **il entrait en collision avec ses propres
vêtements.** Un morceau du modèle de combinaison portait un nom que le moteur lit
comme une consigne de collision, et ce bloc solide, accroché à son torse, le
repoussait à chaque image.

Rien à faire de ton côté, et rien d'autre n'a bougé.

## 0.55.5 — Reprendre une partie dit ce qu'on reprend, et rend la voiture

> **À essayer :** roule quelque part, quitte le jeu **au volant**, relance et
> choisis **Reprendre**.

**Bug corrigé** : on repartait **à pied**, et la voiture restait là où le jeu
l'avait posée au lancement — mesuré à **760 m** de l'endroit qu'on avait quitté.
Maintenant on reprend dans la voiture, à l'endroit exact, moteur coupé.

**Et une ligne dit ce qu'on reprend** en arrivant : *« Reprise — Rejoindre le
labo dans le désert »*. Ça lève le doute qui avait fait ouvrir un ticket le 7 :
depuis que la position est vraiment restaurée, une partie arrêtée dans une rue
**reprend dans cette rue**, ce qui est correct mais ressemble à un bug quand rien
ne l'annonce.

## 0.55.4 — Deux passants qui se croisent se reconnaissent

> **À essayer :** reste sur un trottoir sans bouger et regarde les gens se
> croiser. Ça n'arrive pas à chaque fois — il faut attendre.

Quand deux passants se croisent **en sens inverse** et passent à moins de deux
mètres, il arrive qu'ils **s'arrêtent et se fassent face** deux secondes et
demie, puis reprennent leur chemin là où ils l'avaient laissé.

**Un croisement sur cinq**, et c'est voulu : une rue où tout le monde s'arrête
devient un village où tout le monde se connaît, et le procédé se voit en trente
secondes. Celui qui en rattrape un autre par derrière ne s'arrête pas — on ne
parle pas au dos de quelqu'un.

Les trois nombres sont dans les réglages et s'ajustent à l'oreille et à l'œil :
`salut_distance`, `salut_duree`, `salut_proba`.

## 0.55.3 — La rue s'entend

> **À essayer :** arrête-toi sur un trottoir, ne bouge plus, et écoute passer les
> gens.

Les passants **font du bruit en marchant**. Ils partagent les quinze sons de pas
de Walter — même béton, mêmes chaussures — mais **nettement plus discrets** : à
volume égal, vingt-six marcheurs couvrent tout le reste, y compris les pas de
Walter, qui sont les seuls qui comptent.

Le réglage est à l'oreille. Si tu les trouves trop présents ou pas assez, c'est
`pas_passant_gain` dans les réglages, et ça se change en une ligne.

## 0.55.2 — Les passants marchent enfin sur le trottoir

> **À essayer :** arrête-toi dans n'importe quelle rue et regarde les gens passer.

**Bug corrigé** : quatre passants sur dix ne marchaient pas sur le trottoir. Ils
longeaient la chaussée au milieu de la route, ou s'éloignaient sur le sable le long
des rues du pourtour. Mesuré avant : 92 trajets sur 231 tombaient à côté. Après :
**231 sur 231 sont sur le trottoir.**

Les **voitures garées** et le **mobilier** — poubelles, bancs, boîtes aux lettres,
abris de bus — étaient décalés exactement de la même façon, sur deux côtés d'îlot
sur quatre. Ils sont replacés aussi.

## 0.55.1 — Walter pense tout haut, et le QG prévient avant de fouiller

> **À essayer :** roule jusqu'au désert ou jusqu'au QG de Tuco, et laisse-le parler
> tout seul pendant le trajet.

**47 phrases**, rangées par moment de la mission. Il est professeur : il compte, il
rationalise, il ne dit jamais ce qu'il ressent. Il se tait pendant les dialogues,
attend qu'un message affiché ait disparu, et laisse vingt-cinq secondes au démarrage.
Quand tout a été dit sur une étape, il se tait plutôt que de tourner en boucle.

**Et on sait maintenant qu'on va être fouillé** en entrant chez Tuco. La scène
existait depuis longtemps — Tuco demande, Walter ment, le garde trouve — mais rien
ne prévenait avant d'entrer.

## 0.55.0 — Cuisiner n'est plus un menu

> **À essayer :** au camping-car, lance une cuisson.

Un curseur traverse une barre, **la zone à viser se déplace à chaque passage**, trois
appuis. La moyenne décide de la pureté. Le résultat ne s'écrit nulle part : il se lit
sur **la couleur du cristal** qu'on emporte — brun quand c'est raté, bleu quand c'est
juste, et du brun au bleu la valeur triple.

**Rater ne bloque pas.** Trois passages manqués donnent du brun, pas un mur : la
mission se termine dans tous les cas.

## 0.54.4 — Le menu de test va droit au but

**Pour ceux qui testent.** Ouvre la pause, **Outils**.

**« Mission 1 : aller a une phase… »** propose les dix moments qui comptent —
le coup de fil, chez Jesse, le labo, face a Tuco, la fuite. On y arrive **dans
l'etat ou l'on serait en jouant** : avec la marchandise en poche si la scene la
demande, et l'argent si on l'a deja touche. Plus besoin de refaire vingt
minutes pour regarder un decor.

**Et la liste des lieux ne propose plus que des lieux.** Elle en publiait
quarante et un, dont trente-sept parcelles nommees `terrain_vague_6_7`. Il en
reste quatre, ceux qu'on demande vraiment.

---
## 0.54.5 — Retour à trois hommes chez Tuco

**Correction de la 0.54.3, qui annonçait une chose fausse.** Les trois hommes
de main de Tuco étaient déjà dans le jeu, au fond de la pièce, dans ton dos —
exactement là où la mise en scène les voulait. Trois autres ont été ajoutés
par-dessus : on en voyait **cinq**, dont deux presque l'un dans l'autre.

Les doublons sont retirés. On est revenu à ce qui existait, qui était juste.

---

## 0.54.3 — ~~Tuco n'est plus seul dans son bureau~~ (annulée)

**Cette version ajoutait trois hommes de main qui existaient déjà.** Voir la
0.54.5. Elle est conservée ici parce qu'un numéro publié ne se réécrit pas,
mais il n'y a rien à y essayer.

---
## 0.54.2 — La dalle blanche du bureau de Tuco est enfin une vitre

**Ce qu'il faut essayer** : monte chez Tuco et regarde son bureau.

**Ce bloc blanc posé devant lui était un plateau de verre** — celui sur lequel
la mission demande de poser la botte. Il se lisait comme un morceau oublié. Il
laisse maintenant voir le bureau au travers, avec un bord qui s'allume.

**Et les trois personnages ont perdu quinze mégaoctets sans rien perdre à
l'écran.** Walt, Jesse et Tuco portaient chacun une texture de 2048 pixels pour
un millier de triangles — plus nette que tout ce qui les entoure, et invisible
à la résolution du jeu. Leurs animations et leur squelette n'ont pas bougé.

---

## 0.54.1 — Le QG de Tuco et le camping-car ont leur ambiance

**Ce qu'il faut essayer** : entre dans le camping-car pour cuisiner, puis monte
chez Tuco. Écoute avant de parler.

**Deux nappes qui n'existaient pas.** Le bureau de Tuco a un fond bas et
menaçant, celui d'une pièce où quelqu'un peut perdre son calme. Le camping-car
a un bourdonnement mécanique et confiné — un endroit où la concentration
compte et où ça peut mal tourner.

**Le désert sonnait déjà**, mais son fichier d'origine traînait dans le jeu en
double, treize méga-octets pour rien. Il est sorti du dépôt.

---

## 0.54.0 — Le téléphone sonne comme un téléphone, et les voix jouent

**Ce qu'il faut essayer** : va au QG de Tuco et parle au type qui garde la
porte. Puis reprends la mission depuis le début pour l'appel du matin.

**Tuco répond par l'interphone, et ça s'entend.** Sa voix sort d'un
haut-parleur de portier — étroite, sale, et elle sature quand il hurle de le
laisser entrer. Avant, il avait l'air d'être debout à côté de toi.

**Pareil au téléphone.** L'inconnu qui appelle au nom de Salamanca et Skyler qui
réclame les œufs passent par une vraie ligne : 300 à 3400 Hz, la bande que
transmet un combiné. Toi, non — tu es dans la pièce, ta voix ne traverse rien.

**Et les voix jouent, maintenant.** Soixante et onze répliques ont été
redirigées une par une : Tuco explose au lieu de monter, Jesse râle à chaque
phrase, Skyler est chaleureuse et fatiguée, le garde s'ennuie. Walter reste
contenu — c'est le personnage, pas un oubli : il n'a d'intention que là où la
scène lui en donne une.

---

## 0.53.0 — Tout le monde parle anglais, et tu lis en français

**Ce qu'il faut essayer** : joue la mission 1 et écoute. Puis va parler à Skyler
dans le salon, et décroche le téléphone.

**Les 125 répliques du jeu sont doublées.** En anglais, sous-titrées français —
la convention des jeux de cette époque, et le ton de la série. Fini la voix de
synthèse de Windows qui lisait du français.

**Les voix ont été castées, pas prises au hasard.** Walter se tient, même quand
il ment. Jesse dérape à chaque phrase. Tuco a l'accent de Mexico et part en
vrille sans prévenir — écoute-le compter l'argent, puis découvrir qu'il en
manque.

**La confession de Walter et la dispute avec Skyler n'ont pas bougé** : ce sont
les vraies voix enregistrées, et elles restent les meilleures du jeu.

**Trois voix attendent ton avis** : Skyler, l'homme de main de Tuco, et
l'inconnu qui appelle au début. Elles sont posées, pas validées — si l'une
sonne faux, elle se refait.

---

## 0.51.2 — Une minimap, et on sait enfin de quel côté partir

**Ce qu'il faut essayer** : lance une partie et regarde en bas à droite.

Un disque, toi au centre, et **les rues** — elles sont tracées par les
lampadaires, qui les bordent. La carte **tourne avec la caméra** : le haut du
disque est ce que tu as devant toi, pas le nord.

**Le point jaune est ton objectif.** Quand il est loin — le désert est à neuf
cents mètres — il se colle au bord du disque en pointe, et te dit la direction.
Il ne disparaît jamais : un marqueur qui s'efface dès qu'on sort de portée ne
sert qu'à l'endroit où on n'en a plus besoin.

**Aucun chiffre.** Pas de distance, pas de coordonnées. Tu vois que c'est loin
sur la gauche, tu ne sais pas que c'est 340 m — et c'est voulu : un compteur
transforme un trajet en optimisation.

La minimap se cache quand le téléphone, la roue, un dialogue ou le menu sont
ouverts. Elle occupait le même coin que le téléphone, qui la recouvrait aux
trois quarts.

### Aussi

Le labo du camping-car est meublé : **quatre montages de distillation** avec
leur ballon et leur liquide, **un fût et un jerrycan** au sol, et la verrerie du
décor est passée du bloc blanc opaque à **du verre** — bord qui accroche la
lumière, ménisque, liquides translucides.

Le sol, les paillasses et les cloisons ont de vraies textures. Le bureau de Tuco
aussi.

---

## 0.51.0 — Le jeu se voit enfin

**Rien de neuf à faire. Tout est à regarder.** Aucun asset n'a changé de forme :
c'est la façon dont le jeu est rendu qui a bougé, et ça se voit partout.

### Ce qu'il faut regarder ce soir

**Sors de chez toi la nuit et arrête-toi sous un lampadaire.** Avant, c'était une
tache orange posée sur le mur. Maintenant la lampe a une source, un abat-jour, un
halo — et **le cactus projette son ombre sur la façade**. Huit lampadaires
projettent en même temps, ceux dont tu es le plus près.

**Lève la caméra.** La lune éclaire pour de vrai : elle porte ses propres ombres,
et la voiture ne flotte plus au-dessus de la chaussée.

**Allume les phares et roule.** Ils projettent aussi, et l'air se voit dans leur
faisceau.

**Regarde de près.** Le rendu est passé de 512×384 à **960×720** — presque quatre
fois plus de pixels. Le portrait dans le coin de l'écran est reconnaissable, les
lattes de bois se distinguent, la calandre de l'Aztek a du relief.

**Le grain n'a pas bougé.** C'était le risque : à cette finesse, le jeu pouvait
devenir net comme n'importe quel jeu moderne et perdre ce qui fait son allure. La
fenêtre a donc grandi avec le rendu, et le flou d'agrandissement est resté.

### Ce qui est réparé

**L'intérieur du camping-car et le bureau de Tuco étaient texturés en 32 pixels**
— les décors les plus pauvres du jeu, dans la mission qu'on joue le plus. Ils sont
en 256.

**La voiture de Walter pesait 10 Mo à elle seule**, avec des textures quatre fois
plus fines que tout ce qui l'entoure. Elle en pèse 0,6, et personne ne verra la
différence — sauf au chargement.

### Ce que ça coûte

**Rien de mesurable.** Au centre de la ville, à 22 h, tous effets coupés : 3,0 ms
par image. Avec tout ce qui précède allumé : **2,8 ms**, sur les 33 disponibles.
L'écart est dans le bruit.

*(Ce paragraphe annonçait d'abord « 0,6 ms avant, 0,7 après ». Les deux chiffres
étaient réels, mais pris à deux endroits différents de la ville — le relevé se
faisait là où la dernière partie s'était arrêtée. Il mesure maintenant toujours
au même point. La conclusion, elle, n'a pas changé.)*

Si ça rame chez toi, dis-le tout de suite — c'est le genre de chose qui ne se voit
pas depuis la machine qui l'a fabriqué.

### Deux bugs connus, qui existaient déjà

La suite `conduite` et la suite `murs` échouent, et échouaient déjà avant cette
session. Ils sont ouverts en tickets.

---

## 📌 La session du 7 août 2026 — de la 0.48.10 à la 0.50.0

**Neuf versions, et la première fois qu'on JOUE.** Le détail est en dessous ;
voilà ce qu'il faut en retenir.

---

### Ce que tu peux faire ce soir et que tu ne pouvais pas hier

**Skyler t'appelle pendant que tu roules vers le désert.** Tu décroches (`F`),
tu raccroches (`T`), ou tu laisses sonner. Elle veut des œufs. L'épicerie est en
ville, le camping-car à neuf cents mètres — et c'est là que ça devient
intéressant : faire demi-tour, c'est arriver en retard, et **Jesse le remarque**.
Tuco aussi, plus tard.

**Tu peux gagner ta vie sans mission.** Une fois la mission 1 finie, l'atelier du
camping-car resserre. Tu cuisines, tu vas livrer à un contact sur un terrain
vague, tu es payé — et **le prix suit la pureté** : 300 $ pour du brun, 900 $
pour du bleu. Rien ne l'affiche.

**Tu rapportes les courses à la maison.** L'épicerie ne donne plus de points sur
place : elle vend une boîte d'œufs, quatre dollars, et les points ne tombent que
quand tu la poses sur le plan de travail de ta cuisine. Skyler réagit — dans les
deux cas.

---

### Trois choses qui étaient cassées depuis longtemps

- **La sauvegarde ne gardait que la moitié.** L'argent et l'heure revenaient ;
  ni l'inventaire, ni la position, ni l'avancement. Trois liens manquaient dans
  la scène **depuis quinze versions**. Ce qui a fait croire qu'elle marchait,
  c'est que la moitié qui fonctionnait était la moitié visible.
- **La cachette était introuvable**, et elle bloquait la fin de la mission. Elle
  n'avait aucune planche à l'écran et flottait à un mètre soixante du mur, dans
  un salon de quatorze mètres sur dix.
- **Le camping-car n'était pas là.** Jesse et la porte d'entrée étaient à
  vingt-neuf mètres du véhicule, en plein milieu de la piste, depuis le jour où
  le désert a pris son relief.

---

### Et ce qui reste cassé, dit franchement

**Reprendre une partie ne dit pas où l'on arrive** (#55) — nouveau, et c'est le
revers de la sauvegarde réparée. **La tôle du camping-car ondule** (#52) : c'est
un scan, ça se répare chez Guillaume.

*(Un troisième bug avait été ouvert — « on ne peut pas courir » — puis fermé : on
court très bien, l'erreur venait d'un diagnostic mené sur une liste incomplète.)*

---

## 📌 La session du 6 au 7 août 2026 — de la 0.43 à la 0.48.10

**Onze versions en une soirée.** Voilà ce qu'il faut en retenir, en une lecture.
Le détail version par version est en dessous, si tu veux creuser.

---

### Trois chiffres en haut de l'écran

`$192` · `Famille 60` · `Rue 10`

C'est le gros changement de la soirée. Jusqu'ici le jeu ne montrait **aucun**
chiffre, par principe — on voulait que tout se devine. On a changé d'avis pour
ces trois-là, et pour une raison simple : **ce sont des choses qu'on surveille
en conduisant.** Comme une jauge d'essence. Les cacher aurait été élégant et
pénible.

Et surtout, les mettre côte à côte raconte le jeu sans un mot : **la réputation
monte quand la famille descend.**

- **Famille** — un seul compteur pour Skyler, Junior et Hank ensemble. C'est la
  place que tu laisses à ta vie d'avant. Il baisse tout seul, heure après heure.
- **Rue** — ta réputation. Elle se gagne de plusieurs façons à la fois : la
  qualité de ce que tu livres, le fait de tenir tes délais, celui d'assumer la
  violence, celui de cuisiner toi-même. Aucune ne suffit seule. Et elle ne se
  dépense jamais — elle ouvre des portes.
- **Argent** — comme avant.

Le **porkpie** multiplie tout ce que tu gagnes en réputation par une fois et
demie. Coiffé, tu es Heisenberg, et ça se raconte plus vite.

---

### Le produit a enfin une couleur

Le cristal dans ta main change de teinte selon sa pureté : **brun, ambre, clair,
translucide, bleu**. Celui-là reste sans chiffre — on ne t'annoncera jamais un
pourcentage, tu regardes ta main et tu sais.

---

### Une première mission qui te met vraiment en défaut

**Échap → Outils de test → Déclencher une mission de test → « Un simple service ».**

Tu pars porter dix dollars à Jesse. Vingt secondes après avoir démarré, **Skyler
appelle** : il n'y a plus d'œufs, Junior voulait des pancakes. Tu es sur la route
du désert.

Aucune réponse n'est la bonne, et c'est le sujet :

| Ce que tu fais | Famille | Rue |
|---|---|---|
| Tu passes prendre les œufs | **+10** | **−6** — tu arrives en retard |
| Tu promets, et tu files droit | **−10** | **+4** — au moins tu es fiable |
| Tu ne décroches pas | **−5** | inchangée |

**Rien ne te dit ce que ça t'a coûté.** Les compteurs bougent en silence, et
Skyler ne te reparle jamais des œufs si tu as promis et oublié.

---

### Une épicerie, et le désert enfin libre

Un centre commercial au nord de la ville, avec une **enseigne ambre** qu'on
repère de la route. C'est la première façon de faire *remonter* la famille —
jusqu'ici elle ne savait que descendre.

Et le désert est maintenant **ouvert à toute heure**, sans attendre que la
mission t'y envoie. *(Ça a un prix, voir plus bas.)*

---

### Une boîte à outils, pour toi qui testes

**Échap → Outils de test.** Dix-neuf lignes qui t'évitent de relancer le jeu :

aller directement à n'importe lequel des 45 lieux · traverser les murs et voler ·
accélérer le temps · te donner de l'argent ou tous les objets · devenir
invulnérable · changer la pureté, la famille, la réputation · remplir la ville
de passants et de voitures · voir les collisions · afficher un relevé de
performance pendant que tu joues.

Ce n'est pas caché : **ceux qui jouent à ce jeu sont ceux qui le testent.**

---

### Et l'écran-titre a enfin la tête du jeu

Il s'affichait plus net que la première image de jeu qui le suivait. La promesse
tombait dès qu'on appuyait sur « Nouvelle partie ».

---

### Trois choses qui mentaient, et qu'on a réparées

Aucune ne se voyait en jouant, et c'est bien le problème :

- **Le relevé de performance annonçait un effondrement qui n'existait pas.** Le
  jeu tournait avec vingt-six fois la marge nécessaire ; c'est l'instrument qui
  se trompait.
- **La vérification automatique contrôlait la mauvaise scène** depuis que
  l'écran-titre est passé devant le monde. La vraie porte d'entrée du jeu
  n'était vérifiée par personne.
- **Chaque capture d'écran photographiait le menu** au lieu de la situation
  demandée. Le fichier était bien écrit, l'image était fausse.

---

### Ce qui est cassé, et qu'on répare la prochaine fois

**Le désert était cassé — c'est réparé en 0.48.11**, juste en dessous. Trois
pannes, dont deux qui traînaient depuis une semaine sans que personne puisse les
voir.

**L'épicerie est encore un bouton** : on peut appuyer en boucle et monter la
famille à cent sans bouger. Ce sera une vraie course — quatre dollars, une boîte
d'œufs dans l'inventaire, et Skyler qui réagit quand tu rentres. Ticket #49.

---

## 0.50.0 — Cuisiner, livrer, être payé, recommencer

> **À essayer : finis la mission 1, puis retourne au camping-car.** L'atelier
> resserre. Cuisine, et va vendre.

**Le jeu a enfin une raison de continuer après la mission.** Jusqu'ici, l'argent
n'arrivait que par les missions : la dernière finie, il ne restait rien à faire.

- **L'atelier du camping-car resserre** une fois la mission bouclée, et il ne
  s'épuise pas. Il rend de la marchandise, pas la botte secrète — la botte était
  une scène, la meth est un métier.
- **Un contact attend sur un terrain vague**, à l'écart. Une berline garée, rien
  d'autre : un deal ne s'annonce pas. Tu ne verras l'invite que si tu portes de
  quoi vendre — les mains vides, il n'y a qu'une voiture.
- **Le prix suit la pureté.** Du brun au bleu, la valeur **triple**. Rien ne
  l'affiche : c'est en comparant deux livraisons que ça se comprend.

**Et la sauvegarde marche enfin en entier.** Elle ne gardait que l'argent et
l'heure : ni l'inventaire, ni la position, ni l'avancement de la mission. Trois
lignes manquaient dans la scène depuis quinze versions. Le critère annoncé en
0.41 était pourtant clair — *« quitter avec 3 000 $, un chapeau sur la tête, à
21 h, et retrouver exactement ça »*. Le chapeau n'était jamais revenu.

---

## 0.49.0 — Skyler appelle pendant que tu roules

> **À essayer : lance la mission 1 et prends la voiture après avoir parlé à
> Jesse chez lui.** Au bout d'une vingtaine de secondes de conduite vers le
> désert, le téléphone sonne.

![L'appel, au volant](docs/images/appel-skyler.png)

**Tu peux décrocher (`F`), raccrocher (`T`), ou laisser sonner.** Les trois sont
des réponses, et aucune n'est gratuite.

Si tu décroches, Skyler te demande de passer prendre des œufs. Et là commence le
vrai sujet : **l'épicerie est en ville, le camping-car à neuf cents mètres.**

- **Tu fais demi-tour tout de suite** → tu arrives en retard au camping-car.
  Jesse le remarque, il voit la boîte dans ta main, et ta réputation de rue en
  prend un coup. Tuco aussi la remarquera, plus tard.
- **Tu promets et tu files droit** → il te reste toute la mission pour y penser
  au retour. Ou pour oublier.
- **Tu ne réponds pas** → cinq points de famille, sans un mot.

**Rien ne t'annonce ces coûts.** Les compteurs bougent, personne ne commente —
sauf Jesse et Tuco quand ils voient la boîte. C'était le point qui manquait : un
compteur qui tombe sans que personne en parle passe pour un bug.

**Ce que ça remplace.** La mission de test « Un simple service » disparaît des
outils de test : elle existait pour essayer ce mécanisme avant que les vraies
missions soient écrites. Elles le sont.

---

## 0.48.14 — On trouve enfin la cachette, et le klaxon s'entend

> **Si tu télécharges le jeu pour y jouer, prends celle-ci.** Les deux
> corrections viennent d'une vraie partie, jouée de bout en bout.

**La cachette était introuvable, et elle bloquait la fin de la mission.** La
latte descellée du salon n'existait qu'en tant que point invisible : aucune
planche à l'écran, posée à un mètre soixante du mur le plus proche, au milieu
d'un salon de quatorze mètres sur dix. Le tuto annonçait pourtant « une latte du
mur n'est pas comme les autres ».

Elle est maintenant **contre le mur de gauche, à côté de la bibliothèque**, et
on la voit : une planche un peu plus sombre que le reste. Cherche près de la
bibliothèque.

![La cachette](docs/images/cachette.png)

**Le klaxon s'entend.** Il était enregistré six fois moins fort que le bruit de
portière — mesuré sur les fichiers, pas deviné. Il est remonté au niveau des
autres.

---

## 0.48.13 — L'épicerie vend, la cuisine compte

> **À essayer : va faire les courses, puis rentre chez toi et pose-les sur le
> plan de travail de la cuisine.** Skyler réagit. Recommence sans être passé à
> l'épicerie : elle réagit aussi, mais pas pareil.

![La boîte d'œufs en main](docs/images/boite-oeufs.png)

**L'épicerie était un bouton.** On pouvait appuyer en boucle devant le comptoir
et monter la famille à cent sans bouger de place : le compteur devenait une
manivelle, et les deux cent quatre-vingts mètres de détour ne voulaient plus
rien dire.

**Maintenant elle vend.** Quatre dollars sortent de la poche, une caisse
enregistreuse s'entend au comptoir, et tu repars avec une **boîte d'œufs dans
les mains** — un objet de la roue, comme le revolver ou le chapeau. Si tu n'as
pas les quatre dollars, elle refuse et le dit.

**Et c'est en rentrant que ça compte.** Les points de famille ne tombent plus à
l'épicerie : ils tombent quand tu poses la boîte sur le plan de travail de ta
cuisine, et seulement si tu l'as encore.

![Poser les courses](docs/images/poser-les-courses.png)

**Ce que ça change vraiment :** la course devient perdable. Tu peux acheter puis
mourir, ou oublier de rentrer, ou rentrer les mains vides. Acheter n'est plus la
récompense — rentrer avec l'est.

**Skyler répond dans les deux cas.** Avec les œufs, elle a remarqué. Sans, elle
ne fait pas de reproche : elle dit qu'elle ira elle-même. C'est plus lourd.

---

## 0.48.12 — Le camping-car de Guillaume est dans le jeu

> **À essayer : va au désert et approche-toi du camping-car.** Ce n'est plus la
> caisse à 130 triangles fabriquée par le générateur — c'est **ton modèle**. Il
> y est enfin, et la porte du jeu tombe sur ta porte.

![Le camping-car livré, et le point d'entrée](docs/images/camping-car-porte.png)

**Il n'y avait jamais été.** Le fichier dormait dans `livraisons/` depuis le
début, pendant que deux commentaires du code affirmaient le contraire. Ce qu'on
voyait en jouant, c'était une boîte grise.

**Ce qui a changé pour l'intégrer :**

- Le modèle est **dégraissé au budget du jeu** : 8 000 triangles au lieu de
  17 828, une seule texture 1024 au lieu de quatre en 2048. Il pèse 2,1 Mo au
  lieu de 16,2.
- Le générateur du désert **ne fabrique plus de camping-car**. Il ne peut donc
  plus écraser ta livraison — c'est ce qui était arrivé à ton Jesse.
- Jesse et la porte d'entrée ont été replacés sur le vrai véhicule : la porte
  tombait trois mètres à côté, devant une trappe de soute.

**Pourquoi 8 000 et pas 17 828.** Les cinq niveaux ont été comparés dans le jeu,
côte à côte — voir `docs/03-conventions-assets.md`, la planche y est. En dessous
de 4 000, la carrosserie se froisse et ça fait épave. À partir de 8 000, la
silhouette ne bouge plus : entre 8 000 et ton modèle complet, on ne voit plus la
différence de géométrie. Le reste se jouait sur la texture, huit fois moins
chère.

**Pour la prochaine livraison, si tu veux gagner du temps :** vise ~8 000
triangles et une seule texture couleur. La normale, le metallic/roughness et
l'émissive ne sont pas lues par le rendu du jeu — il est plat, comme sur PS2.
Ça ne change rien à l'écran et ça divise le poids par huit.

---

## 0.48.11 — Le désert redevient un endroit où l'on va, et d'où l'on revient

> **À essayer : va au désert avant d'avoir commencé quoi que ce soit.** Jesse est
> là, debout contre le flanc du camping-car — et il ne dit rien. Il n'a aucune
> raison de te parler tant que rien ne t'a envoyé là. Lance la mission ensuite,
> reviens : cette fois il t'accueille.

**Trois choses réparées, et une seule était de la veille.**

- **Jesse te reprochait un retard hors mission.** Il t'accueillait avec « Vous
  êtes en retard » alors que tu n'avais pas encore quitté ta maison. C'était le
  seul dégât de l'ouverture du désert.
- **Jesse et la porte d'entrée étaient à vingt-neuf mètres du camping-car**, en
  plein milieu de la piste. Ça datait du jour où le désert a pris son relief, il
  y a une semaine : le camping-car a bougé, ce qui devait le suivre est resté.
- **On ne pouvait plus ressortir du désert.** La zone qui te ramène en ville
  était à vingt-six mètres de la piste, donc introuvable en roulant — alors même
  que la flèche peinte au sol, elle, était au bon endroit et te la promettait.

**Ce que ça change pour la suite :** ce qui doit être collé au camping-car s'y
colle désormais tout seul, et la sortie se pose avec la flèche qui l'annonce. Le
jour où le désert sera régénéré, plus rien ne restera en arrière.

**Ce qui n'est PAS réparé, et qu'il faut savoir :** le camping-car que tu vois
est toujours celui fabriqué par le générateur, pas le tien. Ton modèle n'a jamais
été intégré au jeu — il attend dans `livraisons/`. C'est un ticket à part, parce
qu'il pèse 17 Mo et qu'il faut d'abord regarder ensemble ce qu'on en garde.

---

## 0.48.4 — « Un simple service » : le premier vrai choix du jeu

> **À essayer : Échap → Outils de test → « Déclencher une mission de test… » →
> « Un simple service ».** Tu dois porter 10 $ à Jesse au camping-car, puis
> rentrer chez toi. Six secondes après le départ, **Skyler appelle** : il lui
> faut des œufs. `F` pour décrocher, ou laisse sonner.

**Aucune des trois issues n'est gratuite** — et c'est tout le sujet :

| Ce que tu fais | Famille | Réputation |
|---|---|---|
| Tu passes prendre les œufs | **+10** | **−6** — tu arrives en retard |
| Tu décroches, tu promets, tu files droit | **−10** | **+4** — tu es fiable |
| Tu ne décroches pas | **−5** | inchangée |

Les deux compteurs bougent **en sens inverse**, côte à côte en haut de l'écran.
C'est pour ça qu'ils y sont.

**Rien ne t'annonce ce que ça t'a coûté.** Les chiffres bougent en silence, et
Skyler ne te reparle jamais des œufs si tu as promis et oublié.

L'épicerie est à peu près sur la route de la sortie désert : le détour est réel
mais court. C'est un choix, pas une punition.

---

## 0.48.3 — Une épicerie, et de quoi faire remonter la famille

> **À essayer : va au centre commercial au nord de la ville** — il est loin, à
> près de trois cents mètres du point de départ. Une invite **« Faire les
> courses »** t'y attend, et le compteur **Famille** monte de dix. Tu peux y
> retourner autant de fois que tu veux.

C'est la première façon de faire **monter** ce compteur : jusqu'ici il ne faisait
que descendre. Et sa distance est le sujet — une course qui ne détourne de rien
n'est pas un choix, c'est un bouton.

N'importe quel point d'interaction peut désormais nourrir la famille : il suffit
qu'il porte le bon événement. Le jour où on pose un rendez-vous médical ou un
fauteuil dans le salon, il n'y a pas une ligne de code à écrire.

---

## 0.48.2 — La réputation de rue

> **À essayer : regarde le troisième compteur, `Rue`, en haut à gauche.** Règle-le
> depuis les outils de test pour voir. Mets le porkpie : tout ce que tu gagneras
> ensuite comptera une fois et demie.

Elle se gagne par un mélange — pureté livrée, fiabilité, violence assumée,
cuisine faite soi-même — et **ne se dépense jamais** : elle ouvre. Conservée
dans la sauvegarde.

Pas encore là : les missions et les contacts qu'elle ouvrira.

---

## 0.48.1 — Les points de famille

> **À essayer : lance le jeu.** Un compteur **Famille** s'affiche en haut à
> gauche, à côté de l'argent, et il y reste. Il descend tout seul avec les heures
> qui passent, et il change de couleur quand il devient bas — vert, orange, rouge.

**Un seul compteur, pas un par personne.** Ce qu'il suit, c'est la place qu'on
laisse à sa vie d'avant. S'occuper d'eux le fait monter, penser aux courses aussi,
s'occuper de son cancer aussi. Les négliger le fait descendre sans qu'on y touche.

Il est conservé quand tu sauvegardes et reprends. Tu peux le régler depuis les
outils de test (Échap → Outils de test → « Points de famille ») pour voir les
trois couleurs.

Pas encore là : les endroits où gagner ces points — les courses, les rendez-vous
médicaux, les moments passés à la maison. La mécanique existe, les occasions non.

---

## 0.48.0 — La couleur du produit

> **À essayer : Échap → Outils de test → « Pureté du produit ».** Parcours les
> cinq crans avec `A`/`D`, prends le cristal dans la roue, et regarde-le dans ta
> main : il change de couleur — brun, ambre, clair, translucide, bleu.

C'est la première brique de la progression : un labo, une couleur, un type de
client, et les trois avanceront ensemble. **Aucun chiffre n'est affiché nulle
part** — tu ne verras jamais un pourcentage de pureté, seulement la couleur dans
ta main. C'est volontaire : un chiffre transformerait un choix en calcul.

Le palier est conservé quand tu sauvegardes et reprends.

Pas encore là : ce que la pureté change au prix, qui accepte de traiter avec toi,
et ce que coûte une montée de palier.

---

## 0.47.0 — Voir ce que le jeu coûte, pendant qu'on joue

> **À essayer : Échap → Outils de test → « Relevé de performance ».** Un encart
> apparaît en bas à gauche : temps d'image, 99e centile, pire cas, images ratées,
> appels de rendu, mémoire. La première ligne **vire au rouge** dès qu'une image
> est ratée — on ne lit pas un tableau en conduisant.

Trois autres lignes dans le même menu :

- **Foule et trafic** — `aucun / normal / maximum`. Le maximum pose 120 passants
  et 60 voitures : c'est ce qui montre d'un coup ce que la circulation coûte.
  Attention, les passants sont désactivés dans le jeu depuis fin juillet pour une
  bonne raison — leur trottoir se calcule mal quand les rues changent de largeur,
  et certains marchent sur la chaussée. Les rallumer ici sert précisément à les
  regarder.
- **Montrer les collisions** — les formes de collision autour de toi, à 45 m. Il
  dit combien il en a montré sur combien : « 24 sur 2158 ».
- **Montrer les lieux nommés** — les 45 destinations écrites en clair, debout
  dans la ville.

---

## 0.46.0 — Se déplacer sans marcher

> **À essayer : Échap → Outils de test → « Aller à un lieu nommé… ».** Quarante-cinq
> destinations. **Chez Walter**, **chez Jesse**, **l'Alpine** et **le désert** sont
> en tête ; le reste, ce sont les parcelles de la ville. `F` t'y dépose et referme
> le menu.

Et **« Traverser les murs et voler »** : tu passes à travers tout, `W`/`S` pour
avancer, `Espace` pour monter, `Ctrl` pour descendre, `Maj` pour aller trois fois
plus vite. En le recoupant, tu es **reposé sur la première surface sous toi** — on
ne ressort jamais coincé dans un mur.

Un détail qui gênait : le menu s'ouvrait sous le curseur et celui-ci volait
aussitôt la ligne sélectionnée. Le survol ne compte plus que si la souris bouge.

---

## 0.45.0 — Des outils pour tester sans relancer

> **À essayer : en jeu, Échap → « Outils de test ».** Onze lignes qui
> t'évitent une relance. `W`/`S` pour choisir, `A`/`D` pour les valeurs entre
> chevrons, `F` pour déclencher.

Ce qu'il y a dedans : la **vitesse du temps** (figée / normale / ×10 — pour voir
le cycle jour-nuit sans attendre), **faire venir la voiture** devant toi,
**donner de l'argent** (1 000, 10 000, ou remise à zéro), **donner tous les
outils** d'un coup, **l'invulnérabilité**, **se soigner** (et ressusciter si tu
es mort), la **résolution interne** à chaud (256 / 512 / 1024), et **couper
l'ambiance ou la musique** séparément.

Chaque action te répond en bas du cadre : sans ça on appuie trois fois en
croyant qu'il ne s'est rien passé.

Ce n'est pas caché : ceux qui jouent à ce jeu sont ceux qui le testent.

Encore à venir sur ces outils : aller directement à un lieu nommé, traverser
les murs, régler la densité de foule et de trafic, montrer les collisions et les
ancrages, et un relevé de performance affiché pendant qu'on joue.

---

## 0.44.0 — Le titre a le grain du jeu

> **À essayer : lance le jeu et regarde l'écran-titre.** Il passe maintenant par
> le même rendu que le reste — même définition, même adoucissement. Avant, il
> était plus net que la première image de jeu qui le suivait, et la promesse
> tombait dès qu'on appuyait sur « Nouvelle partie ».

Rien d'autre ne bouge à l'écran : le menu se navigue et se clique comme avant.

Toujours à venir sur ce chantier : écran de chargement, cartons de chapitre,
générique de fin, bilan de fin d'acte.

---

## 0.43.0 — Un écran-titre

> **À essayer : lance le jeu.** Tu arrives sur un écran-titre — **Nouvelle
> partie / Quitter** — au lieu de tomber directement dans le monde. Si une
> partie a été sauvegardée, **« Reprendre »** apparaît en premier, et
> « Nouvelle partie » demande de confirmer avant d'écraser.

Le menu se navigue au clavier (W/S pour monter-descendre, F pour valider) ou à
la souris. « Reprendre » recharge le dernier point ; « Nouvelle partie » repart
de zéro.

Pas encore là, et ça viendra sur ce même chantier : écran de chargement,
cartons de chapitre, générique de fin, bilan de fin d'acte. Et le titre
s'affiche en pleine résolution, pas encore à travers le rendu PS2.

---

## 0.42.0 — Mourir ne remet plus tout à zéro

> **À essayer : gagne un peu d'argent, prends le chapeau, puis fais-toi tuer
> (tire sur le garde chez Tuco, par exemple). Sur l'écran de fin, l'invite dit
> maintenant « Reprendre » : tu repars du dernier point sauvegardé, avec ton
> argent et ton chapeau, au lieu de recommencer la mission de zéro.**

Tant qu'aucune partie n'a été sauvegardée, l'écran propose « Recommencer »
comme avant. Et le « Recommencer la mission » du menu pause reste, lui, un vrai
redémarrage à zéro — les deux ne se confondent pas.

Ce que la reprise restaure : l'argent gagné **jusqu'au dernier point** (ce qui
a été gagné depuis est perdu — c'est ce qui rend la mort coûteuse sans être un
retour au début), l'inventaire, l'heure, la position et l'étape de mission.

---

## 0.41.0 — On peut sauvegarder et reprendre

> **À essayer : joue un peu, prends le chapeau, gagne de l'argent, puis quitte
> par le menu pause (Échap → Quitter). Relance le jeu : tu retrouves ton argent,
> ton chapeau sur la tête, l'heure qu'il était, ta position, et l'avancement de
> la mission.**

La partie se sauvegarde **en quittant** et **à la fin d'une mission**. Au
lancement, si une sauvegarde existe, elle **reprend toute seule** — pas besoin
de rejouer la mission depuis le début. Le monde, lui, n'est pas sauvegardé : il
se refabrique à l'identique, l'écrire serait inutile.

Pas encore là, et c'est volontaire : la pureté, la famille et la réputation (qui
n'existent pas encore dans le jeu), la sauvegarde en dormant chez soi, et ce que
devient une mort. Ça viendra par-dessus, sans casser les sauvegardes déjà
écrites.

---

## 0.40.0 — L'interface prend l'esthétique de la série

> **Le portrait de Walter est maintenant une case du tableau périodique** —
> bordure olive épaisse, numéro atomique dans le coin. C'est ce qui ouvre
> chaque épisode, et c'est reconnaissable en un dixième de seconde.

**La barre de vie est segmentée** en douze crans au lieu d'être un rectangle
qui se vide. À 512 pixels de large, une longueur continue ne se lit pas : on
voit qu'elle a baissé, jamais de combien. Douze segments se comptent du coin
de l'œil.

**La vitesse est un cadran, plus un nombre nu.** On ne lit pas un chiffre en
conduisant — on regarde où en est l'aiguille. L'arc s'arrête à la vitesse
maximale réelle de la voiture, donc la position de l'aiguille veut dire quelque
chose. Le chiffre reste au centre, petit, pour quand on veut savoir exactement.

**Un rappel de ce qu'on tient**, en bas à gauche. Le nom de l'objet s'annonçait
une seconde et demie puis disparaissait : c'était juste au moment de choisir, ça
ne l'était plus deux minutes après, quand on approche de quelqu'un sans savoir
si on a le revolver à la main. Rien ne s'affiche les mains vides.

Et toute l'interface partage désormais **trois couleurs** — l'olive de la case,
l'ambre du désert, le rouge du sang — au lieu de laisser chaque élément dériver
vers sa propre nuance.

---

## 0.39.0 — Le nouveau Walter, avec ses vraies animations

> **Walter est remplacé par ton modèle v2**, et ses quatre animations livrées
> sont dans le jeu : **marcher, courir, sauter et remettre ses lunettes.**

Les trois que je fabriquais à sa place — la marche, la course, le saut —
étaient calculées à partir de poses. Elles tenaient debout, mais elles étaient
raides : c'est de l'animation résolue, pas de l'animation faite. Les tiennes
gagnent, et **une régénération ne peut plus les écraser** : un clip livré prime
désormais sur un clip fabriqué, et le générateur le dit quand il en garde un.

Le reste — repos, accroupi, marche accroupie, assis, lecture — est refabriqué
sur le nouveau squelette.

**Deux de tes quatre clips arrivaient sans nom** (des identifiants à rallonge).
Je les ai identifiés en les **mesurant** : celui où le bassin monte de 12 cm est
le saut ; celui où une main s'approche à 19 cm de la tête sans que le bassin
bouge, les lunettes. Vérifié ensuite à l'image, les deux étaient bons.

À essayer : marche, cours, saute. Et mets le chapeau — il se pose toujours
correctement sur la tête du nouveau modèle.

---

## 0.38.0 — Jesse ne se tient plus au garde-à-vous

> **Son animation d'attente est refaite.** Épaules basses et roulées en avant,
> dos creusé, bras qui pendent un peu en arrière, poids sur une jambe, menton
> qui remonte — et la tête qui bascule lentement en arrière et sur les côtés,
> comme quelqu'un qui s'ennuie pendant que tu parles.

Le cycle dure onze secondes au lieu de huit : **la lenteur fait la
nonchalance** autant que la posture.

C'est maintenant son attente par défaut, dès qu'il est immobile.

**Comment j'ai pu le juger.** Je ne peux pas regarder un mouvement — une image
fixe dit si un corps tient debout, jamais s'il bouge bien. Un nouvel outil rend
**huit poses d'un même cycle côte à côte dans une seule image**. La première
planche a montré le problème en une seconde : huit images identiques d'un homme
à l'appel. La tête parcourait 32 mm ; elle en parcourt 62 maintenant.

**En bonus, un raccourci** : `.g.ps1 jouer -Ou jesse` te dépose devant chez
lui. Et `-Ou walter`, `-Ou banc`, `-Ou desert`.

---

## 0.37.0 — Albuquerque, d'après tes photos

> **Toute la ville a changé de couleur**, et les maisons ont des ouvertures
> **vraiment creusées** au lieu de portes peintes sur un mur plat. C'est ce qui
> faisait « Minecraft » : une face plate ne porte aucune ombre.

**Les murs sont en sable, blanc cassé chaud, terre cuite et brun rosé.** Sur
les 56 photos que tu as réunies, le bleu-gris de nos façades n'apparaît sur
aucun mur. Les trottoirs sont en béton clair, presque blancs au soleil ; le sol
du désert est rosé ; les toits sont bruns au lieu de gris.

**Les maisons sont refaites.** De plain-pied, larges, avec **deux portes de
garage en façade** et une allée en béton de six mètres qui y mène — l'élément
le plus caractéristique d'une rue de lotissement là-bas. Portes et fenêtres
sont creusées de 13 à 16 cm : chacune fabrique quatre bandes d'ombre qui
suivent le soleil. Quatre gabarits différents pour qu'une rue ne soit pas un
copier-coller : toit en croupe ou toit plat à parapet, garage à gauche ou à
droite, une ou deux fenêtres.

**Les toits plats ont un parapet.** Là-bas, aucun toit ne s'arrête à ras du
mur : le mur monte de 30 à 60 cm au-dessus et le cache.

**Les centres commerciaux ont leur enseigne de toit**, plus haute que le
bâtiment — comme le Dog House ou le Crossroads Motel.

**Les montagnes ont doublé de hauteur** et se sont rapprochées. Elles
faisaient un liséré ; elles occupent maintenant un vrai morceau de ciel.

**Il y a de la végétation.** Des arbustes taillés en boule plaqués contre les
façades — c'est toute la verdure d'un jardin d'Albuquerque, le reste est du
gravier — et des arbres qui cassent la ligne des toits. Dans les parcs ils
viennent **par groupes de deux ou trois** au lieu d'être semés en verger.

**Des poteaux électriques et leurs câbles traversent les rues.** Sur les
références, pas une vue de rue sans deux ou trois câbles en biais dans le ciel :
ce sont les seules lignes obliques d'un décor fait de verticales, et c'est
exactement pour ça qu'on les remarque.

**La ville n'est plus un damier parfait.** Une rue sur cinq environ a disparu :
les deux îlots qu'elle séparait n'en font plus qu'un, et cette grande parcelle
porte **une seule chose** — un entrepôt et son parking, une aire de
stationnement nue, ou une friche clôturée. C'est ce que montrent les vues
aériennes d'Albuquerque : la trame reste lisible, mais elle n'est jamais
régulière.

**La rue a trois matières au lieu de deux.** Entre la bordure et le trottoir
il y a maintenant une **banquette de gravier** d'un mètre, comme là-bas, et un
**caniveau en béton** au pied de la bordure. La chaussée et le trottoir se
touchaient sur une arête sans épaisseur.

À essayer : marche dans une rue des Hauteurs et regarde les maisons de trois
quarts, avec le soleil de côté — c'est là que les creux se voient. Puis
regarde en l'air, et enfin par terre au bord de la chaussée.

> Mesuré après tout ça : **57 images/seconde, zéro image ratée**, 157 Mo.

---

## 0.36.0 — Les voitures garées existent enfin, et la rue se remplit

> **On ne traverse plus les voitures à l'arrêt.** Elles n'avaient aucune
> collision — quatre cents voitures dans les rues, et on passait au travers de
> chacune. Et quand tu en percutes une maintenant, **c'est toi qui gagnes** :
> elle se fait pousser, elle glisse, elle se repose de travers.

**Les voitures qui roulent ne te baladent plus.** Elles te repoussaient comme
un mur : elles s'arrêtent et te laissent passer.

**Six objets nouveaux dans les rues** : cabine téléphonique, distributeur de
journaux, abri de bus, table de pique-nique, buissons, et des panneaux
publicitaires en sortie de ville. Plus des poubelles et des bennes **repeintes**
— trois cents poubelles identiques, ça se voyait.

**Il y a du monde.** Vingt-six passants au lieu de seize, plus près, et placés
devant toi plutôt que n'importe où autour : ils marchent vers toi au lieu de te
tourner le dos. Avant, on pouvait traverser trois rues sans croiser personne.

**Le désert a des rochers**, serrés au pied des mesas — et **son ambiance
sonore**, celle que tu avais livrée le 27 et qui n'avait jamais été branchée.

À essayer : roule dans une file de voitures garées et pousse-les. Puis va au
désert, et écoute la différence quand tu arrives.

> **Pas fait, et je le dis :** les passants sont toujours les bonshommes en
> boîtes. Les vrais figurants sont importés et le jeu sait les animer, mais le
> report de la démarche de Walter sur leur squelette produit un corps disloqué.
> Le détail est dans le ticket #16.

---

## 0.35.0 — Le désert devient un lieu

> **Il y a du relief.** Des mesas à flancs raides — les seuls repères de la
> zone, on se dirige par elles — un **arroyo** (le lit d'un torrent à sec) que
> la piste traverse en plongeant, et un **fossé** contre la piste : c'est là
> que le camping-car sortira de la route à la mission 1.

**La piste serpente** au lieu d'aller tout droit. Une ligne droite dans une
plaine, on en voit la fin dès le départ et on ne tourne jamais le volant.

À essayer : va au désert et suis la piste jusqu'au bout sans couper. Le passage
de l'arroyo est le seul endroit où tu ne vois pas ce qui arrive.

---

## 0.34.0 — La ville n'est plus posée au milieu de nulle part

> **Il y a des montagnes.** Les Sandia, au nord et à l'ouest, dans la brume.
> Avant, le regard ne rencontrait jamais rien et la plaine paraissait infinie.

**La ville se dilue au lieu de s'arrêter net.** La dernière rangée d'îlots est
maintenant faite de terrains vagues, de maisons isolées et de parkings : on sent
qu'on sort de la ville au lieu de tomber d'une falaise d'immeubles dans le sable.

**Deux routes quittent la ville** — une vers le nord, une vers l'est — avec
leurs poteaux électriques qui filent vers l'horizon. Elles ne mènent nulle part
et disparaissent dans la brume, c'est voulu : elles disent qu'il y a un ailleurs.

À essayer : sors de la ville par le nord et roule jusqu'à ce que la route
s'arrête. C'est la vue qui a le plus changé.

---

## 0.33.0 — Les quartiers, les pavillons et les centres commerciaux

> **La ville a maintenant trois quartiers**, en bandes du nord au sud. Roule
> d'ouest en est et tu changes de monde deux fois, sans qu'aucun panneau ne te
> le dise.

**Les Hauteurs**, à l'ouest — c'est là que tu commences. Des pavillons, leurs
allées, leurs boîtes aux lettres, leurs murets en parpaing et leurs jardins en
gravier. Des parcs. C'est le quartier de Walt, et le jour où quelqu'un
regardera par la fenêtre, c'est ici que ça coûtera le plus cher.

**Le Centre** — les immeubles, les parkings, et des **centres commerciaux de
bord de route** : un bâtiment bas au fond, son auvent, ses vitrines, et le
parking sur la rue. C'est le motif d'Albuquerque, celui de Los Pollos et du
lavage de voitures.

**Rio Sud**, à l'est — l'industrie et les terrains vagues. Peu de monde, et
personne pour regarder.

À essayer : pars de chez Walt et roule vers l'est en ligne droite jusqu'au bout
de la carte. Dis-moi à quel moment tu sens que tu as changé de quartier — si ça
n'arrive jamais, c'est le contraste entre les trois qu'il faut monter.

---

## 0.32.0 — La ville n'est plus soixante-quatre fois le même îlot

> **Trois nouveaux types de parcelle**, tirés au sort sur toute la carte : des
> **parcs**, des **terrains vagues** et des **parkings**. Sur 64 îlots, ça fait
> aujourd'hui 50 bâtis, 6 parkings, 5 terrains vagues et 3 parcs.

**Le parc se traverse à pied.** Deux allées en croix, des arbres, des bancs.
C'est le seul endroit de la ville où passer à pied est plus court qu'en
voiture — descends de voiture et coupe à travers, c'est fait pour.

**Le terrain vague est clôturé**, avec une ouverture de chaque côté. Pas une
fenêtre, donc personne pour regarder : le jour où les témoins existeront, ce
sera l'endroit où faire ce qu'on ne fait pas ailleurs.

**Le parking** a ses places peintes et ses rangées qui se font face.

À essayer : roule jusqu'à en croiser un de chaque, et dis-moi si ça suffit à
ne plus avoir l'impression de tourner en rond. Si ça manque encore, c'est le
nombre de types qu'il faut monter, pas leur fréquence.

---

## 0.31.0 — Le temps passe, et la ville fait treize fois sa taille

> **La ville est passée de 131 à 473 mètres de côté** — 64 îlots au lieu de 4.
> À essayer en premier : sortir de chez Walter, prendre la voiture et rouler
> tout droit sans tourner. Ça dure maintenant plus de dix secondes.

**Les journées passent.** Une heure de jeu par minute réelle, donc une journée
complète en vingt-six minutes. Le soleil descend pendant qu'on joue, les
lampadaires s'allument au crépuscule, les fenêtres s'éclairent, les lumières de
porche aussi. Si tu veux figer l'heure pour regarder quelque chose : menu pause,
réglage « Vitesse du temps », à zéro.

**La mission commence à neuf heures du matin**, quelle que soit l'heure à
laquelle le monde a été fabriqué. Une mission peut désormais imposer son heure —
un rendez-vous de nuit se jouera de nuit.

**La maison de Walter ne reste plus noire la nuit.** Sa lumière de porche
n'était fabriquée que si le monde démarrait de nuit : en partant de jour, la
façade restait une silhouette noire jusqu'au matin.

**Les passants marchent sur les trottoirs et tournent aux carrefours.** Ils
faisaient un aller-retour sur vingt-cinq mètres, toujours le même. Ils suivent
maintenant les rues — et ils sont seize en permanence autour de toi, où que tu
sois, au lieu d'être répartis dans toute la ville.

> **Si ça rame, c'est ici qu'il faut regarder.** La ville seize fois plus grande
> tourne au même prix qu'avant sur ma machine (55 images/seconde), mais c'est le
> premier changement capable de faire tomber une machine plus modeste. Dis-le.

---

## 0.30.0 — Le chapeau, le livre, Jesse, et les objets qu'on voyait pas

> **Le plus gros est invisible dans la liste : les objets qu'on tient étaient
> rendus à un centième de leur taille.** Le revolver mesurait deux millimètres.
> C'est réparé, donc tout ce qu'on équipe se voit enfin — et ça explique aussi
> pourquoi le chapeau semblait ne pas se poser.

**Le porkpie se porte.** Choisis-le dans la roue : Walter lève la main, le
chapeau apparaît sur sa tête. Rechoisis-le, il l'enlève. Il reste en place
pendant que tu tiens autre chose — un chapeau n'est pas un objet qu'on tient.
C'est le modèle livré par Guillaume, pas la boîte de substitution.

**Le livre se lit.** Une fois équipé, **F** quand rien d'autre n'est à portée :
Walter le lève à hauteur de lecture, tourne une page, quatre secondes et demie.
Bouger interrompt.

**L'Aztek roule enfin nez en avant.** Elle était retournée. La cause remontait
loin : la rotation demandée à l'import n'avait jamais été appliquée, et un
redressement automatique la posait en plus sur le nez.

**Walter ne se remonte plus les lunettes à travers la poitrine.** Son
avant-bras passait dans le buste sur douze centimètres pour aller chercher ses
montures. Le geste est refait, coude bas, bras à l'extérieur.

À essayer : prends le chapeau chez toi, mets-le, va conduire avec. Et lis le
livre dehors, puis avance en pleine lecture pour vérifier que ça coupe bien.

**Jesse respire.** Il restait planté sans animation : ses clips avaient été
refaits sur le mauvais squelette, au point que sa marche mesurait zéro mètre de
foulée. Refabriqués sur le sien.

**Le camping-car ressemble à un labo.** Fioles coniques, un condenseur au-dessus
de la cuve, et surtout des **tuyaux** qui courent le long du couloir et
descendent vers la paillasse et l'atelier — c'est ce qui relie les objets entre
eux et ce qui manquait le plus. Un filet de vapeur monte de la cuve.

---

## 0.29.0 — Le QG accessible, la nuit habitable, et l'Aztek

> **Bloquant, corrigé.** On ne pouvait pas se rendre chez Tuco : la voiture
> arrivait tournée vers la sortie, et l'élan qu'elle garde depuis la 0.28.0 la
> renvoyait au désert en une seconde. On arrive maintenant face au bâtiment.

**La nuit se voit.** Ciel étoilé, lune, et une vraie lumière lunaire — froide et
orientée, donc elle garde le relief au lieu d'aplatir la rue comme l'aurait fait
une simple ambiante plus forte. On distingue le sol entre deux lampadaires.

**La voiture de Walter est la Pontiac Aztek** livrée par Guillaume.

**Le menu pause ne vous téléporte plus.** Valider « Reprendre » avec F faisait
aussi ouvrir la porte devant laquelle on se tenait. Échap ferme le menu depuis
n'importe où, les entrées se **cliquent à la souris**, et on peut **maintenir**
A ou D pour faire défiler un réglage.

**Le téléphone affiche l'heure.**

**Le visage de Walter** est en haut à gauche, avec sa barre de vie — toujours
visible désormais — et son argent juste dessous. Les trois parlent de la même
personne, ils sont ensemble.

**Les phares** ne s'allument plus tout seuls à la tombée de la nuit et
s'éteignent en descendant. Ils se commandent à la touche **A**, au volant.

**Le camping-car a une porte** de l'intérieur, comme les maisons.

**Les panneaux disent où ils mènent** : « QG TUCO » à la nouvelle sortie du
désert, et « ALBUQUERQUE » au retour — il annonçait « DESERT » à quelqu'un qui
était déjà dans le désert. La sortie vers Tuco est ramenée à soixante mètres du
camping-car ; à cent quatre-vingt-dix, la route n'était qu'une corvée.

**« Gun de ouf » s'appelle « Revolver ».**

> **Pas fait :** l'objet équipé ne se voit toujours pas dans la main, et Walter
> ne prend pas de position de tir quand il vise.

## 0.28.1 — Les portes, Jesse qui s'en va, et Jesse qui redevient beau

**Jesse avait perdu son visage.** Le modèle de Guillaume avait été écrasé par le
corps générique — c'est ma faute, une régénération d'assets lancée pour une tout
autre raison. Il est revenu, et le générateur ne peut plus le remplacer.

**Les maisons ont une porte de l'intérieur.** Le salon était une boîte lisse : on
cherchait le mur par lequel on était entré.

**Jesse sort vraiment de chez lui.** Il dit qu'il part devant, il traverse la
pièce, il ouvre la porte et il s'en va — au lieu de disparaître sur place.

**Tuco ne reçoit plus les bras en croix.** Sa pose assise gardait les bras
écartés d'un angle écrit à la main, qui ne veut pas dire la même chose sur son
squelette que sur celui de Walter.

## 0.28.0 — La mission 1 en entier, et le camping-car de Guillaume

> **La mission se joue maintenant du début à la fin en plein jour.** Elle se
> jouait de nuit, ce qui n'était pas voulu.

**Le camping-car est celui de Guillaume.** Le vrai modèle remplace la boîte
qu'on avait générée. On ne se coince plus dessus en marchant ou en sautant
contre : sa collision est une caisse simple, et il n'y a donc plus de creux où
rester bloqué. **On entre par le flanc**, plus par le pare-brise.

**À l'intérieur**, il est plus large d'un mètre. La caméra ne sort plus par la
paroi, la cabine est reconnaissable — pare-brise, planche de bord, volant,
sièges — et **les meubles sont solides** : on ne traverse plus les paillasses ni
l'atelier. Une fois sorti, **on peut re-rentrer** : la porte restait fermée pour
toujours.

**Un menu pause**, sur Échap : Reprendre, Options, Recommencer la mission,
Quitter. Les options règlent les volumes, un par un, et la vitesse du cycle
jour/nuit.

**Une nouvelle route mène chez Tuco**, loin au sud de la piste du désert, avec
son panneau et sa flèche. On y allait auparavant sans le vouloir : la sortie
était posée à vingt-cinq mètres du camping-car.

### Ce qui gênait vraiment, et qui est réparé

- **Jesse et Tuco tournaient le dos** à qui leur parlait. Tous les personnages
  animés étaient à l'envers.
- **La boîte à gants donnait un chapeau.** Elle donne le revolver, et Walter
  part désormais **les mains vides** au lieu de commencer coiffé du Porkpie.
- **Après le camping-car, Jesse redisait « allons cuisiner ».** Et il restait
  chez lui pendant qu'il nous attendait dans le désert.
- **On pouvait filer au désert dès la première minute**, avant même de savoir
  pourquoi. La route est fermée jusqu'à la conversation chez Jesse.
- **On pouvait naviguer dans le téléphone pendant l'appel de mission**, et
  raccrocher au nez de celui qui lance la mission.
- **L'objectif s'affichait quatre secondes**, en petit, par-dessus le décor. Il
  a maintenant sa place en haut à gauche et **reste une minute**. Le texte ne
  déborde plus de l'écran du téléphone.
- **« Il vous faut la voiture » s'affichait dans le salon de Jesse**, avant
  d'avoir passé la porte.
- **L'argent de Tuco arrive quand il dit « compte-les si tu veux »**, et le
  garde vient fouiller Walter au moment où Tuco l'ordonne — plus vingt
  répliques trop tôt.
- **L'explosion coupait la parole à Walter.** La réplique va jusqu'au bout, puis
  le blanc se retire sur dix secondes.
- **On traversait le bureau de Tuco.** Et on arrivait collé au mur d'entrée : on
  arrive maintenant au centre de la pièce, face à lui.
- **Dans la cachette, Walter avançait à chaque tranche de mille dollars**, et on
  ne pouvait pas refermer sans déposer. Échap referme.
- **On arrivait à l'arrêt** après chaque fondu de route. La voiture garde un peu
  d'élan.
- **La marche arrière** est nettement plus vive.

> **Pas encore fait, et c'est volontaire :** la voiture n'accélère pas plus fort
> au démarrage. Mesuré : au-delà du réglage actuel, la caisse penche assez en
> virage pour racler du flanc, ce qui la freine net. Le réglage qui manquait
> pour corriger ça existe maintenant (`anti_roulis_force`), mais le châssis se
> règle au volant, pas en aveugle.

## 0.27.3 — Jesse répond enfin de la commande

> **Bug bloquant, corrigé.** Après l''appel de l''homme de Tuco, aller parler à
> Jesse chez lui ne lançait pas la conversation de la mission : il disait « Yo »
> comme d''habitude, et **l''étape ne pouvait plus être franchie**.

Un habitant portait une clé unique, il tenait donc toujours la même
conversation. C''est maintenant la mission qui décide de ce que quelqu''un a à
dire à un moment donné — et qui le rend à sa causette ordinaire l''étape passée.

## 0.27.2 — Les vrais sons de Guillaume

> **À essayer : tire, et surtout va au bout de la scène chez Tuco.** Les coups
> de feu, la fusillade et l''explosion ne sont plus synthétisés — ce sont ceux
> de Guillaume, livrés dans la foulée.
>
> Et **« this is not meth » est là.** Walt annonce ce qu''il tient, puis lance le
> cristal. La réplique passe une seconde avant l''explosion : jouées ensemble,
> la phrase serait devenue un bruit parmi deux autres.

Quatre variantes de coup de feu au lieu de trois, trois fichiers de fusillade
tirés au hasard. Les cinq tickets correspondants sont clos.

## 0.27.1 — Jesse et Tuco, les vrais

> **À essayer : va parler à Jesse chez lui, puis regarde Tuco derrière son
> bureau.** Ce sont les modèles de Guillaume, à la place des corps génériques.

Ils partagent le squelette de Walter, donc **ses animations leur ont été
recopiées** — ils respirent et se tiennent relâchés au lieu d''attendre bras en
croix. C''est ce que faisait Tuco jusqu''ici : le seul clip de son fichier était
une pose en T.

**Corrigé au passage, et ça valait les deux heures** : l''outil qui normalise un
modèle livré mesurait sa taille sur la boîte englobante du maillage, qui décrit
la géométrie **avant** déformation par le squelette. Les deux modèles
s''annonçaient à 2,70 m et ressortaient à 3,10 après une mise à l''échelle censée
les ramener à 1,75. La taille se lit maintenant sur les os, comme les foulées.

## 0.27.0 — La première mission

> **Le jeu a un début, un milieu et une fin.** Quinze étapes, quatre nouveaux
> décors, et de quoi tout rater.
>
> **Sors de chez toi et attends.** Un homme de Salamanca appelle. À partir de
> là, le téléphone est ton carnet de mission : `T`, puis **Mission** — l'objectif
> courant et les deux précédents. À chaque étape franchie il sort tout seul,
> montre la suite, et se range.

**Le déroulé.** Parler à Jesse, prendre la voiture, rejoindre le labo dans le
désert, cuisiner la **botte secrète**, récupérer la marchandise, livrer Tuco,
s'en sortir, rentrer, planquer l'argent.

| Ce qui est nouveau | |
|---|---|
| **L'argent** | En haut à gauche, avec le sac de billets de Guillaume. On démarre avec 100 à 200 $ — tirés au sort — et Tuco en paie **300 000** |
| **La vie** | Une barre, qui n'apparaît qu'au premier coup. Une balle en retire un quart |
| **Le revolver** | Dans la boîte à gants du camping-car. **Clic droit vise, clic gauche tire.** La roue des outils est passée sur `Tab` seul |
| **La mort** | Le temps ralentit, l'image se décolore, et **Walter s'écroule pour de bon** — un vrai ragdoll sur ses vingt-quatre os. Puis on recommence |
| **La cachette** | Une latte du mur, chez Walter. On y règle le montant avec `W`/`S` |

**Quatre décors** construits d'après tes références : l'intérieur du camping-car
— un couloir, la paillasse, la verrerie, les bidons —, la rue du QG avec sa
fresque, et le bureau de Tuco, lambrissé et calfeutré, éclairé par une seule
lampe posée.

**Ce qu'on peut essayer de casser, et qui est prévu :** tirer sur Jesse, sur
Skyler, sur le garde à l'entrée, sur Tuco. Chercher à conduire le camping-car.
Aller chez Tuco sans marchandise. Ressortir de chez soi avec trois cent mille
dollars en poche. Ne rien faire pendant que Tuco s'énerve.

**Ce qui manque, et qui viendra de Guillaume :**

- **le son « this is not meth »** n'était pas dans les livraisons. La scène de
  l'explosion joue un son de synthèse à sa place
- **les coups de feu et l'explosion** sont eux aussi synthétisés — ils tiennent
  la place, ils ne la méritent pas
- **Tuco, le garde et les hommes de main** empruntent les corps des passants, en
  attendant leurs modèles

## 0.26.0 — Sauter, s'accroupir, et emboutir pour de bon

> **À essayer, trois choses.**
>
> - **Espace : il saute.** Environ un mètre de haut. Saute en courant : **il
>   part en avant** et garde son élan jusqu'à l'atterrissage, il ne saute pas
>   sur place.
> - **Ctrl gauche maintenu : il s'accroupit**, et il peut se déplacer comme ça.
>   **Sa capsule de collision descend avec lui** — c'est ce qui compte, sinon
>   s'accroupir ne servirait qu'à aller moins vite.
> - **Rentre dans un mur à plus de 50 mph** : la tôle sonne violent, quoi qu'on
>   ait tapé.

**Le choc violent a deux déclencheurs maintenant**, et le second est nouveau :
au-delà de **50 mph à l'arrivée**, c'est classé violent quelle que soit la
vitesse perdue. Avant, seule la décélération comptait — juste pour un mur, faux
pour tout ce qui cède un peu : on pouvait emboutir à cent kilomètres/heure
quelque chose qui amortit et n'entendre qu'un frottement. Le critère de perte
brutale reste, sinon un mur pris à trente sonnerait léger.

Le seuil se règle : `choc_impact_mph` dans `reglages.tres`.

**Espace saute à pied et reste le frein à main au volant.** Les deux ne se
gênent pas.

Les animations d'accroupissement et de saut sont fabriquées comme les
précédentes, et pour l'accroupissement il a fallu **chercher** les flexions :
descendre le bassin de quarante centimètres sans plier correctement hanches,
genoux et chevilles enterre les pieds. Ils bougent de 2 millimètres.

## 0.25.0 — Walter respire

> **À essayer : lâche les commandes et regarde-le.** Il ne se fige plus sur une
> image de course. Il se tient debout, bras le long du corps, **il respire**, il
> reporte son poids d'un pied sur l'autre — et **toutes les huit secondes il
> remonte ses lunettes**.
>
> **Puis entre dans une maison et marche.** La démarche intérieure était raide ;
> le buste tourne maintenant à l'inverse du bassin, la tête suit avec un temps de
> retard, et les deux pas ne sont plus identiques.

**Pourquoi la marche était robotique, et ce n'était pas l'animation.** La longueur
de foulée était réglée à l'œil : 1,15 m, alors que le clip livré en fait **1,76**.
L'animation était donc jouée 50 % trop vite pour la vitesse réelle — il pédalait.
Les trois foulées sont maintenant **mesurées dans le fichier** au lieu d'être
devinées : `blender -b -P outils/animer_perso.py -- --mesurer` les affiche.

**Les deux animations manquantes sont fabriquées, pas achetées.** Le pack ne
contenait que « Walking » et « Running ». Le repos dérive de la **moyenne du cycle
de marche** — moyenner un cycle symétrique annule le balancement et laisse la
posture de celui qui a riggé le personnage — et la marche relâchée est la marche
livrée plus une couche de mouvement. Rien n'est inventé par-dessus le travail de
Guillaume.

**Toujours en attente côté assets** : une vraie animation de trot. Le trot et la
course partagent encore le clip de course à deux vitesses.

## 0.24.0 — Trois allures

> **À essayer : marche, cours, entre dans une maison.**
>
> - **Par défaut Walter trottine** — c'est le rythme pour traverser un quartier.
> - **Maj + avancer** : il court. Presque deux fois plus vite.
> - **À l'intérieur** : il marche, et Maj n'y change rien. Courir dans un salon de sept
>   mètres n'a pas de sens.

**Une limite à connaître** : le modèle livré porte deux animations, `Walking` et `Running`.
Le trot et la course partagent donc le clip de course, joué à deux vitesses. Ça se tient —
un cycle de course ralenti se lit comme un petit trot — mais **une vraie animation de trot
les séparerait nettement.** C'est la seule chose qui manque côté assets.

**Corrigé au passage, et ça se voit** : la « vitesse de marche » valait 4,2 m/s, soit une
allure de course. C'était la seule vitesse du jeu, donc elle avait été réglée pour traverser
le quartier — **et les passants la partageaient.** Toute la rue trottinait. Elle est
redescendue à 1,65 : les passants marchent enfin.

## 0.23.0 — Le vrai Walter

> **À essayer : marche, cours, regarde-le.** C'est le modèle rigué de Guillaume — un
> squelette de 24 os et sa vraie animation de marche, à la place du pantin de dix segments
> animé par du code. Le chapeau et le revolver s'accrochent à sa main et à sa tête comme
> avant.

Il fait 1,78 m, ses pieds touchent le sol, et **il regarde dans le bon sens** — il arrivait
face caméra, donc marchait à reculons.

La cadence du pas reste calée sur la **distance parcourue**, pas sur l'horloge : c'est ce
qui empêche les pieds de patiner, à n'importe quelle vitesse. On ne joue pas l'animation,
on lui demande l'image qui correspond aux mètres franchis.

Les passants gardent l'ancien corps pour l'instant — leurs modèles rigués arrivent.

## 0.22.0 — La ville bouge

> **À essayer : reste sur un trottoir et regarde la rue.** Il y a maintenant des voitures
> qui **roulent** — dix, chacune sur sa file de droite, qui tournent aux carrefours et
> s'arrêtent derrière ce qui les bloque. Mets-toi devant l'une d'elles, elle te pousse.
>
> **Et suis un passant.** Avant, il refaisait les mêmes vingt-cinq mètres à l'infini. Il
> tourne maintenant aux coins de rue et ne repasse plus au même endroit.

Le générateur publie un **graphe** de la ville — carrefours et tronçons — et tout le monde
y circule : les voitures sur la chaussée, les piétons au milieu du trottoir. Une ville
regénérée avec une autre graine fait circuler ses voitures toute seule.

Rien de tout ça n'est simulé en physique : les voitures suivent une ligne et s'arrêtent si
quelque chose la barre. C'est volontaire — une circulation avec changement de voie est
l'endroit précis où les projets à deux s'enlisent.

## 0.21.0 — Cinq voitures, et une Alpine

> **À essayer : regarde les voitures garées.** Il y en avait un seul modèle décliné en trois
> couleurs ; il y en a maintenant **cinq silhouettes** — pick-up, berline, break, Aztek, et
> une Alpine A110 bleue garée devant chez Walter.
>
> Le parc est pondéré comme une rue d'Albuquerque en 2009 : surtout des pick-up.

**L'Alpine est un anachronisme assumé.** Alpine n'a rien produit entre 1995 et 2017, donc
aucune n'est contemporaine de la série. Celle-ci est une A110 des années soixante-dix,
telle qu'un collectionneur en garderait une — et c'est la seule teinte saturée de tout le
parc. Dans une rue de beiges et de gris, elle se voit à cent mètres. C'est le but.

**Les lieux nommés.** Le panneau DESERT s'était retrouvé au milieu de la chaussée **deux
fois**, à chaque fois qu'une rue changeait de largeur. Le générateur publie maintenant des
lieux nommés — la parcelle des maisons, la sortie vers le désert, la place de l'Alpine — et
la scène les lit au lieu de recopier des coordonnées. Un lieu nommé se recalcule ; une
coordonnée écrite à la main se périme.

## 0.20.0 — Les rues sont enfin praticables

> **À essayer : roule vite en frôlant le trottoir.** Avant, la voiture perdait **62 % de sa
> vitesse** en une seconde et demie. Maintenant elle en garde 82 %.

**Ce n'était pas le trottoir.** Mesuré image par image : franchir une bordure de dix-huit
centimètres à 54 km/h coûte **un** kilomètre/heure.

C'était le **stationnement**. Deux rangées de voitures garées sur une chaussée de huit
mètres laissaient 3,84 m de passage pour une caisse de 1,86 m — moins d'un mètre de chaque
côté. On accrochait une aile à la moindre dérive.

La chaussée passe de 8 à 11 mètres. Les rues sont un peu plus larges, la ville un peu plus
grande, et on peut doubler une voiture garée sans la toucher.

## 0.19.0 — La roue des outils s'entend

> **À essayer : ouvre la roue (`Tab` maintenu) et écoute.** Trois couches se superposent
> maintenant — le déclic de l'ouverture, le monde qui ralentit, et une tenue qui dure aussi
> longtemps que la roue reste ouverte. Elle s'arrête en fondu quand tu relâches.
>
> **Dis si ça porte le geste ou si ça l'alourdit.** C'est exactement la question, et elle
> ne se tranche qu'à l'oreille.

**Tous les sons livrés par Guillaume sont désormais branchés.** Il n'en reste aucun de côté.

## 0.18.0 — Le son marchait à moitié

> **À essayer : rentre dans un mur en voiture.** Ça fait du bruit, et la tôle ne sonne pas
> pareil selon la violence. Marche aussi : frotter un trottoir, taper une benne.
>
> **Et écoute tes pas.** Quinze variantes dehors, elles ne se répètent plus.

**Le bug important.** Le véhicule, le joueur, la roue des outils et le téléphone ne
trouvaient pas le système audio et **restaient muets pour toute la partie**. Les portes et
les portières sonnaient quand même, ce qui rendait la panne difficile à voir : le son
marchait *un peu*.

Concrètement, tout ceci était silencieux et ne l'est plus : les pas, les crans de la roue,
les objets qu'on équipe, la sonnerie du téléphone, le klaxon, et les chocs.

**Ce qui reste muet, et c'est voulu** : deux sons d'interface qui demandent un mécanisme
différent (une nappe qui dure tant que la roue est ouverte).

## 0.17.0 — Les chocs

> **À essayer : tape quelque chose en voiture.** Un frottement et un impact violent ne
> jouent pas le même son.

## 0.16.0 — Le jour et la nuit

> **À essayer :** ouvre `game/systemes/reglages.tres` dans Godot et mets **`temps_vitesse`
> à `0.05`**. Une journée complète passe en huit minutes : le soleil se lève, tourne,
> rougit et se couche ; les lampadaires s'allument au crépuscule ; les fenêtres des
> immeubles s'allument une à une.

Avant, le moment était figé à la génération et changer d'heure demandait de refabriquer
toute la ville.

Par défaut le temps est **arrêté** — un cycle qui tourne pendant qu'on règle autre chose
rend tout réglage impossible à juger.

## 0.15.0 — Le désert, réparé

> **À essayer :** la flèche orange au bout de la route ouest. En voiture, elle emmène au
> désert ; à pied, un bandeau explique pourquoi ça ne marche pas.

**Bugs corrigés** : la flèche pointait vers la ville, le panneau était planté sur la
chaussée, DESERT s'écrivait à l'envers vu de dos, on pouvait repartir à pied, et surtout
**revenir en ville renvoyait aussitôt au désert**, en boucle.

## 0.14.0 — Voir le jeu sans y jouer

> **Pour Benjamin :** `.\bg.ps1 capture -Scenario tous` rend une douzaine de vues du jeu
> dans `.tmp\captures\`. Utile pour vérifier ce qui a changé sans lancer une partie.

## 0.13.0 — Le désert

> **À essayer :** rouler jusqu'au bout de la route ouest et franchir la flèche. Le
> camping-car est là-bas.
>
> **Et le téléphone** : touche `T`, `Appeler`, choisis Jesse ou Skyler. Walter porte le
> combiné à l'oreille.

## 0.11.0 — Le téléphone

> **À essayer :** `T` ouvre le SGH-127. Aucune voix pour l'instant, c'est normal.

## 0.10.0 — La scène de la cuisine, nouvelle prise

> **À essayer :** entre chez Skyler et parle-lui. Les dix répliques ont été réenregistrées.

## 0.9.0 — Les sons de Guillaume, branchés

> **À essayer :** la roue des outils (`Tab`), les portes des maisons, monter et descendre
> de voiture, le klaxon (`H`). Tout ça fait du bruit maintenant.

**Bug corrigé** : aucune boucle sonore ne bouclait — les trois couches du moteur repartaient
de zéro toutes les cinq secondes.

## Avant

Le premier jalon, sans numéro : la ville, la conduite, marcher, les maisons et leurs
habitants, les dialogues doublés, la roue des outils, la visée à la souris, les passants,
le modèle sculpté de Walter. Le détail est dans [docs/JOURNAL.md](docs/JOURNAL.md).
