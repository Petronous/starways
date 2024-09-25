class_name Empire extends RefCounted

const material_template: ShaderMaterial = preload("res://scenes/color_tinter.tres")
var world: World

var color: Color:
	set(val):
		color = val
		material.set_shader_parameter("color_tint", val)
var stars_count: int = 0:
	set(val):
		stars_count = val
		if stars_count == 0: destroy()
var id: int
var name: String
var material: ShaderMaterial
var requests: PriorityQueue = PriorityQueue.new()
var start_boost: float = 3
var process_timer: Timer = Timer.new()



func init(world_: World, id_: int) -> void:
	material = material_template.duplicate()
	color = Color.from_hsv(randf(), 1, 1, 1)
	world = world_
	id = id_
	name = "Empire " + str(id)
	
	(func(): 
		world.add_child(process_timer)
		process_timer.start(1)
		process_timer.timeout.connect(_process)
	).call_deferred()

	
func _process() -> void:
	start_boost -= 3/20.
	if start_boost < 0:
		start_boost = 0
		process_timer.stop()
	
func neutral() -> bool:
	return id == 0
	
func conquer(star: Star):
	star.empire.lose_star()
	stars_count += 1
	star.set_empire(self)
	if stars_count == 1: star.capital = true
	else: star.capital = false

func lose_star():
	stars_count -= 1
	
func set_neutral():
	name = "Neutral"
	process_timer.stop()
	start_boost = 0
	color = Color(1,1,1,1)
	
func destroy():
	assert(stars_count == 0)
	if neutral(): return
	process_timer.queue_free()
	world.remove_child(process_timer)
	world.empires.erase(self)
