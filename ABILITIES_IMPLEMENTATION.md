Système de Capacités Modulaire, Évolutif et Composable (Godot 4)
Ce document décrit toutes les règles, structures, scènes, ressources, comportements et étapes d’évolution nécessaires pour implémenter le système de capacités du projet Pacman Roguelite.

L’agent IA doit respecter strictement toutes les instructions ci-dessous.

🧭 0. Évolutions & Suivi (intégré)
L’agent doit cocher chaque étape dans EVOLUTIONS.md et mettre à jour CHANGELOG.md à chaque milestone.

📄 EVOLUTIONS.md (à générer automatiquement)
Code

# EVOLUTIONS — Système de Capacités

## Étape 1 — Architecture

[ ] Créer AbilityComponent.gd (classe de base)
[ ] Créer AbilityData.gd (Resource)
[ ] Créer AbilityManager.gd (autoload)
[ ] Créer dossiers abilities/components et abilities/ability_list

## Étape 2 — Pool & Tirage

[ ] Implémenter le pool dynamique
[ ] Implémenter le tirage aléatoire de 3 capacités
[ ] Implémenter la suppression du pool après choix
[ ] Implémenter l’ajout du niveau suivant dans le pool

## Étape 3 — Capacités (scènes + scripts + ressources)

[ ] ExtraLife (3 niveaux)
[ ] Dash (3 niveaux)
[ ] SpeedBoost (3 niveaux)
[ ] Invisibility (3 niveaux)
[ ] ParalysisShot (3 niveaux)
[ ] DestructiveShot (3 niveaux)
[ ] Mines (3 niveaux + Mine.tscn)

## Étape 4 — Intégration Player

[ ] Ajouter AbilityManager au flux de mort
[ ] Ajouter l’UI de choix de capacités
[ ] Ajouter l’application des capacités au Player

## Étape 5 — Préparation Enemy

[ ] Vérifier compatibilité des capacités avec Enemy
[ ] Préparer l’ajout futur des capacités aux fantômes

## Étape 6 — Documentation

[ ] Documenter chaque capacité
[ ] Documenter AbilityManager
[ ] Documenter le système de niveaux
[ ] Générer diagrammes

## Étape 7 — CHANGELOG

[ ] Ajouter entrée v0.X pour l’ajout du système de capacités
🧾 CHANGELOG.md (instructions)
À chaque étape majeure, l’agent doit ajouter une entrée :

Code

## [v0.X.X] - YYYY-MM-DD

### Added

- Implémentation du système de capacités modulaires
- Ajout de AbilityManager
- Ajout de <capacité> (niveaux 1, 2, 3)
- Ajout du pool dynamique
- Ajout du tirage aléatoire
- Ajout du système d’upgrade
  🧱 1. Structure des dossiers (obligatoire)
  Code
  res://abilities/
  AbilityData.gd
  AbilityComponent.gd
  ability_list/
  <id>\_level_1.tres
  <id>\_level_2.tres
  <id>\_level_3.tres
  components/
  <id>Ability.tscn
  <id>Ability.gd
  AbilityManager.gd (autoload)
  🧬 2. Architecture des capacités
  2.1. AbilityComponent (base class)
  Chaque capacité est une scène contenant un script dérivé de AbilityComponent.gd.

Règles :
Fonctionne sur Player et Enemy

Activable/désactivable

Upgradable (niveau 1 → 2 → 3)

Applique des stats par niveau

Utilise has_method() pour interagir avec l’entité parent

Utilise des signaux pour remonter les événements

Peut contenir des nodes internes (Timer, Area2D, Sprite…)

2.2. AbilityData (Resource)
Chaque capacité possède 3 ressources :

Code
<id>\_level_1.tres
<id>\_level_2.tres
<id>\_level_3.tres
Chaque ressource contient :

id: String

name: String

description: String

level: int

max_level: int = 3

component_scene: PackedScene

stats: Resource

Règle Local to Scene
ON pour les stats dynamiques

