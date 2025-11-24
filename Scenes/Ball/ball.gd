extends RigidBody2D

var _min_speed = 500 
var _min_burst_through_speed = 750
var _max_speed = 3000
var _reset_pending = false

var _ignore_paddle_timer: float = 0.5
var _ignored_body: Node = null
var _last_frame_velocity: Vector2 = Vector2.ZERO 
@onready var _shapecast: ShapeCast2D = $ShapeCast2D

func _ready():
	var bounce_material = PhysicsMaterial.new()
	bounce_material.friction = 0.0
	bounce_material.bounce = 1.0 
	physics_material_override = bounce_material
	reset()

func _physics_process(delta: float) -> void:
	for node in get_colliding_bodies():
		if node.is_in_group("Bricks"):
			node.try_kill(_min_speed / 5)
			
			
	_shapecast.target_position = linear_velocity * delta * 2.0
	_shapecast.force_shapecast_update()
	
	if _shapecast.is_colliding():
		for i in range(_shapecast.get_collision_count()):
			var collider = _shapecast.get_collider(i)
			
			if collider.is_in_group("Bricks"):
				var impact_speed = linear_velocity.length()
				if impact_speed < _min_burst_through_speed:
					continue
					
				var damage = impact_speed / 5
				if collider.try_kill(damage):
					linear_velocity = linear_velocity * 0.8
					
	if _ignored_body:
		_ignore_paddle_timer -= delta
		if _ignore_paddle_timer <= 0:
			remove_collision_exception_with(_ignored_body)
			_ignored_body = null
			
		
func _integrate_forces(state) -> void:
	if _reset_pending:
		_reset_pending = false
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		state.transform.origin = %Paddle.position + Vector2(0, -50)
		_last_frame_velocity = Vector2.ZERO 
		apply_central_impulse(Vector2(0, 1) * _min_speed)
		return 
		
	var final_velocity = state.linear_velocity
	var collider
	var contact_pos
	
	if get_contact_count():
		collider = state.get_contact_collider_object(0)
		contact_pos = state.get_contact_collider_position(0)
		
	if collider and collider.has_method("get_velocity_at_point"):
		var boost_velocity = collider.get_velocity_at_point(contact_pos)
		final_velocity += boost_velocity * 1.5 
		# TODO: figure out a good balance. no ignoring means unpredictable 
		# TODO: launch but ignoring means slow because of initial paddle release
#		_ignored_body = collider
#		_ignore_paddle_timer = 0.15 
#		add_collision_exception_with(_ignored_body)
		
	final_velocity = final_velocity.normalized() * clamp(final_velocity.length(), _min_speed, _max_speed)
	state.linear_velocity = final_velocity
	_last_frame_velocity = final_velocity

func reset() -> void:
	_reset_pending = true
