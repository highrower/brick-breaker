extends RigidBody2D

var min_speed = 500 
var direction
var reset_pending = false

var _ignore_collision_timer: float = 0.5
var _ignored_body: Node = null

func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	
	var bounce_material = PhysicsMaterial.new()
	bounce_material.friction = 0.0
	bounce_material.bounce = 1.0 
	physics_material_override = bounce_material
	reset()

func _physics_process(delta: float) -> void:
	for node in get_colliding_bodies():
		if node.is_in_group("Bricks"):
			node.queue_free()
			
	if _ignored_body:
			_ignore_collision_timer -= delta
			if _ignore_collision_timer <= 0:
				# Time's up! Re-enable collision so we can hit the paddle again later
				remove_collision_exception_with(_ignored_body)
				_ignored_body = null
		
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
		return 
		
	var boosted_this_frame = false # Flag to track if we got a hit	
	var final_velocity = state.linear_velocity
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		
		# Check if we hit the paddle (check for the method, or use a group)
		if collider and collider.has_method("get_velocity_at_point"):
			# Get the exact point where the ball touched the paddle
			var contact_pos = state.get_contact_collider_position(i)
			
			# Ask the paddle how fast it was spinning at that point
			var boost_velocity = collider.get_velocity_at_point(contact_pos)
			
# Add the boost directly to our tracker
			# Experiment with this multiplier (0.5 to 1.5) to find the "sweet spot"
			# Only apply if the boost is significant (meaning the paddle is snapping)
			if boost_velocity.length() > 100: # Tweak this threshold
				# Apply the boost
				final_velocity += boost_velocity * 1.5 # Multiplier for juice
				
				# CRITICAL: Temporarily disable physics with this paddle
				add_collision_exception_with(collider)
				_ignored_body = collider
				_ignore_collision_timer = 0.15 # Ignore for 150ms (enough to escape)
				boosted_this_frame = true		# 3. Apply Min Speed Logic (Check the NEW velocity, not the old one)
				
		var current_speed = final_velocity.length()

		if current_speed < min_speed and current_speed > 0:
			final_velocity = final_velocity.normalized() * min_speed

		# Optional: Cap Max Speed (Prevent breaking the game)
		if current_speed > 2000:
			final_velocity = final_velocity.normalized() * 2000

		# 4. COMMIT THE CHANGES (Do this exactly once)
		state.linear_velocity = final_velocity

func reset():
	reset_pending = true
