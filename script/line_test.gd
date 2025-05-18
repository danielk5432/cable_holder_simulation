extends Node3D

var line_segment = preload("res://scene/line_segment.tscn")
var line_joint = preload("res://scene/line_joint.tscn")
var line_tip = preload("res://scene/end_tip.tscn")
var line_list = []
var segment_list = []
var length = 109

var angle := 0.0
var rotating := false

func _ready():
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
	$JointEnd.node_a = line_list[-1].get_path()
	
	var tween = create_tween()
	tween.tween_property($LineStart, "global_position", Vector3(0, -27, 0), 1.5)
	tween.tween_property(self, "angle", 7.5 * PI, 20.0).set_delay(0.1)  # 회전 시작
	rotating = true
	var endpos = get_tree().get_root().get_node("Mainscene/Line/LineCurve/LineEnd").global_position
	tween.tween_property($LineStart, "global_position", endpos, .5)
	tween.finished.connect(func():
		rotating = false
		for i in line_list:
			i.linear_velocity = Vector3.ZERO
		$LineEnd.linear_velocity = Vector3.ZERO
		
	)

func _process(delta):
	if rotating:
		var radius = 25.5
		var x = sin(angle) * radius
		var y = -cos(angle) * radius
		var z = -1.1 * angle / PI
		$LineStart.global_position = Vector3(x, y, z)
	
