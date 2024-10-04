extends Node2D

var a_list: Array[Vector2]
var b_list: Array[Vector2]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Laser.add_point(position)
	$Laser.add_point(get_endpoint())
	for i in range(40):
		var a := Vector2(randf()*1400 + 200, randf()*800 + 100)
		a_list.append(a)
		b_list.append(a + Vector2.from_angle(randf()*2*PI)*(randf()*60 + 40))


func get_endpoint() -> Vector2:
	var mouse := get_local_mouse_position()
	var len := position.distance_to(mouse)
	return (mouse - position)*4000/len + position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Laser.points[1] = get_endpoint()
	queue_redraw()
	
func _draw() -> void:
	draw_circle($circle.position, 200., Color.LIGHT_CORAL)
	var res := Borders.get_circle_intersections($circle.position, 200., position, get_local_mouse_position() - position)
	for i in range(a_list.size()):
		var bline := Borders.BorderLine.new()
		bline.vert1 = a_list[i]
		bline.vert2 = b_list[i]
		var state := Borders.get_closer($circle.position, bline, position, get_local_mouse_position())
		draw_line(a_list[i], b_list[i], [Color.RED, Color.GREEN, Color.BLUE][state], 10.)
		draw_circle(a_list[i], 10, Color.WHITE)
	if is_nan(res.x): return
	draw_circle(Vector2(res.x, res.y), 20, Color.BLACK)
	draw_circle(Vector2(res.z, res.w), 20, Color.WHITE)
	
