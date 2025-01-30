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
	"pickup" : Color.WHITE,
	"event" : Color.INDIAN_RED,
	"generic" : Color.WHEAT,
}

const OUTLINE_SHADER := preload("res://resources/highlight_shader.tres")
const ARTIFACT_CONTAINER := preload("res://resources/artifact_container.tscn")

const DOOR_MARKER_OFFSET : float = 50.0
const NORMAL_SCALE := Vector2(0.1, 0.1)
const HOVER_SCALE := Vector2(0.15, 0.15)
const PICKUP_SCALE := Vector2(0.05, 0.05)
const PICKUP_HOVER_SCALE := Vector2(0.07, 0.07)
const HOVER_DURATION : float = 0.15

var marker_offset := Vector2.ZERO
var marker_offset_tween : Tween
var data : NodeData = null
var target_color : Color
var artifact_container : ArtifactContainer = null
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
		if artifact_container:
			_is_hovered = Rect2(marker_offset + (artifact_container.position * Vector2(1, -1)), abs(artifact_container.position * 2)).has_point(get_local_mouse_position())
		else:
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
	texture = preload("res://data/icons/node_marker.png")
	
	position = Vector2(
		data.coordinates.x,
		data.coordinates.y
	)
	
	match data.node_type:
		"pickup":
			scale = PICKUP_SCALE
		_:
			scale = NORMAL_SCALE
	
	name = "n_%s" % data.display_name
	toggle_visible(false)
	
	match data.node_type:
		"dock":
			match data.dock_type:
				"door":
					texture = preload("res://data/icons/door.png")
					target_color = DOOR_COLOR_MAP[data.default_dock_weakness]
					rotation_degrees = data.rotation.z
					marker_offset.x = -DOOR_MARKER_OFFSET
				"teleporter":
					texture = preload("res://data/icons/teleporter_marker.png")
					target_color = COLOR_MAP[data.dock_type]
				"morph_ball":
					target_color = COLOR_MAP[data.dock_type]
		"pickup":
			target_color = COLOR_MAP[data.node_type]
			# HACK This is ugly
			var item_name : String = data.display_name.split("(")[1].split(")")[0]
			match item_name:
				"Power Bomb":
					item_name = "Power Bomb Expansion"
				"Main Power Bombs":
					item_name = "Power Bomb"
				"Morph Ball Bombs":
					item_name = "Morph Ball Bomb"
			if item_name.contains("Missile") and not item_name.contains("Super"):
				item_name = "Missile Expansion"
			
			if item_name.begins_with("Artifact"):
				texture = null
				
				var new_artifact_container := ARTIFACT_CONTAINER.instantiate()
				artifact_container = new_artifact_container
				add_child(artifact_container)
				artifact_container.set_artifact_as_focused(PrimeInventory.new().get_artifact_from_name(item_name))
				artifact_container.scale = Vector2(10.0, -10.0)
				artifact_container.apply_offset()
			else:
				var pickup_texture := load("res://data/icons/%s.png" % item_name)
				if pickup_texture == null:
					push_error("Missing texture for %s" % item_name)
				texture = pickup_texture
				flip_v = true
				material = OUTLINE_SHADER.duplicate()
		"event":
			target_color = COLOR_MAP[data.node_type]
			texture = preload("res://data/icons/event_marker.png")
		"generic":
			target_color = COLOR_MAP[data.node_type]
			texture = preload("res://data/icons/generic_marker.png")
			flip_v = true
	
	offset = marker_offset
	set_color(target_color)

func set_color(color : Color) -> void:
	self_modulate = color

func node_clicked() -> void:
	print(data.display_name)

func node_hover() -> void:
	if marker_offset_tween and marker_offset_tween.is_running():
		marker_offset_tween.kill()
	
	marker_offset_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	match data.node_type:
		"pickup":
			marker_offset_tween.tween_property(self, "scale", PICKUP_HOVER_SCALE, HOVER_DURATION)
		_:
			marker_offset_tween.tween_property(self, "scale", HOVER_SCALE, HOVER_DURATION)

func node_stop_hover() -> void:
	if marker_offset_tween and marker_offset_tween.is_running():
		marker_offset_tween.kill()
	
	marker_offset_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	match data.node_type:
		"pickup":
			marker_offset_tween.tween_property(self, "scale", PICKUP_SCALE, HOVER_DURATION)
		_:
			marker_offset_tween.tween_property(self, "scale", NORMAL_SCALE, HOVER_DURATION)

func toggle_visible(on : bool) -> void:
	const VISIBILITY_CHANGE_DURATION : float = 0.175
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		self, 
		"self_modulate", 
		target_color if on else Room.UNREACHABLE_COLOR, 
		VISIBILITY_CHANGE_DURATION
		)

func set_pickup_reachable(reached : bool) -> void:
	assert(data.node_type == "pickup")
	var item_name : String = data.display_name.split("(")[1].split(")")[0]
	if item_name.contains("Artifact"):
		var a : PrimeInventory.Artifact = PrimeInventory.new().get_artifact_from_name(item_name)
		if reached:
			artifact_container.set_artifact_as_focused(a)
			return
		artifact_container.set_unreached(a)
		return
	material.set_shader_parameter(&"color", Color.GREEN if reached else Color.INDIAN_RED)
