class_name NodeMarker extends Sprite2D

signal state_changed(marker : NodeMarker, new_state : State)
signal node_clicked(marker : NodeMarker)
signal double_clicked(marker : NodeMarker)

enum State {
	INIT = -1,
	DEFAULT,
	HOVERED,
	UNREACHABLE,
	STARTER,
}

const HOVER_DURATION : float = 0.15

var game : Game = null
var data : NodeData = null
var state : State = State.INIT
var prev_state : State = State.INIT
var is_hovered : bool = false
var rect := Rect2()
var hover_tween : Tween

# Set by [GameMap]
var node_connections : Array[NodeConnection] = []

func _init(_game : Game, _node_data : NodeData) -> void:
	game = _game
	data = _node_data
	
	set_z_index(1)
	set_name(data.name)
	set_texture( data.get_texture() )
	set_scale( data.get_scale() )
	
	rect = get_rect()

func _ready() -> void:
	game.init_node_marker(self)

func _input(event: InputEvent) -> void:
	if (
		state == State.HOVERED and
		event is InputEventMouseButton and
		event.get_button_index() == MOUSE_BUTTON_LEFT
		):
			if event.is_pressed():
				_node_clicked()
			elif event.is_double_click():
				double_clicked.emit()

func determine_hover() -> void:
	var mouse_pos := get_local_mouse_position()
	var hover := rect.has_point(mouse_pos - offset)
	
	# No change
	if hover == is_hovered:
		return
	
	is_hovered = hover
	if is_hovered:
		change_state(State.HOVERED)
		return
	change_state(prev_state)

#region Marker State
func change_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	if prev_state == State.HOVERED:
		set_connection_visibility(false)
		_set_scale( data.get_scale() )
	
	match state:
		State.DEFAULT:
			default()
		State.HOVERED:
			hovered()
		State.UNREACHABLE:
			unreachable()
		State.STARTER:
			starter()
	
	state_changed.emit(self, state)

func default() -> void:
	set_color( data.get_color() )

func hovered() -> void:
	set_connection_visibility(true)
	_set_scale( data.get_hover_scale() )

func unreachable() -> void:
	if data.is_event():
		set_color(Color.INDIAN_RED)
		return
	
	set_color(Room.UNREACHABLE_COLOR)

func starter() -> void:
	pass
#endregion

func set_color(color : Color) -> void:
	self_modulate = color

func _node_clicked() -> void:
	print_debug("%s" % data.name)
	node_clicked.emit(self)

func _set_scale(_scale : Vector2) -> void:
	if hover_tween and hover_tween.is_running():
		hover_tween.kill()
	
	hover_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	hover_tween.tween_property(self, "scale", _scale, HOVER_DURATION)

func set_connection_visibility(_visible : bool) -> void:
	for c in node_connections:
		if _visible:
			c.extend_line()
			continue
		c.retract_line()
