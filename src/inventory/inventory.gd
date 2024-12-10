extends Resource
class_name Inventory

signal item_added(item)
signal item_removed(item)

@export var items : Array = [Inventory_Item]

@export var max_size: int = 20

func _ready():
	pass

func add_item(item: Inventory_Item) -> bool:
	if items.size() < max_size:
		items.append(item)
		emit_signal("item_added", item)
		return true
	print("Inventory Full")
	return false

func remove_item(item: Inventory_Item) -> bool:
	if item in items:
		items.erase(item)
		emit_signal("item_removed", item)
		return true
	return false

func has_item(item: Inventory_Item) -> bool:
	return items.has(item)
