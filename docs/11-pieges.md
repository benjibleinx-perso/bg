# Les pièges

**Ce que ce projet a appris en se trompant.** Un piège entre ici quand il a
coûté plus d'une heure, ou quand il a été payé deux fois.

Ils ont presque tous la même forme, et c'est le seul enseignement qui compte :

> **rien ne prévient.** Le code tourne, la console annonce un nombre juste, la
> capture semble correcte, aucun avertissement n'est émis — et le résultat est
> faux. Un piège qui lève une erreur n'est pas un piège, c'est un bug.

---

## 1. Mesurer la scène au lieu du fichier produit

**Payé quatre fois.** C'est le piège central du projet.

| Cas | Ce que la console disait | Ce que le fichier contenait |
|---|---|---|
| Lacet d'import de l'Aztek | rotation appliquée | aucune rotation, jamais |
| Figurants | 1,68 m | 170 m |
| Objets équipés | accrochés, visibles | rendus à 1/100 de leur taille |
| Pieds de Walter | −13 m | mesure en unités d'armature, pas en mètres |

**La parade.** Tout outil qui écrit un `.glb` le **relit** et annonce ses cotes
finales dans le repère de Godot. `importer_modele.py` et
`mettre_a_l_echelle.py` le font ; tout nouvel outil doit le faire.

---

## 2. `bpy.ops.object.transform_apply` n'agit que sur la sélection

Sans objet sélectionné **et actif**, l'opérateur repart sans rien faire et sans
se plaindre. Le `--lacet` de l'import n'a jamais fonctionné pour cette raison,
et deux tentatives de « retourner la voiture » n'ont rien changé puisque ni
l'une ni l'autre n'était appliquée.

**La parade.** Écrire dans les données : `obj.data.transform(Matrix...)`. Et
quand l'objet porte déjà une transformation, conjuguer : `M⁻¹ · S · M`, sinon
on met à l'échelle dans un repère déjà mis à l'échelle et le résultat ne bouge
pas.

---

## 3. L'échelle d'objet ne survit pas à l'export glTF

Une armature à la bonne taille dans Blender sort à sa taille d'origine dans le
`.glb` si l'échelle vit sur l'**objet**. Les figurants sortaient à 170 m avec
un fichier de travail parfaitement juste.

**La parade.** `outils/mettre_a_l_echelle.py`, qui écrit dans les données et
relit le fichier.

---

## 4. Les unités d'armature ne sont pas des mètres

Sur le rig de Walter, l'échelle du squelette vaut **0,011** : ses os sont longs
de deux mille unités. Conséquences observées :

- une mesure de pieds annonçait −13 m pour tous les clips, donc ne
  discriminait rien ;
- un décalage de 24 cm posé sur une attache d'os valait 2,6 mm, et le chapeau
  restait planté dans le crâne ;
- **tout objet équipé était rendu à un centième de sa taille** — le revolver
  mesurait deux millimètres. Il était chargé, accroché, déclaré visible.

**La parade.** Diviser par `ancre.global_transform.basis.get_scale()`, ou
exprimer le décalage dans le repère du monde et le convertir une fois
(`aplomb` dans `outils.json`).

---

## 5. La boîte englobante d'un maillage décrit la géométrie AVANT déformation

Sur un personnage livré à plat, elle annonce n'importe quoi. Les figurants du
pack sont **invisibles** sans leur clip : leur maillage de repos est couché.

**La parade.** Mesurer sur les **os**, jamais sur la boîte.

---

## 6. Une action encore assignée repose le squelette sous vos pieds

Elle est réévaluée au prochain rafraîchissement. En mesurant le crâne pour y
poser un chapeau, on obtenait 1,24 m au lieu de 1,85 : le squelette était
encore dans la pose **assise** du clip précédent.

**La parade.** `arm.animation_data.action = None` avant toute mesure.

---

## 7. Les rotations ne se transfèrent pas entre deux rigs différents

Mesuré : les os de Walter pointent chacun dans l'axe de leur membre ; ceux d'un
Biped pointent **tous** dans la même direction. Recopier une pose de l'un à
l'autre donne une contorsion, pas une pose.

**Symptôme observé :** Jesse planté sans animation, avec une marche dont la
foulée mesurait **zéro mètre**. Et Tuco assis les bras en croix.

**La parade.** Refabriquer les clips sur le squelette cible à partir de SA
marche livrée. Le report entre rigs différents passe par l'espace monde, et
reste non résolu — c'est le fond du ticket #16.

---

## 8. Un solveur ne paie que ce qu'on lui fait payer

Le geste des lunettes visait la bonne cible et faisait passer l'avant-bras dans
la poitrine sur **douze centimètres**, parce que le coût ne regardait que le
point d'arrivée. Le chemin ne coûtait rien.

**La parade.** Modéliser le buste et le crâne en volumes mesurés sur le rig, et
payer ce que le membre traverse. Et doser : on remonte ses lunettes coude bas,
on ne met **pas** un chapeau coude bas — avec le même réglage, la main
s'arrêtait à dix centimètres du crâne.

---

## 9. Godot ne propage pas les entrées dans un SubViewport

Toute l'interface du jeu vit dans un `SubViewport` affiché par un
`TextureRect`. Un `_gui_input` ou un `_unhandled_input` y est **silencieusement
mort** : la roue s'ouvrait, s'animait, se fermait, et la sélection ne bougeait
jamais.

**La parade.** Scruter (`Input.is_action_just_pressed`), c'est la convention du
projet. Et convertir la souris à la main :
`get_tree().root.get_mouse_position() / Vector2(root.size) * size`.

---

## 10. Un modèle rigué regarde +Z, un modèle sans animation regarde −Z

Le canal racine de l'animation écrase la rotation d'import. Le critère du demi-
tour est donc la **présence d'un `AnimationPlayer`**, pas le format du fichier.
Sans ça, Jesse et Tuco tournaient le dos à qui leur parlait.

---

## 11. Un générateur écrase un modèle livré sans le dire

Le Jesse de Guillaume — 6,6 Mo — a été remplacé par 68 Ko de corps générique
par un `generer` lancé pour une tout autre raison.

**La parade.** Retirer de la table du générateur toute clé dont le modèle est
livré. C'est fait pour `jesse` et pour `chapeau` ; à vérifier à chaque
intégration.

---

## 12. La version vit dans `project.godot`, et nulle part ailleurs

`config/version=`. `version.json` en est régénéré. Bumper le second ne fait
rien de visible, et l'exécutable annoncerait un numéro que le jeu contredit.

---

## 13. `-Modifies` n'est pas ciblé

Dès qu'un fichier partagé bouge — `monde.tscn`, `controleur.gd` — il relance
les 27 suites. Croire qu'on économise en l'utilisant est une erreur commise
deux fois dans la même journée.

---

## 14. Une expression régulière trop courte attrape ses voisins

`acceleration = [0-9.]+` a aussi remplacé `marche_acceleration`, ce qui a réglé
l'accélération de la marche à 900. Rattrapé dans le diff, pas par un test.

---

## 15. Supprimer un objet en Blender invalide les références Python

Y compris celles vers **d'autres** objets. Les lectures renvoient de la mémoire
réattribuée, les écritures partent dans le vide, sans erreur.

**La parade.** Re-résoudre par le nom après toute suppression.

---

## 16. Un here-string PowerShell ne tient pas dans un bloc YAML

PowerShell exige que le `"@` de fermeture soit en **colonne zéro**. Un bloc
YAML `run: |` se termine dès qu'une ligne revient en colonne zéro. Les deux
règles s'excluent.

Le fichier de workflow devenait invalide, et GitHub échouait **en zéro seconde
sur chaque push**, y compris ceux qui n'avaient rien à voir avec une release —
donc un mail d'échec à chaque commit.

**La parade.** Un tableau de chaînes joint par `-join "`n"`, indenté comme le
reste. Et une vérification locale avant de pousser :

```powershell
python -c "import yaml,io; yaml.safe_load(io.open('.github/workflows/release.yml',encoding='utf-8'))"
```

**Ce que ça rappelle :** un workflow ne se teste pas en le poussant. Un fichier
de configuration qui n'est validé que par le serveur distant est un fichier
qu'on écrit à l'aveugle.

---

## 17. Un état différé n'est pas un état absent

Le chapeau bascule au milieu du geste, une demi-seconde après le choix. Un test
qui mesure tout de suite trouve l'objet **précédent** encore visible et conclut
que tout va bien. Attendre une **condition**, jamais un nombre de trames : le
mode sans fenêtre ne tourne pas à la vitesse d'un affichage.

---

## 18. Un compteur de moteur n'est pas la mesure qu'il annonce

`diag_ville.gd` a signalé un effondrement du jeu : pire cas tombé de 38 à
**7 images/seconde**, 8 images ratées sur 180, et **16,5 ms de scripts par
image**. De quoi ouvrir une session d'optimisation. Le jeu tournait en réalité
avec vingt-six fois la marge nécessaire, et **zéro** image ratée.

Trois compteurs, trois mensonges — et aucun n'était un bug :

| Ce qu'on lisait | Ce que c'est vraiment |
|---|---|
| `Engine.get_frames_per_second()` échantillonné par image | Un compteur **rafraîchi une fois par seconde**. 180 échantillons sur 3 s ne donnent que 3 valeurs : « 8 images ratées » = 8 échantillons pris dans la même seconde basse, et « 7 au pire » = une seconde entière, jamais une image |
| `Performance.TIME_PROCESS`, lu comme « scripts par image » | Le **maximum de la seconde écoulée**, sur tout le traitement hors physique. Les 16,5 ms valaient une synchro verticale (16,7 ms) — le chiffre disait « le jeu tourne pile à 60 » |
| 60 images de chauffe | ≈ 1 seconde. Le chargement étant descendu à 0,52 s, la mesure démarrait dans la compilation des shaders et la publiait comme pire cas du jeu |

**La parade.** Mesurer le `delta` de chaque image, soi-même, et couper la
synchro verticale — sinon toute image qui tient dans le budget sort à 16,7 ms
et médiane, 99e centile et pire cas affichent le même chiffre. Sortir le **99e
centile** plutôt que la moyenne, et **l'instant** de chaque pic : trois pics
collés au début sont un reste de chauffe, trois pics régulièrement espacés sont
un traitement périodique, et le maximum seul ne permet ni l'une ni l'autre
lecture.

**Ce que ça rappelle :** la règle d'or dit *une image ou un nombre, jamais une
conviction*. Elle a un revers — **un nombre n'est une preuve que si on a lu le
code qui le produit.** Ici l'instrument mesurait sa propre synchro verticale et
son propre démarrage, et il l'annonçait avec l'aplomb d'un chiffre. C'est la
première fois que ce projet se trompe dans ce sens-là : d'habitude un outil
annonce un nombre juste et écrit un fichier faux ; cette fois il n'y avait pas
de fichier, seulement le nombre, et personne pour le contredire.

---

## 19. Une vérification qui se place elle-même au bon endroit valide toujours

`test_desert.gd` contrôlait qu'on peut repartir du désert. Il **téléportait la
voiture sur la zone de retour**, puis vérifiait qu'elle rentrait en ville. Il
passait au vert depuis une semaine pendant que la zone était à **vingt-six
mètres de la piste**, donc introuvable en roulant.

Le test ne mesurait pas ce qu'il annonçait. Il mesurait ce qui se passe *une
fois qu'on y est* — c'est-à-dire la seule partie qui n'était pas cassée.

Même famille, même soirée, trois fois :

