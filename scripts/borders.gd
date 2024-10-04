class_name Borders extends Node2D

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
	center -= na
	var judge = nb - na
	ba -= na
	bb -= na
	var s_c = sign(judge.cross(center))
	assert(s_c != 0)
	var s_ba = sign(judge.cross(ba))
	var s_bb = sign(judge.cross(bb))
	var s_b = sign(s_ba + s_bb)
	if s_c == s_b: 
		if s_ba == 0 or s_bb == 0: return Closer.INTERSECTION
		return Closer.BORDER
	elif s_c == -s_b: return Closer.NEW
	else: return Closer.INTERSECTION
	return 0

func _init(from: Array[Node2D], max_radius_: float = 300) -> void:
	for i in range(from.size()):
		var npoint = BorderCell.new(i, from[i].position)
		points.append(npoint)
	for i in range(points.size()):
		calculate_borders(i)
	max_radius = max_radius_
	max_sq_radius = max_radius*max_radius


func calculate_borders(i: int) -> void:
	var this := points[i]
	for j in range(i+1, points.size()):
		# get a b from intersecting the circle with the this-other bisector
		var other: Vector2 = points[j].pos
		if this.pos.distance_squared_to(other) > max_sq_radius: continue
		var origin: Vector2 = (this.pos + other) / 2.0
		var dir: Vector2 = perpendicular(other - this.pos)
		var res := get_circle_intersections(this.pos, max_radius, origin, dir)
		var a := Vector2(res.x, res.y)
		var b := Vector2(res.z, res.w)
		
		# determine which borders are shadowed by the new line and which intersect it
		var new_borders: Array[BorderLine]
		var intersections: Array[Vector2]
		var intersected: Array[BorderLine]
		var is_shadowed_a := false
		var is_shadowed_b := false
		for border in this.borders:
			match get_closer(this.pos, border, a, b):
				Closer.BORDER: new_borders.append(border)
				Closer.INTERSECTION: 
					intersections.append(
						Geometry2D.segment_intersects_segment(border.vert1, border.vert2, a, b)
					)
					intersected.append(border)
				Closer.NEW: border.destroy(this, borders)
			if this.raycast(border, a): is_shadowed_a = true
			if this.raycast(border, b): is_shadowed_b = true
		
		# if the new line is too far discard it, if it isn't add it and process any intersections
		assert(is_shadowed_a == is_shadowed_b or not intersections.is_empty())
		assert(intersections.size() <= 2)  # both asserts implied by this being voronoi. 
										   # A voronoi cell is always convex, even when in progress
		if is_shadowed_a and is_shadowed_b and intersections.is_empty(): continue
		var n_border: BorderLine
		n_border.cell1 = points[i] 
		n_border.cell2 = points[j]
		if intersections.size() == 0:
			n_border.vert1 = a
			n_border.vert2 = b
		elif intersections.size() == 1:
			pass
		else:
			pass



class BorderLine extends RefCounted:
	var id: int
	var vert1: Vector2
	var neigh1: BorderLine
	var vert2: Vector2
	var neigh2: BorderLine
	var cell1: BorderCell
	var cell2: BorderCell
	
	func destroy(caller: BorderCell, borders: Array[BorderLine]) -> void:
		for cell: BorderCell in [cell1, cell2]:
			if cell == caller: continue
			cell.borders.erase(self)
		borders.erase(self)


class BorderCell extends RefCounted:
	var id: int
	var pos: Vector2
	#var my_verts: Array[int]
	#var my_vert_neighs: Array[Vector2i]
	var borders: Array[BorderLine]
	
	#var real_verts: PackedVector2Array
	
	func _init(id_: int, pos_: Vector2) -> void:
		id = id_
		pos = pos_
		#real_verts = verts
		
	func raycast(border: BorderLine, endpoint: Vector2) -> bool:
		return Geometry2D.segment_intersects_segment(pos, endpoint, border.vert1, border.vert2) != null
