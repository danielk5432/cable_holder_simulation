extends ConeTwistJoint3D

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot.x" : rotation.x,
		"rot.y" : rotation.y,
		"rot.z" : rotation.z
	}
	return save_dict
