extends Node2D

@onready var player: CharacterBody2D = get_node("/root/Game/Player")
@export var enemy_scene: PackedScene

var items_folder = "res://src/inventory/items/"
@export var items = []
var number_of_items = 10

var enemy_types = ["bat", "snake"]

var width = 50
var height = 50
var tile_size = 16

var grid = []
var map = []
var rooms = []

var enemies = []

var wall_sprite_scene : PackedScene
var floor_sprite_scene : PackedScene
var door_sprite_scene : PackedScene
var door_node : Sprite2D

var min_room_size = 4
var max_room_size = 10
var max_rooms = 10

var scan_range: Rect2
const entity_pathfinding_weight = 10.0
@onready var pathfinder : AStarGrid2D = AStarGrid2D.new()

func _ready():
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	width = int(screen_width / tile_size)
	height = int(screen_height / tile_size)
	width = max(width, 10)
	height = max(height, 10)
	wall_sprite_scene = preload("res://src/map/wall_sprite.tscn")
	floor_sprite_scene = preload("res://src/map/floor_sprite.tscn")
	door_sprite_scene = preload("res://src/map/door_sprite.tscn")
	enemy_scene = preload("res://src/enemy/enemy.tscn")

	var dir = DirAccess.open(items_folder)
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = items_folder + file_name
				var item_resource = load(resource_path)
				if item_resource:
					items.append(item_resource)
			file_name = dir.get_next()
		dir.list_dir_end()
	generate_dungeon()	
	
	pathfinder.region = Rect2i(0, 0, screen_width, screen_height)
	pathfinder.update()
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 2:
				pathfinder.set_point_solid(Vector2(x * tile_size, y * tile_size), true)
			else:
				pathfinder.set_point_solid(Vector2(x * tile_size, y * tile_size), false)
				pathfinder.set_point_weight_scale(Vector2(x, y), entity_pathfinding_weight)

	pathfinder.update()
	
	draw_dungeon()

func new_map():
	for child in get_children():
		remove_child(child)
	grid = []
	map = []
	rooms = []
	enemies.clear()
	generate_dungeon()
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	pathfinder.clear()
	pathfinder.region = Rect2i(0, 0, screen_width, screen_height)
	pathfinder.update()
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 2:
				pathfinder.set_point_solid(Vector2(x * tile_size, y * tile_size), true)
			else:
				pathfinder.set_point_solid(Vector2(x * tile_size, y * tile_size), false)
				pathfinder.set_point_weight_scale(Vector2(x, y), entity_pathfinding_weight)

	pathfinder.update()
	draw_dungeon()

func generate_dungeon():
	grid = []
	for x in range(width):
		grid.append([])
		map.append([])
		for y in range(height):
			grid[x].append(0)
			map[x].append({"type": "floor", "sprite": null, "visible": false})

	for i in range(max_rooms):
		var room_width = randi() % (max_room_size - min_room_size) + min_room_size
		var room_height = randi() % (max_room_size - min_room_size) + min_room_size
		var room_x = randi() % (width - room_width - 1)
		var room_y = randi() % (height - room_height - 1)
		var new_room = Rect2(room_x, room_y, room_width, room_height)
		var overlap = false
		for room in rooms:
			if new_room.intersects(room):
				overlap = true
				break
		if not overlap:
			for x in range(new_room.position.x + 1, new_room.position.x + new_room.size.x - 1):
				for y in range(new_room.position.y + 1, new_room.position.y + new_room.size.y - 1):
					grid[x][y] = 2  # Floor
			rooms.append(new_room)
			if len(rooms) > 1:
				var prev_room = rooms[rooms.size() - 2]
				connect_rooms(prev_room, new_room)
	place_walls()

