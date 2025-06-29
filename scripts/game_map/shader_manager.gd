extends Node

const SHADER := preload("res://resources/highlight_shader.tres")

@export var game_map : GameMap

@onready var hover_material : ShaderMaterial = SHADER.duplicate()
@onready var start_room_material : ShaderMaterial = SHADER.duplicate()

var outline_tween : Tween = null

func _ready() -> void:
	game_map.map_resolved.connect(update_signals)

func update_signals(_reached_nodes : Array[NodeData]) -> void:
	for room_data in game_map.room_map:
		var room : Room = game_map.room_map[room_data]
		if not room.state_changed.is_connected(room_state_changed):
			room.state_changed.connect(room_state_changed)

func room_state_changed(_room : Room, _state : Room.State) -> void:
	match _state:
		Room.State.DEFAULT:
			_room.set_material(null)
		
		Room.State.HOVERED:
			if _room.prev_state == Room.State.STARTER:
				set_outline(start_room_material, Room.STARTER_COLOR, _room.config.outline_hover_thickness)
				return
			
			print("%s -> %s (%s)" % [_room.data.name, _state, _room.prev_state])
			_room.set_material(hover_material)
			set_outline(hover_material, Room.HOVER_COLOR, _room.config.outline_hover_thickness)
		
		Room.State.UNREACHABLE:
			_room.set_material(null)
		
		Room.State.STARTER:
			_room.set_material(start_room_material)
			
			set_outline(start_room_material, Room.STARTER_COLOR, _room.config.starter_thickness)

func set_outline(shader : ShaderMaterial, color : Color, width : float) -> void:
	const DURATION : float = 0.2
	
	if outline_tween and outline_tween.is_running():
		outline_tween.kill()
	
	outline_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	outline_tween.tween_method(_set_outline_color.bind(shader), _get_outline_color(shader), color, DURATION)
	outline_tween.tween_method(_set_outline_width.bind(shader), _get_outline_width(shader), width, DURATION)

func _set_outline_color(value : Color, shader : ShaderMaterial) -> void:
	shader.set_shader_parameter(&"color", value)
func _get_outline_color(shader : ShaderMaterial) -> Color:
	return shader.get_shader_parameter(&"color")

func _set_outline_width(value : float, shader : ShaderMaterial) -> void:
	shader.set_shader_parameter(&"width", value)
func _get_outline_width(shader : ShaderMaterial) -> float:
	return shader.get_shader_parameter(&"width")
