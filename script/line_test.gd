extends Node3D

var line_segment = preload("res://scene/line_segment.tscn")
var line_joint = preload("res://scene/line_joint.tscn")
var line_tip = preload("res://scene/end_tip.tscn")
var line_list = []
var segment_list = []
var length = 108

var angle := 0.0
var reeling := false
var connected := false

func _ready():
	make_line()

func make_line():
	line_list.append($LineSegment)
	
	for i in range(length):
		var line = line_segment.instantiate()
		line.position = Vector3(0, -6 * (i+1), 0)
		add_child(line)
		
		var joint = line_joint.instantiate()
		joint.position = Vector3(0, -6 * (i+1) + 3, 0)
		add_child(joint)
		joint.node_a = line_list[-1].get_path()
		joint.node_b = line.get_path()
		line_list.append(line)
	var tip = line_tip.instantiate()
	line_list[-1].add_child(tip)
	$LineEnd.position = Vector3(0, -6 * length - 3, 0)
	$JointEnd.position = Vector3(0, -6 * length - 3, 0)
	$JointStart.node_a = get_tree().get_root().get_node("Mainscene/Line/LineSegments/LineStart").get_path()
	$JointStart.node_b = line_list[0].get_path()
	$JointEnd.node_a = line_list[-1].get_path()
	$JointEnd.node_b = $LineEnd.get_path()
	
	var tween = create_tween()
	tween.tween_property($LineStart, "global_position", Vector3(0, -27, 0), 1.5)
	tween.tween_property(self, "angle", 7.5 * PI, 20.0).set_delay(0.1)  # 회전 시작
	reeling = true
	var endpos = get_tree().get_root().get_node("Mainscene/Line/LineCurve/LineEnd").global_position
	tween.tween_property($LineStart, "global_position", endpos, .5)
	tween.finished.connect(func():
		reeling = false
		for i in line_list:
			i.linear_velocity = Vector3.ZERO
		$LineEnd.linear_velocity = Vector3.ZERO
		$LineStart.freeze = true
		connected = true
		get_tree().get_root().get_node("Mainscene").rotate_flag = true
		save()
	)

func _process(delta):
	if reeling:
		var radius = 25.5
		var x = sin(angle) * radius
		var y = -cos(angle) * radius
		var z = -1.1 * angle / PI
		$LineStart.global_position = Vector3(x, y, z)

func save():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_children()
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
		new_object.rotation = Vector3(node_data["rot_x"], node_data["rot_y"], node_data["rot_z"])
