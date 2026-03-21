extends Resource
class_name AbilityData

@export var id: StringName
@export var name: String = ""
@export_multiline var description: String = ""
@export var level: int = 1
@export var max_level: int = 3
@export var component_scene: PackedScene
@export var stats: Resource
