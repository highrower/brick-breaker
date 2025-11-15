extends StaticBody2D 

enum WallSide { LEFT, RIGHT, TOP }

@export var side: WallSide = WallSide.LEFT
@export var thickness: float = 20.0

func _ready() -> void:
# Give the walls the same perfect bounce material
	var bounce_material = PhysicsMaterial.new()
	bounce_material.friction = 0.0
	bounce_material.bounce = 1.0
	
	# Apply itd
	self.physics_material_override = bounce_material
	var half_thickness = thickness / 2.0
	
	match side:
		WallSide.LEFT:
			position = Vector2(0, Global.screen_height / 2)
			scale.y = 150
		WallSide.RIGHT:
			position = Vector2(Global.screen_width, Global.screen_height / 2)
			scale.y = 150
		WallSide.TOP:
			position = Vector2(Global.screen_width / 2 , 0)
			scale.x = 40
