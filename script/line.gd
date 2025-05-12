@tool
extends MeshInstance3D

@export var point_a: Vector3 = Vector3(0, 0, 0) : set = _on_property_changed
@export var point_b: Vector3 = Vector3(0, 2, 0) : set = _on_property_changed
@export var radius: float = 0.1 : set = _on_property_changed
@export var tube_radius: float = 0.02 : set = _on_property_changed
@export var coils: int = 10 : set = _on_property_changed
@export var segments_per_coil: int = 16 : set = _on_property_changed
@export var ring_segments: int = 8 : set = _on_property_changed

func _ready():
	generate_spring()

func _on_property_changed(value):
	generate_spring()
	return value  # 반드시 value 반환해야 함

func generate_spring():
	var dir = point_b - point_a
	var height = dir.length()
	if height == 0:
		return
	var up = dir.normalized()
	var total_segments = coils * segments_per_coil

	# A → B 방향으로 바라보는 회전 행렬
	var basis = Transform3D().looking_at(point_b, Vector3.UP).basis

	# 단면용 원형 좌표 저장
	var ring_points = []
	for i in range(ring_segments):
		var theta = TAU * float(i) / ring_segments
		ring_points.append(Vector3(cos(theta) * tube_radius, 0, sin(theta) * tube_radius))

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for seg in range(total_segments):
		var t0 = float(seg) / total_segments
		var t1 = float(seg + 1) / total_segments

		var angle0 = t0 * coils * TAU
		var angle1 = t1 * coils * TAU

		var y0 = t0 * height
		var y1 = t1 * height

		var center0 = Vector3(radius * cos(angle0), y0, radius * sin(angle0))
		var center1 = Vector3(radius * cos(angle1), y1, radius * sin(angle1))

		# 현재 스프링 부분의 회전 기준 좌표계 생성
		var tangent = (center1 - center0).normalized()
		var normal = Vector3.UP
		if abs(tangent.dot(normal)) > 0.99:
			normal = Vector3.FORWARD
		var binormal = tangent.cross(normal).normalized()
		normal = binormal.cross(tangent).normalized()
		var rot_basis = Basis(tangent, normal, binormal).transposed()

		for i in range(ring_segments):
			var p0 = rot_basis * ring_points[i] + center0
			var p1 = rot_basis * ring_points[(i + 1) % ring_segments] + center0
			var p2 = rot_basis * ring_points[i] + center1
			var p3 = rot_basis * ring_points[(i + 1) % ring_segments] + center1

			# 삼각형 두 개로 사각형 면 구성
			st.add_vertex(basis * p0 + point_a)
			st.add_vertex(basis * p2 + point_a)
			st.add_vertex(basis * p1 + point_a)

			st.add_vertex(basis * p1 + point_a)
			st.add_vertex(basis * p2 + point_a)
			st.add_vertex(basis * p3 + point_a)

	var mesh = ArrayMesh.new()
	st.commit(mesh)
	self.mesh = mesh
