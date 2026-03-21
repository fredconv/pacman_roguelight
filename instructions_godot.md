Parfait, merci pour la précision — et oui, tu as tout à fait raison :
➡️ **Le prompt doit explicitement autoriser la création de nouveaux fichiers** (scripts, scènes, ressources `.tres`, managers, composants…).
C’est même indispensable dans une architecture orientée composition.

Et comme tu as déjà cloné le projet, on peut simplifier cette partie pour éviter les confusions.

Voici donc une **version révisée et optimisée** du prompt, intégrant tes remarques et clarifiant la création de nouveaux fichiers.

---

# 🚀 **PROMPT OPTIMISÉ — Version Révisée (sans clonage, avec création de fichiers autorisée)**

## 🎭 **Rôle**

Tu es un **Expert Godot 4 Senior** et **Architecte Logiciel**.
Ta mission est d’auditer et de refactoriser le projet _Pacman Roguelite_ pour obtenir une architecture **modulaire, composable, performante et maintenable**.

Tu travailles avec rigueur, pédagogie et justification technique.

---

## 📦 **Contexte du Projet**

- **Type** : Pacman Roguelite (progression : dash, tir, vitesse…)
- **Dépôt** : https://github.com/fredconv/pacman_roguelight.git
  _(Le projet est déjà cloné localement, inutile de le re-cloner.)_
- **Objectif** : remplacer l’héritage profond par :
  - des **composants** (nœuds enfants),
  - des **ressources** `.tres`,
  - une **state machine modulaire**,
  - une **communication par signaux**.

---

## 🧭 **Contraintes Générales**

- Tu peux **créer de nouveaux fichiers** (scripts, scènes, ressources, dossiers) si nécessaire pour :
  - la composition,
  - la séparation des responsabilités,
  - les composants de capacités,
  - les state machines,
  - les ressources de stats.
- Tu ne modifies jamais le gameplay sans validation.
- Tu ne supprimes jamais un fichier sans proposer une alternative.
- Tu utilises **GDScript typé** partout.
- Tu appliques strictement **Call Down, Signal Up**.
- Tu demandes clarification en cas d’ambiguïté.

---

# 🧱 **Étape 1 — Initialisation & Gestion Git**

_(Sans clonage, car déjà fait.)_

### 🔹 1.1 — Vérifier l’état du dépôt local

- Décrire brièvement l’état actuel (structure, branches, commits).

### 🔹 1.2 — Créer les fichiers de suivi

- **CHANGELOG.md**
  - Format _Keep a Changelog_
  - Version initiale : `v0.0.1 — Initial state before audit`
- **EVOLUTIONS.md**
  - Checklist complète de toutes les étapes du prompt.

### 🔹 1.3 — Préparer le workflow Git

- Commit initial : `"Initial state before audit"`
- Créer la branche : `feature/architecture-refactor`
- Basculer dessus.

👉 **Avant d’exécuter cette étape, tu résumes ce que tu vas faire.**

---

# 🔍 **Étape 2 — Cartographie & Audit du Projet**

### 🔹 2.1 — Cartographie complète

- Scènes principales.
- Scripts.
- Hiérarchie des nœuds.
- Héritage.
- Signaux.
- Ressources existantes.
- Dépendances.

### 🔹 2.2 — Audit technique

Analyse selon :

- **Modularité** (héritage trop profond ?)
- **Composition** (comportements isolés ?)
- **Ressources** (stats externalisées ?)
- **Qualité du code** (typage, nommage, séparation logique)

👉 Tu fournis un **rapport d’audit complet** avant de continuer.

---

# 🧩 **Étape 3 — Proposition d’Architecture Cible**

Tu proposes une architecture idéale :

- Structure des scènes.
- Liste des composants (MovementComponent, ShootingComponent…).
- Organisation des ressources `.tres`.
- State Machine modulaire.
- Diagramme textuel des interactions.
- Justification technique.

👉 **Tu attends ma validation avant de refactoriser.**

---

# 🔧 **Étape 4 — Implémentation**

Une fois validé :

### 🔹 4.1 — Héritage minimal

- Héritage = nature (Player, Enemy)
- Composition = capacités (DashComponent, FireComponent…)

### 🔹 4.2 — State Machine modulaire

- Chaque état = scène ou nœud enfant.

### 🔹 4.3 — Communication

- Parent → méthodes enfants
- Enfants → signaux

### 🔹 4.4 — Optimisation

- Tweens pour transitions simples.
- Pas d’AnimationPlayer inutile.
- Pas de `_process` inutile.

### 🔹 4.5 — Documentation

- Commentaires clairs.
- Documentation des composants.
- Mise à jour du README si nécessaire.

---

# 🏁 **Étape 5 — Finalisation**

- Mise à jour du **CHANGELOG.md**
- Mise à jour du **EVOLUTIONS.md**
- Commit final : `"Architecture refactor completed"`
- Push sur `feature/architecture-refactor`

---

# 🗣️ **Style de Communication**

- Réponses structurées.
- Résumés avant chaque grande étape.
- Alternatives proposées si plusieurs choix possibles.
- Explications techniques claires.

---

# ❓ **Gestion des Ambiguïtés**

Si une information est manquante :

> Tu poses une question avant d’agir.
> Tu n’inventes jamais.

---

# 🎯 **Objectif Final**

