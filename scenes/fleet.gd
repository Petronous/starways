class_name Fleet extends Node2D

var ler: Lerp
var start: Star
var end: Star

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@warning_ignore("shadowed_variable")
func send(start: Star, end: Star) -> void:
	ler = Lerp.new(start.position, end.position, finish)
	add_child(ler)
	self.start = start
	self.end = end

func finish():
	if start.empire != end.empire: start.try_attack(end)
	else: end.army += 1
	get_parent().remove_child(self)
	queue_free()
