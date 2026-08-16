# Disclaimer

Ce projet est une **œuvre de fan, non commerciale et non officielle**, réalisée par deux
personnes pour le plaisir et l'apprentissage.

*Breaking Bad* est une création de Vince Gilligan. La série et l'ensemble des marques,
personnages, musiques et éléments qui s'y rattachent appartiennent à Sony Pictures
Television et AMC Networks. Ce projet n'est ni affilié à, ni approuvé par, ni soutenu par
ces sociétés.

## Ce que ce projet fait

Le projet utilise des éléments visuels et sonores issus de la série, à titre de référence,
de substitut temporaire et — pour certains — dans le jeu lui-même. **Aucun droit n'est
revendiqué sur ces éléments**, qui restent la propriété de leurs ayants droit.

## Engagements

- **Aucune exploitation commerciale, jamais.** Le jeu n'est pas vendu, ne comporte aucune
  publicité, aucun achat intégré et n'appelle à aucun don.
- **Aucune promotion.** Le projet n'est ni annoncé, ni référencé, ni présenté nulle part. Le
  lien se donne à qui le demande.
- **Retrait immédiat.** À la première demande d'un ayant droit, le projet et toute copie en
  circulation sont retirés, sans discussion.

## Où le projet est visible — mis à jour le 16/08/2026

Cette page affirmait jusqu'ici que « le dépôt n'est pas public et le jeu n'est pas distribué
publiquement ». **Ce n'est plus vrai depuis le 05/08/2026**, et ça n'avait pas été relu.

- Le dépôt `benjibleinx-perso/bg` est **public**.
- L'exécutable est publié en **releases GitHub ouvertes**, pour que la personne qui teste
  puisse le télécharger sans compte.

Ce qui n'a pas changé : le projet n'est pas vendu, pas promu, et se retire à la première
demande.

## Règles pratiques pour le dépôt

**Les médias issus de la série sont versionnés** — les références visuelles de
`livraisons/references/` (captures, photos de repérage), et certains substituts temporaires
dans le jeu lui-même, en attendant l'asset qui les remplacera. Ils passent par Git LFS,
comme les assets créés par Guillaume.

Ce qui n'entre pas dans git, ce sont les **fichiers de travail bruts** — projets Blender,
textures d'origine, rushes son. Ils vivent dans `assets-ref/`, ignoré par git. La raison est
technique et non juridique : ils pèsent, et un fichier commité reste dans l'historique même
après suppression. Le détail est dans
[docs/03-conventions-assets.md](docs/03-conventions-assets.md).

**Avant d'ajouter un média de la série au dépôt**, se demander s'il finira dans l'exe
distribué. Une image de référence qui reste dans `livraisons/` n'a pas le même statut qu'une
texture embarquée dans le jeu qu'on donne à télécharger.
