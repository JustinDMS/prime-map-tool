class_name EventNodeData extends NodeData

@export var event_id : String

func init(_name : String, room_data : RoomData, data : Dictionary) -> void:
	super(_name, room_data, data)

func get_color() -> Color:
	const COLOR := Color.LIME_GREEN
	return COLOR

func get_texture() -> Texture2D:
	const TEXTURE := preload("res://data/icons/node marker/event_marker.png")
	return TEXTURE
