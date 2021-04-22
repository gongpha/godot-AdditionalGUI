extends Container

var treemap : TreeMap

func _ready() :
	treemap = TreeMap.new()
	
	get_tree().connect("node_added", self, "_node_added")
	get_tree().connect("node_removed", self, "_node_removed")
	get_tree().connect("node_renamed", self, "_node_renamed")
	
func _node_added(node : Node) :	
	queue_sort()
	
func _node_removed(node : Node) :
	queue_sort()

func _notification(what) :
	if what == NOTIFICATION_SORT_CHILDREN :
		treemap.clear_data()
		for c in get_children() :
			var con := c as Control
			if not con :
				continue
				
			var w : float = con.get_name().to_float()
			var idx := treemap.add_data([w, con])
			var rect := treemap.get_cached_rect(idx)
			con.set_position(rect.position)
			con.set_size(rect.size)
				
			
