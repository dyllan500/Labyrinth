extends Resource
class_name Inventory

static var items : Array = []

@export var max_size: int = 20

func _ready():
	pass

func add_item(item: Inventory_Item) -> bool:
	if items.size() < max_size:
		items.append(item)
		return true
	print("Inventory Full")
	return false

func remove_item(item: Inventory_Item) -> bool:
	if item in items:
		items.erase(item)
		return true
	return false

func has_item(item: Inventory_Item) -> bool:
	return items.has(item)
