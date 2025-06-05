extends Generic6DOFJoint3D
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z
	}
	return save_dict

@export var max_length: float = 0.5        # 최대 허용 거리
@export var stiffness: float = 50.0        # 당기는 힘의 세기

var body_a: RigidBody3D
var body_b: RigidBody3D

func _ready():
	# 연결된 두 바디를 가져옵니다
	body_a = get_node_or_null(node_a)
	body_b = get_node_or_null(node_b)

	if body_a == null or body_b == null:
		push_warning("ConeTwistJoint3D: 연결된 바디를 찾을 수 없습니다.")

func _physics_process(delta):
	if body_a == null or body_b == null:
		return

	var pos_a = body_a.global_transform.origin
	var pos_b = body_b.global_transform.origin
	var delta_vec = pos_b - pos_a
	var distance = delta_vec.length()

	if distance > max_length:
		var direction = delta_vec.normalized()
		var force = direction * (distance - max_length) * stiffness

		# 서로 당기는 방향으로 힘을 가함
		body_a.apply_central_impulse(force)
		body_b.apply_central_impulse(-force)
