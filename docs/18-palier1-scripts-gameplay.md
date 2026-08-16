# Palier 1 et sa sortie — Scripts de gameplay détaillés

> **Écrit par Guillaume le 14/08/2026, promu ici sans une virgule de changée.**
> Ce qui suit ce bloc est son texte. Les arbitrages rendus le 16/08/2026 (issue
> #67) sont écrits ici plutôt que fondus dans le corps, pour qu'on continue de
> voir ce qu'il a écrit et ce qui a été décidé après.
>
> **Le titre.** Il disait « Palier 1 » et couvre quatre missions, alors que le
> palier 1 s'arrête à la mission 3 — `docs/15-missions.md` range LE MERCURE
> FULMINANT en ouverture du palier 2, ce que ce document annote d'ailleurs
> lui-même. Titre élargi, périmètre inchangé.
>
> **Mission 1, l'échec existe.** La séquence de jeu ci-dessous ne prévoit aucun
> moment où les sirènes peuvent arriver. La fiche, si : *si elles arrivent avant
> la sortie de zone, cinématique de rattrapage — Walt planque tout dans le fossé
> et joue le randonneur en détresse ; on repart, mais la verrerie est perdue, et
> la première cuisine en monde ouvert coûtera son remplacement.* **C'est la fiche
> qui fait foi.** Pas de game over, pas de minuteur affiché, aucun chiffre : la
> seule trace est la verrerie qui manque plus tard. Sans ça, la sirène n'est
> qu'un décor sonore, et un compte à rebours sans conséquence n'en est pas un.
>
> **Ce qui reste vrai dans les notes transverses** : aucune mission du palier n'a
> d'**état d'échec dur**. Une facture n'est pas un échec — c'est exactement la
> philosophie de l'échec du socle.

Complément à `docs/15-missions.md` : ce document descend d'un cran sous la fiche
(qui dit *ce que la mission raconte*) pour dire *ce que le joueur fait, dans
l'ordre, et ce qui lui est interdit*. Objectif : donner à l'implémentation de
quoi coder sans avoir à deviner, et éviter les incohérences (softlocks, sorties
de mission à mi-scène, objets débloqués trop tôt).

Chaque mission suit le même squelette : **Séquence de jeu** (numérotée, chaque
étape dit ce qui la termine) puis **Interdits actifs** (ce qui est bloqué, et
pourquoi).

---

## Mission 1 · DEUX CORPS, UN CAMPING-CAR (ouverture) ⏱

### Séquence de jeu

1. Cinématique d'ouverture : caméra fixe sur le camping-car dans le fossé,
   fumée, portière ouverte. Le joueur reprend la main à l'intérieur, masque à
   gaz sur le visage.
2. Premier input du jeu : retirer le masque (F). Tant que ce n'est pas fait,
   aucune autre interaction n'est disponible.
3. Objectif sans chiffre : « Ne rien laisser derrière. » Trois objets au sol
   près du camping-car (sac de matériel, bidon, verrerie cassée), ramassables
   un par un (F, surbrillance au survol).
4. Dès le deuxième objet ramassé, le son des sirènes commence à monter en
   volume réel — c'est la pression, pas un minuteur affiché.
5. Les trois objets en poche → cinématique courte, Walter remonte dans le
   camping-car.
6. Mini-interaction de démarrage : deux ou trois appuis façon « moteur qui
   tousse ». Jamais plus de trois essais — c'est le tout premier geste de
   conduite du jeu, il doit être infaillible.
7. Conduite libre jusqu'à une sortie de zone balisée par un repère visuel
   (panneau, crête). Pas de flèche de direction à l'écran.
8. Franchissement de la limite → cinématique : les sirènes étaient des
   pompiers. Fondu, texte « Trois semaines plus tôt. »
9. Reprise en main dans le flashback : séquence guidée à pied avec Jesse, 3-4
   gestes de cuisine (verser, chauffer, surveiller).
10. Micro-choix en dialogue : suivre la méthode de Jesse ou proposer la
    sienne. Les deux réussissent ; seule la teinte du cristal produit change.
11. Fondu, retour au monde ouvert devant chez Walter.

### Interdits actifs

- **Pas de sortie du camping-car** avant masque retiré + 3 objets ramassés —
  la commande « monter dans le véhicule » reste désactivée, pour empêcher un
  départ prématuré qui laisserait des preuves au sol.
- **Pas d'accès à la roue d'outils ni au revolver** — ils n'existent pas
  encore dans l'inventaire à ce stade de l'histoire.
- **Zone de jeu limitée** au site du crash et à la piste de sortie — pas de
  monde ouvert accessible avant la fin de la mission.
- **Conduite et combat désactivés pendant le flashback** — séquence à pied,
  guidée, sans véhicule à proximité.
- **Pas de sauvegarde manuelle en cours de mission** — seule une sauvegarde
  automatique en fin de mission, pour ne jamais figer une partie en pleine
  *in medias res*.

---

## Mission 2 · LA BAIGNOIRE (friction) ☠

### Séquence de jeu

1. Mission déclenchée en monde ouvert une fois la porte réputation franchie
   (première fournée vendue) : appel de Jesse, le corps est toujours dans le
   camping-car garé chez lui.
2. Trajet vers un point d'achat d'acide fluorhydrique. Deux destinations sur
   la carte : magasin proche (le vendeur pose des questions, dialogue plus
   long) ou magasin éloigné (trajet plus long, anonymat garanti).
3. Achat validé par une interaction F au comptoir — pas de mini-jeu, le choix
   du magasin est la seule variable ici.
4. Retour chez Jesse → dialogue de choix central à l'entrée du sous-sol :
   **le bac** ou **la baignoire**.
5. **Branche bac** : manutention — porter/traîner le bac (touche maintenue,
   jauge d'effort visible mais non chiffrée) jusqu'à l'étage, verser l'acide,
   refermer. Se termine proprement, sans minuteur.
6. **Branche baignoire** : versement immédiat → cinématique automatique, le
   plafond cède. Le joueur nettoie ensuite une pièce en contrebas (ramasser
   des débris au F, plusieurs zones à traiter) pendant qu'un minuteur sonore
   démarre : Skyler a appelé, elle arrive.
7. Nettoyage fini avant l'arrivée de Skyler (déclenchement scripté à échéance
   fixe, pas un chiffre affiché) → petite cinématique de soulagement.
8. Skyler arrive avant la fin → cinématique automatique de mensonge
   maladroit (non jouée par le joueur) ; une variable interne
   `mensonge_baignoire` est posée pour la mission 15.
9. Fin commune, retour au monde ouvert.

### Interdits actifs

- **Pas de combat, pas d'arme sortie** — mission domestique de bout en bout.
- **Course et saut désactivés pendant la manutention du bac** — le
  personnage porte quelque chose de lourd, évite les incohérences
  d'animation.
- **Sortie de la pièce bloquée pendant le nettoyage** tant que toutes les
  zones de débris ne sont pas traitées — empêche de fuir la scène en plan.
- **Choix bac/baignoire non réversible** une fois pris dans le dialogue —
  pas de retour en arrière pour changer d'avis.
- **L'arrivée de Skyler dans la branche baignoire est non-annulable** —
  aucune action du joueur (raccrocher, ignorer) ne l'empêche ; seule la
  vitesse de nettoyage joue sur l'issue.

---

## Mission 3 · LE MORCEAU D'ASSIETTE (finale du palier) ☠

### Séquence de jeu

1. Mission fragmentée : une fois déclenchée (portes réputation + vie perso
   franchies), une icône discrète apparaît sur la carte chez Jesse — le
   joueur choisit quand descendre, entre ses activités de monde ouvert.
2. Chaque visite (3 à 4 prévues) : entrer dans le sous-sol (F), s'approcher
   de Krazy-8 attaché au poteau, menu de dialogue.
3. Première étape de chaque visite : proposer un sandwich, sous-choix
   « couper les croûtes ou non » — cosmétique, sert à amorcer l'échange.
4. Dialogue principal à choix (questionner / écouter / rester silencieux) :
   fait progresser une jauge interne d'« humanisation », non affichée.
   Chaque visite l'avance d'un cran, quel que soit le détail des réponses —
   le contenu change, pas l'issue.
5. Entre deux visites, en monde ouvert : cinématique automatique (intervalle
   fixe) montrant Walt écrire « le tuer / le libérer » puis déchirer le
   papier. Pas d'interaction.
6. Dernière visite déclenchée automatiquement après la 3ᵉ ou 4ᵉ : Walt
   descend avec la clé de l'antivol, décidé à libérer Krazy-8.
7. Avant d'ouvrir : séquence d'observation libre des fragments de l'assiette
   cassée, posés sur l'établi — rotation libre à la souris, aucun minuteur.
8. Variable interne `a_remarque_le_tesson` passe à vrai si le joueur a fait
   pivoter le bon fragment (taillé en pointe) au moins une fois — détection
   d'interaction, pas un bouton « j'ai compris ».
9. **Branche « a remarqué »** : Walt remonte, s'effondre, redescend. QTE de
   strangulation volontairement long (5-6 appuis espacés, jamais un seul
   clic) — pénible à jouer, pas satisfaisant.
10. **Branche « n'a pas remarqué »** : Walt ouvre l'antivol, Krazy-8 frappe
    avec le tesson en cinématique, lutte scriptée sans input — même issue,
    Walt blessé en plus.
11. Fin de mission : fondu, retour au monde ouvert avec conséquences (marques
    visibles si branche 2 ; dialogue Skyler modifié à la prochaine visite).

### Interdits actifs

- **Aucune arme utilisable dans le sous-sol** — la scène reste à mains nues.
- **Impossible de quitter une visite en plein dialogue engagé** — évite de
  casser la progression de la jauge d'humanisation.
- **La visite finale ne peut pas être déclenchée avant les 3-4 précédentes**
  — toute tentative prématurée est ignorée silencieusement (pas de message
  d'erreur qui casserait l'immersion).
- **Aucune autre interaction pendant l'observation des fragments** (pas de
  dialogue, d'inventaire, de fuite) — moment isolé, à la souris uniquement.
- **Pas de sauvegarde manuelle entre les visites** tant que la mission n'est
  pas refermée — évite qu'une sauvegarde tombe en pleine jauge
  d'humanisation à mi-chemin ou variable tesson non fixée.

---

## Mission 4 · LE MERCURE FULMINANT (transition vers palier 2) ⏱

### Séquence de jeu

1. Cinématique déclenchée en monde ouvert : Jesse rentre tabassé, sans
   produit ni argent — Tuco a tout pris.
2. Objectif de cuisine spéciale dans le labo actuel : préparer « le
   cristal » (mercure fulminant), rendu visuel/sonore différent d'une
   cuisine normale, sans aucune option de vente ensuite — le jeu ne
   l'explique pas.
3. Fournée prête → cinématique muette : Walt se prépare devant un miroir,
   pose le chapeau pour la première fois. Premier déblocage de l'objet
   « porkpie » dans la roue d'outils, utilisable librement ensuite.
4. Trajet en voiture jusqu'au QG de Tuco, conduite libre, pas de trafic
   hostile.
5. Entrée dans le bâtiment : dialogue de négociation à choix, embranchement
   binaire — exiger le prix fort (tension max, réputation ++) ou accepter
   moins (plus sûr, réputation +).
6. Bascule automatique en cinématique tendue une fois le montant fixé :
   Tuco veut voir le produit fonctionner.
7. Séquence de lancer : une seule fenêtre d'action (curseur qui oscille,
   clic dans la zone verte) — un seul essai, pas de retry immédiat.
