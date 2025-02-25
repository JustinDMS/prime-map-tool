class_name NodeMarker extends Sprite2D

signal started_hover
signal stopped_hover

enum State {
	DEFAULT,
	HOVERED,
	UNREACHABLE,
}

const HOVER_DURATION : float = 0.15

var data : NodeData = null
var state := State.DEFAULT
var prev_state := State.DEFAULT ## Used to return to after hovering

var marker_offset := Vector2.ZERO
var hover_tween : Tween
var _is_hovered : bool = false:
	set(value):
		if _is_hovered == value:
			return
		
		_is_hovered = value
		if _is_hovered:
			set_state(State.HOVERED)
			node_hover()
			started_hover.emit(self)
		else:
			set_state(prev_state)
			node_stop_hover()
			stopped_hover.emit(self)

func _ready() -> void:
	assert(data)
	init_node()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_instance_valid(texture):
		_is_hovered = Rect2(marker_offset - (texture.get_size() * 0.5), texture.get_size()).has_point(get_local_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if not data:
		return
	
	if _is_hovered and event.is_action("press") and event.is_pressed():
		node_clicked()

func init_node() -> void:
	name = data.name
	texture = data.get_texture()
	scale = data.get_scale()
	set_state(State.DEFAULT)

func set_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	match state:
		State.DEFAULT:
			set_color(data.get_color())
		State.HOVERED:
			pass
		State.UNREACHABLE:
			if data is EventNodeData:
				set_color(Color.INDIAN_RED)
			else:
				set_color(Room.UNREACHABLE_COLOR)

func set_color(color : Color) -> void:
	self_modulate = color

func node_clicked() -> void:
	print(data.display_name)

func node_hover() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	hover_tween.tween_property(self, "scale", data.get_hover_scale(), HOVER_DURATION)

func node_stop_hover() -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	hover_tween.tween_property(self, "scale", data.get_scale(), HOVER_DURATION)
