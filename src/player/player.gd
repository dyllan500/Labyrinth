class_name Player extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@onready var gui: Control = get_node("/root/Game/PlayGui")
@export var TILE_SIZE = 16
@export var health : float = 100.0
@export var inventory: Inventory
@export var turn: bool = true
var paused: bool = false
var inventory_screen: bool = false
var pressed_slot = -1;
var equiped : Inventory_Item = null

signal inventory_toggled
signal paused_toggled
signal on_delete

func start_equipped():
	equiped = inventory.items[0]

func take_damage(damage):
	health = health - damage
	if (health <= 0):
		pass #END game

func heal(add):
	health = health + add
	if (health >= 100):
		health = 100

func player_turn():
	var input_direction = Vector2(0,0)
	if Input.is_action_just_pressed("right"):
		input_direction = Vector2(1,0)
	elif Input.is_action_just_pressed("left"):
		input_direction = Vector2(-1,0)
	elif Input.is_action_just_pressed("up"):
		input_direction = Vector2(0,-1)
	elif Input.is_action_just_pressed("down"):
		input_direction = Vector2(0,1)
	if   Input.is_action_just_pressed("ui_inventory_toggle"):
		if not paused:
			inventory_toggled.emit()
			inventory_screen = not inventory_screen
	if   Input.is_action_just_pressed("pause"):
		if not inventory_screen:
			paused_toggled.emit()
			paused = not paused
	if   Input.is_action_just_pressed("equip"):
		if inventory_screen:
			if pressed_slot >= 0 and pressed_slot < inventory.items.size():
				if inventory.items[pressed_slot].name == "sword":
					equiped = inventory.items[pressed_slot]
				elif inventory.items[pressed_slot].name == "potion":
					use_potion()
				elif inventory.items[pressed_slot].name == "food":
					use_food()
	if   Input.is_action_just_pressed("delete"):
		if inventory_screen:
			if pressed_slot >= 0 and pressed_slot < inventory.items.size():
				inventory.remove_item(inventory.items[pressed_slot])
				on_delete.emit()
		
	if input_direction != Vector2(0, 0) and not paused and not inventory_screen:
		turn = false
		var move = true
		var target_position = map.get_floor(position + input_direction * TILE_SIZE)
		if target_position == Vector2(0,0) or target_position == Vector2(-1,-1):
			move = false
		for enemy in map.enemies:
			if target_position == enemy.position:
				enemy.take_damage(equiped.damage)
				gui.add_line("Player hit emeny for " + str(equiped.damage))
				move = false
		for i in map.get_children():
			if map.get_collison(target_position, i.position):
				if i.name.contains("Door_Node"):
					if not map.boss_level:
						map.new_map()
					else:
						if map.enemies.size() <= 0:
							map.new_map()
							map.boss_level = false
				if i.name.contains("ITEM"):
					var item_name = i.name.split("_")[1]
					for item in map.items:
						if item.display_name == item_name:
							if(inventory.add_item(item)):
								for child in map.get_children():
									if child.name.contains(i.name):
										map.remove_child(child)
		if move:
			position = target_position
			print(target_position)

func use_potion():
	var potion = inventory.items[pressed_slot]
	if potion.heal > 0:
		heal(potion.heal)
		gui.add_line("Player healed for " + str(potion.heal))
	else:
		take_damage(potion.damage)
		gui.add_line("Player damaged for " + str(potion.damage))
	inventory.remove_item(inventory.items[pressed_slot])
	on_delete.emit()

func use_food():
	var food = inventory.items[pressed_slot]
	heal(food.heal)
	gui.add_line("Player healed for " + str(food.heal))
	inventory.remove_item(inventory.items[pressed_slot])
	on_delete.emit()

func update_hearts():
	var hearts = gui.get_node("TopLeft/HealthBar")
	var visible_hearts = health / 10
	for i in range(10):
		if i < visible_hearts:
			hearts.get_child(i).visible = true
		else:
			hearts.get_child(i).visible = false

func _physics_process(_delta):
	if map.loading_map:
		position = map.player_position
		map.loading_map = false
	else:
		if turn:
			player_turn()
	if inventory_screen:
		if gui.pressed_slot != -1:
			pressed_slot = gui.pressed_slot
	else:
		pressed_slot = -1
	update_hearts()

func _on_paused_toggled() -> void:
	pass # Replace with function body.
