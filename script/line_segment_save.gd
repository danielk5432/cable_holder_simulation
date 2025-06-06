extends RigidBody3D

var idx

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
	if global_position.x > 20 and global_position.y < -26 and global_position.z > 15:
		global_rotation = Vector3(0, PI/2, PI/-2)
		global_position = Vector3(28, -28, global_position.z)
	elif global_position.x > 15 and global_position.y < -23 and idx > 10:
		global_rotation = Vector3(0, global_rotation.y, PI/-2)
		global_position = Vector3(global_position.x, -28, global_position.z)