| L'instrument | Ce qu'il annonçait | Ce qu'il mesurait |
|---|---|---|
| `test_desert.gd` | « on peut repartir » | ce qui arrive quand on est déjà sur la sortie |
| Situation `camping_car_porte` | « la porte du jeu tombe sur la porte du modèle » | du sable, à 29 m du véhicule, en écrivant un PNG valide |
| La même, vue à la verticale exacte | une géométrie | une image **sans haut ni bas** : caméra au-dessus visant droit en dessous, l'orientation n'est plus définie et rien n'y est trancheable |

**La parade.** Avant de croire un test qui passe, se demander **quel geste du
joueur il reproduit**. S'il commence par placer quelque chose à la main, il ne
vérifie pas qu'on peut y arriver — et « on peut y arriver » est presque toujours
la question. Ajouter alors la mesure que le placement empêchait de poser : ici,
la distance entre la sortie et le point d'arrivée, en mètres imprimés.

**Le corollaire pour les captures.** Une vue qui vise des coordonnées écrites à
la main se périme le jour où le générateur bouge ce qu'elle photographie, et
elle ne le dit pas. Une vue se pose **autour de ce qu'elle montre** — c'est ce
que fait `autour` dans `scenarios.json`. Et jamais à la verticale exacte : il
faut un angle, sinon l'image n'a pas d'orientation et on y lit ce qu'on veut.

---

## 20. Couper un lien ne remet pas la valeur par défaut, il découvre celle du dessous

Trois variantes du camping-car sont sorties **entièrement blanches**, alors que
leur texture de couleur était bien dans le fichier et correctement liée.

La cause : en jetant les canaux PBR inutiles, on avait coupé le lien de la
texture **émissive** vers le shader. Or l'entrée « émission » d'un Principled
vaut blanc, force 1, par défaut — la texture ne faisait que la moduler. Le lien
coupé, il restait un blanc plein : le matériau émettait, l'export écrivait
`emissiveFactor: [1, 1, 1]`, et la couleur de base était noyée dessous.

**La parade.** Après avoir débranché une entrée, **écrire la valeur neutre**
qu'on veut voir à la place. Débrancher n'est pas neutraliser.

**Comment on l'a trouvé** : en lisant le bloc `materials` du `.glb` produit, pas
en regardant Blender. La scène Blender était juste ; c'est le fichier qui
portait le défaut, et c'est encore la règle numéro un du projet.

---

## 21. Une capture montre où un objet FINIT, pas où on l'a posé

Le point d'entrée du camping-car a été placé, puis photographié avec Walter
dessus : l'image le montrait **dehors, contre le flanc, devant la porte**.
Impeccable. Le test, lui, annonçait le point **1,20 m à l'intérieur de la
coque**.

Les deux avaient raison. La coque du véhicule est aussi sa **collision** : la
capsule du joueur, téléportée dans le volume, en avait été **éjectée par la
physique** dans les images qui précèdent la prise de vue. La photo montrait
l'endroit où Walter s'était stabilisé, pas celui où on l'avait mis.

**La parade.** Un scénario qui `place` quelque chose puis photographie ne prouve
la position que si rien ne peut la corriger entre-temps. Pour un point qui doit
être *atteignable*, mesurer la géométrie — `test_desert.gd` interroge désormais
la boîte de la coque et imprime la marge en mètres, négative dedans, positive
dehors.

**Et la leçon de méthode :** quand une image et un nombre se contredisent, aucun
des deux ne ment forcément. Ils ne répondent simplement pas à la même question,
et il faut trouver laquelle avant de corriger quoi que ce soit.

---

## 22. Une conversation ne s'ouvre ni en capture, ni dans la suite `mission`

Deux vérifications de la boucle des courses se sont arrêtées **sans un mot** :
Godot quittait, aucun message d'erreur, aucune trace. Le point commun : les deux
finissaient par ouvrir un dialogue.

- La situation de capture appuyait sur la touche d'interaction devant le plan de
  travail. La conversation s'ouvrait, l'image n'était jamais prise.
- La suite `mission` appelait `point_utilise()`, qui démarre la réponse de
  Skyler.

**Ce n'était pas le contenu neuf.** On l'a mesuré en démarrant `telephone_skyler`
— une fiche qui existe depuis des semaines — au même endroit : même arrêt net.
C'est le contexte qui ne le supporte pas, pas la fiche.

**La parade.** Séparer ce qui se mesure de ce qui se joue. `poser_les_courses()`
est publique, fait le retrait et le crédit, et renvoie si on avait de quoi ; le
dialogue vit dans `point_utilise()`, une ligne au-dessus. Le test vérifie la
mécanique et se contente de contrôler que les deux fiches **existent** —
`dialogue.connait()` ne les ouvre pas.

**Le réflexe général :** avant de conclure qu'un ajout casse un test, refaire le
même geste avec quelque chose qui marchait déjà. Ça coûte une exécution et ça
évite de réécrire du code qui n'avait rien.

---

## 23. `generer` ne reproduit pas la ville du dépôt — il en fabrique une plus petite

**Le pire piège trouvé jusqu'ici, parce qu'il détruit sans rien dire.**

`.\bg.ps1 generer` a été lancé pour monter les textures. Il s'est terminé
normalement, sans erreur. La ville est passée de :

| | Avant | Après `generer` |
|---|---|---|
| Étendue | **519 m** | 137 m |
| Lampadaires | **526** | 32 |
| Éléments de décor | **2 674** | 297 |
| Triangles | **62 910** | 7 134 |

**La cause :** `bg.ps1` a `[int]$Blocs = 2` en valeur par défaut, et la ville du
dépôt n'a jamais été générée avec 2 blocs. Le vrai nombre n'est écrit **nulle
part** — ni dans le journal, ni dans les notes de version, ni dans un commentaire.

Le seul symptôme visible venait après, et de biais : `ancrage : aucun lieu nommé
'terrain_vague_3_7'`. La ville neuve n'avait plus les quartiers que le reste du
jeu référence.

**La parade, en attendant mieux : ne pas lancer `generer` tout court.** Les
générateurs s'appellent un par un, et seuls `gen_ville.py` et `gen_banc_graphique.py`
dépendent de `--blocs` :

```powershell
blender -b -P outils/gen_lieux.py   -- --nom tous
blender -b -P outils/gen_maison.py  -- --nom toutes
blender -b -P outils/gen_decor.py   -- --nom tous
```

