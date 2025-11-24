class_name TwistController
extends Node

@export var max_twist_degrees: float = 45.0
@export var twist_sensitivity: float = 0.2
@export var snap_duration: float = 0.5 

@onready var _paddle = $".."
@onready var _collision_shape = $"../CollisionShape2D"

var _twist_start_position: Vector2 = Vector2.ZERO
var _twist_tween: Tween
var _starting_rotation: float = 0.0

func _ready() -> void:
	_starting_rotation = _paddle.rotation

func _input(event: InputEvent) -> void:
	if "index" in event and event.index == 1:
		if event is InputEventScreenTouch:
			if not event.pressed:
				_release_twist_mechanic()
			else:
				_twist_start_position = event.position
				_start_twist_mechanic()
		if event is InputEventScreenDrag:
			var is_right_of_paddle = event.position.x > _paddle.position.x
			_apply_twist(event.position, is_right_of_paddle)

func _start_twist_mechanic() -> void:
	if _twist_tween:
		_twist_tween.kill()
	
	_paddle.modulate.a = 0.5 
	_collision_shape.set_deferred("disabled", true)

func _apply_twist(current_touch_pos: Vector2, is_right_of_paddle: bool) -> void:
	var diff_y = _twist_start_position.y - current_touch_pos.y
	var target_rot = diff_y * twist_sensitivity
	if is_right_of_paddle:
		target_rot = -target_rot
	_paddle.rotation_degrees = clamp(target_rot, -max_twist_degrees, max_twist_degrees)

func _release_twist_mechanic() -> void:
	_collision_shape.set_deferred("disabled", false)
	_paddle.modulate.a = 1.0
	
	_twist_tween = create_tween()
	_twist_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_twist_tween.tween_property(_paddle, "rotation", _starting_rotation, snap_duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
