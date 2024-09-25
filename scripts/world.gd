class_name World
extends Node2D

@export var worldsize: int = 4
var bg_mat: ShaderMaterial


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
	bg_mat = $CanvasLayer/ColorRect.material
	redraw_bg()
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

func redraw_bg(shift:Vector2 = Vector2(0., 0.)) -> void:
	pass
	#var stars_num: int = stars.stars.size()
	#assert(stars_num <= 1024)
	#bg_mat.set_shader_parameter("stars_num", stars_num)
	#var stars_pos: PackedVector2Array = []
	#var stars_col: PackedVector3Array = []
	#stars_pos.resize(1024)
	#stars_col.resize(1024)
	#var size: float = min(get_viewport_rect().size.x, get_viewport_rect().size.y)
	#for i in range(stars_num):
		#var star: Star = stars.stars[i]
		#var pos: Vector2 = star.get_global_transform_with_canvas().origin - shift
		#pos.x /= size
		#pos.y /= size
		#stars_pos[i] = pos
		#var col: Color = star.empire.color
		#if star.empire.neutral(): col = Color(0.1,0.1,0.1,1)
		#stars_col[i] = Vector3(col.r, col.g, col.b)
	#bg_mat.set_shader_parameter("stars_pos", stars_pos)
	#bg_mat.set_shader_parameter("stars_cols", stars_col)
	#bg_mat.set_shader_parameter("scale", $Camera2D.zoom.x)
	#$CanvasLayer/ColorRect.queue_redraw()

func _pos_to_id(x:int, y:int, xsz:int) -> int:
	return x*xsz + y

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
