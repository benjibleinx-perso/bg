# Les retours de Guillaume — version 2

**Ce document est la transcription intégrale, mot pour mot, du fichier
`livraisons/briefs/retours-2.0.docx`, livré le 27 août 2026 au soir.**
Rien n'y est résumé, reformulé ni trié : c'est le texte de Guillaume, et c'est
lui qui fait foi quand une question se pose sur un battement.
Seuls les titres de section ont été marqués comme titres.

Il répond à la version **0.58.49**, la dernière livrée ce jour-là, et il couvre
deux choses que le premier retour ne couvrait pas : le **reste du jeu** hors
mission 1, et les points de la version 1.1 qui ont été traités mais mal.

> **Quand ce document et [docs/21](21-mission1-retours-guillaume.md) se
> contredisent, c'est celui-ci qui gagne** — même raison qu'entre le script et
> le retour : il a été écrit en jouant la version d'après.

Deux fichiers sont livrés avec lui, rangés dans `livraisons/images/` :
`ecran-titre-fond.jpg` (le fond de l'écran-titre) et `icone-jeu.png` (l'icône
de l'application).

---


Ok

Voici les retours sur la dernière version du jeu :

## RETOURS SUR LA MISSION 1 :

- Quand on a un peu avancé dans la mission, l’option « recommencer la mission » dans le menu fait parfois disparaitre des item. S’assurer que cette option réintègre PARFAITEMENT tous les éléments dispos au début. Ça doit être absolument une vraie remise à 0. Pour cette mission comme pour les prochaines.

- J’insiste sur l’effet low shutter/flou de mouvement. C’est bien tu as rajouté un flou de mouvement mais il n’est visible qu’au mouvement de la souris, c’est un flou de mouvement de caméra. J’aimerais un effet un peu plus fantomatique, comme une sorte de filtre/shadder avec un effet qu’on a avec un obturateur très bas sur une caméra (genre shutter 5 ou 10).

  Ajouter notamment un mouvement de « tangage » de la caméra, souple et pas trop ample, de manière à rendre la marche difficile.

- Remplacer le RV par le model V2 que je t’ai livré. Ce n’est pas grave s’il est plus large. Assure-toi cependant qu’il n’entrave pas le déroulement de la mission. S’il faut pousser des items ou des positions de personnage, adapte.

- Manque Audio de prise de dégat (walter) et l’audio « feu qui brule le joueur ». à ajouter à la liste des audio manquants que je te fournirais.

- Essaye de faire en sorte que la trajectoire qui amene le joueur au point final où il peut retirer le masque l’amene de FACE au RV. Pour ça, arrange toi pour que la dernière ligne droite vers le point final aille dans la direction du RV tout simplement.

- Au moment où le joueur retire son masque, ajouter une phrase paniquée de Jesse qui constante la mort des deux gars part terre en mode « oh shit, What do fuck did you do with the chemicals » ou un truc comme ça ( tu peux améliorer toutes mes propositions de dialogue, comme d’habitude).

- Le masque sur Walter est mal placé. Tente de le replacer correctement. Si tu n’y arrives pas, dit moi comment le faire manuellement sur Godot. Ce sera peut-être plus simple pour les petits ajustements de position

- Remplacer les cadavres par les modèles 3D de Krazy-8 et Emilio que je t’ai déjà livré.

- Le son de la toux est bien. Couper la suite avec « heck heck uuuhhg ». Par contre, rajouter une variante de la toux, pour varier les sons possibles.

- Le démarrage (avant de ramener les cadavres) :

- Ne pas mettre le son de démarrage quand on rentre dedans.

- Quand Jesse dit « Wait », nous faire descendre du RV automatiquement 1.5s après

- Les cadavres :

  - Quand Jessse va récupérer les cadavres :

    - Il traverse le feu. Déplacer la flamme pour qu’il ne la traverse plus.

    - Il doit dérouler son dialogue en entier sans qu’on ai besoin de faire « suivant » avec E. D’ailleurs, Il faut que ce soit JESSE qui demande à Walter de l’aider et non l’inverse. Walter répond avec dégout à l’idée d’embarquer de toucher et d’embarquer des cadavres. On doit sentir la panique. Mais il sait que Jesse a raison.

  - Quand Jesse tire son cadavre, il traverse le sol et fini dans les airs, faire en sorte qu’il ne traverse pas le sol non plus. Ni lui ni le cadavre. Les deux doivent suivre la courbure du sol. Pareil pour le cadavre que le joueur tirera.

- Rajouter l’audio de Jesse en effort quand il tire.

  - Quand le joueur tire son cadavre :

    - Le cadavre n’est pas tourné dans la bonne direction quand on le tient. S’assurer qu’on lui prenne bien les pieds.

    - Le cadavre tourne en fonction de la caméra (souris) Il ne doit pas tourner et doit rester dans l’axe de Walter

    - Ok pour les pauses de fatigue, mais elles se déclenchent trop vite. On peut faire en sorte que le personnage soit fatigué au bout de 4 secondes de tirage

    - Faire en sorte que le joueur ne puisse que tirer (donc reculer) quand il tient le corps. En gros désactiver la possibilité d’avancer mais garder le recul et les directions droite gauche

    - Rajouter des sons d’effort de Walter

- Les phrases écrites de Jesse sont bien ! Ce serait mieux de les voir en audio (avec sous-titres) plutôt qu’en bandeaux muets. Ça guide le joueur sans qu’il n’ait besoin de lire l’étape de mission. Il faut garder cette mécanique à l’avenir. La garder subtile aussi, pour que le joueur comprenne sans qu’on ne lui dise explicitement. Exemple : au lieu de dire « montez dans le RV pour démarrer et partir » Dire qqchose de plus naturel style « Allez on s’taille ! » Tu l’as déjà fait mais il faut continuer cette mécanique sur d’autres missions futures.

- Quand on a rammener le cadavre, Jesse doit rester dehors tant qu’on est pas rentré dans le RV. Ça nous permettra de lui parler et qu’il nous pose sa question. Tant qu’on est dehors, Jesse est dehors avec nous. Ce n’est que pour partir que Jesse rentrera.

  Par contre, quand on parle à Jesse et qu’on lui répond qu’on a bien tout pris. Jesse monte alors en premier dans le RV en disant « alors partons vite ».

- Démarrage du RV (après les cadavres)

  -  Changer la touche pour lancer le démarrage en de E à A (car sinon ça peut nous faire sortir du RV quand on rappuit dessus) Et du coup la touche de validation va devenir « espace ». Si on échoue, on a donc la possibilité de sortir avec E ou de réessayer avec A. PAS Q : car Q nous sert à se déplacer. Attention : mon clavier est en azerty et celui de Ben est Suisse (une sorte de qwerty bizarre) Donc quand je dis « Q » je parle d’un clavier Azerty.

  - L’audio du démarrage :

    - Le bruitage de démarrage de moteur est là, mais il faut rajouter l’audio du son de moteur qui essaye de démarrer pendant qu’on maintient la touche de démarrage.

    - Le son de fin de démarrage est bien là quand on fail. Il faut le même son quand on lache tout simplement la touche de démarrage.

    - Il manque l’audio du RV qui démarre quand on a réussi .

    - Il manque le bruitage du Rv qui roule.

    - Ajouter un gros « YES, let’s fucking go » de Jesse quand on arrive à démarrer.

- En sortant du RV, j’ai pu parler à un Jesse invisible qui se tenait là ou il était après avoir trainé sont cadavre. Il faut retirer ça.

- Retirer l’étape où il faut appuyer sur E pour « Se remettre en route »

- LE RV VA BEAUCOUP TROP VITE.

  Tu avais corrigé sa vitesse dans une précédente version car tu as estimé qu’il n’arrivait pas à sortir du ravin. Il n’y avait aucun problème avec ça dans les versions précédentes. Un joueur humain n’avait pas de grosses difficultés à sortir, il fallait juste prendre un peu d’élan (ce qui rend la manœuvre très réaliste. Remettre la vitesse du RV qu’on avait avant.

- Le RV vole quelques centimètres au dessin de la route. Le mettre à bon niveau de sol

- La sortie sur la piste : Il faut absolument interdire la téléportation vers Albuquerque à ce moment là du jeu. Le joueur doit se déplacer dans l’autre direction. Tourner d’ailleurs (pour cette mission seulement) la fleche au sol pour qu’elle pointe dans l’autre direction (pour insiter le joueur à partir à droite.

- Changer la hitbox pour le fait de rouler sur la piste. Il faut que le jouer roule sur la route. Donc inclure TOUTE la route pour déclenher la suite. Aussi, si ce n’est pas déjà le cas, enlever la détection des 4 roues. Simplement calculer si le joueur est bien sur la route ou pas. Le point d’origine suffit pour ça.

- Enlever le message pour la téléportation vers Chez Tuco. Il n’existe pas à ce moment là du jeu.

- Agrandir la carte du désert dans la direction de la route on arrive vite dans le vite.

- Pour l’instant, mettre à la fin de la route une grande montagne qui se prolonge sur tous les rebords de la map. Il ne faut plus qu’il y ait de vide accessible par le joueur. Ce relief nous permettra de délimiter la map sans avoir de vide sans lequel on peut tomber. Rajouter un mur invisible pour s’assurer que le joueur ne tente pas de le grimper.

  Ajouter au bout de la route (dans la montagne) un tunnel (réel) mais qui est barrée avec une barrière de travaux solide. + mur invisible. Quand le jeu sera plus développé, le tunnel et la zone derrière sera accessible. Pour l’instant c’est fermé.

- La cinématique ne se déclenche pas. On a juste un écran noir, pas de voir, pas de texte, pas de « 3semaines plus tôt », rien. De plus ça ne dure que 2secondes. Puis on est téléporté à la suite

- Suite après le « 3 semaines plus tôt » : IL Y A 2 RV au même endroit.

  Remplacer l’autre RV par notre VOITURE. C’est d’ailleurs avec elle qu’on devra rentrer chez nous à la dernière étape.

- Jesse flotte dans les airs, encore.

- Sortir du RV nous téléporte au milieu de la route, super loin. Nous téléporter à la sortie du RV dans tous les cas.

- Quand on « enlève » la chemise, changer la texture du model pour le rentre torse-nu. Si ce n’est pas possible ou trop compliqué, je te fournirais la texture ou le modèle entier. Plus tard. Ajouter aussi un bruitage de vetement qu’on retire.

- « verser ». Il faudrait rendre cette séquence plus claire. Il faut cliquer sur JESSE qui est en train de manipuler les fioles. Ça déclenche ce dialogue. Mais au lieu de dire « again » à la fin, Walter va dire : « Attends, je vais te montrer ». Ainsi c’est plus logique de jouer le mini jeu qui arrive.

- Le premier mini jeu « verser lentement » :

  - Important : Pour tous les mini jeux, on aimerait BEAUCOUP plus de réalisme. Manipuler de vrais item 3D est dans la scène (avec la caméra qui s’approche de l’attelier. Tu peux largement t’inspirer des mécaniques de jeux de cuisine (3D) voire de potions etc. On veut voire des vraies fioles, du vrai liquide, de vrai feu etc. Génère tous les assests necessaires simples. Si besoin je peux te fournir les assets compliqués. Générer du coup aussi un vrai liquide dans un bécher mais avec les contraintes techniques de l’époque ps2. Arrange-toi pour que ce soit le plus réaliste possible mais pas trop « lourd » à calculer pour les moteurs de l’époque.

    Bien faire attention à ce que le liquide tombe bien dans l’ouverture du récipient de bas. Ajouter la contrainte de devoir mettre la BONNE quantité de liquide dans le récipient du bas. Le joueur est libre d’arrêter de verser quand il veut (valider avec « espace »)

- Les commentaires de Jesse pendant qu’on cuisine sont bien mais prennent trop de place à l’écran. Il faut que ce soit de simple phrase d’ambiance avec sous-titres en bas et qui ne polluent pas trop l’espace de jeu (Gros cadre noir de dialogue). De plus on a pas besoin de le passer avec E si ce sont des phrases de contexte. On reserve la touche E pour les dialogues de l’histoire avec des échanges plus long. Pas dans le gameplay actif.

- Quand on fait le choix de skip l’étape ou de bien faire, il faut que ça ait un impact : Si on ne skip pas, Le produit est bon est on a le dialogue où la meth est bonne

- Si on skip, Il faut que le résultat soient moins bon. Dans le dialogue de fin de cuisine, Walter doit être deçu genre «  on peut faire beaucoup mieux que ça. On aurait pas du sauter une étape » (bien adapter cette phrase au personnage)

- Je n’ai pas réussi à bien surveiller la couleur, et pourtant j’ai pu accéder à la suite. Soit le minijeu ne marche pas, c’est c’est une victoire automatique. Pareil, faire des commentaire quand on réussi ou qu’on échoue aux minijeux.

- Jesse est souvent proche des atelier et il arrive fréquemment qu’on lui parle au lieu de cuisiner avec la touche E. Remédier à cela, surtout pour le dernier mini jeu qui semble disparaitre parfois ou réapparaitre quand on parle à Jesse. C’est confusant.

- Pour tous les dialogues, surtout celui de la fin avec Emilio, permettre au jour de se déplacer pendant le dialogue.

- A la fin du dernier dialogue sur Emilio. Quand on reparle à Jesse au moment où il faut sortir, il ressort son script de l’accueil dans le labo. Mettre autre chose à la place style « Je vous tiendrais au courant de comment ça s’est passé avec Emilio »

- Dernière étape, rentrer : Ne pas nous téléporter chez nous, mais faire conduire le joueur jusqu’à chez nous. Ajouter un marqueur sur la carte pour nous indiquer la direction. Le joueur peux s’y rendre via le téléporteur ou la route/sol, c’est lui qui décide. Il doit juste arriver devant chez lui.

## RETOURS SUR LE RESTE DU JEU :

- C’est aussi une réponse à une de tes questions : le lancement du jeu.

  Il y avait dans une version précédente une sorte de cinématique d’intro. Un montage de plusieurs plans avec caméras en mouvement et une voix off. Cette intro était cool mais elle a disparu. Si elle existe encore, il faut qu’elle se déclenche au LANCEMENT du jeu, avant l’écran titre. Cette animation peut être skippé avec la touche entrée (l’indiquer discrètement en bas de l’écran au bout de 3s de cinématique, même si on peut la skipper avant). Une fois l’intro finie ou skippé, on arrive sur l’écran titre.

- L’écran titre justement : il fut A TOUT PRIS améliorer le rendu. Le fond est incroyablement moche ! Je t’ai mis en livraison un visuel que tu peux mettre en fond en attendant.

  Donne-moi le temps qu’il faudrait pour que tu le recrée toi-même avec l’esthétique actuel du jeu (en 3D donc comme si c’était un vrai décor dans le jeu). Selon le temps que ça prendrait, et le taux de réussite, on pourra juste laisser l’image

- Walter a les pieds dans le sol, il faudrait le surélever légèrement.

- J’aime bien la nouvelle interface, plus harmonieuse. Par contre les phrases qui défilent de temps en temps sont assez mal placées et n’ont pas vraiment de sens à ce stade du jeu. Le mieux serait de les retirer pour l’instant. On verra pour les remettre selon dans les parties « monde ouvert » quand aucune mission n’est en cours.

- Dans le menu, quand les pages sont trop longues, et qu’on descend la souris pour choisir une option plus bas, ça défile/scroll trop vite. Il faut réduire cette vitesse pour que ce soit jouable.

- On ne peut plus tuer Jesse avec le revolver (il ne meurt pas). Faire en sorte qu’il puisse être tué comme avant

- Utilise l’icone du jeu (livrée) comme icone pour l’application (au lieu de celle de godot)

- Refais le visage de Walter qui est horriblement laide (à coté de la barre de vie). Mets une image de son visage (quand il a encore des cheveux).

- Dans le menu téléphone, Quand on clique sur « mission », faire en sorte que le téléphone soit plus gros et l’interface plus grande pour permettre d’y naviguer plus facilement, mieux lire etc. Il est trop petit pour les options avec beaucoup de texte.

## Ce que je livre :

- Visuel de l’écran titre

- Icone du jeu.