func connect_rooms(room1: Rect2, room2: Rect2):
	var x1 = room1.position.x + room1.size.x / 2
	var y1 = room1.position.y + room1.size.y / 2
	var x2 = room2.position.x + room2.size.x / 2
	var y2 = room2.position.y + room2.size.y / 2
	
	if randf() > 0.5:
		create_corridor(Vector2(x1, y1), Vector2(x2, y1))
		create_corridor(Vector2(x2, y1), Vector2(x2, y2))
	else:
		create_corridor(Vector2(x1, y1), Vector2(x1, y2))
		create_corridor(Vector2(x1, y2), Vector2(x2, y2))

func create_corridor(start: Vector2, end: Vector2):
	var x1 = int(start.x)
	var y1 = int(start.y)
	var x2 = int(end.x)
	var y2 = int(end.y)
	
	while x1 != x2 or y1 != y2:
		if x1 < x2:
			x1 += 1
		elif x1 > x2:
			x1 -= 1
		
		if y1 < y2:
			y1 += 1
		elif y1 > y2:
			y1 -= 1
		
		if grid[x1][y1] != 2:
			grid[x1][y1] = 2
	place_walls_around_corridor(start, end)

func place_walls_around_corridor(start: Vector2, end: Vector2):
	var x1 = int(start.x)
	var y1 = int(start.y)
	var x2 = int(end.x)
	var y2 = int(end.y)
	if x1 != x2:
		var min_x = min(x1, x2)
		var max_x = max(x1, x2)
		for x in range(min_x, max_x + 1):
			if y1 > 0 and grid[x][y1 - 1] == 0:
				grid[x][y1 - 1] = 1  # Wall above corridor
			if y1 < height - 1 and grid[x][y1 + 1] == 0:
				grid[x][y1 + 1] = 1  # Wall below corridor
				
	if y1 != y2:
		var min_y = min(y1, y2)
		var max_y = max(y1, y2)
		for y in range(min_y, max_y + 1):
			if x1 > 0 and grid[x1 - 1][y] == 0:
				grid[x1 - 1][y] = 1  # Wall left of corridor
			if x1 < width - 1 and grid[x1 + 1][y] == 0:
				grid[x1 + 1][y] = 1  # Wall right of corridor

func place_walls():
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 0:
				# Check if any of the adjacent tiles are floor (2) or corridor (1), if so, make this a wall
				if (x > 0 and grid[x - 1][y] == 2) or (x < width - 1 and grid[x + 1][y] == 2) or (y > 0 and grid[x][y - 1] == 2) or (y < height - 1 and grid[x][y + 1] == 2):
					grid[x][y] = 1

func draw_dungeon():
	var count = 0
	for x in range(width):
		for y in range(height):
			var tile_type = grid[x][y]
			var sprite_node : Sprite2D = null
			var collision_node : StaticBody2D = null
			if tile_type == 1:  # Wall tile
				sprite_node = wall_sprite_scene.instantiate()
				collision_node = StaticBody2D.new()
				var collision_shape = CollisionShape2D.new()
				var shape = RectangleShape2D.new()
				shape.extents = Vector2(tile_size / 2, tile_size / 2)
				collision_shape.shape = shape
				collision_node.add_child(collision_shape)
				collision_node.collision_layer = 2
				collision_node.collision_mask = 1
			elif tile_type == 2:  # Floor tile
				sprite_node = floor_sprite_scene.instantiate()
				sprite_node.name = "Floor" + str(count)

			if sprite_node:
				sprite_node.position = Vector2(x * tile_size, y * tile_size)
				sprite_node.visible = true
				add_child(sprite_node)
				if collision_node:
					collision_node.position = Vector2(x * tile_size + 8, y * tile_size + 8)
					add_child(collision_node)
				map[x][y] = {"type": tile_type, "sprite": sprite_node, "collision": collision_node, "visible": false}
			count = count + 1

	place_player()
	spawn_enemies()
	place_door()
	place_items()
	reveal_tile(player.position)

func _process(delta):
	reveal_tile(player.position)
	
	if not player.turn:
		for enemy in enemies:
			if enemy is Enemy:
				if(enemy.health <= 0):
					remove_child(enemy)	
					enemies.erase(enemy)
				enemy.move_enemy_towards_target()
		player.turn = true

