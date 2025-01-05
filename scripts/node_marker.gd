class_name NodeMarker extends Sprite2D

signal started_hover
signal stopped_hover

const DOOR_COLOR_MAP := {
	"Normal Door" : Color.DEEP_SKY_BLUE,
	"Wave Door" : Color.MEDIUM_PURPLE,
	"Ice Door" : Color.ALICE_BLUE,
	"Plasma Door" : Color.ORANGE_RED,
	"Missile Blast Shield (randomprime)" : Color.DARK_GRAY,
	"Permanently Locked" : Color.BLACK,
	"Circular Door" : Color.DEEP_SKY_BLUE,
	"Square Door" : Color.DEEP_SKY_BLUE,
}

const COLOR_MAP := {
	"teleporter" : Color.PURPLE,
	"morph_ball" : Color.ORCHID,
	"pickup" : Color.DARK_ORANGE,
	"event" : Color.INDIAN_RED,
	"generic" : Color.WHEAT,
}
const DOOR_MARKER_OFFSET : float = 50.0

var data : NodeData = null
var target_color : Color
var _is_hovered : bool = false:
	set(value):
		if _is_hovered == value:
			return
		
		_is_hovered = value
		if _is_hovered:
			node_hover()
			started_hover.emit(self)
		else:
			node_stop_hover()
			stopped_hover.emit(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_is_hovered = Rect2(offset - (texture.get_size() * 0.5), texture.get_size()).has_point(get_local_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if not data:
		return
	
	if _is_hovered and event.is_action("press") and event.is_pressed():
		node_clicked()

func _ready() -> void:
	if data:
		init_node()

func init_node() -> void:
	texture = preload("res://data/icons/node_marker.png")
	
	position = Vector2(
		data.coordinates.x,
		data.coordinates.y
	)
	
	name = "n_%s" % data.display_name
	toggle_visible(false)
	
	if data.node_type == "dock":
		match data.dock_type:
			"door":
				target_color = DOOR_COLOR_MAP[data.default_dock_weakness]
				rotation_degrees = data.rotation.z
				offset.x = -DOOR_MARKER_OFFSET
			"teleporter", "morph_ball":
				target_color = COLOR_MAP[data.dock_type]
		self_modulate = target_color
		return
	target_color = COLOR_MAP[data.node_type]
	self_modulate = target_color

func node_clicked() -> void:
	print(data.display_name)

func node_hover() -> void:
	_is_hovered = true
	print("Hovered %s" % data.display_name)

func node_stop_hover() -> void:
	_is_hovered = false

func toggle_visible(on : bool) -> void:
	const VISIBILITY_CHANGE_DURATION : float = 0.25
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		self, 
		"self_modulate", 
		target_color if on else Color.TRANSPARENT, 
		VISIBILITY_CHANGE_DURATION
		)
