extends Control
var _cache := []

class TreeMapControl :
	extends TreeMap
	
	func update() -> Array :
		update_tree()
		var cache := []
		var idx : int = 0
		for i in _rendered_rects_cache :
			var stats := {
				"data" : get_data(idx),
				"total" : get_total(),
				"max" : get_max(),
				"min" : get_min()
			}
			cache.push_back([i, stats])
			idx += 1
			
		return cache

var treemap : TreeMapControl

func _ready() :
	treemap = TreeMapControl.new()
	
	connect("resized", self, "_resized")
	yield(get_tree(), "idle_frame")
	_resized()
	
func _resized() :
	treemap.set_rect(get_rect())
	update_tree()
		
func update_tree() :
	_cache = treemap.update()
	update()
	
func add_data(data) -> int :
	var returned := treemap.add_data(data)
	update_tree()
	return returned
	
func remove_data(idx : int) :
	var returned = treemap.remove_data(idx)
	update_tree()
	return returned
	
func clear_data() -> void :
	treemap.clear_data()

func _draw() :
	for i in _cache :
		draw_item(i[0], i[1])

func draw_item(rect : Rect2, stats : Dictionary) :
	pass # Abstract