OFF pour les stats statiques

🧩 3. Diagramme à suivre pour chaque capacité
Chaque capacité doit suivre ce diagramme standardisé :

Code
┌──────────────────────────────┐
│ Ability\_<Name> │
│ (Scene: <Name>Ability.tscn) │
└───────────────┬──────────────┘
│
▼
┌──────────────────────────────┐
│ AbilityComponent.gd │
│ - ability_id │
│ - level │
│ - max_level = 3 │
│ - stats_per_level[] │
│ │
│ + apply_level(level) │
│ + upgrade() │
│ + \_apply_stats(stats) │
└───────────────┬──────────────┘
│
▼
┌──────────────────────────────┐
│ Stats Resources (.tres) │
│ - <id>\_level_1.tres │
│ - <id>\_level_2.tres │
│ - <id>\_level_3.tres │
└──────────────────────────────┘
🎲 4. AbilityManager (autoload)
AbilityManager gère :

le pool de capacités disponibles

les niveaux acquis

le tirage aléatoire

l’application des capacités

la mise à jour du pool

4.1. Pool initial
Le pool doit contenir toutes les capacités niveau 1 :

ExtraLife (1)

Dash (1)

SpeedBoost (1)

Invisibility (1)

ParalysisShot (1)

DestructiveShot (1)

Mines (1)

4.2. Tirage aléatoire
À chaque mort :

tirer 3 capacités aléatoires dans le pool

les renvoyer à l’UI

4.3. Application d’une capacité
Quand le joueur choisit une capacité :

Si c’est un nouveau niveau 1
→ instancier la scène Ability
→ appliquer les stats du niveau 1
→ ajouter le composant au Player

Si c’est un niveau supérieur
→ appeler upgrade() sur le composant existant

Mettre à jour le pool :

retirer la capacité choisie

ajouter le niveau suivant si level < 3

sinon la retirer définitivement

💣 5. Capacités à implémenter (3 niveaux chacune)
5.1. ExtraLife
Niveau 1 : +1 vie

Niveau 2 : +2 vies

Niveau 3 : +3 vies

5.2. Dash
Niveau 1 : dash de 3 cases

Niveau 2 : dash de 4 cases

Niveau 3 : dash de 5 cases

5.3. SpeedBoost
Niveau 1 : +X% vitesse pendant 2 sec

Niveau 2 : +X% vitesse pendant 3 sec

Niveau 3 : +X% vitesse pendant 4 sec

5.4. Invisibility
Niveau 1 : 5 sec

Niveau 2 : 7 sec

Niveau 3 : 10 sec

5.5. ParalysisShot
Niveau 1 : immobilise 3 sec

Niveau 2 : immobilise 4 sec

Niveau 3 : immobilise 5 sec

5.6. DestructiveShot
Niveau 1 : renvoie au spawn

Niveau 2 : renvoie au spawn + stun 1 sec

Niveau 3 : renvoie au spawn + stun 2 sec

5.7. Mines
Niveau 1 : 1 mine max

Niveau 2 : 2 mines max

Niveau 3 : 3 mines max

Mines : règles supplémentaires
Le joueur peut poser une mine via input

La mine reste sur la map

Si un fantôme marche dessus :

explosion

fantôme renvoyé à son spawn

mine détruite

🧠 6. Règles techniques obligatoires
Les capacités doivent être des scènes (composition)

Les capacités doivent fonctionner sur Player et Enemy

Utiliser has_method() pour la sécurité

Utiliser Local to Scene pour les stats dynamiques

Communication via signaux

Tweens pour transitions UI

Aucun héritage profond

Code GDScript typé

🎯 Résultat final attendu
Un système complet, modulaire, scalable, permettant :

d’ajouter facilement de nouvelles capacités

d’ajouter des niveaux supplémentaires

d’ajouter des capacités aux ennemis

de faire évoluer le gameplay roguelite naturellement

