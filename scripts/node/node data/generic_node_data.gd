class_name GenericNodeData extends NodeData

@export var heal : bool

func init(_game : Game, _name : String, room_data : RoomData, data : Dictionary) -> void:
	super(_game, _name, room_data, data)
	
	heal = data.heal

func get_color() -> Color:
	const COLOR := Color.WHEAT
	return COLOR

func get_texture() -> Texture2D:
	const TEXTURE := preload("res://data/icons/node marker/generic_marker.png")
	return TEXTURE
