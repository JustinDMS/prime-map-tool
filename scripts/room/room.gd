class_name Room extends TextureButton

signal started_hover
signal stopped_hover
signal clicked
signal double_clicked(room_data : RoomData)

enum State {
	INIT = -1,
	DEFAULT,
	HOVERED,
	UNREACHABLE,
	STARTER,
}

const HOVER_COLOR := Color.WHITE
const STARTER_COLOR := Color.GREEN
const UNREACHABLE_COLOR := Color("#4b7ea3")
const UNREACHABLE_OUTLINE_COLOR := Color("#62a5d4")

var room_color_tween : Tween = null
var outline_tween : Tween = null
var node_markers : Array[NodeMarker] = []

var game : Game = null
var data : RoomData = null
var config : OutlineConfig = null
var state : State = State.INIT
var prev_state : State = State.INIT

func _init(_game : Game, _data : RoomData) -> void:
	game = _game
	data = _data
	
	# Control and TextureButton properties
	set_ignore_texture_size(true)
	set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT_COVERED)
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	
	mouse_entered.connect(hover_start)
	mouse_exited.connect(hover_end)
	
	set_name(data.name) # Set name in SceneTree
	set_texture_normal(data.texture)
	set_z_index( game.get_room_z_index(data.name) )
	
	var _scale := game.get_region_scale()
	set_flip_h( _scale.x < 0 )
	set_flip_v( _scale.y < 0 )

func _ready() -> void:
	game.init_room(self)

func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton and
		state == State.HOVERED and
		event.get_button_index() == MOUSE_BUTTON_LEFT
	):
		room_clicked()
		
		if event.is_double_click():
			double_clicked.emit(data)

func hover_start() -> void:
	change_state(State.HOVERED)
	started_hover.emit(self)

func hover_end() -> void:
	change_state(prev_state)
	stopped_hover.emit(self)

func room_clicked() -> void:
	print_debug(data.name)
	clicked.emit()

## Used for accurate hover detection with irregular room shapes
func create_bitmap() -> void:
	var image := data.texture.get_image()
	if is_flipped_h(): image.flip_x()
	if is_flipped_v(): image.flip_y()
	
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1)
	set_click_mask(bitmap)

func get_global_center() -> Vector2:
	return global_position + ( size * game.get_region_scale() * 0.5 )

#region Room State
func change_state(new_state : State) -> void:
	prev_state = state
	state = new_state
	
	match state:
		State.DEFAULT:
			default()
		State.HOVERED:
			hovered()
		State.UNREACHABLE:
			unreachable()
		State.STARTER:
			starter()

func default() -> void:
	set_color( game.get_region_color(data.region) )
	set_outline( game.get_region_color(data.region), config.outline_thickness)

func hovered() -> void:
	if prev_state == State.STARTER:
		set_outline(STARTER_COLOR, config.outline_hover_thickness)
		return
	
	set_outline(HOVER_COLOR, config.outline_hover_thickness)

func unreachable() -> void:
	set_color(UNREACHABLE_COLOR)
	set_outline(UNREACHABLE_OUTLINE_COLOR, config.outline_thickness)

func starter() -> void:
	prev_state = State.STARTER
	set_color( game.get_region_color(data.region) )
	set_outline(STARTER_COLOR, config.starter_thickness)
#endregion

func set_color(new_color : Color) -> void:
	const DURATION : float = 0.2
	if room_color_tween and room_color_tween.is_valid():
		room_color_tween.kill()
	
	room_color_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	room_color_tween.tween_property(self, "self_modulate", new_color, DURATION)

func set_outline(color : Color, width : float) -> void:
	const DURATION : float = 0.2
	
	# Color methods
	var set_outline_color := \
	func(value : Color) -> void:
		material.set_shader_parameter(&"color", value)
	var get_outline_color := \
	func() -> Color:
		return material.get_shader_parameter(&"color")
	
	# Width methods
	var get_outline_width := \
	func() -> float:
		return material.get_shader_parameter(&"width")
	var set_outline_width := \
	func(value : float) -> void:
		material.set_shader_parameter(&"width", value)
	
	if outline_tween and outline_tween.is_running():
		outline_tween.kill()
	
	outline_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	outline_tween.tween_method(set_outline_color, get_outline_color.call(), color, DURATION)
	outline_tween.tween_method(set_outline_width, get_outline_width.call(), width, DURATION)

class OutlineConfig:
	var shader_path : StringName
	var outline_thickness : float
	var outline_hover_thickness : float
	var starter_thickness : float
	
	func _init(
		_shader_path : StringName,
		_outline_thickness : float,
		_outline_hover_thickness : float,
		_starter_thickness : float
	):
		shader_path = _shader_path
		outline_thickness = _outline_thickness
		outline_hover_thickness = _outline_hover_thickness
		starter_thickness = _starter_thickness
