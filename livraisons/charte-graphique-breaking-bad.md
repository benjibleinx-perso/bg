# Charte graphique — inspirée de Breaking Bad, adaptée au jeu

Aucune image dans ce document : les captures réelles de la série sont
protégées par le droit d'auteur. Tout est donc décrit avec assez de
précision (couleurs en hex, compositions, polices) pour être exploitable
sans support visuel. Cette charte guide l'**inspiration**, pas la copie —
l'objectif est un habillage low-poly PS2 qui évoque la série, pas une
reproduction de ses plans.

> **Note trademark** : le logo *Breaking Bad* et son traitement exact sont
> une propriété de Sony Pictures Television. On s'inspire ici du *principe*
> (tuile de tableau périodique, jeu de mots chimique), jamais du fichier
> logo lui-même — l'exécution graphique doit rester la vôtre.

---

## 1. Palette de couleurs

La série code ses personnages et ses lieux par couleur de façon très
délibérée (choix revendiqué du showrunner Vince Gilligan et du chef opérateur
Michael Slovis). Les teintes ci-dessous sont des **approximations de travail**
— à ajuster à l'écran, en gardant le sens plutôt que la valeur exacte.

| Teinte | Hex approx. | Sens dans la série | Où l'utiliser dans le jeu |
| --- | --- | --- | --- |
| Vert olive / kaki | `#6B7F5E` | Walt au début : argent, ambition encore mesurée, cardigans et chemises | Tenue civile de Walt, intérieur de sa maison en début de palier |
| Jaune sécurité | `#F4C430` | Business de la meth, combinaisons hazmat, danger autant qu'excitation | Combinaison de la roue à outils, éclairage du labo/camping-car |
| Bleu cristal | `#A8D8E8` | Le produit lui-même — le bleu est un choix de marque volontaire de la série, pour rendre le cristal reconnaissable à l'écran | Rendu du produit fini, effet de lueur pâle sur la verrerie |
| Bleu ardoise | `#4A6FA5` | Skyler : loyauté, tristesse, un foyer qui tient encore | Intérieur maison Walter côté Skyler, dialogues la concernant |
| Rouge sourd | `#B23A2E` | Jesse : agressivité, instabilité | Détails de la tenue de Jesse, éclairage tendu des scènes de rue |
| Orange alerte | `#E8720C` | Signal de danger imminent, juste avant un évènement grave | Ambiance courte avant un basculement de mission (jamais permanent) |
| Violet | `#6A4C93` | Obsession, besoin de contrôle (Marie dans la série) — pas de personnage direct dans le jeu pour l'instant, teinte à garder en réserve | — |
| Noir/anthracite désaturé | `#2B2B2B` | Bascule morale tardive (Heisenberg assumé) | Réservé aux paliers avancés (2+), à ne pas utiliser ici |
| Vert logo (chimie) | `#026635` (source : identité visuelle officielle) | Réservé au titre, aux menus, jamais à un décor jouable | Écran-titre, en-têtes de menu uniquement |

**Palette de fond, désert du Sud-Ouest** (toujours visible en toile de fond,
quel que soit le personnage à l'écran) :
- Adobe / façades : `#C19A6B`
- Sable / piste : `#D9C7A3`
- Terre cuite : `#B5651D`
- Ciel délavé, milieu de journée : `#A9C6D9`
- Végétation clairsemée : `#7A7A52`

**Règle générale, cohérente avec `CLAUDE.md` (« le ton ne bouge pas : lent,
sale, provincial »)** : aucune de ces teintes ne doit jamais apparaître
saturée à 100%. Désaturer systématiquement de 15-20% et ajouter un léger
grain/poussière — la série elle-même vieillit ses couleurs plutôt que de les
rendre éclatantes.

---

## 2. Lumière et composition

- **Extérieurs jour** : lumière crue, dure, presque écrasante — pas
  d'ombres douces. Le désert n'offre aucun répit visuel, et c'est voulu.
- **Intérieurs domestiques** (maison Walter) : lumière chaude, tons
  beige/brun, contraste doux — un cocon qui s'oppose au reste.
- **Intérieurs "travail"** (camping-car, labo) : lumière plus froide, plus
  dure, parfois une seule source visible (lampe, néon) qui laisse le reste
  dans la pénombre.
- **Cadrage** : la série affectionne les plans larges et symétriques,
  souvent en plongée ou contre-plongée marquée pour écraser ou magnifier un
  personnage. Dans le jeu, ça se traduit surtout au niveau des
  cinématiques (positions de caméra fixes lors des dialogues scriptés) —
  pas besoin d'un système de caméra dynamique pour ça, juste des points de
  vue de caméra bien choisis à la main pour chaque scène.

---

## 3. Typographie

Le titre original joue sur un principe simple et efficace : les premières
lettres de « **Br**eaking » et « **Ba**d » sont mises en scène comme deux
cases de tableau périodique (symbole chimique + numéro atomique — Br
(brome, 35) et Ba (baryum, 56)), en blanc sur vert profond, sur fond noir.
Le texte du titre lui-même utilise une police à empattements ronds et
épais, de la famille **Cooper Black** — une police ancienne (1921),
largement disponible, pas une création propriétaire de la série.

**Pour le jeu, deux usages différents :**
- **Titre / écrans de mission / moments symboliques** : reprendre le
  *principe* de la tuile chimique (une lettre encadrée avec son numéro,
  fond sombre, vert profond) est un bel hommage sans copier le logo exact —
  à condition d'utiliser sa propre mise en page. Cooper Black (ou une police
  gratuite au rendu proche, ex. *Bevan* ou *Bitter Black*) convient pour ces
  moments ponctuels.
