class_name Player extends CharacterBody2D

@export var TILE_SIZE = 8

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	position += input_direction * TILE_SIZE

func _physics_process(delta):
	get_input()
