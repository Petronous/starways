class_name Borders extends CanvasItem

var points: Array[BorderCell]
#var verts: PackedVector2Array = []
var borders: Array[BorderLine] = []
var max_radius: float
var max_sq_radius: float

enum Closer {BORDER, INTERSECTION, NEW}

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

static func perpendicular(vec: Vector2) -> Vector2:
	return Vector2(vec.y, -vec.x)

static func get_closer(center: Vector2, border: BorderLine, na: Vector2, nb: Vector2) -> Closer:
	var ba := border.vert1
	var bb := border.vert2
	center -= ba
	var judge = bb - ba
	na -= ba
	nb -= ba
	# TODO: it's more complicated
	#var s_c = sign(judge.cross(center))
	#assert(s_c != 0)
	#var s_na = sign(judge.cross(na))
	#var s_nb = sign(judge.cross(nb))
	#var s_n = sign(s_na + s_nb)
	#if s_c == s_n: return Closer.NEW
	#elif s_c == -s_n: return Closer.BORDER
	#else: return Closer.INTERSECTION
	return 0

func _init(from: Array[Node2D], max_radius_: float = 300) -> void:
	for i in range(from.size()):
		var npoint = BorderCell.new(i, from[i].position, borders)
		points.append(npoint)
	for i in range(points.size()):
		calculate_borders(i)
	max_radius = max_radius_
	max_sq_radius = max_radius*max_radius


func calculate_borders(i: int) -> void:
	var this: Vector2 = points[i].pos
	for j in range(i+1, points.size()):
		var other: Vector2 = points[j].pos
		if this.distance_squared_to(other) > max_sq_radius: continue
		var origin: Vector2 = (this + other) / 2.0
		var dir: Vector2 = perpendicular(other - this)
		var res := get_circle_intersections(this, max_radius, origin, dir)
		var a := Vector2(res.x, res.y)
		var b := Vector2(res.z, res.w)
		var new_borders: Array


class BorderLine extends RefCounted:
	var id: int
	var vert1: Vector2
	var vert2: Vector2
	var cell1: int
	var cell2: int


class BorderCell extends RefCounted:
	var id: int
	var pos: Vector2
	#var my_verts: Array[int]
	#var my_vert_neighs: Array[Vector2i]
	var my_borders: Array[int]
	
	#var real_verts: PackedVector2Array
	var real_borders: Array[BorderLine]
	
	func _init(id_: int, pos_: Vector2, borders: Array[BorderLine]) -> void:
		id = id_
		pos = pos_
		#real_verts = verts
		real_borders = borders
