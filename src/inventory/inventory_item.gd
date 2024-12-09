extends Resource

class_name Inventory_Item

@export var name: String = ""
@export var display_name: String = ""
@export var texture: Texture2D
@export var damage: int
@export var heal: int
@export var duration: int
@export var type: String = ""
@export var description: String = ""
@export var reveal: bool = false

var prefixes = ["Aqua", "Ignis", "Terra", "Lux", "Nox", "Vita", "Mortis"]
var roots = ["furo", "cael", "ventus", "lumen", "umbr", "sanct", "arc"]
var suffixes = ["ium", "or", "alis", "is", "us", "a", "um"]

func generate_latin_name() -> String:
	var prefix = prefixes[randi() % prefixes.size()]
	var root = roots[randi() % roots.size()]
	var suffix = suffixes[randi() % suffixes.size()]
	return prefix + root + suffix
