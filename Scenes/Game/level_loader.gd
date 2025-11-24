extends Node

const BRICK_SCENE = preload("res://Scenes/Brick/Brick.tscn")
const MARGIN = 15

var min_play_area
var max_play_area
@export var play_dimension = 8
@onready var _play_area = %PlayArea

func _ready():
	min_play_area = _play_area.position
	max_play_area = _play_area.position + _play_area.size
	load_level("res://Levels/level_1.json")

func load_level(level_path):
	var file = FileAccess.open(level_path, FileAccess.READ)
	var text = file.get_as_text()
	var json_data = JSON.parse_string(text)
	
	var increment = Vector2(_play_area.size.x / play_dimension, _play_area.size.y / play_dimension)

	if json_data:
		var level_layout = json_data.layout

		for y in range(play_dimension):
			for x in range(play_dimension):
				var brick_type = level_layout[y][x]

				if brick_type > 0:
					var new_brick = BRICK_SCENE.instantiate()
					var brick_size = new_brick.scale.x * new_brick.get_node("CollisionShape2D").shape.size.x
					var brick_pos = min_play_area + Vector2(x * increment.x + brick_size, y * increment.y + brick_size)
					new_brick.position = brick_pos
					new_brick.set_hp(brick_type)

					add_child(new_brick)
	else:
		print("Error parsing level JSON!")
