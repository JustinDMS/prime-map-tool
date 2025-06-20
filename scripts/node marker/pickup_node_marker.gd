class_name PickupNodeMarker extends NodeMarker

const OUTLINE_SHADER := preload("res://resources/highlight_shader.tres")
const OUTLINE_REACHED_COLOR := Color.LIME_GREEN
const OUTLINE_UNREACHABLE_COLOR := Color.INDIAN_RED
const OUTLINE_THICKNESS : float = 20.0

func init_node() -> void:
	super()
	
	material = OUTLINE_SHADER.duplicate()
	material.set_shader_parameter(&"width", OUTLINE_THICKNESS)
	material.set_shader_parameter(&"inside", false)
	flip_v = true

func set_reachable(reached : bool) -> void:
	if data.is_nothing():
		return
	
	material.set_shader_parameter(&"color", OUTLINE_REACHED_COLOR if reached else OUTLINE_UNREACHABLE_COLOR)
