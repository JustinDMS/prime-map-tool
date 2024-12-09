class_name Room extends ColorRect

signal started_hover
signal stopped_hover
signal clicked

const HOVER_COLOR := Color.YELLOW
const UNREACHABLE_COLOR := Color.WEB_GRAY
const ROOM_COLOR : Array[Color] = [
	"#999999",
	"#FFA400",
	"#CADBC8",
	"#3E5641",
	"#392F5A",
	"#A4031F",
	"#700000"
]

var region : int = 0
var data : RoomData = null
var is_hovered : bool = false:
	set(value):
		if is_hovered == value:
			return
		
		is_hovered = value
		if is_hovered:
			started_hover.emit(self)
		else:
			stopped_hover.emit(self)

func _input(event: InputEvent) -> void:
	if not data:
		return
	
	if is_hovered and event.is_action("press") and event.is_pressed():
		room_clicked()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	if data:
		init_room()

func init_room() -> ColorRect:
	set_color(ROOM_COLOR[region]) 
	
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
	
	mouse_entered.connect(room_hover)
	mouse_exited.connect(room_stop_hover)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	return self

func set_region(new_region : int) -> void:
	region = new_region

func set_region_color() -> void:
	set_color(ROOM_COLOR[region]) 

func room_hover() -> void:
	set_color(HOVER_COLOR)
	is_hovered = true

func room_stop_hover() -> void:
	set_region_color()
	is_hovered = false

func set_room_unavailable() -> void:
	set_color(UNREACHABLE_COLOR)

func room_clicked() -> void:
	print(data.name)
	clicked.emit()
