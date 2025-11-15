extends CharacterBody2D

var pressed = false
var movement_speed = 5
var destination
var mesh_extent
@export var min_boundary: float = 0.0
@export var max_boundary: float = 1440.0 # default (project settings width
@export var length_ratio = .3

func _ready() -> void:
	position = Vector2(Global.screen_width * 0.5, Global.screen_height * 0.8)

func _physics_process(_delta: float) -> void:
	if pressed:
		move(destination)

func _input(event):
	if event is InputEventScreenTouch:
		pressed = event.is_pressed()
		if pressed:
			destination = event.position.x
	elif event is InputEventScreenDrag:
		destination = event.position.x
		
func move(dest):
	var new_pos = move_toward(position.x, dest, movement_speed)
	var clamped_x = clamp(new_pos, min_boundary + mesh_extent, max_boundary - mesh_extent)
	position.x = clamped_x
	
func boundary_setup(min_bound, max_bound):
	min_boundary = min_bound
	max_boundary = max_bound
	set_paddle_width()

func set_paddle_width():
	var playable_area = max_boundary - min_boundary
	var new_length = playable_area * length_ratio
	
	$CollisionShape2D.shape.height = new_length
	$MeshInstance2D.mesh.height = new_length
	mesh_extent = new_length / 2
	
