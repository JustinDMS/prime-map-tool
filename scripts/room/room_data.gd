class_name RoomData extends Resource

@export var region : StringName
@export var name : String
@export var texture : Texture2D

@export var nodes : Array[NodeData]
@export var default_node : NodeData

func init(_game : Game, _region : StringName, _name : String, _data : Dictionary) -> void:
	region = _region
	name = _name

## Override in subclasses
func get_room_texture() -> Texture2D:
	return null

func clear_nodes() -> void:
	nodes.clear()
	default_node = null
