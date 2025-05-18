extends Node3D

var original_positions = {}
var exploded_positions = {}
var rotate_objects = []
var explode_flag = true
var rotate_flag = true

var rotation_min = 0.0
var rotation_max = 720.0
var rotation_speed = 5.0


var rotation_dir = 0
var shaft_rotation = 0.0

func _ready():
	for child in get_children():
		if child is Node3D:
			original_positions[child.get_node("Model")] = child.get_node("Model").transform.origin
	rotate_objects = [$TensionLever, $Shaft]

func _input(event):
	if event.is_action_pressed("explode") and explode_flag:
		explode()
	if event.is_action_released("explode") and explode_flag:
		implode()
	if event.is_action_pressed("reset") and rotate_flag:
		pass
		reset()
	if event.is_action_pressed("spinclock") and rotate_flag:
		rotation_dir = 1
	elif event.is_action_pressed("spincounterclock") and rotate_flag:
		rotation_dir = -1
	if event.is_action_released("spinclock") or event.is_action_released("spincounterclock"):
		rotation_dir = 0

func _process(delta):
	if rotate_flag:
		rotate_shaft(rotation_dir)

func calculate_exploded_positions():
	var exploded = {}
	var spacing = 15.0  # 펼쳐질 거리
	var count = get_child_count()
	for i in range(count):
		var child = get_child(i).get_node("Model")
		if child is MeshInstance3D:
			var offset = Vector3(0, 0, (i - count + 1) * spacing)
			exploded[child] = original_positions[child] + offset
	return exploded

func explode():
	exploded_positions = calculate_exploded_positions()
	var tween = create_tween().set_parallel(true)
	for child in exploded_positions:
		tween.tween_property(child, "position", exploded_positions[child], 0.3)

func implode():
	var tween = create_tween().set_parallel(true)
	for child in original_positions:
		tween.tween_property(child, "position", original_positions[child], 0.3)

func rotate_shaft(dir : int):
	shaft_rotation += dir * rotation_speed
	shaft_rotation = clamp(shaft_rotation, rotation_min, rotation_max)
	for rot_obj in rotate_objects:
		rot_obj.rotation_degrees.z = shaft_rotation

func reset():
	if shaft_rotation < rotation_speed:
		shaft_rotation = 0
		return
	rotate_flag = false
	var tween = create_tween().set_parallel(true)

	var start_angle = shaft_rotation
	var end_angle = 0.0
	shaft_rotation = 0.0
	for rot_obj in rotate_objects:
		tween.tween_method(func(val):
			var rot = rot_obj.rotation
			rot.z = val
			rot_obj.rotation = rot
		, start_angle, end_angle, start_angle / rotation_speed / 60)

	tween.finished.connect(func():
		rotate_flag = true
	)
