extends StaticBody2D

@export var hp = 1

func _ready() -> void:
	scale = Vector2(Global.brick_size, Global.brick_size)
