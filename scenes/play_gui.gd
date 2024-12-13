extends Control

signal inventory_toggled
signal paused_toggled
signal refresh
@export var pressed_slot = -1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InventoryUI/InventoryRows/Row1/Button1.slot = 0;
	$InventoryUI/InventoryRows/Row1/Button2.slot = 1;
	$InventoryUI/InventoryRows/Row1/Button3.slot = 2;
	$InventoryUI/InventoryRows/Row1/Button4.slot = 3;
	$InventoryUI/InventoryRows/Row1/Button5.slot = 4;
	$InventoryUI/InventoryRows/Row2/Button1.slot = 5;
	$InventoryUI/InventoryRows/Row2/Button2.slot = 6;
	$InventoryUI/InventoryRows/Row2/Button3.slot = 7;
	$InventoryUI/InventoryRows/Row2/Button4.slot = 8;
	$InventoryUI/InventoryRows/Row2/Button5.slot = 9;
	$InventoryUI/InventoryRows/Row3/Button1.slot = 10;
	$InventoryUI/InventoryRows/Row3/Button2.slot = 11;
	$InventoryUI/InventoryRows/Row3/Button3.slot = 12;
	$InventoryUI/InventoryRows/Row3/Button4.slot = 13;
	$InventoryUI/InventoryRows/Row3/Button5.slot = 14;
	$InventoryUI/InventoryRows/Row4/Button1.slot = 15;
	$InventoryUI/InventoryRows/Row4/Button2.slot = 16;
	$InventoryUI/InventoryRows/Row4/Button3.slot = 17;
	$InventoryUI/InventoryRows/Row4/Button4.slot = 18;
	$InventoryUI/InventoryRows/Row4/Button5.slot = 19;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_player_inventory_toggled() -> void:
	$InventoryUI.visible = !$InventoryUI.visible;
	$Blur.visible = $InventoryUI.visible;
	inventory_toggled.emit();

func pause_toggled() -> void:
	$Blur.visible = $InventoryUI.visible;
	paused_toggled.emit();

func _on_button_button_clicked(slot: int):
	pressed_slot = slot

func _on_player_on_delete():
	refresh.emit();
