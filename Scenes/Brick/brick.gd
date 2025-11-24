extends StaticBody2D

@export var _hp: float = 100.0 : set = set_hp

@export var min_hp: float = 100.0
@export var max_hp: float = 1000.0
@export var start_color: Color = Color.WHITE
@export var end_color: Color = Color.RED

var _is_dead = false

func set_hp(new_hp: float):
	_hp = new_hp
	modulate = get_color_from_hp(_hp)
	_is_dead = _hp <= 0

func _ready() -> void:
	modulate = get_color_from_hp(_hp)

func _physics_process(delta: float) -> void:
	if _is_dead:
		queue_free()

func try_kill(damage: int) -> bool:
	set_hp(_hp - damage) 
	_is_dead = _hp <= 0
	return _is_dead

func get_color_from_hp(current_hp: float) -> Color:
	var clamped_hp = clampf(current_hp, min_hp, max_hp)
	var t = inverse_lerp(min_hp, max_hp, clamped_hp)
	return start_color.lerp(end_color, t)
