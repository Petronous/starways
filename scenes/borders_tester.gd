extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Laser.add_point(position)
	$Laser.add_point(get_endpoint())
	

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
	if is_nan(res.x): return
	draw_circle(Vector2(res.x, res.y), 20, Color.BLACK)
	draw_circle(Vector2(res.z, res.w), 20, Color.WHITE)
