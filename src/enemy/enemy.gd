class_name Enemy extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@export var TILE_SIZE = 16
@export var health : float = 100.0
@export var attack : float = 10.0

func turn():
	if(health <= 0):
		for i in map.get_children():
			if i.name == name:
				map.remove_child(i)

func _physics_process(delta):
	turn()

func _ready():
	collision_layer = 2
	collision_mask = 1
	visible = false
	name = "Enemy"
