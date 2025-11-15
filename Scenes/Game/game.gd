extends Node

func _ready() -> void:
	$Paddle.boundary_setup(0 + $LeftWall.thickness / 2, Global.screen_width - $RightWall.thickness / 2)

func _process(delta: float) -> void:
	pass
