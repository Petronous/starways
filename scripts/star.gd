class_name Star
extends Node2D

enum {
	REQ_NONE,
	REQ_NEUTRAL,
	REQ_ENEMY,
}

const max_prog: float = 8
const cycle_interval: float = .33
const fleet_template: PackedScene = preload("res://scenes/fleet.tscn")
const packet_template: PackedScene = preload("res://scenes/packet.tscn")

# [[otherStar, lane],...]
var neighbors: Array[Star] = []
var lanes: Array[Lane] = []
var prog_speed: float = 1:
	set(val):
		prog_speed = val
		if prog_speed <= 0: $ProductionTimer.stop()
		elif $ProductionTimer.is_stopped(): $ProductionTimer.start(max_prog/(prog_speed + empire.start_boost))
	get:
		return prog_speed + empire.start_boost
var world: World
var empire: Empire
var requests: PriorityQueue
var id: int
var request_type: int = REQ_NONE
var storage: int = 0:
	set(val):
		storage = val
		if storage > 0: $StoredLabel.text = str(storage)
		else: $StoredLabel.text = ""
var pending_packets: int = 0

var storage_cap: int = 27
var army: int = 0:
	set(val):
		army = val
		$ArmiesVisualiser.set_armies(army, army_cap)
var army_cap: int = 9:
	set(val):
		army_cap = val
		$ArmiesVisualiser.set_armies(army, army_cap)
var approach_difficulty = 1
var behavior: Callable = standard_mode
var target: Star
var enemies: Array[Star]
var allies: Array[Star]
var fortification = .3
var capital: bool = false


func start_prod_timer(rand_magnitude: float = 0.1) -> void:
	prog_speed = prog_speed - empire.start_boost
	#$DebugLabel.text = str(prog_speed)
	$ProductionTimer.wait_time = max_prog/prog_speed - rand_magnitude*max_prog/prog_speed*randf()
	$ProductionTimer.start()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_prod_timer(1)
	look_through_neighbors()
	pick_behavior()
	behavior.call()
	await get_tree().create_timer(randf()*cycle_interval).timeout
	$CycleTimer.start(cycle_interval*randf())



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func produce() -> void:
	start_prod_timer()
	scale += Vector2(.1, .1)
	await get_tree().create_timer(.1).timeout
	add_storage()
	scale -= Vector2(.1, .1)
	

func add_army() -> void:
	if army < army_cap: army += 1
func add_storage(size: int = 1) -> void:
	if storage < storage_cap: storage += size

func receive_packet(size: int) -> void:
	add_storage(size)
	pending_packets -= 1


func cycle() -> void:
	$DebugLabel.text = str(enemies.size())
	look_through_neighbors()
	pick_behavior()
	behavior.call()
	$CycleTimer.start(cycle_interval)
	
func look_through_neighbors() -> void:
	enemies = []
	allies = []
	if empire.neutral(): return
	for other in neighbors:
		if empire != other.empire: 
			enemies.append(other)
			if not other.empire.neutral() and request_type <= REQ_ENEMY:
				request_type = REQ_ENEMY
		else:
			allies.append(other)
	if enemies.size() > 0 and request_type <= REQ_NEUTRAL: request_type = REQ_NEUTRAL
	if target == null or target not in enemies:
		target = enemies.pick_random() if not enemies.is_empty() else null
	if target == null and request_type <= REQ_ENEMY:
		request_type = REQ_NONE
		
func pick_behavior() -> void:
	if empire.neutral():
		behavior = inert_mode
		return
	if enemies.size() == 0:
		behavior = standard_mode
		return
	else:
		behavior = battle_mode
		return
func inert_mode() -> void:
	prog_speed = 0
	if randf() <= .0005:
		world.make_empire(self)
func battle_mode() -> void:
	standard_mode()
	send_attack()
func standard_mode() -> void:
	prog_speed = 1
	try_send_packet()
	convert_to_armies()
	
func send_attack() -> void:
	if army <= 0: return
	army -= 1
	var fleet: Fleet = fleet_template.instantiate()
	world.add_child.call_deferred(fleet)
	fleet.send(self, target)
	
func try_attack(targ: Star) -> void:
	#assert(targ.empire != empire)
	if randf() < targ.fortification: return
	if targ.army <= 0:
		empire.conquer(targ)
	else:
		targ.army -= 1


func try_send_packet() -> void:
	if storage == 0: return
	if allies.is_empty(): return
	var ally: Star = allies.pick_random()
	if request_type == REQ_NONE:
		if ally.request_type == REQ_NONE and \
		   ally.get_weight() + 1 >= get_weight(): return
	elif ally.get_weight() + 3 >= get_weight(): return
	var packet: Packet = packet_template.instantiate()
	packet.init(self, ally)
	#packet.ler.speed = max(.5, 3 - max(0,(empire.stars_count - 10)/10.))
	world.add_child.call_deferred(packet)
	storage -= 1
	ally.pending_packets += 1
	
func convert_to_armies() -> void:
	if storage >= 3 and army < army_cap:
		add_army()
		storage -= 3


func get_weight() -> int:
	return storage + army*3 - request_type*3 + pending_packets


func set_pos(x: float, y: float) -> void:
	position.x = x
	position.y = y
	
func set_empire(em: Empire) -> void:
	empire = em
	if empire != null: start_prod_timer(1)
	$StarSprite.material = empire.material
	requests = empire.requests
	for lane in lanes:
		if lane.star1.empire == lane.star2.empire and lane.star1.empire:
			lane.set_color(Color.WHITE)
		else:
			lane.set_neutral()
	
#func find_lane(target: Star) -> Lane:
	#for pair in connections:
		#if pair[0] == target:
			#return pair[1]
	#return null
