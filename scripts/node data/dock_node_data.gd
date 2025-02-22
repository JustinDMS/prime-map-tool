class_name DockNodeData extends NodeData

@export var type : String
@export var default_dock_weakness : String
@export var rotation : Vector3
@export var default_connection : NodeData

func init(_name : String, room_data : RoomData, data : Dictionary) -> void:
	super(_name, room_data, data)
	
	type = data["dock_type"]
	default_dock_weakness = data["default_dock_weakness"]
	
	if is_door():
		rotation = Vector3(
			data["extra"]["world_rotation"][0],
			data["extra"]["world_rotation"][1],
			data["extra"]["world_rotation"][2]
		)

func get_color() -> Color:
	const DOOR_COLOR_MAP := {
		"Normal Door" : Color.DEEP_SKY_BLUE,
		"Normal Door (Forced)" : Color.DEEP_SKY_BLUE,
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
	}
	
	if is_door():
		return DOOR_COLOR_MAP[default_dock_weakness]
	return COLOR_MAP[type]

func get_texture() -> Texture2D:
	const TEXTURE_MAP := {
		"door" : preload("res://data/icons/door.png"),
		"teleporter" : preload("res://data/icons/teleporter_marker.png"),
		"morph_ball" : preload("res://data/icons/node_marker.png")
	}
	return TEXTURE_MAP[type]

func is_door() -> bool:
	return type == "door"

func is_vertical_door() -> bool:
	const THRESHOLD := 20.0
	return abs(rotation.x) > THRESHOLD

func is_teleporter() -> bool:
	return type == "teleporter"
