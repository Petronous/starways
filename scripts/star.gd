class_name Star
extends Node2D

# [[otherStar, lane],...]
var connections: Array[Array] = []
var packet_progress: float = 0
const max_prog = 8
var prog_speed = 1
var world: World
var requests: PriorityQueue
var id: int
var requesting: bool = false
var storage: int = 0
var storage_cap = 9
var approach_difficulty = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	packet_progress = randf()*max_prog


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	packet_progress += delta*prog_speed
	if packet_progress >= max_prog:
		packet_progress = randf()*max_prog*0.1
		scale += Vector2(.1, .1)
		#receive_packet()
		await get_tree().create_timer(.1).timeout
		scale -= Vector2(.1, .1)
	try_send_packet()
	if storage > 0: $stored.text = str(storage)
	else: $stored.text = ""


func receive_packet() -> void:
	if storage < storage_cap: storage += 1


func try_send_packet() -> void:
	pass


func set_pos(x: float, y: float) -> void:
	position.x = x
	position.y = y
