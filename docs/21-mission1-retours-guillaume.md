# Mission 1 — les retours de Guillaume (version 1.1)

**Ce document est la transcription integrale, mot pour mot, du fichier
`livraisons/briefs/mission-1-retours-1.1.docx`, livre le 23 aout 2026.**
Rien n'y est resume, reformule ni trie : c'est le texte de Guillaume, et
c'est lui qui fait foi quand une question se pose sur un battement.
Seuls les titres de section ont ete marques comme titres.

Il repond a la version **0.58.13**, la premiere que Guillaume a jouee de
bout en bout.

---

Ok.

Merci pour cette première mission.

Ce doc contiendra les retours et modifications à apporter à celle-ci.

Ce sera un très gros retour, très détaillé. Merci de le lire en entier avant de travailler et de n’omettre aucun détail.

J’avoue ne pas avoir tenu compte de tous les tickets ouverts à la suite de la dernière version. Merci de m’envoyer un mail quand tu auras fini ce travail, avec un résumé de ce qui a été fait, ce qui a échoué, et ce qui manque pour continuer. (gui.s@live.fr, compte Guiking sur Github, (Guillaume))

## Changements globaux :

Le plus gros problème de cette mission est qu’elle est trop rapide. On exécute les taches une à une très rapidement et la mission se termine en moins de 5 minutes sans difficulté. Je sais que c’est la première mission du jeu mais on vise quand même une difficulté et une durée de vie plus agréable. La cible de nos joueurs sont principalement des hommes de 25-35 ans. Donc très à l’aise avec les jeux vidéos. Il faut améliorer ça.

### Des pistes d’amélioration :

Ajouter des étapes de missions, plus de choses à faire. Mais toujours en lien avec l’épisode de la série.

Faire en sorte que les taches à accomplir soient plus longues, soient plus scriptées..

SURTOUT : il faut plus de Gameplay. Toutes les étapes de missions ne sont qu’un item à « cliquer » et la tache se résout par texte. Ça, il en faut le moins possible, sinon on va vite s’ennuyer dans l’intégralité du jeu. Il faut que le joueur face plus d’actions qui se jouent.

Il y a beaucoup (trop) d’indications textuelles de ce que le joueur doit faire pour passer à l’étape suivante. Le plus possible, essayer de faire en sorte que le joueur devine ce qu’il doit faire, ou que les PNJ autour parlent ou agisse quelque-chose pour nous attirer vers la suite,  au lieux qu’on nous dise tout via un texte de mission. Il faut que l’enchainement des actions soit le plus logique et naturel possible. Merci de garder ça en tête pour la suite des missions.

Quand le personnage meurt, on voit sont corps s’effondrer mais il est absolument énorme. Il faut qu’il garde sa taille réelle.

Quand un Game Over est provoqué par la mort de quelqu’un d’autre, c’est Walter qui meurt sur l’écran de game over. Il faut que ce soit un plan sur le personnage qui meurt, au ralenti, 1 seconde avant de lancer sont animation de mort (qu’on est le temps de suivre).

Lors d’un dialogue, ok pour passer les partie avec une touche comme à l’heure actuelle. Mais inclure une exception : quand un personnage à sa parole coupée. Si dans le dialogue, un personnage se fait couper la parole, le jeu ne laisse pas au joueur le temps d’appuyer sur suivant, la phrase d’après s’enchaine toute seule.

Inclure une zone de mission à respecter, à deux niveaux. Je m’explique.

Quand le personnage est au milieu d’une mission avec des actions à faire dans un périmètre précis, il faut empêcher le joueur de partir et faire sa vie au milieu de l’action. Si le joueur s’éloigne trop, ET qu’il y a un personnage à proximité faisant partie de la mission, celui-ci lui lancera un dialogue pour le pousser à revenir et continuer la mission. Exemple : Jesse : « M. White, where are you going, we need to finish this ! ». Ça c’est le premier niveau « d’avertissement » si le joueur s’éloigne trop. Le second, si le joueur va encore plus loin, après l’avertissement, l’écran devient gris, un titre apparait au milieu de l’écran style : « Vous quittez la zone de mission » avec un compte à rebours de 10 secondes qui se lance dès qu’on franchit cette distance de la zone de mission. A la fin de ce décompte, c’est game over « Vous vous êtes enfui » ou un truc comme ça.