**Ce qui sauve, c'est que `game/assets/` est versionné** : `git checkout --
game/assets` a tout rendu. Si la génération avait été commitée, la ville était
perdue — elle n'existe que comme fichier, sa graine ne suffit pas à la refaire
sans son nombre de blocs.

**Réglé le jour même.** Le nombre a été retrouvé en générant 7, 8 et 9 **dans un
dossier à part** — `gen_ville.py` accepte `--sortie`, donc on peut chercher sans
rien risquer — et en comparant l'étendue publiée :

| `--blocs` | Étendue | Lampadaires |
|---|---|---|
| 7 | 466 m | 384 |
| **8** | **519 m** | **526** |
| 9 | 576 m | 658 |

Huit tombe pile, et la graine 505 était déjà la bonne. `bg.ps1` a maintenant
`[int]$Blocs = 8`, et la valeur est commentée avec la raison — sans quoi elle
redeviendra un nombre magique que le prochain changera.

**La leçon générale : un défaut qui détruit est pire qu'une erreur.** Une commande
qui refuse de tourner se corrige en une minute ; une commande qui tourne et
remplace le travail par autre chose ne se voit que trois sessions plus tard.

---

## 24. `mat.use_nodes = True` casse `generer` en Blender 5.2, et ne sert plus à rien

Le même piège que celui documenté dans `aplatir()`, mais dans neuf générateurs.

`Material.use_nodes` est déprécié. L'affecter écrit un `DeprecationWarning` sur
la **sortie d'erreur**, et PowerShell traite la moindre ligne de stderr d'un
binaire natif comme une erreur : `generer` s'arrêtait sur `gen_ville.py:331`,
avec un message qui parlait de Blender 6.

**Et la ligne ne servait déjà plus.** Mesuré : en Blender 5.2,
`bpy.data.materials.new()` crée **déjà** le `node_tree` et son Principled BSDF.

```
APRES new()      : node_tree = present
BSDF present     : True
```

Les onze occurrences ont été retirées. Les `scene.world.use_nodes` sont restés —
c'est un `World`, pas un `Material`, et ces fichiers ne sont pas dans la chaîne.

**Le réflexe :** avant de contourner un avertissement de dépréciation, vérifier
si la ligne fait encore quelque chose. Souvent elle ne fait plus que se plaindre.

---

## 25. L'échelle était **écrasée**, pas multipliée — et l'instrument mentait aussi

Deux bugs emboîtés, découverts sur le premier modèle 3D généré. L'ordre dans
lequel ils sont apparus est toute la leçon.

### Le symptôme

`integrer -Hauteur 0.48` annonçait `echelle x1.2000 pour atteindre 0.48 m`, et
écrivait un fichier de **1,198 m**. Deux fois et demie trop grand, sans un mot.

### Le vrai bug

```gdscript
obj.scale = (facteur,) * 3        # AVANT — ecrase
obj.scale = tuple(s * facteur for s in obj.scale)   # APRES — multiplie
```

Il était là depuis toujours et **ne pouvait pas se déclencher** : tous les
modèles livrés à la main arrivent à l'échelle 1, et écraser 1 par 1,2 donne 1,2.

Un modèle Tripo, lui, arrive avec **une échelle de 0,4008 sur son nœud**. La
boîte mesurait donc correctement 0,400 m, le facteur 1,2 était correct — et
l'écrasement rendait `0,998 × 1,2` au lieu de `0,400 × 1,2`.

**La règle : une transformation se compose, elle ne se remplace pas.** Un défaut
qui dort pendant cinquante imports n'est pas un défaut absent.

### Le faux coupable, et c'est le plus instructif

Avant de trouver ça, `lire_glb.py` — que je venais d'écrire — a désigné
`importer_modele.py`. Il lisait les `min`/`max` des accesseurs de POSITION en
croyant tenir « la mesure du fichier ».

**Il ignorait les transformations de nœuds.** Sur ce modèle il annonçait 0,998 m
quand l'objet en fait 0,400. J'ai donc conclu que la chaîne écrivait un fichier
faux, et j'ai « corrigé » du code qui n'avait rien — un détachement de parent qui
ne servait à rien.

C'est le **piège 18 à l'identique** : avant de corriger ce qu'un instrument
dénonce, vérifier l'instrument. La différence, cette fois, c'est que
l'instrument avait dix minutes d'âge et que je l'avais écrit moi-même.

`_etendue()` compose maintenant les matrices de nœuds et transforme **les huit
coins** — deux ne suffisent plus dès qu'il y a une rotation.

### Et un troisième cas, qu'il faut dire plutôt que mesurer

La même fonction annonçait **0,018 m pour Walt**, qui fait 1,78 m. Un maillage
peau est en pose de référence : c'est l'armature qui le place. `lire_glb` rend
donc `hauteur = None` sur un modèle riggé, et le dit. **Mieux vaut rien qu'un
nombre faux** — un appelant qui compare à une cible croirait au nombre.

### Ce qui a sauvé la mise

Le garde-fou ajouté au même moment : `integrer` **relit le fichier écrit** et
refuse si la hauteur ne correspond pas à 1 % près. C'est lui qui a rendu les
trois bugs visibles au lieu de les laisser passer en silence.

---

## 26. `diag` mesurait un endroit différent à chaque fois

**Le piège 18 pour la troisième fois, et c'est celui qui coûte le plus cher en
mauvaises conclusions.**

Deux relevés consécutifs, sans qu'une ligne de code ait bougé entre les deux :

```
temps d'image  0.7 ms median,  125 appels de rendu
temps d'image  5.0 ms median,  906 appels de rendu
```

Un facteur sept. J'en ai conclu qu'un shader de verre coûtait quatre
millisecondes, et j'ai commencé à le démonter. Il ne coûte rien : mesuré avec et
sans, à quelques minutes d'écart, **4,8 contre 5,0 ms**.

**La cause :** `monde.tscn` **reprend la sauvegarde** à son chargement. Le relevé
se fait donc là où la dernière partie s'est arrêtée. Et comme chaque
`bg.ps1 capture` joue une situation puis sauvegarde en partant, l'endroit change
tout seul entre deux `diag`. En périphérie de la ville : 22 appels de rendu. En
plein centre : 906.

**La parade.** `diag_ville.gd` pose maintenant le joueur à un **point fixe**,
`(0, 1.5, 0)`, à la même image que l'heure. Deux relevés consécutifs donnent
2,4 et 2,8 ms — cohérents.

Le point est en dur et **pas un lieu nommé** : les noms viennent du générateur et
changent avec la graine. `terrain_vague_3_7` existait le matin et plus
l'après-midi (voir piège 23). `--lieu <nom>` reste disponible pour mesurer
ailleurs volontairement.

---

## 27. J'ai écrasé un test, et le remplaçant était moins exigeant

**Le plus cher de la session, parce qu'il ne se voit pas.** J'ai écrit
`verifs/test_voix.gd` en croyant le créer. Il existait depuis deux commits, et
`git status` l'a affiché `M` — modifié — au lieu de `??`. C'est la seule chose
qui l'a signalé, et je ne l'ai vu qu'au moment de commiter.

Le test que j'ai remplacé faisait **deux choses de plus** que le mien :

1. **Il mesurait la crête du bus audio**, pas la présence du fichier. Un WAV
   valide de zéro seconde se charge sans erreur et ne s'entend pas — compter les
   fichiers l'aurait déclaré bon. Le mien comptait les fichiers.
2. **Il appelait `Dialogue.VOIX` et `Dialogue._simplifier()`** au lieu de les
   recopier. Son commentaire disait pourquoi, et j'ai fait exactement ce qu'il
   interdisait : *« si le test refaisait le sien, il validerait sa propre
   convention et pas celle qui est réellement utilisée »*. Deux copies de la
   même règle restent d'accord entre elles en étant fausses toutes les deux.

**La parade, et elle vaut au-delà des tests :** avant d'écrire un fichier dans
`verifs/`, `outils/` ou `systemes/`, vérifier qu'il n'existe pas. `Write` écrase
sans rien demander. Et devant un `M` là où on attendait `??`, s'arrêter : c'est
un fichier qu'on croyait neuf.

Le test livré est la **fusion** : la mesure de volume et l'appel aux fonctions du
jeu viennent de l'ancien, le détail par personnage et la distinction
« posée mais pas importée » du nouveau. Il relève **−6,5 dB** sur le bus
Interface, ce qui est la seule preuve qu'on entend quelque chose.

---

## 28. `ConvertFrom-Json` rend un tableau comme UN SEUL objet

Trois voix sont sorties fusionnées en une, sous le nom `Jesse Walter Tuco`, sans
la moindre erreur :

```powershell
$lot = @(Get-Content $f -Raw | ConvertFrom-Json)   # $lot.Count = 1
```

PowerShell 5.1 ne déroule pas un tableau JSON dans le pipeline : il l'émet
entier. Le `@()` autour n'en fait donc pas une liste de *n* éléments, mais une
liste de **un** qui les contient tous — et `$v.qui` sur cette collection
concatène silencieusement les valeurs de tous les éléments.

```powershell
$lot = @()
$lot += (Get-Content $f -Raw | ConvertFrom-Json)   # le += aplatit
```

**Ce qui rend ce piège coûteux :** il ne lève rien. La boucle tourne une fois,
le script annonce « 1 voix à ranger » au lieu de 8, et il faut lire ce nombre
pour s'apercevoir qu'il est faux.

---

## 30. Cinq nombres justes, et aucun ne mesurait la bonne chose

**Le piège 18 sous sa forme la plus trompeuse : l'instrument ne ment pas, il
répond à une autre question.**

J'ai transféré les clips de marche de Walter vers les huit figurants du pack.
Puis j'ai mesuré le fichier produit, comme la règle l'exige :

```
skins=1   maillages=2   images=1   4 animations   0,36 Mo
8/8 conformes
```

Cinq mesures, toutes exactes, toutes vérifiées sur le fichier écrit et pas sur
l'intention. Et **aucune** ne répondait à « est-ce que ce corps tient debout ».

À l'image, les figurants sont **disloqués** — membres en étoile, bassin de
travers. Exactement le résultat de `retarget_figurants.py` trois mois plus tôt,
par une méthode opposée.

**La cause du transfert raté :** deux squelettes peuvent partager 22 noms d'os
sur 24 sans partager leurs **orientations de repos**. Une rotation enregistrée
pour le `LeftUpLeg` de Walter suppose l'axe de Walter. Copier une courbe n'est
pas retargeter — il faut composer l'écart :
`rotation_cible = repos_cible⁻¹ · repos_source · rotation_source`.

**Ce qui aurait dû arriver en premier :** `outils/apercu_modele.py` existait
depuis le 31/07, écrit précisément pour cette question, et son en-tête le dit —
*« pour répondre à : est-ce que ce corps tient debout, il faut le regarder SEUL,
dans une pose CHOISIE »*. Une commande, quinze secondes.

**La parade :** avant de mesurer, écrire la question à laquelle on veut
répondre. Si la question porte sur une **forme** — un corps, un décor, un
cadrage — aucune quantité n'y répond, et il n'y a qu'à regarder. Compter les
os d'un personnage disloqué donne exactement le même nombre que compter ceux
d'un personnage debout.

Et le signal d'alarme, quand il est là : `gen_ville.py` portait en commentaire
« **le corps se disloque, membres en étoile** », vingt lignes au-dessus de la
table que j'allais modifier. Je l'ai lu **après** avoir fabriqué les huit
fichiers.

---

## 29. J'ai ajouté trois personnages qui existaient déjà, sur une recherche tronquée

**C'est la règle « une absence ne prouve rien » de [CLAUDE.md](../CLAUDE.md),
repayée au prix fort.** Elle y était écrite depuis des semaines, avec son
exemple — le bug « on ne peut pas courir » ouvert sur une liste coupée par ma
propre commande.

J'ai cherché les hommes de main de Tuco dans `mission1.tscn` :

```
Grep "Bureau|Tuco|Homme|Argent|Liasse|Sachet"   →  [limit: 25]
```

Le dernier résultat affiché était `CaisseBasse`, ligne 616. `Homme1`, `Homme2`
et `Homme3` sont **lignes 670 à 686**. La coupure est tombée entre les deux.

J'en ai conclu qu'ils n'existaient pas, j'ai écrit dans le commit qu'ils étaient
« décrits partout, posés nulle part », et j'en ai ajouté trois. Le jeu en a
affiché **cinq**, dont deux à soixante centimètres l'un de l'autre. C'est
Benjamin qui l'a vu, en jouant.

Et le comble : les trois originaux portaient un commentaire qui disait
exactement ce qu'ils faisaient là — *« Les trois hommes de main sont DERRIERE
le joueur, au fond de la piece. C'est le placement du scenario, et il fait
tout : on ne les voit pas, on sait qu'ils sont la. »*

**La parade, et elle est mécanique :** quand une recherche sert à prouver
qu'une chose **n'existe pas**, la troncature n'est pas un détail d'affichage,
c'est une réponse fausse. Soit on relance sans limite, soit on compte —
`output_mode: "count"` ne se tronque pas. Un `[limit: N]` en bas d'un résultat
qui sert à conclure à une absence doit arrêter la main.

**Et le contrôle qui aurait tout évité coûtait dix secondes :** charger la scène
et compter ce qu'elle contient. C'est ce qu'a fait `verifs/ou_est_qg.gd` après
coup, et il a donné la réponse du premier coup — sept personnages, trois de
trop. On mesure la scène chargée, pas le fichier lu à travers un filtre.

### Ce que ça a coûté en affirmations fausses

La note de version de la 0.51.0 annonçait « 0,6 ms avant, 0,7 après ». Les deux
chiffres étaient réels et la conclusion était juste — **la refonte ne coûte
rien** — mais ils décrivaient deux endroits différents et ne se comparaient pas.

La mesure honnête, faite au même point en coupant les effets par réglage :

| | Temps d'image | Appels de rendu |
|---|---|---|
| Effets coupés | 3,0 ms | 751 |
| **0.51.0 complète** | **2,8 ms** | 786 |

L'écart est dans le bruit. **Une mesure de performance ne vaut que si l'on peut
dire où elle a été prise.**

## 31. Un compteur qui agrège deux causes désigne toujours la mauvaise

`test -Suite foule` annonçait **« 12 passants sous la carte »**. Aucun n'était
tombé.

Le compteur valait `global_position.y < 0.05`. Or il y a **trois sols** dans
cette ville, et un passant repose forcément sur l'un d'eux :

| Sol | Hauteur | Ce que ça veut dire |
|---|---|---|
| Trottoir | **0,18 m** | il est où il doit être |
| Chaussée | **0,01 m** | il marche sur la route |
| Sable du désert | **−0,05 m** | il s'est éloigné de la ville |

Le seuil mettait les deux derniers dans le même sac, sous un nom qui décrivait
un quatrième cas — passer au travers du décor — qui ne s'est jamais produit.

**Ce que ça allait coûter :** chercher un trou dans la collision du sol. Il n'y
en a pas. Le vrai défaut était horizontal, à trente mètres de là.

Ce qui l'a évité : relever les hauteurs une par une avant de corriger quoi que
ce soit. Trois paliers nets — 18, 1–3 et −5 cm — et **identiques après deux
secondes de marche**, ce qui excluait une chute en cours. Un agrégat n'aurait
jamais montré ça.

**La règle : un compteur nomme UNE cause.** Si deux défauts qui se corrigent à
des endroits différents peuvent l'incrémenter, il ne dit pas lequel, et le nom
qu'on lui a donné tranchera à sa place — dans le mauvais sens une fois sur deux.

### Et son jumeau : un test qui recopie les constantes du générateur

Le même fichier déclarait :

```gdscript
# Doivent correspondre a outils/gen_ville.py.
const PAS := 54.0
const ROUTE := 8.0
```

`gen_ville.py` disait **57** et **11** depuis des semaines. Le commentaire
énonçait une obligation que rien ne vérifiait. Et depuis la trame irrégulière du
31/07/2026 — des îlots de 30 à 64 m — **aucun pas fixe ne peut décrire cette
ville** : la duplication n'était pas seulement périmée, elle était devenue
impossible à tenir.

Remplacé par une grandeur que le jeu porte lui-même : la hauteur du sol sous le
passant. Elle ne se recopie pas, donc elle ne se désynchronise pas.

**Une constante dupliquée d'un outil vers un test finira par mentir, et le
commentaire qui l'accompagne mentira avec elle.** Mesurer ce que la scène
contient, pas ce qu'un autre fichier prétend avoir produit.

## 32. Deux tests d'affilée ont validé un mécanisme DÉBRANCHÉ

Brancher le son des pas sur les passants a pris dix minutes. **Écrire une mesure
capable de le contredire en a pris trois fois plus**, et il a fallu deux essais
ratés pour y arriver.

Le protocole qui les a démasqués tient en une phrase : **commenter la ligne qui
branche, relancer, et exiger le rouge.** Sans ce geste, les deux versions
seraient au vert dans le dépôt aujourd'hui, à surveiller un mécanisme qu'on
aurait pu supprimer sans qu'elles bronchent.

### Essai 1 — la crête d'un bus partagé

```gdscript
_crete = maxf(_crete, AudioServer.get_bus_peak_volume_left_db(_bus, 0))
_verifier(_crete > -60.0, "on entend le pas d'un passant")
```

Débranché : **−14,3 dB**, et au vert. Le bus « Effets » porte tout ce que le jeu
émet ; il n'était jamais silencieux. Le seuil ne pouvait pas ne pas passer.

**Un agrégat global ne prouve jamais qu'une source PARTICULIÈRE a émis.**

### Essai 2 — appeler soi-même ce qu'on veut voir appelé

```gdscript
p0.call("_poser_le_pied")        # puis : le son a-t-il été joué ?
```

Débranché : **toujours au vert**. Évidemment — l'appel manuel court-circuite
exactement le signal dont on cherche à savoir s'il est connecté. Ça teste que la
méthode fonctionne, ce dont personne ne doutait.

**C'est le piège 19 sous un autre déguisement** : une vérification qui produit
elle-même la condition qu'elle observe valide toujours. Là-bas on téléportait la
voiture sur la sortie avant de vérifier qu'on peut sortir ; ici on déclenche le
pas avant de vérifier qu'il se déclenche.

### Ce qui marche

Ne rien appeler. Laisser les passants marcher deux secondes, et **compter les
lecteurs qu'`Audio` a fabriqués** :

```
  ok   on entend marcher les passants (6 pas joue(s) en 2 s)
