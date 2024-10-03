extends Camera2D

@onready var target_zoom := zoom.x
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"): target_zoom *= 1.1
	elif event.is_action_pressed("zoom_out"): target_zoom /= 1.1
	
	
func _process(_dt: float) -> void:
	if target_zoom < zoom.x*.99 or target_zoom > zoom.x*1.01: mult_zoom(sqrt(target_zoom/zoom.x))
	
	
func mult_zoom(mult:float) -> void:
	var prev := get_local_mouse_position()
	zoom *= mult
	var curr := get_local_mouse_position()
	position += prev - curr
	
