# Refactorisation Architecturale : Séparation SceneManager / GameManager

## 🎯 **Objectif de la refactorisation**

Séparer les responsabilités entre deux gestionnaires spécialisés pour une architecture plus modulaire et maintenable :

- **SceneManager** : Gestion PURE des scènes (chargement/déchargement uniquement)
- **GameManager** : Gestion PURE de la logique de jeu (score, vies, niveaux)

## 🏗️ **Architecture AVANT (Monolithique)**

```
SceneManager.gd (163 lignes)
├── Gestion des scènes
├── Gestion du score
├── Gestion des vies
├── Gestion des niveaux
├── Logique de game over
├── Logique de victoire
└── Connexions de signaux mixtes
```

**PROBLÈMES :**

- ❌ **Responsabilités multiples** : Un seul script fait tout
- ❌ **Couplage fort** : Logique métier liée aux scènes
- ❌ **Difficile à tester** : Tout est mélangé
- ❌ **Difficile à maintenir** : Changements impactent tout
- ❌ **Réutilisabilité limitée** : Impossible de réutiliser séparément

## 🎯 **Architecture APRÈS (Modulaire)**

### **SceneManagerNew.gd** - Responsabilité unique

```
SceneManager (Pure)
├── change_scene(SceneType)
├── change_scene_by_path(String)
├── _cleanup_current_scene()
├── _load_new_scene(String)
├── get_current_scene()
├── goto_main_menu()
└── goto_game()
```

**RESPONSABILITÉS :**

- ✅ **Chargement/déchargement** de scènes uniquement
- ✅ **Gestion des transitions** propres
- ✅ **Mapping SceneType → .tscn**
- ✅ **Signaux techniques** (scene_changed, scene_change_failed)

### **GameManager.gd** - Logique métier pure

```
GameManager (Pure)
├── start_new_game()
├── add_score(int)
├── player_died()
├── level_completed()
├── trigger_game_over()
├── trigger_game_won()
└── Gestion d'état (MENU/PLAYING/PAUSED/GAME_OVER/VICTORY)
```

**RESPONSABILITÉS :**

- ✅ **Données persistantes** (score, vies, niveau)
- ✅ **Logique de jeu** (game over, victoire, progression)
- ✅ **États de jeu** (menu, playing, paused, etc.)
- ✅ **Signaux métier** (score_changed, lives_changed, game_over)

## 📡 **Communication Inter-Modules**

### **GameManager → SceneManager**

```gdscript
# GameManager demande des changements de scène
SceneManager.goto_main_menu()
SceneManager.goto_game()
```

### **SceneManager → GameManager**

```gdscript
# SceneManager informe des changements
SceneManager.scene_changed.connect(GameManager._on_scene_changed)
```

### **Scènes de jeu → GameManager**

```gdscript
# Les scènes communiquent avec la logique métier
GameManager.add_score(10)
GameManager.player_died()
GameManager.level_completed()
```

## 🎮 **Configuration AutoLoad**

**project.godot :**

```ini
[autoload]
GameConstants="*res://GameConstants.gd"
SceneManager="*res://scenes/SceneManagerNew.gd"  # Gestion scènes
GameManager="*res://scenes/GameManager.gd"       # Logique jeu
```

**AVANTAGES :**

- ✅ **Deux singletons spécialisés** au lieu d'un monolithe
- ✅ **Accessibilité globale** pour chaque responsabilité
- ✅ **Initialisation automatique** des deux systèmes

## 🔄 **Flux d'exécution typique**

### **Démarrage d'une nouvelle partie :**

```
1. Menu → bouton "Nouvelle Partie"
2. GameManager.start_new_game()
3. GameManager → SceneManager.goto_game()
4. SceneManager.change_scene(GAME_LEVEL)
5. SceneManager.scene_changed → GameManager._on_scene_changed()
```

### **Mort du joueur :**

```
1. Scène de jeu détecte collision
2. GameManager.player_died()
3. GameManager gère logique vies
4. Si game over → GameManager.trigger_game_over()
5. GameManager → SceneManager.goto_main_menu()
```

### **Niveau terminé :**

```
1. Scène de jeu détecte tous dots collectés
2. GameManager.level_completed()
3. GameManager gère progression
4. Si victoire → GameManager.trigger_game_won()
5. Sinon → continuer niveau suivant
```

## 📊 **Métriques d'amélioration**

### **Complexité réduite :**

- **SceneManager** : 163 → 89 lignes (**-45%**)
- **GameManager** : Nouveau, focalisé (85 lignes)
- **Total** : Même fonctionnalité, code plus clair

### **Couplage réduit :**

- **Avant** : 1 classe monolithique
- **Après** : 2 classes spécialisées avec interfaces claires

### **Responsabilités claires :**

- **SceneManager** : 0% logique métier (100% technique)
- **GameManager** : 0% gestion scènes (100% logique)

## 🧪 **Avantages pour les tests**

### **Tests unitaires possibles :**

```gdscript
# Test du GameManager sans scènes
func test_score_calculation():
    var gm = GameManager.new()
    gm.add_score(100)
    assert(gm.get_player_score() == 100)

# Test du SceneManager sans logique
func test_scene_loading():
    var sm = SceneManager.new()
    sm.change_scene(SceneType.MAIN_MENU)
    assert(sm.get_current_scene_type() == SceneType.MAIN_MENU)
```

### **Mocking facilité :**

- GameManager peut être testé avec un SceneManager mocké
- SceneManager peut être testé sans GameManager

## 🔮 **Extensibilité future**

### **Ajouts faciles dans SceneManager :**

- Nouveaux types de scènes (Settings, Credits)
- Transitions animées
- Préchargement de scènes
- Cache de scènes

### **Ajouts faciles dans GameManager :**

- Système de sauvegarde
- Achievements
- Statistiques avancées
- Modes de jeu alternatifs

## 🎉 **Bénéfices obtenus**

### **📐 Architecture**

- ✅ **Single Responsibility Principle** respecté
- ✅ **Séparation des préoccupations** claire
- ✅ **Couplage faible** entre modules
- ✅ **Cohésion forte** dans chaque module

### **🔧 Maintenabilité**

- ✅ **Modifications isolées** : Changer scènes n'affecte pas logique
- ✅ **Debugging simplifié** : Problème technique vs métier
- ✅ **Code autodocumenté** : Responsabilités évidentes

### **🚀 Performance développeur**

- ✅ **Développement parallèle** possible
- ✅ **Tests unitaires** facilités
- ✅ **Réutilisabilité** des modules

Cette refactorisation transforme une architecture monolithique en une architecture modulaire professionnelle, suivant les meilleures pratiques du développement logiciel ! 🏗️✨