func reveal_tile(position: Vector2):
	var tile_x = int(position.x / tile_size)
	var tile_y = int(position.y / tile_size)
	for dx in range(-3, 3 + 1):
		for dy in range(-3, 3 + 1):
			var reveal_x = tile_x + dx
			var reveal_y = tile_y + dy
			if reveal_x >= 0 and reveal_x < width and reveal_y >= 0 and reveal_y < height:
				var tile_data = map[reveal_x][reveal_y]
				if !tile_data["visible"]:
					if tile_data["sprite"] != null:
						tile_data["sprite"].visible = true
						tile_data["visible"] = true
				for item in get_children():
					if item is Enemy:
						if item.position.distance_to(Vector2(reveal_x*tile_size, reveal_y*tile_size)) < tile_size:
							item.visible = true
					else:
						if item.position.distance_to(Vector2(reveal_x*tile_size, reveal_y*tile_size)) < tile_size:
							item.visible = true

func get_random_floor_tile() -> Vector2:
	var floor_tiles = []
	for room in rooms:
		for x in range(room.position.x + 1, room.position.x + room.size.x - 1):
			for y in range(room.position.y + 1, room.position.y + room.size.y - 1):
				if grid[x][y] == 2:
					floor_tiles.append(Vector2(x, y))
	if floor_tiles.size() > 0:
		return floor_tiles[randi() % floor_tiles.size()]
	else:
		return Vector2(-1, -1)

func place_player():
	var random_floor_tile = get_random_floor_tile()
	player.position = random_floor_tile * tile_size
	
func place_door():
	var collision_node : StaticBody2D = null
	door_node = door_sprite_scene.instantiate()
	collision_node = StaticBody2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(tile_size / 2, tile_size / 2)
	collision_shape.shape = shape
	collision_node.add_child(collision_shape)
	collision_node.collision_layer = 2
	collision_node.collision_mask = 1
	var random_floor_tile = get_random_floor_tile()
	door_node.position =  random_floor_tile * tile_size
	door_node.name = "Door_Node"
	collision_node.name = "Door_Collide"
	door_node.visible = false
	add_child(door_node)
	collision_node.position = Vector2(random_floor_tile.x * tile_size + 8, random_floor_tile.y * tile_size + 8)
	add_child(collision_node)
	
func spawn_enemies():
	var placed_enemies = 5
	for i in range(placed_enemies):
		var random_enemy_type = enemy_types[randi() % enemy_types.size()]
		spawn_enemy(random_enemy_type)

func spawn_enemy(enemy_type: String):
	var enemy_scene = load("res://src/enemy/" + enemy_type + ".tscn")
	var enemy_instance = enemy_scene.instantiate()
	var random_floor_tile = get_random_floor_tile()
	enemy_instance.position = random_floor_tile * tile_size
	add_child(enemy_instance)
	enemies.append(enemy_instance)
			
func place_items():
	var item_num = 0
	for i in range(3):
		for item in items:
			var random_floor_tile = get_random_floor_tile()
			var sprite_node = Sprite2D.new()
			var collision_node : StaticBody2D = null
			sprite_node.texture = item.texture
			collision_node = StaticBody2D.new()
			var collision_shape = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			shape.extents = Vector2(tile_size / 2, tile_size / 2)
			collision_shape.shape = shape
			collision_node.add_child(collision_shape)
			collision_node.collision_layer = 2
			collision_node.collision_mask = 1
			sprite_node.position = Vector2(random_floor_tile.x * tile_size + 8, random_floor_tile.y * tile_size + 8)
			sprite_node.visible = true
			sprite_node.name = "ITEM_" + item.name + "_" + str(item_num) + "_Sprite"
			collision_node.name = "ITEM_" + item.name + "_" + str(item_num)
			add_child(sprite_node)
			collision_node.position = Vector2(random_floor_tile.x * tile_size + 8, random_floor_tile.y * tile_size + 8)
			add_child(collision_node)
			item_num = item_num + 1
