extends Node3D

var cable_rotate_flag = false
var rotate_objects = []

var rotation_min = 0.0
var rotation_max = 360.0 * 3.75
var rotation_speed = 2.0
var rot = 0.0
var rotation_dir = 0

var line_end: Node3D
var x_max = -64
var line_speed = 0.43

func _ready():
	Engine.set_time_scale(3)
	rotate_objects.append(get_node("Line/LineCurve"))
	rotate_objects.append(get_node("3dModel/SpringHousing"))
	line_end = get_node("Line/LineSegments/LineEnd")

func _input(event):
	if event.is_action_pressed("spinclock") and cable_rotate_flag:
		rotation_dir = 1
	elif event.is_action_pressed("spincounterclock") and cable_rotate_flag:
		rotation_dir = -1
	if event.is_action_released("spinclock") or event.is_action_released("spincounterclock"):
		rotation_dir = 0

func _process(delta):
	if cable_rotate_flag:
		rotate_shaft(rotation_dir)
		move_line_end()

func rotate_shaft(dir : int):
	rot += dir * rotation_speed
	rot = clamp(rot, rotation_min, rotation_max)
	for rot_obj in rotate_objects:
		rot_obj.rotation_degrees.z = rot

func move_line_end():
	line_end.global_position.x = x_max - rot * line_speed
	