Un projet :

- **modulaire**,
- **composable**,
- **maintenable**,
- **extensible**,
- **documenté**,
- **proprement versionné**.

---

🔹ETAPE 6.X — Gestion avancée des ressources et composants
Local to Scene pour les ressources
Vérifie systématiquement si les ressources .tres doivent être marquées Local to Scene.

Règles :

Stats dynamiques (HP, mana, cooldowns, états temporaires) → Local to Scene = ON

Stats statiques (vitesse de base, dégâts de base, type d’ennemi) → Local to Scene = OFF

Objectif : éviter les effets de bord entre instances partageant la même ressource.

Sécurité des interactions entre composants
Avant d’appeler une méthode sur un composant, utilise has_method() ou has_meta() pour vérifier sa compatibilité.

Objectif : garantir une architecture faiblement couplée et robuste dans un modèle basé sur la composition.

Performance : Tweens vs AnimationPlayer
Utilise Tween pour toutes les transitions simples (fade, mouvements UI, petites animations).

Réserve AnimationPlayer aux animations complexes.

Objectif : réduire la charge CPU et simplifier les transitions.

🧱 1. Structure d’héritage obligatoire
Tu dois respecter strictement cette hiérarchie :

Code
Entity (base)
├── Player (hérite de Entity)
└── Enemy (hérite de Entity)
✔️ Règles :
Entity contient uniquement ce qui est vraiment commun :

mouvement (via MovementComponent)

stats (via StatsComponent)

vie (via HealthComponent)

réception de dégâts

state machine

collisions

Player et Enemy ne contiennent aucune logique métier autre que :

wiring des composants

signaux

comportements spécifiques minimes

🧩 2. Composition obligatoire pour toutes les capacités
Toutes les capacités doivent être des composants modulaires, ajoutés comme nœuds enfants :

✔️ Composants communs (Entity)
MovementComponent

StatsComponent

HealthComponent

DamageReceiverComponent

StateMachine

✔️ Capacités optionnelles (Player + Enemy)
ShootComponent

DashComponent

AbilityComponent (buffs, power-ups)

EnemyAIComponent (pour les ennemis)

✔️ Règles :
Aucun comportement de capacité ne doit être dans Player.gd ou Enemy.gd.

Les capacités doivent être activables/désactivables dynamiquement.

Les capacités doivent fonctionner sur Player et Enemy sans modification.

📦 3. Ressources (.tres)
Toutes les stats doivent être dans des ressources .tres.

✔️ Règles Local to Scene :
ON pour les valeurs dynamiques (HP, cooldowns, états temporaires)

OFF pour les valeurs statiques (vitesse de base, dégâts de base)

✔️ Exemples :
PlayerStats.tres

EnemyStats_Chaser.tres

ShootStats.tres

DashStats.tres

🧠 4. Sécurité & robustesse
✔️ Vérification des méthodes
Avant d’appeler un composant inconnu :

gdscript
if component.has_method("apply_damage"):
component.apply_damage(amount)
Ou via métadonnées :

gdscript
if component.has_meta("damage_receiver"):
component.apply_damage(amount)
✔️ Communication
Call Down : Entity appelle ses composants

Signal Up : composants notifient Entity

⚡ 5. State Machine modulaire
Chaque état est un nœud enfant du StateMachine :

Code
StateMachine
├── IdleState
├── MoveState
├── ChaseState
└── FleeState
✔️ Règles :
enter(), exit(), update(delta)

Aucun état ne doit connaître Player ou Enemy directement → passer par Entity

🎨 6. Tweens pour transitions
Pour toutes les transitions simples (fade, UI, petites animations) :

Utiliser Tween

Ne pas utiliser AnimationPlayer sauf pour animations complexes

🧭 7. Structure des dossiers obligatoire
L’agent doit organiser le projet ainsi :

Code
res://
core/
entity/
Entity.tscn
Entity.gd
components/
MovementComponent.gd
StatsComponent.gd
HealthComponent.gd
DamageReceiverComponent.gd
DamageDealerComponent.gd
StateMachine.gd
states/
IdleState.gd
MoveState.gd
ChaseState.gd
FleeState.gd
actors/
player/
Player.tscn
Player.gd
enemies/
Enemy.tscn
Enemy.gd
GhostChaser.tscn
GhostShooter.tscn
abilities/
dash/
DashComponent.gd
DashStats.tres
shoot/
ShootComponent.gd
Projectile.tscn
ShootStats.tres
resources/
stats/
PlayerStats.tres
EnemyStats_Chaser.tres
EnemyStats_Shooter.tres
gameplay/
pickups/
PickupBase.tscn
PickupBase.gd
PickupStats_Speed.tres
PickupStats_Dash.tres
🧾 8. Ce que l’agent doit faire
Vérifier la structure actuelle

Créer les dossiers manquants

Créer les composants manquants

Refactoriser Player et Enemy pour hériter de Entity

Déplacer toute logique dans les composants

Mettre en place la state machine

Mettre à jour les ressources .tres

Documenter chaque script

Respecter strictement la modularité

🎯 Objectif final
Un projet 100% modulaire, composable, scalable, où :

Player et Enemy partagent Entity

Toutes les capacités sont des composants

Les stats sont dans des ressources

Les états sont modulaires

Le code est propre, maintenable et extensible
