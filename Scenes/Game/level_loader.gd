extends Node

const BRICK_SCENE = preload("res://Scenes/Brick/Brick.tscn")
const MARGIN = 15

var min_play_area
var max_play_area
@export var play_dimension = 8

func _ready():
	var margin_and_walls = (Global.wall_thickness / 2) + MARGIN
	min_play_area = Vector2(0 + margin_and_walls, 0 + margin_and_walls)
	max_play_area = Vector2(Global.screen_width - margin_and_walls, Global.screen_height * .4)
	load_level("res://Levels/level_1.json")

func load_level(level_path):
	var file = FileAccess.open(level_path, FileAccess.READ)
	var text = file.get_as_text()
	var json_data = JSON.parse_string(text)
	
	var play_size = Vector2(max_play_area.x - min_play_area.x, max_play_area.y - min_play_area.y)
	var increment = Vector2(play_size.x / play_dimension, play_size.y / play_dimension)

	if json_data:
		var level_layout = json_data.layout

		for y in range(play_dimension):
			for x in range(play_dimension):
				var brick_type = level_layout[y][x]

				if brick_type > 0:
					var new_brick = BRICK_SCENE.instantiate()
					var brick_pos = min_play_area + Vector2(x * increment.x + Global.brick_size, y * increment.y + Global.brick_size)
					new_brick.position = brick_pos

					add_child(new_brick)
	else:
		print("Error parsing level JSON!")