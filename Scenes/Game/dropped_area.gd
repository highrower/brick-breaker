extends Area2D


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	$CollisionShape2D.shape.size.x = Global.screen_width
	$MeshInstance2D.mesh.size.x = Global.screen_width
	position.x = Global.screen_width / 2
	position.y = Global.screen_height * 0.9

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Balls"):
		print("You lose")
		body.call_deferred("reset")
