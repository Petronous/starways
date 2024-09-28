class_name World
extends Node2D

@export var worldsize: int = 4

var stars: StarCollection = StarCollection.new()
var requests: PriorityQueue = PriorityQueue.new()
var empires: Array[Empire] = []
var emp_id_counter: int = 0
var running: bool = false

func _enter_tree() -> void:
	$Camera2D.zoom = Vector2(6./worldsize, 6./worldsize)
	var emp = Empire.new()
	emp.init(self, emp_id_counter)
	emp_id_counter += 1
	emp.set_neutral()
	empires.append(emp)
	stars.init(self, self)
	for x in range(worldsize):
		for y in range(worldsize):
			var pos_scale = 150
			make_star((x - (worldsize-1)/2. + randf()/3.)*pos_scale, 
					(y - (worldsize-1)/2. + randf()/3.)*pos_scale
				)
	for x in range(worldsize):
		for y in range(worldsize):
			var this_id = _pos_to_id(x, y, worldsize)
			var right_id = _pos_to_id(x+1, y, worldsize)
			var down_id = _pos_to_id(x, y+1, worldsize)
			var diag_id = _pos_to_id(x+1, y+1, worldsize)
			if x+1 < worldsize: stars.connect_stars(this_id, right_id)
			if y+1 < worldsize: stars.connect_stars(this_id, down_id)
			if x+1 < worldsize and y+1 < worldsize:
				if randf() < .33: stars.connect_stars(right_id, down_id)
				if randf() < .33: stars.connect_stars(this_id, diag_id)
	make_empire(stars.stars.pick_random())


func _ready() -> void:
	running = true


func make_star(x: int, y: int) -> void:
	var star: Star = stars.make_star(x, y)
	star.requests = requests
	star.set_empire(empires[0])
	
func make_empire(star: Star) -> void:
	var emp := Empire.new()
	emp.init(self, emp_id_counter)
	emp_id_counter += 1
	empires.append(emp)
	emp.conquer(star)
	star.army = 3

func _pos_to_id(x:int, y:int, xsz:int) -> int:
	return x*xsz + y

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
