class_name Packet extends Node2D

var size: int = 1
var ler: Lerp
var end: Star
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func init(start: Star, end_: Star) -> void:
	ler = Lerp.new(start.position, end_.position, finish)
	add_child(ler)
	end = end_


func finish() -> void:
	end.receive_packet(size)
	get_parent().remove_child(self)
	queue_free()
