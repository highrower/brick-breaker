extends Node

var viewport_size = Vector2.ZERO
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
var wall_thickness = 20.0
var brick_size = 35

func _ready():
	viewport_size = get_viewport().size
	