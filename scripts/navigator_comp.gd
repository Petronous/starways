class_name Navigator extends RefCounted

var navnet: AStar2D
var stars: Array[Star]
var path: PackedInt64Array
var last_id: int = 0
var segment_progress: float = 0
var speed: float
var on_hit: Callable
var on_finish: Callable
var lane: Lane

func init(navnet_: AStar2D, stars_: Array[Star], 
		  onfinish := Callable(), onhit := Callable(), spd := 1.0) -> void:
	navnet = navnet_
	stars = stars_
	speed = spd
	on_hit = onhit
	on_finish = onfinish
	
func gen_path(sid: int, eid: int) -> void:
	path = navnet.get_id_path(sid, eid)
	assert(path.size() > 1)
	
func next(dt: float) -> Vector2:
	segment_progress += speed * dt / get_seg_len()
	while segment_progress >= 1:
		last_id += 1
		segment_progress -= 1
		if not on_hit.is_null(): on_hit.call(path[last_id])
		if last_id == path.size() - 1:
			if not on_finish.is_null(): on_finish.call()
			return get_seg_start()
	
	var s_pos: Vector2 = get_seg_start()
	var e_pos: Vector2 = get_seg_end()
	return s_pos*(1 - segment_progress) + e_pos*segment_progress
	
func heading(parent_pos: Vector2) -> float:
	if last_id >= path.size()-1: return 0
	var target_pos: Vector2 = stars[path[last_id+1]].position
	return parent_pos.angle_to_point(target_pos)

func get_seg_start() -> Vector2:
	return stars[path[last_id]].position
func get_seg_end() -> Vector2:
	return stars[path[last_id + 1]].position

func get_seg_len() -> float:
	return get_seg_start().distance_to(get_seg_end()) / 150.
