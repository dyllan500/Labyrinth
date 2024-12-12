extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_inventory_button_hover(slot: int):
	if slot < Inventory.items.size():
		$ItemName.text    = Inventory.items[slot].display_name;
		if Inventory.items[slot].reveal:
			$Description.text = Inventory.items[slot].description;
			if Inventory.items[slot].damage > 0:
				$Damage_Heal.text = "Damage: " + str(Inventory.items[slot].damage);
			else:
				$Damage_Heal.text = "Heal: " + str(Inventory.items[slot].heal);
		else:
			$Description.text = "Unknown"
			$Damage_Heal.text = "Unknown"
	else:
		$ItemName.text    = "None";
		$Description.text = "No item selected."
		$Damage_Heal.text = "None"
