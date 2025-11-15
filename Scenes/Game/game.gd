extends Node

func _ready() -> void:
	$Paddle.boundary_setup(0 + Global.wall_thickness / 2, Global.screen_width - Global.wall_thickness / 2)

func _process(delta: float) -> void:
	pass