```

Débranché : `0 pas joue(s)`, rouge. La mesure porte sur une conséquence que seul
le branchement peut produire.

**La question à se poser devant toute vérification d'un branchement : qu'est-ce
qui, dans ce test, ne pourrait PAS arriver si le fil était coupé ?** Si la
réponse est « rien », le test ne surveille rien.

## 33. Un banc d'essai posé dans le monde finit toujours par être rattrapé par lui

`test -Suite conduite` annonçait **« 0 km/h, seuil 45 »**. Le moteur n'a jamais
rien eu.

C'est la **troisième fois** que le circuit de ce test se fait rattraper par le
décor, et les trois symptômes étaient identiques — une vitesse finale basse, qui
ressemble à une panne de conduite :

| Quand | Ce qui avait grandi | Ce que la voiture a percuté |
|---|---|---|
| 31/07/2026 | la bande de cactus, de 75 à 165 m | un saguaro, à 17 m |
| 09/08/2026 | les crêtes, de 300/420 m à **230/360 m** | `montagne_col`, à 27,8 m |

Le circuit était à x = −260, donc **derrière** la crête ouest une fois celle-ci
rapprochée. Personne n'a pensé au circuit en rapprochant les montagnes, et
personne n'y pensera la prochaine fois.

### Les deux mesures qui manquaient

**La courbe, pas le point d'arrivée.** « 23 km/h à l'arrivée » ne dit pas si la
voiture n'accélère pas ou si elle a été arrêtée. Un relevé par seconde a montré
une montée parfaitement régulière jusqu'à 37,2 km/h **puis un arrêt net** — la
signature d'un choc, pas d'une panne.

**Le nom de ce qu'on heurte.** `ELLE A HEURTE : montagne/montagne_col a 27.8 m`.
Sans lui, il faut deviner, et on devine mal : le premier réflexe a été de
soupçonner l'accélération de l'Aztek.

### Et le remplacement était pire que le mal

Nouvelle position choisie plein sud, mesurée **dégagée sur 160 m dans les quatre
directions**. Le test est passé au vert en annonçant **282,5 km/h**, pour une
vitesse maximale réglée à 130.

Il n'y a pas de sol à cet endroit. `vitesse_kmh()` renvoie
`linear_velocity.length()` — **la norme du vecteur, chute comprise**. La voiture
tombait, et un seuil de 45 km/h franchi par une chute libre ne mesure rien du
tout. L'écart latéral à 0,00 m et la dérive de cap à 0,0° avaient l'air parfaits :
une chute verticale ne dérive pas.

**Un test qui passe avec un chiffre impossible n'est pas un test qui passe.** 282
pour un plafond à 130 aurait dû arrêter la lecture immédiatement.

### Ce qui rend la chose durable

Ce n'est pas la nouvelle position — elle sera rattrapée un jour comme les deux
précédentes. C'est que **le banc vérifie maintenant son propre terrain avant de
mesurer** : un sol dessous, la distance libre devant sur la largeur du véhicule
(trois rayons parallèles, parce qu'un rayon seul passe entre deux cactus par
lesquels la voiture ne passe pas), et le nom de l'obstacle s'il y en a un.

**Un banc d'essai doit valider son terrain avant de mesurer ce qu'on lui
demande** — sinon il rend un verdict sur le sujet alors qu'il décrit son décor.

## 34. Un nom de maillage de trois lettres a rendu le jeu injouable

Retour manette en main, le 09/08/2026 : « **Walt est injouable, il est bloqué
dans un mur au spawn, il traverse la maison, il va trop vite et fini par tomber
dans le vide** ».

Quatre symptômes, une seule cause : **j'avais appelé un morceau de la
combinaison `Col`**.

```python
c = Maillage("Col", mats["combinaison_sombre"])   # le col du vetement
```

À l'import d'un glTF, Godot lit ce nom comme une consigne de **collision** et
fabrique un `StaticBody3D` dans le maillage. Le vêtement étant accroché à l'os du
torse, le corps solide se retrouvait greffé sur le joueur :

```
/root/Monde/.../Joueur/Corps/Walter/Armature/Skeleton3D/Attache_Spine02/blouse/Col/StaticBody3D
```

Walt entrait en collision **avec ses propres habits**, à chaque image, et le
moteur le repoussait. Le reste en découle : coincé au départ, poussé au travers
des murs, vitesse qui monte, sortie de carte.

### Ce qui a rendu le diagnostic long

Le déplacement **ne passe pas par la vélocité**. Le relevé affichait `vitesse
0.0` pendant que le personnage parcourait deux mètres toutes les vingt images.
J'ai donc éliminé, dans l'ordre et à tort : les entrées (axes à zéro, aucune
manette), la foule, un mur qui le repousse, le trafic, les garde-fous de passage.
Tout cela mesuré, tout cela juste, et à côté de la plaque.

**Ce qui a tranché en une mesure : demander au moteur physique DANS QUOI le corps
se trouve**, et imprimer le chemin complet de ce qu'il touche.

```gdscript
var q := PhysicsShapeQueryParameters3D.new()
q.shape = forme.shape
q.transform = Transform3D(Basis(), joueur.global_position + forme.position)
q.exclude = [joueur.get_rid()]
# puis : str(collider.get_path())  — le chemin, pas seulement le nom
```

Le nom seul disait « Col/StaticBody3D » et n'apprenait rien. **Le chemin
désignait le coupable immédiatement** : il commençait par `Joueur/`.

### Et la portée réelle

Ce même défaut cassait **toute la planche de captures** (#61) : le sujet, poussé
hors du cadre entre le placement et le déclic, n'était jamais sur l'image. Un
ticket entier ouvert sur des symptômes qui n'étaient qu'une conséquence.

**Les règles qui en sortent, et la première vaut pour tout asset :**

- **Aucun maillage ne s'appelle `Col`, `Colonne`, ni rien qui finisse par
  `-col`, `-colonly`, `-convcol`.** Le nom d'un nœud dans un glTF est une
  INSTRUCTION pour Godot, pas une étiquette. Ici : « Rabat ».
- **Un corps qui bouge sans vélocité est poussé par quelqu'un.** Ne pas chercher
  qui le commande — chercher ce qu'il touche.
- **Excluer le porteur ne suffit pas** : `exclude = [joueur]` n'exclut pas les
  corps portés PAR le joueur, qui ont leur propre RID.

## 35. Un outil miroir qui cesse de l'être range des fichiers que personne ne cherche

`outils/voix_ia.ps1` nomme les voix générées **exactement** comme le jeu les
cherchera. Son en-tête le dit lui-même : « sans quoi le jeu cherchera un nom qui
n'existe pas et restera muet SANS LA MOINDRE ERREUR ».

C'est précisément ce qui est arrivé. Cinq voix générées, cinq voix rangées, un
script qui annonce « 5 rangee(s) » — et le test :

```
  Walter   51 ont   5 sans
  manque : Walter : [measured, dry] There is nothing out here. That is not a complaint.
```

Côté Godot, l'empreinte porte sur `[jeu] vo` quand la réplique est dirigée :

```gdscript
static func _prononce(replique: Dictionary) -> String:
    var jeu := str(replique.get("jeu", ""))
    if jeu == "": return vo
    return "[%s] %s" % [jeu, vo]