(à noter que cette feature ne sera active que pour les missions où c’est logique de la mettre, où tout se passe au même endroit par exemple, notamment pour les missions de « campagne/histoire ». Elle sera la plupart du temps absente des missions secondaire, ou de missions quotidiennes ou open world)

Réparer la caméra : Faire en sorte que les mouvements de la souris suivent la même logique de mouvement que les jeux classiques sur PC en 3eme personne. De même pour les mouvements QZDS (AWSD). Il me sembles qu’ils doivent être orientés en fonction de l’axe de la caméra. Je te laisse réparer ça pour le rendre jouable dans la NORME des autres jeux du style.

En arrivant à Albuquerque, ce serait mieux d’apparaitre à l’entrée de la ville (route vers le désert) et non un peu au milieu d’une route. 

## 2 – modifications point par point de la mission:

La mission doit impérativement se dérouler la journée.

Faire en sorte que Walter se déplace doucement tant qu’il n’a pas retiré son masque.

L’effet « masque » est sympa mais il faudra l’accentuer beaucoup plus. Faire en sorte que ce soit beaucoup plus difficile d’y voir quoi que ce soit. Rajouter un effet « low shutter » comme si le personnage était sonné.

Ne pas mettre un plan large au début de la scène. On veut la « surprise » quand on enlève le masque.

Faire durer la séquence avec le masque. La vision est trouble et illisible, on ne sait pas où on est, ni où on va vraiment. On peut se déplacer mais on ne voit pas grand-chose. On entends la voix de Jesse  (faible et diffuse dans un acouphène) qui essaye de nous indiquer où aller « Par ici Mr.White », Tout en étant paniqué. Il nous indique plus ou moins des directions, que le joueur doit suivre pour avancer dans le script. Avancer, Tourner à droite, l’autre droite (gauche, car il s’est trompé de panique) Puis il propose à Walter d’enlever le masque. C’est là qu’on voit le décor.

À ce moment-là, le joueur doit se trouver plus ou moins devant le RV, face à lui. Donc s’arranger pour que le petit « trajet » nous y amène alors qu’on ne voyait presque rien.

Rajouter des flammes autour du RV. Elles serviront à 2 choses : 1 prendre des dégats, et 2, d’étape supplémentaire dans la suites d’actions. Il faut récupérer le matériel d’abord, en essayant de ne pas marquer dans les flammes.

Puis du coup, essayer d’éteindre les flammes. Cette étape n’est pas dans le suivi de la mission, c’est juste une interaction possible. Quand on s’approche des flammes, il y a marqué « éteindre ». Si on exécute l’action, Walter s’approche du feu puis recule de 2 pas en toussant et on se couvrant la bouche de son coude. Cela pourra rajouter du temps de jeu et du stress au joueur quand il entendra les sirènes. Le jeu ne dira jamais au joueur qu’il est impossible d’éteindre les flammes. C’est une mécanique pour créer du stress et être fidèle à la série.

Il faut que Jesse fasse davantage de dialogues (qui ne fige ni le jeu, ni le joueur) juste des dialogues de Jesse stressé et paniqué. D’abord à cause des corps de Krazy-8 et Emilio. Puis à cause des flammes, enfin à cause des sirène de « policiers ». prévoir 2-3 phrases différentes par thème.

Mettre Jesse en position debout mais légèrement apeuré. Pendant la séquence.*

On peut parler à Jesse n’importe quand. Selon l’étape où en est le joueur, il peut répondre par la panique « on est dans la merde.. » ou une indication sur ce qu’il faut faire, style «  on peux pas laisser tout le matos dehors, on va se faire choper direct » .

L’option « retirer le masque » n’est cliquable que devant le RV. Elle devrait l’être depuis n’importe où. De toute façon on devrai arriver à un point plus ou moins précis avec la mise à jour.

Ajouter la feature de non-dépassement de la zone de mission.

