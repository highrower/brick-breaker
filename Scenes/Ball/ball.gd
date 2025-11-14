extends CharacterBody2D

var speed = 1000
var direction

func _ready():
	reset()


func _physics_process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0) 
		direction = direction.bounce(collision.get_normal())
		
func reset():
	position = Vector2(Global.viewport_size.x * 0.5, Global.viewport_size.y * 0.2)

	var ran_x = randf_range(-1, 1)
	var ran_y = randf_range(-1, 1)
	direction = Vector2(ran_x, ran_y).normalized()
	