```

Le script, lui, hachait `vo` seul. **La direction d'acteur avait été ajoutée à
l'empreinte d'un côté et pas de l'autre.** Tant que les répliques doublées
n'étaient pas dirigées, les deux formules coïncidaient et rien ne se voyait.

**Un outil qui doit reproduire un calcul du jeu est un MIROIR, et un miroir se
casse en silence.** Les deux fonctions portent maintenant le même nom —
`_prononce` côté Godot, `Prononce` côté PowerShell — pour qu'on les trouve
ensemble.

Ce qui a sauvé la mise : la suite `voix` ne vérifie pas que les fichiers
existent, elle vérifie que **chaque réplique de `dialogues.json` a le sien**.
C'est la différence entre compter des fichiers et mesurer ce qui manque.

## 36. L'éditeur Godot vide un `.tres` de ses commentaires, dans un commit qui parle d'autre chose

`game/default_bus_layout.tres` portait 51 lignes expliquant les bus audio :
pourquoi deux bus de plus plutôt qu'un filtre cuit dans les fichiers, pourquoi
300–3400 Hz sont la bande réelle d'une ligne téléphonique et pas un réglage à
l'oreille, pourquoi seul le correspondant est filtré et jamais Walter.

Le commit `fcc02e6` du 12/08/2026 les a toutes effacées. Son message :

```
1 modele(s) 3D
```

Il livrait effectivement un modèle 3D. Le fichier de bus a suivi parce que le
projet avait été ouvert dans l'éditeur, et que **Godot réécrit un `.tres` en
entier quand il l'enregistre** — il n'a aucune notion de commentaire à
préserver, ils ne font pas partie de la ressource qu'il a chargée.

**Ce qui rend la perte invisible, ce n'est pas le diff — c'est le message.**
Personne ne relit le diff d'un fichier audio dans un commit qui annonce un
modèle 3D. Et la ligne de statistiques ne trahit rien :

```
game/default_bus_layout.tres | 53 ++------------------------------------------
```

Un `-51` sur un fichier de configuration ressemble à un nettoyage.

Rien de fonctionnel n'avait bougé — vérifié en comparant les seules lignes
`bus/*` et les paramètres d'effets, identiques à deux valeurs près (`pre_gain`
et `post_gain` à `0.0`, qui sont les défauts de `AudioEffectDistortion`). C'est
la **note** qui était perdue, c'est-à-dire la seule chose qu'on ne peut pas
retrouver en relisant le code.

**Un commentaire placé dans un fichier que l'éditeur possède est un dépôt
fragile.** Deux gestes :

- **Lire le diff d'un `.tres` avant de committer**, quel que soit le sujet
  annoncé du commit. C'est le seul moment où la perte est encore gratuite.
- Le fichier porte maintenant son propre avertissement en tête. Il ne survivra
  pas non plus à un enregistrement — mais il sera dans le diff, juste au-dessus
  de ce qui disparaît.

Ce qui a limité la casse : `default_bus_layout.tres` est le **seul** `.tres`
commenté du dépôt. `game/systemes/reglages.tres`, l'autre, n'en porte aucun.

## 37. Une passe de cohérence valide trois fichiers qui disent la même chose fausse

Le 09/08/2026, une passe de cohérence a parcouru le dépôt entier — fichiers,
docs, tickets, code. Elle a trouvé six chiffres faux dans le README, deux canaux
documentés qui ne menaient nulle part, sept faux orphelins. Du bon travail.

Elle est passée à côté de ceci, écrit à trois endroits :

> `docs/03-conventions-assets.md` — « Les médias issus de la série — image, son,
> vidéo, police, logo — vivent dans `assets-ref/`, ignoré par git. »
>
> `DISCLAIMER.md` — « **Aucun média issu de la série n'est versionné dans git** —
> ni image, ni son, ni vidéo, ni police, ni logo. »
>
> `livraisons/LISEZ-MOI.md` — « **Les médias issus de la série.** Ils vont dans
> `assets-ref/`, qui n'entre jamais dans git. »

**Il y en avait 39 dans le dépôt**, dont huit depuis le 26/07 — commitées par
celui-là même qui avait écrit la règle. Et le `DISCLAIMER` affirmait par ailleurs
« le dépôt n'est pas public et le jeu n'est pas distribué publiquement », alors
que le dépôt est public depuis le 05/08 et que les exe sortent en releases
ouvertes.

**Pourquoi la passe ne pouvait pas les voir.** Elle cherchait des
**incohérences** : un chiffre qui contredit un autre chiffre, un label cité qui
n'existe plus, un lien mort. Ces trois phrases-là étaient parfaitement cohérentes
— entre elles. Elles se confirmaient l'une l'autre, et plus elles étaient
répétées, plus elles avaient l'air vérifiées.

**Une règle recopiée à trois endroits ne devient pas vraie ; elle devient
crédible.** Et c'est exactement le contraire de ce qu'on veut : la duplication
transforme une affirmation invérifiée en évidence.

Le geste qui manquait tient en une ligne, et il ne compare aucun document à un
autre :

```powershell
git ls-files 'livraisons/*.jpg' 'livraisons/*.png'   # 39
```

**Une règle se vérifie contre le DÉPÔT, pas contre les autres pages qui la
répètent.** Devant une affirmation absolue — « aucun », « jamais », « toujours »
— la question n'est pas « est-ce écrit pareil ailleurs ? » mais **« quelle
commande la contredirait, et qu'est-ce qu'elle répond ? »**

Corrigé le 16/08/2026, aux trois endroits. Ce qui reste à mesurer — quels assets
de l'exe distribué viennent de la série — est en #74, parce que le fichier prévu
pour y répondre, `livraisons/LICENCES.md`, est décrit dans la charte depuis le
début et **n'a jamais été créé**. Une règle qui n'a pas d'instrument n'est pas
une règle, c'est une intention.

## 38. Une vérification réparée à moitié cache la moitié qui reste

La vue `camping_car_porte` existe pour trancher une question, et elle le dit :
« la SEULE question est de savoir si la porte du jeu tombe sur la porte du
modèle ».

Elle a déjà été réparée une fois. Le piège 19 raconte la première version : elle
visait `(877, −804)`, une coordonnée recopiée à la main, le générateur a posé le
camping-car vingt-neuf mètres plus loin, et elle a continué de rendre un PNG
parfaitement valide — du sable. La correction a introduit `autour`, qui ancre la
**caméra** sur ce qu'elle photographie. C'était le bon geste.

Mais le **joueur**, lui, a continué d'être posé sur `pos: [1.75, 0.4, 1.27]` —
une copie en dur de la position que `PorteCampingCar` avait le jour où on l'a
recopiée. La vue photographiait donc bien le camping-car, et posait Walter à
l'endroit où la porte **était censée** se trouver.

**Le geste qui tranche a coûté une minute** : déplacer le nœud de deux mètres
dans `mission1.tscn`, relancer la capture.

```
noeud a 1.27  ->  empreinte EEE6845D9C36CF33   Joueur pose a (906, 1, -803)
noeud a 3.27  ->  empreinte 785409FEB17723C7   Joueur pose a (906, 1, -801)
```

Avant correction, les deux empreintes étaient **identiques**. Deux mètres de
déplacement du point d'entrée du jeu ne produisaient aucun effet sur la vue
chargée de le contrôler.

**Ce qui rend ce piège plus coûteux que le 19 dont il descend : la moitié
réparée sert d'alibi à la moitié qui reste.** La vue avait été corrigée, le
commit était écrit, le récit était dans `capture.gd` — plus personne n'allait
regarder. Une correction partielle ne laisse pas un défaut visible à moitié : elle
le rend invisible en entier.

Et le fichier voisin tenait la règle. `mission1.tscn` dit, trois lignes au-dessus
du nœud : *« ON S'ANCRE SUR LE CAMPING-CAR, ON NE RECOPIE PLUS SA POSITION. »*
La scène l'appliquait. La vue chargée de la vérifier, non.

**La question qui trie**, parce que toutes les coordonnées en dur ne sont pas des
défauts. Sur 33 étapes `placer` des scénarios, 31 posent sur une coordonnée du
monde, et la plupart ont raison de le faire : `walt_face`, `walt_dos`, `blouse`,
`purete_*` posent Walter quelque part pour le photographier, et rien dans l'image
ne dépend de l'endroit exact.

> **Ce scénario affirme-t-il que deux choses COÏNCIDENT ?**

Si oui, il doit lire au moins l'une des deux — `sur: "<noeud>"` depuis le
16/08/2026 — sinon il affirme ce qu'il a lui-même posé. Si non, une coordonnée en
dur est la bonne réponse et le restera.


## 39. Une deuxième mission réveille les fils de la première, un par un

Trois morceaux de la mission de rodage se sont déclenchés pendant « Deux corps »,
à trois soirées d'intervalle, et chacun a été découvert **en jouant** — jamais
par une suite.

1. **Les tueurs de Tuco**, dans le fossé. L'étape s'appelait `fuir` des deux
   côtés. Walter se faisait abattre au milieu du désert, à quinze kilomètres du
   QG, pendant qu'il ramassait des éclats de verre.
2. **Le décompte** qui va avec, armé par le même nom.
3. **Le mot de la fin** — « Il ne faut pas que Skyler trouve ça » — joué après la
   première cuisine. Walter n'a pas un dollar sur lui : il n'a rien à cacher.

**Une seule cause, trois fois.** Ces branchements ont été écrits quand il
n'existait qu'une mission, et ils n'ont donc jamais eu besoin de demander
*laquelle*. `a_l_etape("fuir")` suffisait, parce qu'il n'y avait qu'un `fuir` au
monde. Le code n'est pas devenu faux : **son hypothèse implicite a cessé d'être
vraie**, et rien dans sa forme ne dit qu'il en avait une.

C'est ce qui le rend invisible à la relecture. Un fil cassé se voit ; un fil qui
écoute un signal trop large se lit comme du code correct, parce qu'il l'était.

**Le troisième était le pire, et pour une raison qui vaut d'être notée.** Les
deux premiers venaient d'une collision de NOM — mesurable, réparable, et un
contrôle peut la refuser. Le troisième ne collisionnait rien : il écoutait
`_sur_victoire()`, « une mission vient de finir ». Un signal juste, un
branchement propre, et une réplique qui ne pouvait appartenir qu'à une seule
mission. **Aucune vérification de nommage ne l'aurait attrapé** — il a fallu le
voir à l'écran.

### Ce qu'on en fait

**Avant de brancher une réaction de scénario, demander sur quoi elle s'appuie :**

- **un nom d'étape** → il est partagé par tout le jeu. Depuis le 16/08/2026, un
  contrôle refuse qu'une même clé serve dans deux missions et nomme les deux
  fichiers. Le doublon devient rouge au lieu de devenir mortel.
- **un événement de point** (`objet:botte`, `action:livraison`) → il vit dans une
  scène, qui appartient à une mission. Sûr par construction, rien à faire.
- **un signal de mission** (`victoire`, `échec`) → **c'est le cas dangereux.** Il
  est vrai pour toutes les missions, et le contenu qu'on y accroche ne l'est
  presque jamais. Il faut regarder `mission.fichier`.

### La question courte

> **Cette ligne serait-elle encore juste s'il y avait dix missions ?**

Elle se pose une fois, à l'écriture, et elle coûte une seconde. Les trois fois où
elle n'a pas été posée, le prix a été une soirée de test de Benjamin partie dans
un bug qui n'avait rien à voir avec ce qu'on venait de livrer.

Et le corollaire, moins confortable : **le jour où une deuxième mission arrive,
tout ce qui a été écrit du temps de la première est suspect**. Pas faux — suspect.
Ça se relit en entier, une fois, plutôt que de se découvrir en trois soirées.


## 40. Un rayon vers le sol trouve ce qui est POSÉ sur le sol

`pose_au_sol` lance un rayon depuis huit mètres au-dessus et pose le nœud là où
il touche. Écrit pour le fossé, il a marché pendant des semaines — sur des
personnages et des objets qui n'avaient rien au-dessus d'eux.

Le semis de débris est le premier à avoir été centré sur le camping-car. Sa
coque est une caisse de trois mètres de haut ; le rayon l'a touchée, et tout le
semis s'est posé sur le **toit** — un anneau d'éclats flottant à hauteur de tête.

**Le code était juste, son hypothèse ne l'était plus.** « Le premier contact sous
un point est le sol » est vrai tant que rien n'est posé dessus. C'est la même
forme que le piège 39 : une hypothèse implicite, vraie à l'écriture, que rien
dans la ligne ne signale.

### La correction, et pourquoi celle-là

Trois réponses étaient possibles, et deux sont des pièges à leur tour :

- **filtrer par couche de collision** — il aurait fallu déplacer le terrain sur
  une couche à lui, donc toucher aux collisions de tout le jeu pour un décor ;
- **exclure par nom** (« ignorer la Coque ») — ça marche jusqu'au deuxième
  véhicule, et ça échoue en silence ;
- **traverser** : à chaque contact, exclure le corps touché et relancer. Le
  dernier contact avant le vide est le sol, puisque rien n'est enterré dessous.

La troisième ne connaît ni les couches ni les noms. Elle dit ce qu'on voulait
dire depuis le début : **le sol est ce qu'il y a de plus bas**. Elle vaut aussi
pour un objet glissé sous un véhicule, cas qu'aucune des deux autres ne couvre.

### Le second défaut, qui se cachait derrière le premier

Rayon corrigé, le semis restait faux : **un maillage d'un seul tenant n'a qu'une
hauteur**, et le fossé creuse 2,30 m sur quinze mètres de rayon. Posé au fond,
ses bords s'enterrent ; posé au bord, son centre flotte. Aucun réglage n'y
pouvait rien — la forme elle-même était impossible.

C'est ce qui rend ce piège coûteux : **corriger la cause visible aurait laissé
le défaut**, sous une forme plus discrète (des éclats à demi enfouis au lieu
d'éclats volants), donc plus durable. La question à poser après une correction
qui marche : *est-ce que ça marchait par hasard ailleurs aussi ?*

### La question qui trie

> **Ce que je pose, y a-t-il quelque chose au-dessus — et s'étend-il assez loin
> pour que le relief change sous lui ?**

Si oui à la première, le rayon doit traverser. Si oui à la seconde, il faut
plusieurs points de pose, pas un meilleur rayon.


## 41. Le chantier « décor entier » était une porte

Deux gros morceaux restaient à la mission 1, tous deux estimés à plusieurs
séances : l'intérieur du camping-car (B1) et sa conduite (A8). Les deux ont été
faits dans la même soirée, et pour la même raison — **l'essentiel existait déjà**.

**L'intérieur.** `clairiere.tscn` portait l'excuse écrite noir sur blanc :
*« le camping-car de la clairière n'a pas d'intérieur à lui, et en creuser un
demandait un décor entier pour une scène de quatre répliques. »* Or
`campingcar_interieur.glb` existait depuis la mission de rodage — couloir, deux
paillasses, verrerie, atelier, plafonniers — posé au large du monde. Il n'était
même pas masqué pendant « Deux corps » : il était là, vide, et personne ne
pouvait y entrer. Le travail a été **une porte et six points**.

**La conduite.** `desert.gd` disait *« on ne le conduit pas »*, et on avait fini
par réécrire l'objectif du joueur pour ne plus promettre ce que le décor ne
pouvait pas tenir. Mais `vehicule.tscn` était réglé depuis des semaines, la
caméra savait déjà changer de cible, le moteur audio vivait déjà sur son
véhicule. Le seul vrai obstacle — le contrôleur ne connaissait qu'un véhicule —
tenait en un groupe et une ligne.

### Ce qui rend ce piège coûteux

**L'excuse était écrite, datée, et argumentée.** Ce n'était pas un oubli : c'était
une décision documentée, prise de bonne foi, qui a cessé d'être vraie sans que
personne ne la relise. Une note d'arbitrage vieille de trois jours se lit comme
une loi.

Et le coût ne se voit pas : on ne mesure jamais le temps qu'on a passé à *ne pas*
faire quelque chose. Deux battements du script sont restés absents des semaines
parce qu'un commentaire disait qu'ils étaient chers.

### Ce qu'on en fait

> **Avant d'estimer un chantier, chercher ce qui existe — et ne jamais faire
> confiance à une note qui explique pourquoi c'est impossible.**

Trois minutes de `find` et `grep` ont remplacé deux séances estimées. La question
n'est pas « comment je construis ça » mais « qu'est-ce qui, dans ce dépôt, fait
déjà les trois quarts du travail ». Le jeu a un système de lieu clos, un système
de véhicule, un système de points, un système d'effets — presque tout ce qu'on
croit devoir écrire est une combinaison de ces quatre-là.

Corollaire, et c'est le plus utile : **quand une note dit qu'une chose est trop
chère, la vérifier avant de la croire.** Elle a été écrite à un moment où c'était
peut-être vrai. Les deux excuses de cette soirée étaient fausses toutes les deux.


## 42. Les chiffres écrits étaient justes, c'est ce qu'on en faisait qui mentait

La sirène de la séquence A monte étape par étape : `0.18 → 0.34 → 0.44 → 0.54 →
0.62 → 0.78 → 0.90 → 1.00`. La courbe est écrite dans le JSON de la mission,
relisible à côté du script, et **elle était bonne**.

Elle ne s'entendait pas. Le niveau était converti en volume par une droite de
−60 dB à −9 dB, et à 0,18 cette droite donne **−51 dB** : rien. La sirène
n'existait qu'à partir de la moitié du parcours, et le battement A4 — *« un son
continu, FAIBLE, qui va monter »* — était un silence.

**Les décibels ne sont pas perceptifs.** Un niveau de 0 à 1 est une amplitude ;
le convertir linéairement en décibels écrase tout le bas de la plage. Il fallait
`linear_to_db`, ce qui donne −24 dB au premier palier : discret et présent.

### Pourquoi rien ne pouvait l'attraper

La vérification lisait les valeurs **écrites** : elle contrôlait que la montée
existe, qu'elle ne redescend pas, qu'aucune étape n'est muette au milieu. Tous
ces contrôles étaient verts, et ils avaient raison de l'être — le défaut n'était
pas dans les données, il était dans la fonction qui les traduit.

C'est le même genre d'angle mort que le piège 18, où un instrument mesurait sa
propre synchro verticale : **la donnée et sa restitution sont deux choses, et
vérifier l'une ne dit rien de l'autre.**

### Ce qu'on en fait

La suite imprime désormais **les deux courbes** — les niveaux écrits et les
décibels réellement appliqués — et refuse un premier palier sous −35 dB.

> **Quand une valeur est traduite avant d'être utilisée, mesurer ce qui sort de
> la traduction, jamais ce qui y entre.**

Ça vaut pour tout ce qui a une unité perceptive : le son en décibels, la lumière
en énergie, une couleur en gamma, une vitesse en km/h affichée. Une table de
valeurs « propres » ne prouve rien tant qu'on n'a pas regardé ce que le joueur
reçoit au bout.

---

## 43. Le même nom de lieu dans trois scènes, et le marqueur en désigne un

**17/08/2026.** Le battement A6 dit « Retourner au camping-car ». Son étape
pointait vers `PorteCampingCar`, et le marqueur de la minimap envoyait le joueur
**à neuf cents mètres du fossé**, vers le camping-car de la mission de rodage.

`PorteCampingCar` existe dans **trois** scènes : la clairière de la séquence B,
la mission de rodage, et c'est celui-là que `find_child` rendait — le premier de
l'arbre, qui contient toutes les scènes du jeu en même temps.

### Pourquoi ça a tenu si longtemps

**Parce que rien n'était bloqué.** Le déclencheur réel est un point posé à quatre
mètres de la portière, et il fonctionnait. Le marqueur mentait dans son coin.

Un joueur qui connaît la scène retourne au camping-car d'instinct : il ne
regarde pas sa minimap, donc il ne voit pas l'erreur. Il faut ne PAS connaître
la scène pour la rencontrer — c'est-à-dire être exactement le joueur pour qui
la mission est écrite.

C'est le piège 39 sous un autre jour : **un nom qui ne dit pas de quelle mission
il vient**. Là c'était une clé d'étape, ici c'est un nom de nœud.

### Ce qu'on en fait

`test_parcours.gd` compte les nœuds portant chaque nom cité par une étape, et
refuse qu'il y en ait deux.

> **Un nom de lieu unique dans sa scène ne l'est pas dans le jeu.** Toutes les
> scènes cohabitent dans le même arbre : ce qui résout par nom résout par ordre
> d'arbre, c'est-à-dire par hasard.

---

## 44. Un test qui joue mesure la machine tant qu'on ne fige pas le temps

**17/08/2026.** La suite « parcours » a rendu **deux verdicts différents sur le
même dépôt à trois minutes d'intervalle** : bloquée à l'étape 2 une fois, à
l'étape 10 la suivante. Rien n'avait changé entre les deux.

En headless, le delta d'une image suit la charge de la machine. Une suite qui
**mesure** s'en moque ; une suite qui **joue** en dépend entièrement — la
physique, les glissements dans une cuvette à 24 %, la distance parcourue en
quarante secondes.

`--fixed-fps 60` règle la chose en un argument. Il est posé par suite dans
`bg.ps1`, pas globalement : les autres n'en ont pas besoin et il les ralentirait.

> **Un test qui ne dit pas deux fois la même chose ne dit rien** — et il est pire
> qu'absent, parce qu'on finit par relancer jusqu'à obtenir le résultat qui
> arrange.

---

## 45. Tripo lit toute image comme la vue de face d'un objet debout

**17/08/2026.** Le pantalon du fossé a demandé **trois générations**, et à chaque
fois c'est l'image d'entrée qui décidait, jamais le modèle 3D ni ses réglages :

| L'image | Ce qui est sorti |
|---|---|
| un tas froissé, vu de face | les deux jambes fusionnent — ça se lit comme une jupe |
| le pantalon **à plat, vu du dessus** | un **fuseau vertical de 1,10 m**, mesuré |
| étalé au sol, vu en trois-quarts bas, avec son ombre portée | un pantalon en volume, une jambe pliée, debout |

La deuxième est la leçon : une photo à plat prise à la verticale ne donne pas un
objet plat. Le générateur suppose qu'on lui montre la **face** d'un objet
**debout**, et il extrude en profondeur — d'où la quille.

**Ce qui marche pour un objet qui doit finir au sol** : le photographier comme si
on était debout devant, en trois-quarts bas, avec son ombre. Le modèle arrive
debout et c'est la scène qui le couche — sur le flanc pour un vêtement, jamais
sur le dos, sinon 85 cm de long deviennent 75 cm de haut, c'est-à-dire un tas.

Corollaire mesuré le même soir : **un objet se dimensionne sur sa capture en jeu,
pas sur sa taille réelle.** Le ballon de verrerie était illisible à 24 cm,
discret à 34, lu à 42.

> **Le modèle n'est jamais le problème : l'image l'est.** Avant de changer de
> moteur, de budget de faces ou de qualité de texture, regarder ce qu'on a
> donné à voir.


## 46. Une rustine expliquée trois fois devient une intention

Le personnage ne pouvait pas se déplacer latéralement. Gauche et droite le
faisaient **pivoter sur place**, l'avancée suivait son axe à lui, et la caméra
n'entrait pas dans le calcul. Trois commentaires, dans trois fichiers,
présentaient ça comme un choix : *« les commandes des jeux de l'époque »*,
*« ce n'est pas de la nostalgie »*, *« ici la boucle n'existe pas »*.

C'était une rustine. La caméra se replaçait dans le dos du personnage à chaque
image ; le personnage lisait sa direction sur la caméra ; les deux se
poursuivaient, et aller sur le côté les faisait tourner indéfiniment. Trois
parades ont été payées avant celle-là — bloquer la caméra, figer le repère à
l'appui, puis retirer le déplacement latéral — et **aucune n'attaquait la
cause**, qui était le recentrage automatique.

Le supprimer a coûté huit lignes. Le jeu se conduit maintenant comme n'importe
quel jeu à la troisième personne, ce que le retour de Guillaume demandait en
une phrase : *« je te laisse réparer ça pour le rendre jouable dans la NORME
des autres jeux du style »*.

**Ce qui aurait dû alerter** : une contrainte de gameplay dont la justification
est une histoire technique. Une vraie décision de conception se justifie par ce
qu'on veut que le joueur ressente, pas par ce qui s'est mal passé en mars.

> **Quand un commentaire raconte trois tentatives pour expliquer une
> limitation, ce n'est pas une décision : c'est une cicatrice, et la cause vit
> ailleurs.**

Et le corollaire, plus cher encore : **le test la gardait.** `test_camera.gd`
vérifiait que gauche et droite pivotent sans déplacer, et que la caméra finit
dans le dos du personnage. Vert, complet, argumenté — il certifiait les deux
symptômes comme s'ils étaient le contrat. Un test écrit pendant qu'on répare
décrit la réparation, pas ce qu'on veut.


## 47. Une invite écrite en dur ne rougit jamais

« F   Descendre », onze fois, dans cinq fichiers. Le jour où la touche d'action
est passée à E, aucun test n'a bronché et rien n'a planté : le texte restait
parfaitement lisible, il mentait simplement au joueur.

C'est la famille de défauts la plus discrète du projet — celle où **le
symptôme est un texte juste au mauvais moment**. Elle ne peut se corriger qu'à
la source : les invites lisent maintenant l'InputMap par `Touches`, et
`test -Suite commandes` vérifie les deux bouts de la chaîne — la touche
déclarée, et le texte affiché.

Le même soir a montré pourquoi ça compte : le remappage écrivait bien la
nouvelle touche, mais `InputMap.action_add_event()` l'ajoute en **fin** de
liste. « Avancer » devenait `[flèche haut, K]`, l'affichage lisait la flèche,
et le menu annonçait « Haut » juste après qu'on ait choisi K. Le réglage
marchait ; c'est son affichage qui mentait — deux fois le même piège dans la
même soirée.


## 48. Le cadavre est énorme, et les os sont pourtant justes

« Quand le personnage meurt, on voit son corps s'effondrer mais il est
absolument énorme » — Guillaume, 23/08/2026. Diagnostic mené la même nuit, et
il n'a pas fini où il commençait.

**Ce que la mesure dit** : rien. L'envergure des os vaut **1,72 m debout et
1,72 m couché**, avant comme après la simulation. Les poses sont justes, le
ragdoll tombe correctement, aucun test ne peut rougir.

**Ce que l'image dit** : un corps qui remplit le cadre à six mètres de la
caméra — soit à peu près cent fois trop grand.

**La cause est dans la hiérarchie**, et elle se lit en une ligne :

```
Joueur → Corps → Walter → Armature (échelle 0,010) → Skeleton3D → char1
```

Le `.glb` livré est en **centimètres**. `outils/importer_perso.py` le ramène à
1,78 m en posant `arm.scale`, **sans appliquer la transformation aux données** :
l'échelle reste portée par le nœud Armature, et le `Skeleton3D` en hérite —
échelle globale 0,01.

Or un `PhysicalBone3D` est un corps rigide : **le moteur physique normalise
l'échelle**. Dès que `physical_bones_start_simulation()` démarre, les corps
vivent dans un espace à l'échelle 1 pendant que le squelette est à 0,01, et le
maillage skinné se retrouve rendu à sa taille native — celle du fichier, en
centimètres lus comme des mètres.

> **Un défaut peut être parfaitement invisible aux os et énorme à l'écran.**
> Entre la pose d'un os et le pixel, il y a une hiérarchie de transformations,
> et une échelle qui traîne sur un nœud parent ne se voit dans aucune mesure
> qui part de ce nœud-là.

**La correction est à l'import** : appliquer l'échelle aux données pour que le
`.glb` sorte en mètres, armature à 1. C'est un chantier d'assets, pas une ligne
de code — il faut réimporter le personnage, puis revérifier tout ce qui se
mesure sur lui : la foulée, la hauteur des yeux, les points d'accroche de
l'équipement, les poses.

La preuve, elle, est rejouable à la demande :
`.\bg.ps1 capture -Scenario corps_effondre`.

### Ce qu'il a fallu pour le réparer, et les trois pièges qui attendaient dedans

Corrigé le 23/08/2026 pour Walter — `importer_perso.py` applique maintenant
l'échelle **aux données**. Trois choses ont résisté, et aucune n'était dans le
plan :

**1. `transform_apply` ne met à l'échelle NI la pose courante NI les
animations.** Il redimensionne les sommets et les os au repos, un point c'est
tout. Le personnage sortait à la bonne taille avec les pieds à 4,80 m du sol :
sa pose entière était restée en unités natives. Il faut multiplier soi-même
`pose.bones[].location` et chaque courbe de translation de chaque action —
144 courbes pour Walter.

**2. L'ordre des opérations décide du résultat.** L'échelle doit entrer dans
les données **avant** le calage au sol : `transform_apply` ne touche pas
`arm.location`, donc un décalage vertical calculé avant se retrouve exprimé
dans les anciennes unités. Inversé, on obtient un personnage enterré jusqu'aux
épaules.

**3. Blender 4.4 a supprimé `action.fcurves`.** Les courbes vivent maintenant
dans des couches, des bandes et des « channelbags ». Un script écrit pour une
version antérieure s'arrête net. On accepte les deux formes plutôt que
d'imposer une version : ces scripts sont relancés à la main, parfois des mois
après avoir été écrits.

**Et le vrai coût, celui qui reste** : Jesse et Tuco portent toujours
l'échelle, et n'ont pas pu être réimportés — **leur recette n'était écrite
nulle part**. Le réimport depuis leur source brute sort un fichier neuf fois
plus lourd, sans les clips que le jeu leur demande. La recette de Walter, elle,
est désormais dans
[docs/03-conventions-assets.md](03-conventions-assets.md#la-recette-dimport-de-chaque-personnage-riggé).

> **Un asset du jeu est le RÉSULTAT d'une suite de commandes. Si la suite n'est
> pas écrite, l'asset n'est plus reproductible — et le jour où il faut le
> corriger, on découvre qu'on ne peut pas.** L'outil `alleger_textures.py`
> existe déjà pour cette raison, dite dans son en-tête un mois plus tôt : on
> l'avait constaté sans en tirer la règle.


## 49. Un générateur lancé pour une texture écrit tout ce qu'il sait écrire

`gen_textures.py --moment jour --sortie game/assets/images`, lancé pour
régénérer **un** portrait de 64 pixels. Il a fait deux choses de plus, et
aucune n'était demandée :

- **cent sept textures** déposées dans un dossier qui en contient deux. Sans
  gravité — elles n'étaient pas suivies par git, `git clean` a suffi ;
- **`donnees/monde.json` basculé de « nuit » à « jour »**, parce que le
  générateur écrit le moment qu'on lui passe.

Le second est le vrai piège, et il était **déjà écrit dans le fichier qu'il a
modifié** : *« le fichier seul donnerait un ciel de jour sur des fenêtres de
nuit »*. Le dépôt s'est retrouvé exactement dans cet état — monde déclaré en
plein jour, textures de nuit installées — et le commit était déjà poussé quand
je l'ai vu, en relisant son diff.

**Ce qui aurait évité ça** : `--sortie` détourne un outil de son dossier de
travail. Un outil qu'on détourne ne fait pas *moins* que d'habitude, il fait
la même chose ailleurs.

> **Avant de lancer un générateur pour une seule chose, se demander ce qu'il
> écrit EN PLUS.** Et relire le `git status` en cherchant ce qu'on n'a pas
> demandé, pas en vérifiant que ce qu'on voulait y est.


## 50. Le camping-car pesait onze tonnes dans un commentaire et 1 350 kg en jeu

Il montait cinq mètres hors du fossé, ralentissait — 8 km/h, puis 7, puis 4 —
et calait. Le moteur tournait, les roues tournaient, rien ne signalait quoi que
ce soit. La suite qui **joue** la mission butait là depuis une semaine, avec
une note qui disait honnêtement : *« je n'ai pas tranché si c'est le jeu ou le
pilote »*.

**C'était le jeu, et il a fallu trois mesures pour le voir :**

1. gaz à fond, hors contexte : il avance de 5,4 m en dix secondes **en gagnant
   de l'altitude** — donc il n'est pas bloqué ;
2. mais sa vitesse **décroît** pendant la montée : il n'a pas la force, il a
   l'élan ;
3. et sa masse, mesurée dans le jeu : **1 350 kg**. Or sa scène déclare
   `mass = 11000.0` avec un commentaire qui explique ce que ces onze tonnes
   apportent. `appliquer_reglages()` écrasait la valeur par celle de la
   berline, au premier chargement, depuis toujours.

Le calcul tombe alors tout seul : 900 N sur deux roues motrices pour 1 350 kg
donnent 1,33 m/s². Une pente à 24 % oppose 2,3 m/s². **Il ne pouvait pas
remonter** — aucun réglage de conduite n'y aurait changé quoi que ce soit.

> **Une valeur écrite dans une scène et écrasée au chargement est pire qu'une
> valeur absente** : elle est documentée, argumentée, et fausse. Tout le monde
> la lit et personne ne la vérifie — le commentaire disait même à quoi elle
> servait.

**Et la correction évidente ne marchait pas.** Lui rendre ses onze tonnes l'a
rendu totalement immobile : la suspension est réglée pour 1 350 kg (raideur
200, course 0,22), et sous onze tonnes elle s'écrase — les roues ne portent
plus. Lui rendre sa masse demande donc de refaire sa suspension, ce qui est un
autre chantier. On a corrigé ce qui bloquait : la poussée.

---

## 51. La dérive qui devait faire la difficulté annulait l'échec

Le mini-jeu de versement repose sur une idée simple : la fiole se vide, donc le
jet raccourcit, donc il faut incliner davantage pour porter au même endroit. On
ne peut pas bloquer la souris et attendre.

**Sauf que verser à fond ne ratait jamais.** Le test l'a dit en une phrase :
« verser à fond n'a jamais raté en dix secondes ».

La cause est la mécanique elle-même. À pleine inclinaison le jet passe au-delà
du bécher — c'est bien un échec — mais il faut *insister* un tiers de seconde
pour que ce soit sanctionné, et pendant ce tiers de seconde **la fiole se
vide**. Le jet raccourcit donc, et il retombe dans le bécher juste avant la fin
de la tolérance. La dérive corrigeait la faute à la place du joueur.

Le calcul le montre et il n'a rien de subtil : la portée résiduelle à fiole
vide valait 53 points quand le bord du bécher est à 88. Tout finissait par
rentrer.

> **Quand une mécanique fait bouger la difficulté toute seule, vérifier dans
> quel SENS elle la fait bouger à l'extrême.** Une dérive qui rend le geste
> plus dur au milieu peut le rendre impossible à rater au bout. La grandeur
> qui dérive a un plancher, et il se calcule — il ne se choisit pas à l'œil.

Ce qui l'a attrapé n'est pas une relecture : c'est un test qui **joue** et qui
exige de pouvoir rater.

---

## 52. Un garde-fou qui empêche quelque chose qui n'arrivait pas

Jesse est posé face à sa verrerie — c'est ce que le retour demande. Un PNJ se
tourne vers le joueur quand celui-ci approche : il allait donc se détourner de
son atelier pendant toute la cuisine, et le placement serait resté invisible.

Un champ a été écrit pour ça, le PNJ marqué « absorbé par son travail », un
test écrit pour le prouver. **Vert.**

Puis le geste qui tranche — commenter le fil, relancer, exiger le rouge : le
test est **resté vert**. Le champ n'empêchait rien.

La cause tenait en une ligne, à quatre-vingts lignes de là : un PNJ ne pivote
que si quelqu'un lui a passé le joueur à observer, et **seuls les habitants de
maisons le reçoivent**. Jesse, dans un camping-car, ne pivotait jamais.

Le champ a été **retiré**, pas gardé au cas où.

> **Avant d'écrire de quoi empêcher un comportement, vérifier qu'il a lieu.**
> Le raisonnement était juste — les PNJ pivotent — mais il portait sur une
> classe entière alors que le cas précis en était exclu. Un garde-fou qui ne
> garde rien est pire que pas de garde-fou : il désigne un endroit du code
> comme surveillé, et plus personne n'y regarde.

Et le remède est toujours le même : **couper le fil et exiger le rouge**. Il
coûte une minute et il a servi deux fois ce soir-là.

---

## 53. L'avant d'un personnage n'est pas l'avant de son nœud

Vérifier que Jesse fait face à sa paillasse : trois lignes, et deux verdicts
faux avant le bon.

Le premier comparait sa direction à celle du nœud `PaillasseCuisine` — qui
n'est pas le meuble mais le **porteur des trois points d'interaction**, posé un
mètre en arrière de lui. 117 degrés annoncés sur un placement que la capture
montre juste. *Le test avait tort, pas le jeu.*

Le second mesurait `-basis.z` sur le nœud du PNJ, ce qui est l'avant en Godot.
Il annonçait **exactement l'opposé** de ce qu'on voit à l'écran. La raison est
écrite dans `pnj.gd` depuis longtemps : les modèles riggés livrés regardent
vers `+Z`, donc leur géométrie est suspendue à un pivot `Corps` retourné d'un
demi-tour. L'avant du nœud est le dos du personnage.

> **Mesurer l'orientation d'un personnage sur le nœud qui porte sa GÉOMÉTRIE,
> jamais sur celui qui porte son script.** Entre les deux, il y a toutes les
> parades d'import — et elles sont invisibles depuis l'extérieur.

Deuxième leçon, plus générale : **le nom d'un nœud ne dit pas où il est**. Un
nœud appelé « Paillasse » peut être une poignée d'interaction posée à côté du
meuble du même nom. Avant de mesurer une distance ou un angle vers quelque
chose, vérifier **où il est vraiment**.

---

## 54. Deux nœuds du même nom, et la mesure porte sur le mauvais

Vérifier que la sortie du camping-car dépose bien devant la porte par laquelle
on est entré. Le contrôle cherche `PorteCampingCar`, mesure, et annonce
**113,6 mètres d'écart**. Diagnostic écrit, correction faite, commentaires
rédigés autour du chiffre.

**Le chiffre était faux.** `PorteCampingCar` existe **deux fois** : dans la
clairière du flashback, et dans le camping-car de la mission de rodage —
cent mètres plus loin. `find_child` rend le premier trouvé. La mesure comparait
la sortie d'une mission avec la porte d'une autre.

L'écart réel était de **trois mètres**. Il n'y avait pas de bug à cet endroit.

Pire : la correction, qui visait ce même nom, pointait donc elle aussi sur la
mauvaise porte. **Le remède reproduisait le symptôme qu'il prétendait guérir**,
et le contrôle l'aurait validé puisqu'il mesurait la même chose de travers.

Ce qui a sauvé la mise est une mesure voisine, faite pour une autre raison :
l'ancienne coordonnée tombait à trois mètres du camping-car de la clairière. Un
chiffre en contredisait un autre, et il a fallu choisir lequel croire.

> **Un nom de nœud n'est pas une adresse.** Avant de viser quelque chose par
> son nom — dans du code, dans une scène, dans un test — compter combien de
> nœuds le portent. Le jeu contient deux `PorteCampingCar`, deux `Sortie` et
> plusieurs `Porte` ; `test_mission.gd` le dit noir sur blanc depuis des
> semaines, et ça a été repayé quand même.

Deux conséquences tenues :

- les nœuds visés par leur nom depuis une autre scène portent désormais des
  noms **uniques dans tout le jeu** — `ArriveeFlashback`,
  `SortieDuCampingCarClairiere` ;
- le contrôle **vérifie l'unicité** avant de mesurer quoi que ce soit. Une
  distance juste sur le mauvais nœud reste une distance juste : elle ne dit
  rien, et elle est verte.

Et la leçon de fond, celle qui coûte le plus cher : **un diagnostic chiffré
inspire une confiance qu'un raisonnement n'obtient jamais**. Trois commentaires
et un message de commit avaient déjà été écrits autour de « 113,6 mètres »
avant qu'on découvre que le nombre ne mesurait pas ce qu'on croyait. Le
`print()` de la valeur brute — les deux positions, pas seulement l'écart — est
ce qui a fini par trahir l'erreur.

### 54 bis — et la deuxième fois, l'homonyme était créé par le code

Le même piège, deux heures plus tard, sur un nom que personne n'avait posé dans
une scène.

Le système qui applique les filtres d'écran s'appelle `FiltreEcran` dans
`monde.tscn`. Le calque qu'il crée à l'exécution s'appelait… `FiltreEcran`
aussi.

Un contrôle écrit pour vérifier que **le filtre se lève** quand on retire le
masque ne pouvait donc pas passer : il cherchait par nom, trouvait le système —
qui ne disparaît jamais — et concluait que le calque était encore là. Et son
jumeau, celui qui vérifiait que le filtre est *posé*, était **vert pour la même
mauvaise raison** : il trouvait le système, filtre ou pas.

Un contrôle vert et un contrôle rouge, tous deux faux, sur la même ligne de
recherche.

> **Le nom d'un nœud créé à l'exécution est aussi une adresse.** Nommer un
> enfant comme son parent, ou comme le système qui le fabrique, crée un
> homonyme que personne ne verra dans l'arbre des scènes — il n'existe qu'en
> jeu.

Le calque s'appelle maintenant `CalqueFiltre`. La règle qui en sort tient en
une ligne : **un nœud créé par du code porte un nom qui dit ce qu'il est, pas
celui de qui l'a créé.**

## 55. Deux étapes qui se mordent la queue, et l'événement tombe dans le vide

Le plus grave de la soirée du 24/08/2026, et il ne se voyait pas à l'écran.

Le retour de Guillaume demande que « écouter » cesse d'être une action à
cliquer. L'étape qui l'attendait — « remonter » — a donc été rebranchée sur
`volant`, c'est-à-dire sur le fait de s'asseoir au poste de conduite. Ça se
tenait : l'objectif dit « retourner au camping-car », et on le franchit en y
retournant.

**Premier mur.** On ne monte dans une épave gelée que s'il y a un geste de
tableau de bord qui attend — le contrôleur le vérifie, et il a raison : sans ce
garde, la portière s'ouvrait dès le réveil sous le masque. Sauf que ce geste,
c'est *mettre le contact*, et il n'existait qu'à l'étape **suivante**. Il
fallait donc avoir remonté pour pouvoir remonter.

La suite qui joue l'a trouvé en une passe : soixante appuis à 0,7 m du volant,
et le jeu ne proposait rien.

**Second mur, et c'est celui qui compte.** Le contact rendu disponible une
étape plus tôt, la boucle s'ouvrait — mais le joueur assis pouvait alors mettre
le contact **avant** que `volant` n'ait été constaté. Le moteur prenait, son
événement tombait pendant une étape qui ne l'attendait pas, et l'étape suivante
l'attendait ensuite pour toujours.

Un camping-car qui tourne, une mission morte, et **rien à l'écran pour le
dire** : l'objectif affiché reste, le jeu répond aux commandes, tout va bien.

> **Un événement émis pendant une étape qui ne l'attend pas est perdu, et il ne
> revient jamais.** `mission.evenement()` compare au `valide_par` de l'étape
> COURANTE et rend `false` — personne ne le rattrape, personne ne le signale.
> Deux étapes qui se franchissent au même endroit, dans la même seconde, sont
> une course dont on perd une fois sur dix.

Les deux étapes n'en font plus qu'une. Le vrai remède n'est pas d'ordonner la
course : c'est de **ne pas en créer**. Une étape qui ne demande aucun geste que
la suivante ne demande déjà n'est pas une étape.

## 56. Une phrase rangée par clé d'étape devient muette quand l'étape disparaît

Trois d'un coup, le même soir, et le contrôle qui les surveillait était vert.

`marmonnements.json` range ce que Jesse dit **par clé d'étape**. La même soirée
a sorti deux étapes du déroulé — les corps et le pantalon quittent le suivi de
mission — et fusionné une troisième. Leurs phrases sont restées dans le
fichier, parfaitement valides, et plus rien ne pouvait les afficher.

Rien ne casse. Le JSON est bon, le fichier se charge, le compteur annonce
toujours « 89 phrases ». Elles ne sortent simplement plus jamais.

Le contrôle existait pourtant, et il était vert : il vérifiait que **chaque
temps fort a ses phrases**, c'est-à-dire qu'il partait des étapes pour aller
vers le fichier. Dans ce sens-là, une clé orpheline est invisible.

> **Un contrôle qui vérifie que tout ce qui est attendu existe ne dit rien de
> ce qui existe sans être attendu.** Les deux sens sont deux contrôles, et
> c'est celui qu'on n'écrit pas qui trouve les choses mortes.

Le second sens est écrit : aucune clé du fichier ne doit viser une étape
absente de toutes les missions. Il a coûté quinze lignes et il aurait crié
trois fois ce soir-là.

## 57. Une commande dont on masque la sortie ne dit plus qu'elle a échoué

Petit, bête, et il a failli coûter deux heures de travail.

Pour savoir si une suite rouge l'était **avant** la session, le réflexe est bon :
`git stash`, on relance, `git stash pop`. Écrit ainsi, en PowerShell :

```powershell
git stash pop -q 2>&1 | Out-Null
```

Le `pop` a échoué. Le `Out-Null` a mangé le message. Le `-q` a mangé le reste.
`git status` annonçait un dépôt **propre** — ce qui, juste après une session de
travail, aurait dû sauter aux yeux et n'y a pas sauté : c'est exactement ce
qu'on s'attend à voir après un stash réussi.

Le travail était intact dans `stash@{0}`, mais rien ne le disait, et un
`git commit` à cet instant aurait livré une version amputée.

> **On ne fait jamais taire une commande qui modifie l'état du dépôt.** Le
> silence d'un `git push`, d'un `git stash pop` ou d'un `git checkout` est
> indiscernable de leur succès. Rediriger leur sortie est bon pour un
> `git log` ; sur les autres, on lit le message.

Le corollaire tient au vérificateur : **après un stash pop, le dépôt doit être
SALE**. Un statut propre est la preuve que quelque chose a raté.

## 58. Une durée calculée de tête, et trois mètres qui n'existaient nulle part

Le retour de Guillaume ne donne qu'un seul chiffre, et il est central : « la
tractation complète doit bien prendre au moins 20 secondes ». C'est lui qui
répond au diagnostic du document — « la mission est trop rapide ».

Le calcul semblait simple. Un trajet de 10,7 m, une allure de 0,75 m/s, deux
pauses de 3,5 s : quatorze secondes de marche plus sept d'arrêt, vingt et une.
Confortablement au-dessus.

**La suite en a rendu seize.**

L'écart tient à une chose qu'aucune estimation ne pouvait contenir : le corps se
traîne **1,15 m derrière** Walter, et il est déposé dès qu'*il* arrive à la
portière. Walter s'arrête donc à près de quatre mètres du camping-car, et ces
quatre mètres ne sont dans aucun des deux nombres qu'on multiplie.

> **Une durée de gameplay ne se calcule pas, elle se joue et se chronomètre.**
> Le trajet réel n'est jamais la distance entre deux points : il y a la laisse
> d'un objet tiré, le rayon d'une zone d'arrivée, l'accélération au départ,
> l'angle qu'on ne prend pas parfaitement. Chacun coûte moins d'un mètre, et
> ensemble ils font un quart du total.

Le réglage tient maintenant en trois nombres — allure 0,55, pause 4 s, dépôt
2 m — et c'est la suite qui les a trouvés, pas le raisonnement. Elle imprime la
durée mesurée à chaque lancement, ce qui est la seule façon qu'elle ne se
reperde pas au prochain réglage de vitesse.

## 59. Un mécanisme nouveau ressemble toujours à un blocage

Trois fois le même motif, et il vaut d'être nommé une bonne fois.

La suite qui JOUE traverse la mission en marchant et en appuyant sur E. Chaque
fois qu'un geste d'un genre nouveau est arrivé, elle a crié — et le premier
réflexe a été, les trois fois, de chercher le bug dans le jeu :

- le **cadran du démarreur** : elle appuyait soixante fois sur un mini-jeu qui
  demande de *tenir* la touche et de presser au bon moment ;
- les **trois secondes de roulage** : elle arrivait sur la zone de sortie, s'y
  arrêtait, et appuyait sur une zone qui attendait justement qu'elle *roule* ;
- la **traction des corps** : elle appuyait soixante fois pendant que le jeu
  affichait, en toutes lettres, « Maintenir pour attraper les pieds ».

Dans les trois cas le jeu allait bien, et c'est le **pilote** qui ne savait pas
jouer.

> **Un test qui joue doit apprendre chaque verbe nouveau du jeu.** Tant qu'il
> ne connaît qu'« appuyer », tout ce qui n'est pas un appui lui ressemble à une
> porte fermée — et son rouge accuse le dernier endroit touché.

Ce qui a sauvé les trois fois : le message d'échec **imprime ce que le jeu
propose**. « Le jeu propose : "E Maintenir pour attraper les pieds" » ne
laisse aucun doute sur qui a tort. Un message qui aurait dit « l'étape ne se
franchit pas » aurait envoyé chercher dans la mission.
