class_name Room extends TextureButton

signal started_hover
signal stopped_hover
signal clicked

enum State {
	DEFAULT,
	HOVERED,
	UNREACHABLE,
}

const ROOM_COLOR : Array[Color] = [
	"#999999",
	"#EA8C55",
	"#C9D6EA",
	"#7FB685",
	"#BC96E6",
	"#A7333F",
	"#700000"
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
const HOVER_COLOR := Color.YELLOW
const UNREACHABLE_COLOR := Color.WEB_GRAY

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

func _gui_input(event: InputEvent) -> void:
	if not data:
		return
	
	if _is_hovered and event.is_action("press") and event.is_pressed():
		room_clicked()

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
	
	set_state(State.DEFAULT)
	hide_nodes.call_deferred()

func change_to_color(new_color : Color) -> void:
	const DURATION : float = 0.2
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "self_modulate", new_color, DURATION)

func show_nodes() -> void:
	const DURATION : float = 0.2
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	for n in get_children():
		tween.tween_property(n, "self_modulate", Color.WHITE, DURATION)

func hide_nodes() -> void:
	const DURATION : float = 0.2
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	for n in get_children():
		tween.tween_property(n, "self_modulate", Color.TRANSPARENT, DURATION)

func set_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	match state:
		State.DEFAULT:
			change_to_color(ROOM_COLOR[region])
		State.HOVERED:
			change_to_color(HOVER_COLOR)
			show_nodes()
		State.UNREACHABLE:
			change_to_color(UNREACHABLE_COLOR)
	
	if prev_state == State.HOVERED:
		hide_nodes()

func room_hover() -> void:
	set_state(State.HOVERED)
	_is_hovered = true

func room_stop_hover() -> void:
	set_state(prev_state)
	_is_hovered = false

func room_clicked() -> void:
	print_debug(data.name)
	clicked.emit()
