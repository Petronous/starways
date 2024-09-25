class_name Lerp extends Node

var start: Vector2
var end: Vector2
var onfinish: Callable
var progress: float = 0
var speed: float = 3

func _init(start_pos: Vector2, end_pos: Vector2, on_finish: Callable, speed_:float = 0) -> void:
	start = start_pos
	end = end_pos
	onfinish = on_finish
	if speed_ > 0: speed = speed_
	
	
func _ready() -> void:
	get_parent().position = start
	
	
func _process(dt:float) -> void:
	progress += speed * dt / start.distance_to(end) * 150.
	if progress >= 1:
		onfinish.call()
		return
	get_parent().position = start*(1 - progress) + end*progress
	get_parent().rotation = start.angle_to_point(end)
