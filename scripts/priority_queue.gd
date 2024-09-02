class_name PriorityQueue extends RefCounted

var values: PackedInt32Array = [0]
var priorities: PackedInt32Array = [0]


func empty() -> bool:
	assert(priorities.size() >= 1, "Too empty")
	return priorities.size() <= 1


func push(val: int, pri: int) -> void:
	var idx: int = priorities.size()
	values.append(val)
	priorities.append(pri)
	_bubble_up(idx)


func top() -> int:
	return values[1]


func pop() -> int:
	assert(priorities.size() > 1, "Popped empty heap")
	var val: int = top()
	_swap(1, priorities.size() - 1)
	priorities.remove_at(priorities.size()-1)
	values.remove_at(values.size()-1)
	_bubble_down(1)
	
	return val
	
	
func _swap(i: int, j: int) -> void:
	var temp:int = values[i]
	values[i] = values[j]
	values[j] = temp
	temp = priorities[i]
	priorities[i] = priorities[j]
	priorities[j] = temp


func _bubble_up(i: int) -> void:
	while i > 1: 
		if priorities[i/2] < priorities[i]: _swap(i, i/2)
		else: break
		i /= 2


func _bubble_down(i: int) -> void:
	while i*2 < priorities.size():
		var swap_target:int = 0
		var lchild:int = i*2
		var rchild:int = i*2 + 1
		if rchild >= priorities.size() or priorities[lchild] > priorities[rchild]: 
			swap_target = lchild
		else: swap_target = rchild
		
		if priorities[swap_target] < priorities[i]: break
		_swap(i, swap_target)
		i = swap_target


func _test():
	var to_add = [4, 1, 3, 5, 2]
	var res = []
	for i in to_add:
		push(i, i)
		print(values, priorities)
	while not empty():
		res.append(pop())
	assert(res == [5, 4, 3, 2, 1])
	assert(priorities.size() == 1 and priorities[0] == 0)
	assert(values.size() == 1 and values[0] == 0)
