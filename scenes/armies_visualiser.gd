class_name ArmiesVisualizer extends Node2D
const army_template: PackedScene = preload("res://scenes/army.tscn")

var armies: Array[Sprite2D] = []
var old_max: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = randf()*2*PI


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += delta*.7
	
	
func del_armies(target: int) -> void:
	assert(target >= 0)
	while armies.size() > target:
		var to_remove = armies.pop_back()
		remove_child(to_remove)
		to_remove.queue_free()

func add_armies(target: int) -> void:
	assert( target <= old_max)
	while armies.size() < target:
		var army: Sprite2D = army_template.instantiate()
		army.rotation = float(armies.size())/old_max * 2*PI
		armies.append(army)
		add_child(army)

func set_armies(count: int, mx: int = 9) -> void:
	assert(0 <= count)
	count = min(count, mx)
	if old_max != mx:
		del_armies(0)
		old_max = mx
	del_armies(count)
	add_armies(count)
