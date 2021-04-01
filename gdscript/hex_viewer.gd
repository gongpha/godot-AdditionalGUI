extends Control
class_name HexViewer

export(PoolByteArray) var data : PoolByteArray

var font : Font

var data_lines : int

var visible_lines : int

var cache_ascii_width : int
var cache_address_width : int

export(int) var line_spacing : int = 20
export(int) var bytes_per_line : int = 16
export(int) var character_spacing : int = 10
export(int) var address_margin : int = 50
export(int) var hex_margin : int = 50

onready var vbar := $vbar as VScrollBar
onready var hbar := $hbar as HScrollBar

var static_hex_char_width : int

func _get_hex_width() -> int :
	return static_hex_char_width * bytes_per_line + character_spacing * (bytes_per_line - 1)
	
func _get_all_width() -> int :
	return cache_address_width + address_margin + _get_hex_width() + hex_margin + cache_ascii_width

func _update_scrollbar() :
	
	var size := get_size()
	var hmin := hbar.get_combined_minimum_size()
	var vmin := vbar.get_combined_minimum_size()

	vbar.set_begin(Vector2(size.x - vmin.x, 0))
	vbar.set_end(Vector2(size.x, size.y))

	hbar.set_begin(Vector2(0, size.y - hmin.y))
	hbar.set_end(Vector2(size.x - vmin.x, size.y))
	
	var _max : int = _get_all_width() + vbar.get_size().x
	
	
	if size.x < _max :
		hbar.show()
		hbar.set_page(size.x)
	else :
		hbar.set_value(0)
		hbar.hide()
	
	if visible_lines >= vbar.get_max() :
		vbar.set_value(0)
		vbar.hide()
	else :
		vbar.show()
		vbar.set_page(visible_lines)
	update()

func _update_capacity() :
	data_lines = ceil(data.size() / float(bytes_per_line))
	vbar.set_max(data_lines)
	_update_scrollbar()
	
func _update_line_width() :
	var max_ascii_width : int = 0
	
	var first_line : int = vbar.get_value()
	var hbar_pos : int = -hbar.get_value()
	
	var line = first_line
	
	while line < first_line + visible_lines + 1 :
		var start_ch : int = line * bytes_per_line
		
		var characters_raw := data.subarray(start_ch, min(start_ch + bytes_per_line - 1, data.size()-1))
		var i : int = 0
		for c in characters_raw :
			if (c < 0x20 || c > 0x7e) :
				characters_raw[i] = 0x2e # .
			i += 1
		var characters = characters_raw.get_string_from_ascii()
		
		var text_w : int = font.get_string_size(characters).x
		if (text_w > max_ascii_width) :
			max_ascii_width = text_w
		
		line += 1
	cache_ascii_width = max_ascii_width
	
func _scrolling() :
	update()
	
func _resized() :
	visible_lines = get_size().y / line_spacing
	hbar.set_max(_get_all_width() + vbar.get_size().x)
	_update_scrollbar()

func _gui_input(event):
	if event is InputEventMouseButton :
		
		if event.is_pressed() :
			if (event.button_index == BUTTON_WHEEL_UP) :# && !mb->get_command()
				if (event.get_shift()) :
					hbar.set_value(hbar.get_value() - (100 * event.get_factor()))
				elif vbar.visible :
					vbar.set_value(vbar.get_value() - 3 * event.get_factor())
			if (event.button_index == BUTTON_WHEEL_DOWN) :# && !mb->get_command()
				if (event.get_shift()) :
					hbar.set_value(hbar.get_value() + (100 * event.get_factor()))
				elif vbar.visible :
					vbar.set_value(vbar.get_value() + 3 * event.get_factor())
			update()

func _ready():
	#new
	connect("resized", self, "_resized")
	font = get_font("")
	
	vbar.connect("scrolling", self, "_scrolling")
	hbar.connect("scrolling", self, "_scrolling")
	
	static_hex_char_width = font.get_string_size("00").x
	cache_address_width = font.get_string_size("00000000").x
	
	_update_line_width()
	_update_capacity()
	_resized()
	update()
	
func get_line_number(line : int) -> String :
	var ostr := "%X" % (line * bytes_per_line)
	for s in 8 - ostr.length() :
		ostr = "0" + ostr
	return ostr

func get_byte(byte : int) -> String :
	var ostr := "%X" % byte
	if ostr.length() < 2:
		ostr = "0" + ostr
	return ostr

func _draw():
	
	var first_line : int = vbar.get_value()
	var hbar_pos : int = -hbar.get_value()
	
	
	var line = first_line
	var ypos = line_spacing
	
	while line < first_line + visible_lines + 1 :
		var start_ch : int = line * bytes_per_line
		draw_string(font, Vector2(character_spacing + hbar_pos, ypos), get_line_number(line))
		
		var my_max : int = 0;
		for c in bytes_per_line :
			
			if start_ch + c >= data.size() :
				return
			var aaa := data[start_ch + c]
			var string := get_byte(aaa)
			draw_string(font, Vector2(cache_address_width + address_margin + hbar_pos + (static_hex_char_width * c) + (character_spacing * c), ypos), string, Color.white if c % 2 == 0 else Color.gray)

		var characters_raw := data.subarray(start_ch, min(start_ch + bytes_per_line - 1, data.size()-1))
		var i : int = 0
		for c in characters_raw :
			if (c < 0x20 || c > 0x7e) :
				characters_raw[i] = 0x2e # .
			i += 1
		var characters = characters_raw.get_string_from_ascii()
		draw_string(font, Vector2(_get_all_width() - cache_ascii_width + hbar_pos, ypos), characters)
		
		var text_w : int = font.get_string_size(characters).x
			
		line += 1
		ypos += 1 * line_spacing