Enlever la partie « regarder les corps » en tant que suivi de mission. Le joueur peux les regarder, Les personnages feront un dialogue, 1 phrase chacun. Par contre, au début du jeu, juste après le masque, pousser le joueur à aller voir ces corps via une phrase de Jesse. Style « Tout s’est passé si vite, qu’est-ce qu’on va faire d’eux maintenant ? ». On rajoutera une vraie tache les concernant plus tard.

Le pantalon : au moment de le ramassé ou pas, la mission l’indique comme facultatif. Sauf qu’on ne peut pas continuer la mission sans l’avoir ramassé, donc c’est bête. Il faut que ça reste facultatif (c’est une blague de la série). Ma proposition :

Déjà, le mettre beaucoup plus loin du RV, il est trop facile à trouver ici.

Ensuite, retirer cette étape du suivi de mission. Si le joueur le trouve, il peut le ramasser, mais s’il ne le ramasse pas, la mission continue normalement.

Enfin, une fois les 3 objets ramassé, On peut parler à Jesse, il nous demande si on a bien tout pris. On a un choix à faire : « oui j’ai tout le matériel » ou « non attends je vais vérifier encore ». Ça peut mettre la puce à l’oreille du joueur sans lui dire au sujet du pantalon.

avec 3 objets, la mission continuera. 

SI le joueur a trouvé le pantalon avant de parler a Jesse, celui-ci ne proposera pas le choix de chercher encore ou non. A la place il fera une remarque sur le pantalon de Walt…

(Le fais de trouver le pantalon pourra être un future succès, mais on pourra en parler plus tard si on avance le sujet, tu peux mettre cette info quelque-part dans une liste des succès possibles à faire dans le jeu)

Enlever l’action de « écouter » ça ne devrait pas être une étape cliquable, mais un dialogue lancé automatiquement, dès la récolte du 3ème objet important. Pendant ce dialogue, le joueur peu toujours jouer.

Faire en sorte que le son des sirène soit un peu plus fort à chaque grandes étapes :1 : Le premier objets, le dernier objet, Les corps

Quand on monte dans le RV pour la première fois, il FAUT que Jesse monte aussi. Il peut se déplacer jusqu’au RV pour éviter une téléportation trop lointaine. (puis il y aura la mission des corps)

Ajouter une tache à faire avec les 2 corps : les embarquer dans le RV. C’est une nouvelle étape qui rajoutera du temps de jeu et du stresse :

JUSTE au moment de d’essayer de démarrer le RV pour la première fois (bruit de moteur qui ne démarre pas), l’un des deux personnage lance un dialogue (stop le RV aussi) « ATTEND !.. les corps… on peut pas les laisser là non plus.. – Putain… allez vient m’aider ! »

