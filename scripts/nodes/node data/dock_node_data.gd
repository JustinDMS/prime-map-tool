class_name DockNodeData extends NodeData

@export var type : String
@export var default_dock_weakness : String
@export var rotation : Vector3
@export var default_connection : NodeData

func init(_game : Game, _name : String, _room_data : RoomData, _data : Dictionary) -> void:
	super(_game, _name, _room_data, _data)
	type = _data.dock_type
	default_dock_weakness = _data.default_dock_weakness

func get_texture() -> Texture2D:
	const TEXTURE_MAP := {
		"door" : preload("res://data/icons/node marker/door.png"),
		"teleporter" : preload("res://data/icons/node marker/teleporter_marker.png"),
		"morph_ball" : preload("res://data/icons/node marker/node_marker.png")
	}
	return TEXTURE_MAP["door"]	 # HACK! Breaks prime

func is_door() -> bool:
	return type == "door"

func is_vertical_door() -> bool:
	const THRESHOLD := 20.0
	return abs(rotation.x) > THRESHOLD

func is_teleporter() -> bool:
	return type == "teleporter"

func is_morph_ball_door() -> bool:
	return type == "morph_ball"
