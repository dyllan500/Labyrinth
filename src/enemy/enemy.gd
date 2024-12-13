class_name Enemy extends CharacterBody2D
@onready var map: Node2D = get_node("/root/Game/Map")
@export var tile_size = 16
@export var health: float = 100.0
@export var attack: float = 10.0
@onready var player: CharacterBody2D = get_node("/root/Game/Player")
@onready var gui: Control = get_node("/root/Game/PlayGui")

func _ready():
	collision_layer = 2
	collision_mask = 3
	visible = false
	name = "Enemy"

func _process(_delta):
	pass

func take_damage(damage):
	health = health - damage

func move_enemy_towards_target():
	var start_tile = Vector2(position.x / tile_size, position.y / tile_size)
	var target_tile = Vector2(player.position.x / tile_size, player.position.y / tile_size)
	var path = map.pathfinder.get_point_path(start_tile, target_tile)

	if path.size() > 1:
		var move = true
		var next_tile = path[1]
		var target_position = next_tile * tile_size
		var tile_x = int(target_position.x / tile_size)
		var tile_y = int(target_position.y / tile_size)
		if target_position == player.position:
				move = false
				player.take_damage(attack)
				gui.add_line("Enemy hit player for " + str(attack))
		for enemey in map.enemies:
			if target_position == enemey.position:
				move = false
		if tile_x < map.width and tile_y < map.height:
			if map.grid[tile_x][tile_y] == 2 and move:
				position = target_position
