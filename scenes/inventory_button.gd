extends Button
class_name Inventory_Button

@export var slot : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_play_gui_inventory_toggled() -> void:
	if slot < Inventory.items.size():
		icon = Inventory.items[slot].texture;
