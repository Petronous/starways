class_name Star
extends Node2D

# [[otherStar, lane],...]
var connections: Array[Array] = []
var packet_progress: float = 0
const max_prog = 1
var prog_speed = 1
var stockpile: float = 0
var world: World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	packet_progress += delta
	

func set_pos(x: float, y: float):
	position.x = x
	position.y = y
