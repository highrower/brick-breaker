extends Area2D


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	$CollisionShape2D.shape.size.x = Global.viewport_size.x
	$MeshInstance2D.mesh.size.x = Global.viewport_size.x
	position.x = Global.viewport_size.x / 2
	position.y = Global.viewport_size.y * 0.9

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Balls"):
		print("You lose")
		body.reset()
