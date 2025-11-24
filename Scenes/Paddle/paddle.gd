extends StaticBody2D

@export var smoothing_speed: float = 10.0

@onready var _play_area = %PlayArea
var _min_boundary 
var _max_boundary

var _destination_x: float = 0.0
var _current_angular_velocity: float = 0.0
var _previous_rotation: float = 0.0

func _ready() -> void:
	_min_boundary = _play_area.position.x
	_max_boundary = _play_area.position.x + _play_area.size.x
	_destination_x = position.x

func _physics_process(delta: float) -> void:
	_move_to_destination(delta)
	_current_angular_velocity = (rotation - _previous_rotation) / delta
	_previous_rotation = rotation

func _input(event: InputEvent) -> void:
	if ((event is InputEventScreenTouch and event.pressed) or event is InputEventScreenDrag) and event.index == 0:
		_destination_x = event.position.x

func _move_to_destination(delta: float) -> void:
	var clamped_dest: float = clampf(_destination_x, _min_boundary, _max_boundary)
	position.x = lerp(position.x, clamped_dest, smoothing_speed * delta)

func get_velocity_at_point(point: Vector2) -> Vector2:
	var arm = point - global_position
	return Vector2(-arm.y, arm.x) * _current_angular_velocity
