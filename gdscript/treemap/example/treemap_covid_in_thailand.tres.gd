extends "res://gdscript/treemap/treemap_control.gd"

class TreeMapCovidInThailand :
	extends "res://gdscript/treemap/treemap_control.gd".TreeMapControl
	
	func get_data_weight(data) -> float :
		return data[1]
	
func get_data_name(data) -> float :
	return data[0]

func get_data_weight(data) -> float :
	return data[1]

func draw_item(rect : Rect2, stats : Dictionary) :
	var col := Color(1,0,0)
	var a : float = get_data_weight(stats["data"])
	var b : float = get_data_weight(stats["max"])
	var c : float = a / b
	col.g = 1 - c
	col.b = 1 - c
	
	draw_rect(rect, col, true)
	var font := get_font("")
	var size := font.get_string_size(str(get_data_weight(stats["data"])))
	var pos := Vector2(-size.x / 2, size.y / 4) + rect.position + rect.size / 2
	draw_string(font, pos.round(), str(get_data_weight(stats["data"])), Color.black)
	
	size = font.get_string_size(str(get_data_name(stats["data"])))
	pos = Vector2(-size.x / 2, size.y / 4 + 20) + rect.position + rect.size / 2
	draw_string(font, pos.round(), str(get_data_name(stats["data"])), Color.black)

func _ready() :
	treemap = TreeMapCovidInThailand.new()
	
	#yield(get_tree(), "idle_frame")
	#for i in range(100) :
	#	add_data(["", round(rand_range(1, 80))])\
	#yield(get_tree(), "idle_frame")
	# Covid-19 in Thailand (by province "Changwat")
	# Data from April 19, 2021
	
	add_data(["Samut Sakon", 17756])
	add_data(["Bangkok", 8056])
	add_data(["Chiang Mai", 2651])
	add_data(["Chonburi", 2190])
	add_data(["Nonthaburi", 1257])
	add_data(["Samut Prakan", 1238])
	add_data(["Pathumtani", 1056])
	add_data(["Prachuap Kirikan", 907])
	add_data(["Rayong", 880])
	add_data(["Narathiwat", 513])
#	add_data(["Phuket", 478])
#	add_data(["Nakhon Pathom", 466])
#	add_data(["Songkhla", 457])
#	add_data(["Tak", 389])
#	add_data(["Nakhon Ratchasima", 360])
#	add_data(["Surattani", 302])
#	add_data(["Phetchaburi", 301])
#	add_data(["Chantaburi", 295])
#	add_data(["Chiang Rai", 269])
#	add_data(["Khonkaen", 248])
