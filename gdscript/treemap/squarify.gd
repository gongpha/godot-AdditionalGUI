extends Reference
class_name Squatify

class TreeMapLayout :
	var container_rect : Rect2
	var datas : Array # Vector<float>
	var total_weight : float
	var is_vertical : bool
	var next : TreeMapLayout
	
	func _sub_rect(rect : Rect2, rect_ : Rect2) :
		if rect_.size.x == rect.size.x :
			return Rect2(rect.position.x, rect.position.y + rect_.size.y, rect.size.x, rect.size.y - rect_.size.y)
		else :
			return Rect2(rect.position.x + rect_.size.x, rect.position.y, rect.size.x - rect_.size.x, rect.size.y)
	
	func _multiply_num(rect : Rect2, num : float) -> Rect2 :
		var ratio := clamp(num, 1e-308, 1)
		if rect.size.x <= rect.size.y :
			return Rect2(rect.position.x, rect.position.y, rect.size.x, rect.size.y * ratio)
		else :
			return Rect2(rect.position.x, rect.position.y, rect.size.x * ratio, rect.size.y)
	
	func _multiply_ori_num(rect : Rect2, is_vertical : bool, weight : float) -> Rect2 :
		var ratio := clamp(weight, 1e-308, 1)
		if is_vertical :
			return Rect2(rect.position.x, rect.position.y, rect.size.x, rect.size.y * ratio)
		else :
			return Rect2(rect.position.x, rect.position.y, rect.size.x * ratio, rect.size.y)
			
	func _rect_aspect_ratio(rect : Rect2) -> float :
		return rect.size.x / rect.size.y if rect.size.x > rect.size.y else rect.size.y / rect.size.x
		
	func get_layout_rects() -> Array :
		var res := [] # Vector<Rect2>
		var last : float = 0
		for d in datas :
			last += d
		var last_rect := _multiply_num(container_rect, last / total_weight)
		for i in datas :
			var this_rect := _multiply_ori_num(last_rect, is_vertical, i / last)
			last_rect = _sub_rect(last_rect, this_rect)
			last -= i
			res.push_back(this_rect)
		return res
			
	func push_data(weight : float) -> TreeMapLayout :
		if datas.empty() :
			datas.append(weight)
			var rect := _multiply_num(container_rect, weight / total_weight)
			is_vertical = rect.size.x < rect.size.y
			if (container_rect.size.x < container_rect.size.y) == is_vertical and total_weight > weight :
				next = TreeMapLayout.new()
				next.container_rect = _sub_rect(container_rect, rect)
				next.total_weight = total_weight - weight
				return next
		else :
			var f_ratio : float = 0
			var total := weight
			for d in datas :
				total += d
			var curr_rect := _multiply_num(container_rect, total / total_weight)
			var last_rect := _multiply_ori_num(curr_rect, is_vertical, datas.back() / total)
			f_ratio = _rect_aspect_ratio(last_rect)
			
			var s_ratio : float = 0
			total = 0
			var next_layout := TreeMapLayout.new()
			for d in datas :
				total += d
			curr_rect = _multiply_num(container_rect, total / total_weight)
			last_rect = _multiply_ori_num(curr_rect, is_vertical, datas.back() / total)
			s_ratio = _rect_aspect_ratio(last_rect)
			
			next_layout.container_rect = _sub_rect(container_rect, curr_rect)
			next_layout.total_weight = total_weight - total
			var rect := _multiply_num(next_layout.container_rect, weight / total_weight)
			next_layout.is_vertical = rect.size.x < rect.size.y
			
			if f_ratio < s_ratio :
				datas.append(weight)
			else :
				next_layout.datas.append(weight)
				next = next_layout
				return next
		return null
		
static func _travel(layout : TreeMapLayout, size : int) -> Array :
	var res := [] # Vector<Rect2>
	#res.resize(size)
	while layout :
		var curr := layout.get_layout_rects()
		res.append_array(curr)
		layout = layout.next
	return res

static func squarify(data_array : Array, rect : Rect2, object : Object, func_to_get_weight : String) -> Array :
	if data_array.empty() :
		return []
	var total : float = 0
	for d in data_array :
		total += object.call(func_to_get_weight, d)
	
	var original := TreeMapLayout.new()
	original.container_rect = rect
	original.total_weight = total
	var curr := original
	for i in data_array :
		var next := curr.push_data(object.call(func_to_get_weight, i))
		if next :
			curr = next
	
	return _travel(original, data_array.size())
