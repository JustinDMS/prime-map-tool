class_name Room extends TextureButton

signal started_hover
signal stopped_hover
signal clicked
signal double_clicked(node_data : NodeData)

enum State {
	DEFAULT,
	HOVERED,
	UNREACHABLE,
	STARTER,
}

const OUTLINE_SHADER := preload("res://resources/highlight_shader.tres")
const COLOR_CHANGE_DURATION : float = 0.2

const ROOM_COLOR : Array[Color] = [
	"#EA8C55",
	"#C9D6EA",
	"#7FB685",
	"#BC96E6",
	"#A7333F",
]
## Rooms that need to have their z index increased to better match the game
const MANUAL_Z_ROOMS : Array[String] = [
	"Hall of the Elders",
	
	"Upper Edge Tunnel",
	"Frost Cave Access",
	
	"Life Grove Tunnel",
	"Frigate Crash Site",
	
	"Main Quarry",
	"Security Access B",
	"Omega Research",
	"Elite Control",
	"Elite Research",
	
	"Transport Tunnel C",
	"Warrior Shrine",
]
const HOVER_COLOR := Color.WHITE
const UNREACHABLE_COLOR := Color("#4b7ea3") # Map Blue from Game

var region : int = 0
var data : RoomData = null
var state := State.DEFAULT
var prev_state := State.DEFAULT ## Used to return to after hovering
var _is_hovered : bool = false:
	set(value):
		if _is_hovered == value:
			return
		
		_is_hovered = value
		if _is_hovered:
			started_hover.emit(self)
		else:
			stopped_hover.emit(self)
var room_color_tween : Tween = null
var outline_tween : Tween = null
var node_markers : Array[NodeMarker] = []

func _gui_input(event: InputEvent) -> void:
	if _is_hovered and event.is_action("press") and event.is_pressed():
		if not event.double_click:
			room_clicked()
		else:
			double_clicked.emit(data.default_node)

func _ready() -> void:
	mouse_entered.connect(room_hover)
	mouse_exited.connect(room_stop_hover)
	
	if data and data.texture:
		init_room()

func init_room():
	if data.name in MANUAL_Z_ROOMS:
		z_index += 1
	
	var image := data.texture.get_image()
	image.flip_y()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1)
	texture_normal = data.texture
	texture_click_mask = bitmap
	
	region = data.region
	set_name(data.name)
	
	var x1 : float = data.aabb[0]
	var y1 : float = data.aabb[1]
	var _z1 : float = data.aabb[2]
	var x2 : float = data.aabb[3]
	var y2 : float = data.aabb[4]
	var _z2 : float = data.aabb[5]
	
	position.x = x1
	position.y = y1
	
	custom_minimum_size.x = abs(x2 - x1)
	custom_minimum_size.y = abs(y2 - y1)
	
	material = OUTLINE_SHADER.duplicate()
	material.set_shader_parameter(&"pattern", 1)
	material.set_shader_parameter(&"inside", true)
	
	set_state(State.DEFAULT)

func change_to_color(new_color : Color, duration := COLOR_CHANGE_DURATION) -> void:
	if room_color_tween and room_color_tween.is_valid():
		room_color_tween.kill()
	
	room_color_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	room_color_tween.tween_property(self, "self_modulate", new_color, duration)

func set_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	match state:
		State.DEFAULT:
			change_to_color(ROOM_COLOR[region])
			set_outline(ROOM_COLOR[region], 2)
		State.HOVERED:
			if prev_state == State.STARTER:
				set_outline(Color.GREEN, 3)
			else:
				set_outline(Color.WHITE, 3)
		State.UNREACHABLE:
			change_to_color(UNREACHABLE_COLOR)
			set_outline(Color("#62a5d4"), 2)
		State.STARTER:
			prev_state = State.STARTER
			change_to_color(ROOM_COLOR[region])
			set_outline(Color.GREEN, 8)

func room_hover() -> void:
	set_state(State.HOVERED)
	_is_hovered = true

func room_stop_hover() -> void:
	set_state(prev_state)
	_is_hovered = false

func room_clicked() -> void:
	print_debug(data.name)
	clicked.emit()

func set_outline(color : Color, width : float) -> void:
	const DURATION : float = 0.2
	
	if outline_tween and outline_tween.is_running():
		outline_tween.kill()
	
	outline_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	outline_tween.tween_method(set_outline_color, get_outline_color(), color, DURATION)
	outline_tween.tween_method(set_outline_width, get_outline_width(), width, DURATION)

func set_outline_color(value : Color) -> void:
	material.set_shader_parameter(&"color", value)
func get_outline_color() -> Color:
	return material.get_shader_parameter(&"color")

func set_outline_width(value : float) -> void:
	material.set_shader_parameter(&"width", value)
func get_outline_width() -> float:
	return material.get_shader_parameter(&"width")

func get_global_center() -> Vector2:
	var tmp = size
	tmp.y *= -1
	return global_position + (tmp * 0.5)
