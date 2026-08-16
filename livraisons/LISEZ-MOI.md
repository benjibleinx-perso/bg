# Livraisons

**C'est ici que Guillaume dépose, et ici qu'on se parle.**

Rien de ce dossier n'est lu par le jeu. C'est un sas : ce qui est intégré part
dans `game/`, transformé par les outils, et la source reste ici.

## Ce qu'on attend de toi, c'est dans les tickets

**https://github.com/benjibleinx-perso/bg/issues**

Une ligne = une chose qui manque au jeu : le detail, le format, et le dossier ou la poser.
Filtre sur l'etiquette **🎨 Guillaume** pour ne voir que ce qui t'attend. Ca se lit tres
bien depuis l'appli GitHub sur telephone.

**Ton cycle :**

1. `.\go.ps1` — tu recuperes la derniere version
2. Tu deposes tes fichiers dans le dossier indique par le ticket
3. `.\livrer.ps1 "mes sons de flingue"` — ca part
4. Tu ouvres un ticket **Je livre un fichier** en disant a quel besoin ca repond
5. Quand c'est integre, le ticket se ferme et **tu recois un mail**

Le mode d'emploi complet : [docs/09-communiquer.md](../docs/09-communiquer.md).

## Où se pose quoi

```
livraisons/
  briefs/           les deroules de mission, les cadrages ecrits
  references/       les images de reference, RANGEES PAR SUJET :
    camping-car/      exterieur/ et interieur/
    desert/           paysages, pistes, vegetation
    personnages/      un dossier par personnage
    qg-tuco/
  modeles/          .glb, .obj, .fbx — personnages, vehicules, decors
    figurants/      le pack de figurants, tel que livre
  images/           textures et icones destinees a l'ecran
  sons/             LE SAS AUTOMATIQUE — voir plus bas
  voix/             les repliques enregistrees, rangees par le script
  integre/          ce qui est deja dans le jeu, garde comme source
```

**Les references se rangent par SUJET, jamais par mission.** Une photo de
camping-car sert la mission 1 et la mission 2 : rangee sous « Mission 1 », elle
sera recopiee a la suivante, et on ne saura plus laquelle fait foi. C'est
arrive — six photos existaient en trois exemplaires.

Le nom dit ce que l'image montre, en minuscules avec des tirets :
`corps-au-sol-gros-plan.jpg`. Pas un numero : personne ne retrouve
`23065133.jpg` dans une liste de trente.

**Un texte d'ecriture — un deroule, un script de mission — ne reste pas ici.**
Il est promu dans `docs/` des qu'il est lu, sans une virgule de changee. C'est
la que le projet ira le chercher dans six mois.

## Les sons se rangent tout seuls

Pose tes fichiers dans `livraisons/sons/`, en respectant les sous-dossiers du
[brief son](../docs/04-brief-son.md) — `vehicule/`, `ambiance/`, `pas/`. Au
prochain `.\livrer.ps1` ou `.\go.ps1`, ils partent vers `game/assets/sons/`, là
où Godot les lit, et le format est vérifié au passage.

Tu n'as donc **pas** à savoir où le jeu les range. Pose et livre.

**Le dossier se vide tout seul, et c'est normal.** Ce n'est pas une perte : les
enregistrements bruts restent dans `voix/originaux/` pour les voix, et
`integre/` garde les autres sources.

## Ce qui ne va PAS ici

**Les fichiers de travail bruts.** Projets Blender, textures d'origine, rushes
son non montes : ils vont dans `assets-ref/`, qui n'entre jamais dans git. Ils
pesent, et un binaire commite reste dans l'historique meme apres suppression.

*(Les medias issus de la serie, eux, sont bien versionnes — les references
ci-dessus. Cette page disait le contraire jusqu'au 16/08/2026 : c'etait vrai
quand le depot etait prive. Voir [DISCLAIMER.md](../DISCLAIMER.md).)*

**Ce qui est généré par script.** Textures, ville, véhicules, maisons, objets,
décors de mission : tout ça sort de `outils/` et se refabrique avec
`.\bg.ps1 generer`. Ne jamais poser à la main un fichier qu'un générateur
écrase à la commande suivante.
