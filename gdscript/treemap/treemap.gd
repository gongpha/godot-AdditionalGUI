extends Reference
class_name TreeMap

var _input_arr := [] # Vector<...>
var _total_cache : float = 0
var _rendered_rects_cache := []
var _rect : Rect2

var _min_data # Data*
var _max_data # Data*

func _update_min_max() :
	if _input_arr.empty() :
		_min_data = null
		_max_data = null
		
	for i in _input_arr :
		if not _min_data :
			_min_data = i
		if not _max_data :
			_max_data = i
		
		var w := get_data_weight(i)
		
		if w < get_data_weight(_min_data) :
			_min_data = i
		if w > get_data_weight(_max_data) :
			_max_data = i
	
func add_data(data) -> int :
	_input_arr.append(data)
	_total_cache += get_data_weight(data)
	_update_min_max()
	update_tree()
	return _input_arr.size() - 1
	
func remove_data(idx : int) :
	var data_ = _input_arr[idx]
	_input_arr.remove(idx)
	_total_cache -= get_data_weight(data_)
	_update_min_max()
	update_tree()
	return data_
	
func get_data(idx : int) :
	return _input_arr[idx]
	
func get_total() -> float :
	return _total_cache
	
func get_min() :
	return _min_data
	
func get_max() :
	return _max_data
	
func clear_data() -> void :
	_input_arr.clear()
	_total_cache = 0
	update_tree()
	
func get_data_weight(data) -> float :
	return data
	
func set_data_weight(data, weight : float) :
	data = weight
	
func get_cached_rect(idx : int) -> Rect2 :
	return _rendered_rects_cache[idx]
	
func set_rect(rect : Rect2) -> void :
	_rect = rect
	update_tree()
	
func get_rect() -> Rect2 :
	return _rect
	
func update_tree() : # Protected
	_rendered_rects_cache = Squatify.squarify(_input_arr, _rect, self, "get_data_weight")
