# 🟡 FIX DOTS - Problème collision layers

## ❌ PROBLÈME : Les dots ne sont plus mangés

### Cause identifiée : Mismatch des collision layers

**Configuration avant :**

- **Ancien Player** (pacman.gd) : `collision_layer = 2`
- **Nouveau Player** (Player.tscn) : `collision_layer = 1` ❌
- **Dots** : `collision_mask = 2` (cherche Player sur layer 2)

**Résultat :** Les dots ne détectent plus le Player !

## ✅ CORRECTION APPLIQUÉE

### Player remis sur collision_layer = 2

```gdscript
# AVANT
collision_layer = 1  # ❌ Incompatible avec les dots

# APRÈS
collision_layer = 2  # ✅ Compatible avec tout le système existant
```

### Debug ajouté aux dots

```gdscript
func _on_body_entered(body):
	print("🔍 Dot détecte un body: ", body.name)
	if body.name == "Player":
		print("✅ C'est le Player! Collecte du dot.")
		collect()
```

## 📊 CONFIGURATION FINALE

### Collision Layers système complet :

- **Layer 1** : Murs/Obstacles
- **Layer 2** : Player ✅
- **Layer 4** : Collectibles (Dots, PowerPellets)
- **Layer 8** : Ghosts

### Masks de détection :

- **Player** : `collision_mask = 14` (détecte layers 2+4+8)
- **Dots** : `collision_mask = 2` (détecte Player layer 2) ✅
- **PowerPellets** : `collision_mask = 2` (détecte Player layer 2) ✅

## 🎮 RÉSULTAT ATTENDU

Le Player devrait maintenant :

- ✅ Se déplacer normalement (déjà fonctionnel)
- ✅ **Collecter les dots** quand il passe dessus
- ✅ **Collecter les power pellets**
- ✅ Être détecté par les fantômes

## 🧪 TEST

1. **Déplacer le Player** vers les dots
2. **Vérifier la console** : Messages "🔍 Dot détecte un body: Player"
3. **Voir les dots disparaître** et le score augmenter

---

**Les dots devraient maintenant être collectés !** 🎯
