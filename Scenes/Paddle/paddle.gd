extends StaticBody2D

var pressed = false
var dragging = false
var move_velo = Vector2(5, 0)
var movement_speed = 300
var destination
var mesh_extent
var starting_rotation
var rotation_speed
var twist_start_position
@export var min_boundary: float = 0.0
@export var max_boundary: float = 1440.0 # default (project settings width
@export var length_ratio = .3

func _ready() -> void:
	starting_rotation = rotation
	rotation_speed = 0
	position = Vector2(Global.screen_width * 0.5, Global.screen_height * 0.8)
	destination = Vector2(Global.screen_width * 0.5, Global.screen_height * 0.8).x
	boundary_setup(0 + Global.wall_thickness / 2, Global.screen_width - Global.wall_thickness / 2)
	move_and_collide(Vector2.ZERO)  # flush test-only movement

func _physics_process(delta: float) -> void:
	move(destination, delta)

func _input(event):
	if event is InputEventScreenTouch:
		pressed = event.is_pressed()
		if not pressed:
			if event.index == 0:
				dragging = false
			if event.index == 1:
				rotation = starting_rotation
		else:
			if event.index == 1:
				twist_start_position = event.position
			if not dragging:
				destination = event.position.x
			else: 
				destination = position.x # so touches after first dont move paddle
	elif event is InputEventScreenDrag:
		dragging = true
		if event.index == 0:
			destination = event.position.x
		if event.index == 1:
			twist(event)
			
var last_twist_pos: Vector2

func twist(event):
	print("Starting pos: " + str(twist_start_position))
	print("Curr pos: " + str(event.position))
	print("difference: " + str(twist_start_position -  event.position))
	
	rotation_degrees = (twist_start_position -  event.position).length() / 30 
#	if event.index != 1: 
#		return
#
#	if last_twist_pos == null:
#		last_twist_pos = event.position
#		return
#
#	var delta = event.position - last_twist_pos
#	last_twist_pos = event.position
#
#	var sensitivity = 0.005  # tweak to taste
#	rotation += delta.x * sensitivity	
		
func move(dest, delta):
	var clamped_x = clamp(dest, min_boundary + mesh_extent, max_boundary - mesh_extent)
	position.x = lerp(position.x, clamped_x, 10 * delta)

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
	
