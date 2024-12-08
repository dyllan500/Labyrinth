class_name Player extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@export var TILE_SIZE = 16
@export var health : float = 100.0
@export var attack : float = 10.0
@export var inventory: Inventory

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
		var target_position = position + input_direction * TILE_SIZE
		var collision = move_and_collide(input_direction * TILE_SIZE)
		if not collision:
			position = target_position
		else:
			print("I collided with ", collision.get_collider().name)
			print(collision.get_collider_id())
			for i in map.get_children():
				if i.name == collision.get_collider().name and collision.get_collider().name.contains("Enemy"):
					i.health = i.health - attack
					print("hit")
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
					
	print(inventory.items)

func _physics_process(delta):
	move()
