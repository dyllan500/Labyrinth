class_name Player extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@export var TILE_SIZE = 16
@export var health : float = 100.0
@export var attack : float = 10.0


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
			if collision.get_collider().name.contains("Enemy"):
					for i in map.get_children():
						if i.name == collision.get_collider().name:
							i.health = i.health - attack
							print("hit")

func _physics_process(delta):
	move()
