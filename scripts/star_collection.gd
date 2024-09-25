class_name StarCollection extends RefCounted

const star_scene = preload("res://scenes/star.tscn")
const lane_scene = preload("res://scenes/starlane.tscn")
var stars:Array[Star] = []
var nav_graph: AStar2D = AStar2D.new()
var parent: Node2D
var world: World

func init(parent_: Node2D, world_: World):
	parent = parent_
	world = world_


func make_star(x:int, y:int) -> Star:
	var star:Star = star_scene.instantiate()
	star.set_pos(x, y)
	star.world = world
	star.id = stars.size()
	world.add_child(star)
	stars.append(star)
	nav_graph.add_point(star.id, Vector2(x, y))
	return star


func connect_stars(i: int, j: int):
	var lane:Lane = lane_scene.instantiate()
	lane.initialize(stars[i], stars[j])
	world.add_child(lane)
	stars[i].neighbors.append(stars[j])
	stars[i].lanes.append(lane)
	stars[j].neighbors.append(stars[i])
	stars[j].lanes.append(lane)
	nav_graph.connect_points(i, j)
