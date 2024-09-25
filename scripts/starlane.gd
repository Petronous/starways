class_name Lane
extends Line2D

var star1: Node2D
var star2: Node2D
var length: float
const INNER := 1
const BORDER := 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func initialize(s1:Node2D, s2:Node2D):
	star1 = s1
	star2 = s2
	length = s1.position.distance_to(s2.position)
	add_point(s1.position)
	add_point(s2.position)
	
func set_color(col: Color) -> void:
	default_color = col
func set_neutral() -> void:
	default_color = Color.DARK_GRAY
