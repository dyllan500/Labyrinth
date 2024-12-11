extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_inventory_button_hover(slot: int):
	if slot < Inventory.items.size():
		$ItemName.text    = Inventory.items[slot].display_name;
		$Description.text = Inventory.items[slot].description;
	else:
		$ItemName.text    = "None";
		$Description.text = "No item selected."
