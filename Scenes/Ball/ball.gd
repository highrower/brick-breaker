extends RigidBody2D

var min_speed = 500 
var direction
var reset_pending = false

func _ready():
	var bounce_material = PhysicsMaterial.new()
	bounce_material.friction = 0.0
	bounce_material.bounce = 1.0 
	physics_material_override = bounce_material
	reset()

func _physics_process(delta: float) -> void:
	for node in get_colliding_bodies():
		if node.is_in_group("Bricks"):
			node.queue_free()
		
func _integrate_forces(state):
	if reset_pending:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		
		var new_transform = state.transform
		new_transform.origin = Vector2(Global.screen_width * 0.5, Global.screen_height * 0.5)
		state.transform = new_transform
		
		reset_pending = false
		
		var ran_x = randf_range(-1, 1)
		var ran_y = randf_range(-1, 1)
		direction = Vector2(ran_x, ran_y).normalized()
		apply_central_impulse(Vector2(0, -1) * min_speed)
	var current_velocity = self.linear_velocity
	var current_speed = current_velocity.length()

	if current_speed < min_speed and current_speed > 0:
		var current_direction = current_velocity.normalized()
#		apply_force(current_direction * (min_speed - current_speed))
		self.linear_velocity = current_direction * min_speed

func reset():
	reset_pending = true
