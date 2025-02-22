class_name NodeMarker extends Sprite2D

signal started_hover
signal stopped_hover

enum State {
	DEFAULT,
	HOVERED,
	UNREACHABLE,
}

const OUTLINE_SHADER := preload("res://resources/highlight_shader.tres")
const ARTIFACT_CONTAINER := preload("res://resources/artifact_container.tscn")

const DOOR_MARKER_OFFSET : float = 50.0
const HOVER_DURATION : float = 0.15

var data : NodeData = null
var marker_offset := Vector2.ZERO
var marker_offset_tween : Tween
var artifact_container : ArtifactContainer = null

var state := State.DEFAULT
var prev_state := State.DEFAULT ## Used to return to after hovering

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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if artifact_container:
			_is_hovered = Rect2(marker_offset + (artifact_container.position * Vector2(1, -1)), abs(artifact_container.position * 2)).has_point(get_local_mouse_position())
		elif is_instance_valid(texture):
			_is_hovered = Rect2(marker_offset - (texture.get_size() * 0.5), texture.get_size()).has_point(get_local_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if not data:
		return
	
	if _is_hovered and event.is_action("press") and event.is_pressed():
		node_clicked()

func _ready() -> void:
	if data:
		init_node()

func init_node() -> void:
	name = data.name
	texture = data.get_texture()
	scale = data.get_scale()
	
	if data is PickupNodeData:
		if data.is_artifact():
			texture = null
			var new_artifact_container := ARTIFACT_CONTAINER.instantiate()
			artifact_container = new_artifact_container
			add_child(artifact_container)
			artifact_container.set_artifact_as_focused(PrimeInventory.get_artifact_from_name(data.item_name))
			artifact_container.scale = Vector2(10.0, -10.0)
			artifact_container.apply_offset()
		else:
			material = OUTLINE_SHADER.duplicate()
			flip_v = true
	
	if data is DockNodeData and data.is_door():
		if data.is_vertical_door():
			marker_offset.y = DOOR_MARKER_OFFSET
		else:
			rotation_degrees = data.rotation.z
			marker_offset.x = -DOOR_MARKER_OFFSET
		offset = marker_offset
	
	set_state(State.DEFAULT)

func set_color(color : Color) -> void:
	self_modulate = color

func node_clicked() -> void:
	print(data.display_name)

func node_hover() -> void:
	if marker_offset_tween and marker_offset_tween.is_running():
		marker_offset_tween.kill()
	
	marker_offset_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	marker_offset_tween.tween_property(self, "scale", data.get_hover_scale(), HOVER_DURATION)

func node_stop_hover() -> void:
	if marker_offset_tween and marker_offset_tween.is_running():
		marker_offset_tween.kill()
	
	marker_offset_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	marker_offset_tween.tween_property(self, "scale", data.get_scale(), HOVER_DURATION)

func set_pickup_reachable(reached : bool) -> void:
	assert(data is PickupNodeData)
	
	if data.is_nothing():
		return
	
	if data.is_artifact():
		var a : PrimeInventory.Artifact = PrimeInventory.get_artifact_from_name(data.item_name)
		if reached:
			artifact_container.set_artifact_as_focused(a)
			return
		artifact_container.set_unreached(a)
		return
	material.set_shader_parameter(&"color", Color.LIME_GREEN if reached else Color.INDIAN_RED)