8. **Réussite** : vitre soufflée, Tuco impressionné, paie le montant
   négocié à l'étape 5.
9. **Échec** : Tuco rit, prend quand même le produit, ne paie que la
   moitié — aucune autre conséquence, la mission continue normalement.
10. Sortie avec l'argent (ou la moitié) : cinématique de fermeture, fondu
    sur un panneau « Camping-car amélioré disponible » au prochain accès
    au garage.
11. Retour au monde ouvert : le montant reçu permet, en une ou deux ventes
    supplémentaires au pire, d'atteindre le premier niveau interne du
    nouveau labo — jamais un vrai retour à zéro ressenti.

### Interdits actifs

- **La fournée de mercure fulminant est marquée « non-vendable »** dans les
  points de vente habituels — empêche de la liquider avant la cinématique et
  de casser la scène.
- **Pas de combat, arme rangée de force** avant la séquence de lancer — si
  le joueur tente d'équiper le revolver, l'action est ignorée avec un petit
  refus animé de Walt.
- **Issues du QG verrouillées** dès le dialogue de négociation engagé —
  impossible de fuir à mi-scène, ce qui laisserait Jesse et Walt dans un
  état narratif incohérent.
- **Le chapeau reste absent de la roue d'outils** jusqu'à la cinématique du
  miroir — son apparition doit rester un moment de mise en scène, pas un
  objet ramassable en avance.
- **Une seule tentative pour la séquence de lancer** — pas de « réessayer »
  immédiat, l'échec doit rester un vrai résultat de mission.

---

## Notes transverses (pour l'implémentation)

- **Variables d'état posées ce palier**, à faire persister dans la
  sauvegarde : `mensonge_baignoire` (mission 2), `a_remarque_le_tesson` et
  `walt_blesse_krazy8` (mission 3). Elles ne changent rien avant la
  mission 15 — de simples booléens à faire remonter dans les dialogues de
  la fausse piste finale.
- **Objets débloqués ce palier** : porkpie (mission 4, pas avant). Le
  revolver reste bloqué tout le palier 1 — à débloquer explicitement au
  palier 2.
- **Aucune mission de ce palier n'a d'état d'échec dur** (game over) —
  conforme à la philosophie de l'échec du socle : un raté coûte de l'argent,
  du temps ou une trace, jamais la partie.
- **Sauvegarde manuelle** : désactivée pendant les missions 1 et 3
  (séquences fragiles / fragmentées), disponible normalement dans les
  missions 2 et 4 en dehors des scènes scriptées.

*Complément à `docs/15-missions.md` — projet de fan, non commercial.*
