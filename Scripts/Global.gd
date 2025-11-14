extends Node

var viewport_size = Vector2.ZERO

func _ready():
	viewport_size = get_viewport().size