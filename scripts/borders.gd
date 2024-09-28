class_name Borders extends CanvasItem

var points: PackedVector2Array
var assigned_verts: Array[PackedInt32Array]
var verts: PackedVector2Array
var borders: Array[Vector4i] = []
var max_radius: float
var max_sq_radius: float

func _init(from: Array[Node2D], max_radius: float = 300) -> void:
	for node in from:
		points.append(node.position)
	for i in range(points.size()):
		calculate_borders(i)
	self.max_radius = max_radius
	max_sq_radius = max_radius*max_radius

func calculate_borders(i: int) -> void:
	var this: Vector2 = points[i]
	for j in range(i+1, points.size()):
		var other: Vector2 = points[j]
		if this.distance_squared_to(other) > max_sq_radius: continue
		var origin: Vector2 = (this + other) / 2.0 - this # 0,0 at the circle center
		
		
static func get_circle_intersections(c_pos: Vector2, c_radius: float, 
		line_origin: Vector2, line_dir: Vector2) -> Vector4:
	var o := line_origin - c_pos
	var l := line_dir
	var a := l.length_squared()
	var b := 2*(o.x*l.x + o.y*l.y)
	assert(b == 2*o.dot(l))
	var c := o.length_squared() - c_radius*c_radius
	var d := b*b - 4*a*c
	if d < 0:
		return Vector4(NAN, NAN, NAN, NAN)
	d = sqrt(d)
	var t1 := (-b + d)/(2*a)
	var t2 := (-b - d)/(2*a)
	return Vector4(t1*l.x,t1*l.y,t2*l.x,t2*l.y)
