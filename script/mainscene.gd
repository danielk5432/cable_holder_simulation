extends Node3D

var rotate_flag = false

func _input(event):
	if event.is_action_pressed("spinclock") and rotate_flag:
		pass
	elif event.is_action_pressed("spincounterclock") and rotate_flag:
		pass
	if event.is_action_released("spinclock") or event.is_action_released("spincounterclock"):
		pass
