class_name Room extends ColorRect

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
	"#CADBC8",
	"#627264",
	"#BC96E6",
	"#A4031F",
	"#700000"
]
const HOVER_COLOR := Color.YELLOW
const UNREACHABLE_COLOR := Color.WEB_GRAY

var region : int = 0
var data : RoomData = null
var state := State.DEFAULT
var prev_state := State.DEFAULT ## Used to return to after hovering
var is_hovered : bool = false:
	set(value):
		if is_hovered == value:
			return
		
		is_hovered = value
		if is_hovered:
			started_hover.emit(self)
		else:
			stopped_hover.emit(self)

func _gui_input(event: InputEvent) -> void:
	if not data:
		return
	
	if is_hovered and event.is_action("press") and event.is_pressed():
		room_clicked()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	mouse_entered.connect(room_hover)
	mouse_exited.connect(room_stop_hover)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	
	if data:
		init_room()

func init_room():
	region = data.region
	
	var x1 : float = data.aabb[0]
	var y1 : float = data.aabb[1]
	var _z1 : float = data.aabb[2]
	var x2 : float = data.aabb[3]
	var y2 : float = data.aabb[4]
	var _z2 : float = data.aabb[5]
	
	position.x = x1
	position.y = y1
	
	size.x = abs(x2 - x1)
	size.y = abs(y2 - y1)
	
	set_state(State.DEFAULT)

func change_to_color(new_color : Color) -> void:
	const DURATION : float = 0.2
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "color", new_color, DURATION)

func set_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	match state:
		State.DEFAULT:
			change_to_color(ROOM_COLOR[region])
		State.HOVERED:
			change_to_color(HOVER_COLOR)
		State.UNREACHABLE:
			change_to_color(UNREACHABLE_COLOR)

func room_hover() -> void:
	set_state(State.HOVERED)
	is_hovered = true

func room_stop_hover() -> void:
	set_state(prev_state)
	is_hovered = false

func room_clicked() -> void:
	print_debug(data.name)
	clicked.emit()
