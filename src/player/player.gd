class_name Player extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@export var TILE_SIZE = 16
@export var health : float = 100.0
@export var attack : float = 10.0
@export var inventory: Inventory
@export var turn: bool = true

func move():
	var input_direction = Vector2(0,0)
	if Input.is_action_just_pressed("right"):
		input_direction = Vector2(1,0)
	elif Input.is_action_just_pressed("left"):
		input_direction = Vector2(-1,0)
	elif Input.is_action_just_pressed("up"):
		input_direction = Vector2(0,-1)
	elif Input.is_action_just_pressed("down"):
		input_direction = Vector2(0,1)
		
	if input_direction != Vector2(0, 0):
		turn = false
		var move = true
		var target_position = position + input_direction * TILE_SIZE
		var tile_x = int(target_position.x / TILE_SIZE)
		var tile_y = int(target_position.y / TILE_SIZE)
		var collision = move_and_collide(target_position)
		for enemy in map.enemies:
			if target_position == enemy.position:
				enemy.health = enemy.health - attack
				print("hit_enemy")
				move = false
		if map.grid[tile_x][tile_y] == 2 and move:
				position = Vector2(tile_x * TILE_SIZE, tile_y * TILE_SIZE)
		if collision:
			for i in map.get_children():
				if i.name.contains("Door_Collide") and i.get_instance_id() == collision.get_collider_id():
					position = target_position
					map.new_map()
				if i.name.contains("ITEM") and i.get_instance_id() == collision.get_collider_id():
					position = target_position
					var item_name = i.name.split("_")[1]
					for item in map.items:
						if item.name == item_name:
							inventory.add_item(item)
					for child in map.get_children():
						if child.name.contains(i.name):
							map.remove_child(child)
	#print(inventory.items)
	
func _physics_process(delta):
	if(health <= 0):
		get_tree().quit()
	if turn:
		move()
