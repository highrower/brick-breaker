extends StaticBody2D 

enum WallSide { LEFT, RIGHT, TOP }

@export var side: WallSide = WallSide.LEFT
@export var thickness: float = 20.0

func _ready() -> void:
	var viewport_size = get_viewport().size
	var half_thickness = thickness / 2.0
	
	match side:
		WallSide.LEFT:
			position = Vector2(0, viewport_size.y / 2)
			scale.y = 150
		WallSide.RIGHT:
			position = Vector2(viewport_size.x, viewport_size.y / 2)
			scale.y = 150
		WallSide.TOP:
			position = Vector2(viewport_size.x / 2 , 0)
			scale.x = 100