Suivi complet du système de capacités modulaires (Godot 4)
Ce fichier liste toutes les étapes nécessaires à l’implémentation du système de capacités modulaires, évolutives et composables.
Chaque étape doit être cochée par l’agent IA lorsqu’elle est terminée.
Chaque milestone doit être reportée dans le CHANGELOG.md.

🧱 Étape 1 — Architecture de base
Création des fondations du système de capacités
Code
[ ] Créer AbilityComponent.gd (classe de base)
[ ] Créer AbilityData.gd (Resource)
[ ] Créer AbilityManager.gd (autoload)
[ ] Créer dossiers abilities/components et abilities/ability_list
[ ] Mettre à jour CHANGELOG.md : "Initialisation du système de capacités"
🎲 Étape 2 — Pool dynamique & Tirage aléatoire
Gestion du pool, tirage et suppression
Code
[ ] Implémenter le pool dynamique initial (toutes capacités niveau 1)
[ ] Implémenter le tirage aléatoire de 3 capacités
[ ] Implémenter la suppression du pool après choix
[ ] Implémenter l’ajout du niveau suivant dans le pool
[ ] Implémenter la disparition définitive après niveau 3
[ ] Mettre à jour CHANGELOG.md : "Implémentation du pool dynamique"
🧩 Étape 3 — Implémentation des capacités (scènes + scripts + ressources)
Chaque capacité doit suivre le diagramme standardisé :

Code
┌──────────────────────────────┐
│ Ability\_<Name> │
│ (Scene: <Name>Ability.tscn) │
└───────────────┬──────────────┘
│
▼
┌──────────────────────────────┐
│ AbilityComponent.gd │
│ - ability_id │
│ - level │
│ - max_level = 3 │
│ - stats_per_level[] │
│ │
│ + apply_level(level) │
│ + upgrade() │
│ + \_apply_stats(stats) │
└───────────────┬──────────────┘
│
▼
┌──────────────────────────────┐
│ Stats Resources (.tres) │
│ - <id>\_level_1.tres │
│ - <id>\_level_2.tres │
│ - <id>\_level_3.tres │
└──────────────────────────────┘
Capacités à implémenter (3 niveaux chacune)
Code
[ ] ExtraLife (3 niveaux)
[ ] Dash (3 niveaux)
[ ] SpeedBoost (3 niveaux)
[ ] Invisibility (3 niveaux)
[ ] ParalysisShot (3 niveaux)
[ ] DestructiveShot (3 niveaux)
[ ] Mines (3 niveaux + Mine.tscn)
[ ] Mettre à jour CHANGELOG.md : "Ajout des capacités de base"
🧍‍♂️ Étape 4 — Intégration Player
Intégration du système dans le flux de jeu du joueur
Code
[ ] Ajouter AbilityManager au flux de mort du Player
[ ] Ajouter l’UI de choix de capacités (3 choix)
[ ] Connecter l’UI à AbilityManager
[ ] Appliquer la capacité choisie au Player
[ ] Gérer l’upgrade si la capacité existe déjà
[ ] Mettre à jour CHANGELOG.md : "Intégration Player"
👻 Étape 5 — Préparation Enemy
Préparer l’architecture pour donner des capacités aux fantômes plus tard
Code
[ ] Vérifier compatibilité des capacités avec Enemy
[ ] Vérifier que les capacités ne dépendent pas de PlayerInput
[ ] Préparer un AbilityContainer sur Enemy
[ ] Tester l’ajout manuel d’une capacité sur un Enemy
[ ] Mettre à jour CHANGELOG.md : "Préparation Enemy"
📦 Étape 6 — Ressources & Stats
Gestion des ressources .tres et règles Local to Scene
Code
[ ] Créer toutes les ressources AbilityData (3 niveaux par capacité)
[ ] Créer toutes les ressources Stats (si séparées)
[ ] Vérifier Local to Scene = ON pour les stats dynamiques
[ ] Vérifier Local to Scene = OFF pour les stats statiques
[ ] Mettre à jour CHANGELOG.md : "Ajout des ressources AbilityData"
🧠 Étape 7 — Sécurité & Robustesse
Vérifications, signaux, interactions sûres
Code
[ ] Utiliser has_method() pour interactions entre composants
[ ] Ajouter signaux dans AbilityComponent si nécessaire
[ ] Vérifier compatibilité avec Entity (Player + Enemy)
[ ] Vérifier absence d’héritage profond
[ ] Mettre à jour CHANGELOG.md : "Sécurisation du système"
🎨 Étape 8 — UI & Tweens
Interface de choix des capacités
Code
[ ] Créer UI de choix (3 boutons)
[ ] Ajouter transitions via Tween (pas d’AnimationPlayer)
[ ] Ajouter affichage du niveau (ex: Dash Lv.2)
[ ] Ajouter description de la capacité
[ ] Mettre à jour CHANGELOG.md : "UI de choix de capacités"
🧪 Étape 9 — Tests & QA
Vérification complète du système
Code
[ ] Tester tirage aléatoire
[ ] Tester upgrade (1 → 2 → 3)
[ ] Tester disparition du pool
[ ] Tester respawn avec capacité active
[ ] Tester Mines sur un fantôme
[ ] Tester compatibilité Enemy
[ ] Mettre à jour CHANGELOG.md : "Tests & QA"
📚 Étape 10 — Documentation
Documentation complète du système
Code
[ ] Documenter AbilityManager
[ ] Documenter AbilityComponent
[ ] Documenter chaque capacité
[ ] Documenter le système de niveaux
[ ] Ajouter diagramme global dans README
[ ] Mettre à jour CHANGELOG.md : "Documentation complète"
🏁 Étape 11 — Finalisation
Dernière étape
Code
[ ] Vérifier que toutes les cases sont cochées
[ ] Vérifier que CHANGELOG.md est complet
[ ] Vérifier que toutes les capacités fonctionnent
[ ] Commit final : "Système de capacités complet"
Lecture + Exécution complète du système de capacités
Lis entièrement le fichier suivant :

