class_name World
extends Node2D

@export var star_scene: PackedScene
@export var lane_scene: PackedScene
@export var worldsize: int = 4

var stars:Array[Star] = []
var requests: PriorityQueue = PriorityQueue.new()
var nav_graph: AStar2D = AStar2D.new()

func _enter_tree() -> void:
	requests._test()
	for x in range(worldsize):
		for y in range(worldsize):
			var pos_scale = 150
			make_star((x - (worldsize-1)/2.)*pos_scale, (y - (worldsize-1)/2.)*pos_scale)
	for x in range(worldsize):
		for y in range(worldsize):
			var this_id = _pos_to_id(x, y, worldsize)
			var right_id = _pos_to_id(x+1, y, worldsize)
			var down_id = _pos_to_id(x, y+1, worldsize)
			var diag_id = _pos_to_id(x+1, y+1, worldsize)
			if x+1 < worldsize: connect_stars(this_id, right_id)
			if y+1 < worldsize: connect_stars(this_id, down_id)
			if x+1 < worldsize and y+1 < worldsize:
				connect_stars(right_id, down_id)
				connect_stars(this_id, diag_id)

func _pos_to_id(x:int, y:int, xsz:int) -> int:
	return x*xsz + y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func make_star(x:int, y:int):
	var star:Star = star_scene.instantiate()
	star.set_pos(x, y)
	star.world = self
	star.requests = requests
	star.id = stars.size()
	add_child(star)
	stars.append(star)
	nav_graph.add_point(star.id, Vector2(x, y))


func connect_stars(i: int, j: int):
	var lane:Lane = lane_scene.instantiate()
	lane.initialize(stars[i], stars[j])
	add_child(lane)
	stars[i].connections.append([stars[j], lane])
	stars[j].connections.append([stars[i], lane])
	nav_graph.connect_points(i, j)