- **HUD, menus, dialogues en jeu** : une police épaisse et arrondie comme
  Cooper Black serait en décalage avec l'esthétique PS2 basse résolution du
  jeu — mieux vaut une police bloc, lisible en petite taille, cohérente avec
  les jeux de l'époque (type *Pixellari*, *Press Start 2P* en usage modéré,
  ou une police système bloc sans-serif classique). Réserver l'habillage
  « chimie » aux moments qui doivent se sentir importants, pas au texte
  courant.

---

## 4. Motifs iconographiques récurrents

- Masque à gaz, lunettes de protection, combinaison jaune intégrale —
  déjà présents dans la roue à outils du jeu (`outils.json`), à garder
  visuellement cohérents avec cette charte plutôt qu'à redessiner.
  Le porkpie (chapeau) est le pendant vestimentaire discret de ce même
  glissement — sa texture et sa teinte doivent rester sobres (feutre
  brun/gris), jamais un habillage « déguisement ».
- Symboles chimiques et tableau périodique, utilisés avec parcimonie —
  un clin d'œil ponctuel (écran de chargement, titre de mission), jamais un
  élément de décor permanent dans le monde ouvert.
- Cristal bleu pâle luminescent — seule touche de couleur franche autorisée
  dans un intérieur autrement terne, pour qu'elle saute aux yeux à chaque
  fois qu'elle apparaît.
- Désert, adobe, ciel immense — le fond permanent du jeu, à ne jamais
  laisser un décor urbain "générique" prendre le dessus dessus.

---

## 5. Application aux lieux déjà existants dans le jeu

| Lieu | Teinte dominante | Ambiance |
| --- | --- | --- |
| Maison de Walter | Vert olive / brun chaud | Cocon, encore intact en palier 1 |
| Maison de Jesse | Rouge sourd / désordre visuel | Instable, jamais rangé |
| Camping-car (en service) | Jaune sécurité / bleu cristal | Concentré, presque clinique malgré le cadre miteux |
| Camping-car (accidenté) | Terre/poussière, aucune couleur franche | Chaos, urgence |
| Ville ouverte, jour | Palette désertique de fond (§1) | Écrasant, vide, sous un ciel trop grand |

---

## 6. Traduction en contraintes PS2 low-poly

- Texture par élément : privilégier des à-plats de couleur avec un léger
  bruit/grain plutôt que des dégradés fins — les dégradés lisses ne
  survivent pas à la basse résolution et cassent l'effet "sale" recherché.
- Brouillard de distance déjà en place dans le moteur : s'en servir pour
  accentuer l'écrasement du désert (§2), pas seulement pour masquer la
  distance de rendu.
- Nombre de couleurs distinctes par texture : rester bas (esthétique PS2
  oblige) — c'est cohérent avec la désaturation recommandée en §1, qui va
  dans le même sens pour deux raisons différentes (fidélité à la série,
  contrainte technique).

---

## 7. Ce qu'il ne faut pas faire

- Ne jamais saturer une couleur à fond, même pour "faire pop" une scène —
  contraire au ton du jeu et à la série elle-même.
- Ne jamais utiliser le violet ou le noir/anthracite (réservés, §1) tant
  que les personnages ou paliers concernés ne sont pas en jeu.
- Ne jamais transformer le motif "tableau périodique" en élément de décor
  récurrent — c'est un clin d'œil de titre, pas un habillage de HUD.
- Ne jamais chercher à reproduire un plan ou un logo exact de la série —
  s'en inspirer, jamais le copier.

*Projet de fan, non commercial. Document de référence pour l'équipe et pour
Claude Code — à faire évoluer si la direction artistique change.*