À ce moment là le joueur dois descendre du RV et allez récupérer les corps. Mais il ne fini pas avec juste la touche action. Il faut maintenir la touche action sur un corps (ce qui va faire se pencher le personnage (dos courbé) pour l’attraper par les pieds) et il faudra reculer jusqu’à l’entrée du RV pour le trainer leennntement. Le personnage fatigue et lâchera 2 fois le cadavre pour souffler un peu (animation d’essoufflement + impossibilité de reprendre le cadavre pendant l’animation (3-4s). à chaque pause, Walt puis Jesse lancera une phrase en fond «  Allez », « Ils arrivent, dépêche !! », ou « putain qu’il sont lourds ». Il faudra bien sur reprendre les pieds du cadavre à chaque fois. Une fois devant l’entrée du RV, le corps se téléportera à l’intérieur.

Important, durant cette étape, Jesse part devant et tracte sont cadavre lui-même. Cela permettra au joueur de voir ce qu’il faut faire. Seul Walter fera des pauses, Jesse lui fait tout d’une traite. La tractation complète doit bien prendre au moins 20 secondes.

Le démarrage : ne PAS écrire « le moteur tousse » par pitié, il faut le vivre, pas le lire.

Aussi, il faut rajouter un petit gameplay de démarrage.  Mettre par exemple un cercle épais avec une zone à cliquer, placée aléatoirement sur le cercle. Une aiguille tourne en vitesse constante, il faut maintenir la touche E pour laisser apparaitre ce cadrant de démarrage, et appuyer sur A quand l’aiguille est dans la zone de validation. Il faut valider 3 zones de suite ( chacune de plus en plus petites). Quand une zone est validée, l’aiguille tourne dans l’autre sens. Si le joueur se trompe : Son de moteur qui se noie et le cadrant disparait. Jesse fait une remarque style « Mr. White, seriously ! ». C’est un mini jeu un peu comme avec la cuisine de meth, mais version circulaire. Au début du minijeu démarrage, et de temps en temps, Jesse peut sortir un « come on, come on, come on ».

Il manque les bruitages d’ailleurs, mais je peux les fournir si tu n’arrives pas à les trouver.

Quand les 3 zones sont cliquées d’affilé, la voiture peut démarrer.

La fumée reste à l’endroit ou le RV était au début. Elle devrait suivre le RV et non rester au sol.

Rejoindre la piste : C’est assez confusant ici. Il faut effectivement rejoindre la piste, mais je trouve qu’on est trop proche de la route. Et aussi qu’on ne devrai pas sortir pour déclencher la suite, on ne comprend pas. Le mieux serait de déclencher une cinématique dés qu’on se trouve les 4 roues sur la route et qu’on roule pendant au moins 3 secondes.

La cinématique : Le RV avance (caméra face au RV et qui le suit), on entends Walter dire « Merde… ils ont percé le réservoir d’essence avec leur flingue, on est à sec ! » Le RV se mets à ne plus rouler droit et fini sa course sur le coté de la route. « Jesse :We’re so done ..».

(À ce moment là je n’ai plus d’idée pour enchainer mais soit on continue la cinématique en les faisant sortir, soit la cinématique s’arrête, le jouer doit sortir et aller sur le bord de la route et la suite de la cinématique se lance. Honnêtement je n’ai pas la réponse ce soir. Je te laisse faire le meilleur choix.

Suite de la cinématique du coup : Walter et Jesse sont sur le bord de la route et regarde en direction d’un véhicule à sirène qui approche. Long plan où on VOIT le camion de pompier rouler sur la route, passer devant Walter et Jesse, et se diriger vers la zone où il y avait le feu tout à l’heure.

Il n’y a pas de model de camion de pompier. En attendant que je t’en livre un, merci de mettre un véhicule temporaire (gros camion de pompier jaune, ref en livraison).

Le titre « 3 semaine plus tôt » doit apparaitre à la fin de la cinématique. Sur un fond noir pendant quelques secondes et non en jeu. C’est une vraie pause. On ouvre sur un fondu du noir vers le jeu. Rajouter un petit effet sonore à l’apparition de ce titre.

A ce moment-là, plusieurs choses sont mal placées. Le RV est à cheval sur un caillou et flotte un peu dans le vide. Il faut juste le mettre sur un sol plat. Mais garder l’idée du gros massif qui le cache de la route. Jesse lui est carrément dans la pierre. Le déplacer ailleurs.

On peut traverser le RV. Il faut le rendre solide.

Dans le RV : Mettre Jesse face à un atelier, en train de manipuler des fioles. La il n’est pas dans le bon sens.

 Bug : En parlant plusieurs fois à Jesse dans le RV ça fini par lancer le dialogue d’avant « this is your office …» puis ça nous téléporte à l’entrée du RV à l’intérieur. Réparer ce bug.

Petit point important avant de commencer la cuisine. Bien faire comprendre que c’est Jesse qui cuisine et Walter qui lui donne des conseils. Ce n’est pas très clair. Rajouter quelques éléments de jeu pour que l’on comprenne bien ça (placement de Jesse, position de caméra à certains moments, dialogues en plus ou modifiés). Il faut juste que ce soit un peu plus clair.

La cuisine : On arrive à la partie la plus frustrante à jouer mais aussi celle qui va te demander le plus de créativité. Les dialogues sont super, il faut les garder voire en rajouter. MAIS on ne fait que cliquer sans vraiment jouer. Il faut ABSOLUMENT que ces étapes de cuisine soit des mini jeux. Il faut créer des mécaniques de jeu différentes pour chacune des étapes. Et il faut avoir la possibilité de réussir ou échouer à ces étapes de cuisine. Je te laisse réfléchir et trouver de bons gameplays, simples à comprendre, avec un petite indication de la mécanique à faire. Par exemple pour verser, il faut baisser la souris vers le bas de sorte que le liquide d’une fiole coule dans un récipient. Pas assez baissé ou trop, le liquide tombe hors du récipient et c’est l’échec, et recommencer. C’est un exemple parlant, il faut que tu trouves les autres.

Tu as la possibilité de changer les étapes de cuisine en soit si tu penses à une idée plus visuelle et jouable. A toi d’adapter au mieux. Mais de mettre l’accent sur le côté JEU, précision, choix/ordre des ingrédient, de dose, ou de timing. Inspire-toi des mécaniques des simulateurs de cuisine par exemple.

Réserve des idées de mini jeu pour de futures étapes de cuisine aussi (avec les différents labos qui vont débloquer de nouvelles méthodes de cuisine) Ici on ne garde effectivement que 3 étapes de cuisines pour l’instant. C’est un ajustement très important car ça constituera une des mécaniques principales du jeu. Je te laisse travailler sérieusement là-dessus.

Ce serait bien de finaliser cette première mission avec une meilleure fin. À quoi va servir ce que l’on vient de cuisiner ? Il faut appeler le fait que ça va nous amener à la situation du début de la mission. Mentionner peut-être Krazy-8 ou un  acheteur potentiel. Bref, rapproche-toi de la série pour déterminer quoi ajouter une fois la meth cuisiner pour comprendre un peu mieux ce qui va se passer. C’est surtout pour créer du sens à ce qu’on est en train de faire.

Quand je suis sorti du camping car, je me suis retrouvé sur la route (loin du camping car et surtout, il y avait sur la route, près de moi, un AUTRE camping car, (2 dans la même vue) puis le script « that is not them, it’s the firetruck » s’est lancé..

Gros bug, merci de faire en sorte que ça ne se reproduise plus.

Il faut pouvoir(devoir) rentrer avec notre voiture, garée non loin du RV. Avec mon bug, j’ai pu conduire le RV, ça ne doit pas être possible à ce moment là de la mission.

## 3 – Modifications globales sur le jeu.

Remettre l’intro au début du jeu AVANT d’arriver sur l’écran titre. Cet écran pourrait servir à charger le jeu s’il est plus lourd à l’avenir.

Améliorer GRANDEMENT l’écran titre qui est tout moche. Changer notamment la police pour quelque chose qui se rapproche plus de la charte graphique de Breaking Bad (livrée).

Améliorer par la même occasion les écrans textes avec la même rigueur.

Améliorer l’interface joueur et l’icône de Walter.

Retirer les dialogues textes et audio de Skyler et Jesse qu’on avait mis au tout début du jeu. Ces dialogues ne servent plus à rien.

Changer la touche action (f) par la touche E, dans tous le jeu.

Ajouter dans le menu pause, une option « commande » pour consulter et modifier les commandes

## 4 – Ce que je te fournis dans le dossier livraison :

Un fichier charte graphique : Celui-ci sera un peu la « bible » graphique et visuel de la série et donc du jeu. Tu devras t’en inspirer pour toutes les créations de décors, polices, habillages, GUI, Interfaces etc. De sorte à rester cohérant tout au long du développement du jeu.

Animation d’essoufflement

Animation « tirer un objet lourd » à utiliser pour tirer les corps. Attention : peux-tu modifier cette animation de sorte que les bras soient plus bas ? Juste baisser la hauteur des bras pour ce que soit logique.

Référence visuel pour le camion de pompier en attendant le vrai model.

## PS/INFOS :

* Tu peux prendre la liberté d’améliorer mes phrases de dialogue. Je les écris pour donner une idée mais c’est à toi de les rendre plus fidèles au personnage, à la série, voire carrément reprendre une vrai phrase de la série si tu penses qu’elle serait adaptée.