Code
ABILITIES_IMPLEMENTATION.md
Ce fichier contient toutes les instructions officielles pour implémenter le système de capacités modulaires du projet Pacman Roguelite.

🎯 Ta mission
Lire et analyser le fichier ABILITIES_IMPLEMENTATION.md

Exécuter toutes les étapes, dans l’ordre, en respectant strictement :

l’architecture Entity → Player/Enemy

la composition via scènes de capacités

le système de niveaux (1 → 2 → 3)

le pool dynamique

le tirage aléatoire

la suppression du pool après choix

l’ajout du niveau suivant

la disparition définitive après niveau 3

Créer tous les fichiers nécessaires :

scènes de capacités

scripts AbilityComponent dérivés

ressources AbilityData (3 niveaux par capacité)

AbilityManager (autoload)

Mine.tscn pour la capacité Mines

Mettre à jour EVOLUTIONS.md en cochant chaque étape

Mettre à jour CHANGELOG.md à chaque milestone

Documenter chaque capacité et chaque système

Respecter toutes les règles techniques du fichier MD :

composition obligatoire

Local to Scene

has_method()

signaux

Tweens

GDScript typé

aucune logique métier dans Player/Enemy

📌 Important
Ne jamais inventer de logique non décrite dans le fichier MD.

Ne jamais modifier le gameplay existant sans justification.

Toujours respecter la modularité et la compatibilité Player/Enemy.

Toujours suivre les diagrammes fournis dans le fichier MD.

🏁 Résultat attendu
À la fin de l’exécution :

Le système de capacités doit être entièrement fonctionnel

Toutes les capacités doivent exister en 3 niveaux

Le pool dynamique doit fonctionner

Le tirage aléatoire doit fonctionner

Le Player doit pouvoir choisir une capacité après la mort

Le Player doit respawn avec la capacité active

Le système doit être prêt pour donner des capacités aux fantômes plus tard

EVOLUTIONS.md doit être entièrement coché

CHANGELOG.md doit être à jour
