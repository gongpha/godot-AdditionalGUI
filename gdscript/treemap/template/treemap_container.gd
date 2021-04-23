extends Container
class_name TreeMapRectContainer

export(int) var _initial_weight : float = 1

var _my_level : int = 0
var _root : TreeMapRectContainer

class TreeMapContainer :
	extends TreeMap
	
	func get_data_weight(data) -> float :
		return data[0]

var treemap : TreeMapContainer

func _ready() :
	treemap = TreeMapContainer.new()
	get_tree().connect("node_added", self, "_node_added")
	get_tree().connect("node_removed", self, "_node_removed")
	get_tree().connect("node_renamed", self, "_node_renamed")
	
func _node_added(node : Node) :	
	queue_sort()
	
func _node_removed(node : Node) :
	queue_sort()
	
func _node_renamed(node : Node) :
	queue_sort()
	
func set_data_weight(idx : int, weight : float) :
	treemap.get_data(idx)[0] = weight
	
func get_data_weight(idx : int) -> float :
	return treemap.get_data(idx)[0]
	
func _update_hierarchy() :
	pass
	
func _travel_for_hierarchy(int_ : int) :
	_my_level = int_
	_update_hierarchy()
	for c in get_children() :
		if c.has_method("_travel_for_hierarchy") :
			c._travel_for_hierarchy(int_ + 1)

func _notification(what) :
	if what == NOTIFICATION_PARENTED or what == NOTIFICATION_UNPARENTED :
		var parent := get_parent() as TreeMapRectContainer
		if not parent :
			_root = self
		else :
			_root = parent._root
		
		_root._travel_for_hierarchy(0)
		
	if what == NOTIFICATION_SORT_CHILDREN :
		treemap.set_rect(Rect2(Vector2(), get_rect().size))
		treemap.clear_data()
		
		var msize : Vector2
		if get_combined_minimum_size() != Vector2() :
			msize = get_combined_minimum_size()
		else :
			msize = Vector2(50, 50)
		if get_size() < msize :
			hide()
		else :
			show()
		
		var nodes := [] # List<{int, Control*}>
		for c in get_children() :
			var con := c as Control
			if not con :
				continue
			nodes.append([treemap.add_data([_initial_weight, con]), con])
			#print("node +" + str(con))
			
		for c in nodes :
			fit_child_in_rect(c[1], treemap.get_cached_rect(c[0]))
			#print("ps =" + str(treemap.get_cached_rect(c[0])))
