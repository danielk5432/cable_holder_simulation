extends RigidBody3D

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

func _physics_process(delta):
	if global_position.y < -25 && global_position.x < -23:
		global_rotation = Vector3(0, 0, -PI/2)
		global_position = Vector3(global_position.x, -27, 0)
