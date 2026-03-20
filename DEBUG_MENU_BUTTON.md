# 🏠 AJOUT BOUTON RETOUR MENU - DEBUG PANEL

## ✅ FONCTIONNALITÉ AJOUTÉE

**Nouveau bouton dans le panneau DEBUG LEVELS :**

- 🏠 **RETOUR MENU** - Permet de quitter le jeu en cours et revenir à l'écran d'accueil

## 🛠️ MODIFICATIONS APPLIQUÉES

### 1. Ajout du bouton dans `create_debug_panel()`

```gdscript
# Nouveau bouton après le bouton RESET
var menu_button = Button.new()
menu_button.text = "🏠 RETOUR MENU"
menu_button.custom_minimum_size = Vector2(100, 30)
menu_button.pressed.connect(_on_debug_menu_button_pressed)

# Style vert pour bien le distinguer
var menu_style = StyleBoxFlat.new()
menu_style.bg_color = Color(0.1, 0.3, 0.1, 0.9)  # Vert foncé
menu_button.add_theme_color_override("font_color", Color.LIGHT_GREEN)
```

### 2. Fonction de gestion du clic

```gdscript
func _on_debug_menu_button_pressed():
    # Utilise SceneManager.return_to_menu() si disponible
    # Sinon fallback vers changement direct de scène
    scene_manager.return_to_menu()
```

## 🎮 UTILISATION

**Dans le jeu :**

1. Appuyer sur **F1** pour activer le debug
2. Le panneau "🔧 DEBUG LEVELS" apparaît à gauche
3. Cliquer sur **🏠 RETOUR MENU** pour quitter
4. Retour automatique à l'écran d'accueil

## 📊 STRUCTURE DU PANNEAU DEBUG

```
🔧 DEBUG LEVELS
├── LV1  LV2
├── LV3  LV4
├── 🔄 RESET
├── 🏠 RETOUR MENU  ← NOUVEAU
└── F1: Toggle Debug
```

## 🎯 AVANTAGES

- ✅ **Sortie rapide** du jeu en cours
- ✅ **Interface cohérente** avec le style du panneau debug
- ✅ **Icône claire** 🏠 pour identifier la fonction
- ✅ **Couleur verte** pour la distinguer des autres boutons
- ✅ **Gestion d'erreur** avec fallback si SceneManager indisponible

## 🚀 PRÊT À TESTER

Le bouton est maintenant disponible dans le panneau debug !

**Test :**

1. Lancer le jeu (START GAME)
2. Appuyer sur **F1**
3. Cliquer sur **🏠 RETOUR MENU**
4. Vérifier le retour à l'écran d'accueil

---

**Fonctionnalité ajoutée avec succès !** 🎉
