extends Node3D

@onready var pivot = $Pivot
@onready var camera = $Pivot/Camera3D

var orbiting := false
var panning := false
var last_mouse_pos := Vector2.ZERO

var distance := 60.0  # 초기 줌 거리
var zoom_speed := 1.2
var min_distance := 10.0
var max_distance := 100.0

func _ready():
	update_camera_position()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			orbiting = event.pressed

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance /= zoom_speed
			distance = clamp(distance, min_distance, max_distance)
			update_camera_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance *= zoom_speed
			distance = clamp(distance, min_distance, max_distance)
			update_camera_position()

	elif event is InputEventMouseMotion:
		var delta = event.relative
		if orbiting:
			rotate_camera(delta)
		elif panning:
			pan_camera(delta)

func rotate_camera(delta: Vector2):
	var rotation_speed = 0.005
	rotate_y(-delta.x * rotation_speed)
	pivot.rotate_x(-delta.y * rotation_speed)
	pivot.rotation_degrees.x = clamp(pivot.rotation_degrees.x, -85, 85)

func pan_camera(delta: Vector2):
	var pan_speed = 0.01 * distance
	var right = -pivot.transform.basis.x
	var up = transform.basis.y
	var offset = (right * delta.x + up * delta.y) * pan_speed
	pivot.position += offset

func update_camera_position():
	camera.transform.origin = Vector3(0, 0, distance)
