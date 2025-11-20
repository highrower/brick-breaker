extends StaticBody2D

@export_group("Paddle Settings")
@export var movement_speed: float = 300.0
@export var smoothing_speed: float = 10.0
@export var length_ratio: float = 0.3

@export_group("Boundaries")
@export var min_boundary: float = 0.0
@export var max_boundary: float = 1440.0

@export_group("Twist Mechanics")
@export var max_twist_degrees: float = 45.0
@export var twist_sensitivity: float = 0.2
@export var snap_duration: float = .5 # How long the "boing" takes

var _pressed: bool = false
var _dragging: bool = false
var _destination_x: float = 0.0
var _twist_start_position: Vector2 = Vector2.ZERO
var _twist_tween: Tween
var _starting_rotation: float = 0.0
var _mesh_extent: float = 0.0
var _current_angular_velocity: float = 0.0
var _previous_rotation: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var mesh_instance: MeshInstance2D = $MeshInstance2D

func _ready() -> void:
	_starting_rotation = rotation
	
	var start_pos := Vector2(Global.screen_width * 0.5, Global.screen_height * 0.8)
	position = start_pos
	_destination_x = start_pos.x
	
	_boundary_setup(0 + Global.wall_thickness / 2.0, Global.screen_width - Global.wall_thickness / 2.0)
	
#	move_and_collide(Vector2.ZERO) # flush physics.... needed if im not using staticbody2d

func _physics_process(delta: float) -> void:
	_move_to_destination(delta)
	_current_angular_velocity = (rotation - _previous_rotation) / delta
	_previous_rotation = rotation

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	_pressed = event.pressed
	
	if event.index == 0:
		if not _pressed:
			_dragging = false
		else:
			_destination_x = event.position.x

	if event.index == 1:
		if not _pressed:
			_release_twist_mechanic()
		else:
			_twist_start_position = event.position
			_start_twist_mechanic()

func _handle_drag(event: InputEventScreenDrag) -> void:
	_dragging = true
	
	if event.index == 0:
		_destination_x = event.position.x
	
	if event.index == 1:
		_apply_twist(event.position)

func _start_twist_mechanic() -> void:
	if _twist_tween:
		_twist_tween.kill()
	
	modulate.a = 0.5 
	$CollisionShape2D.set_deferred("disabled", true)

func _apply_twist(current_touch_pos: Vector2) -> void:
	var diff_y = _twist_start_position.y - current_touch_pos.y
	
	var target_rot = diff_y * twist_sensitivity
	
	rotation_degrees = clamp(target_rot, -max_twist_degrees, max_twist_degrees)

func _release_twist_mechanic() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
	modulate.a = 1.0
	
	# THE TWEEN (The Angry Birds Snap)
	_twist_tween = create_tween()
	
	# 1. Rotate back to 0 (or starting_rotation)
	# 2. Use TRANS_ELASTIC for the "Boing" overshoot effect
	# 3. Use EASE_OUT so it settles gently
	_twist_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # so rotation velocity matches
	_twist_tween.tween_property(self, "rotation", _starting_rotation, snap_duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

func _move_to_destination(delta: float) -> void:
	var clamped_dest: float = clampf(_destination_x, min_boundary + _mesh_extent, max_boundary - _mesh_extent)
	position.x = lerp(position.x, clamped_dest, smoothing_speed * delta)

func _boundary_setup(min_bound: float, max_bound: float) -> void:
	min_boundary = min_bound
	max_boundary = max_bound
	_update_paddle_geometry()

func _update_paddle_geometry() -> void:
	var playable_area: float = max_boundary - min_boundary
	var new_length: float = playable_area * length_ratio
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape.height = new_length
	
	if mesh_instance and mesh_instance.mesh:
		mesh_instance.mesh.height = new_length
		
	_mesh_extent = new_length / 2.0

# Helper function the Ball will call
func get_velocity_at_point(point: Vector2) -> Vector2:
	# Calculate the lever arm (vector from pivot to hit point)
	var arm = point - global_position

	if _current_angular_velocity == 0:
		print("Paddle is not spinning! Velocity: 0")
	# Physics Math: Tangential Velocity = Angular Velocity * Radius (perpendicular)
	# We create a vector perpendicular to the arm, scaled by spin speed
# 1. Create the perpendicular vector manually (Rotates 90 degrees)
	# If arm is (x, y), perpendicular is (-y, x)
	var perpendicular_arm = Vector2(-arm.y, arm.x)
	
	# 2. Scale it by the rotation speed
	# Physics: Tangential Velocity = Radius_Perpendicular * Angular_Velocity
	var tang_velocity = perpendicular_arm * _current_angular_velocity
	
	return tang_velocity
