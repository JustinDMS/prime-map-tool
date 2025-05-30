class_name RoomData extends Resource

@export var region : StringName
@export var name : String
@export var texture : Texture2D
@export var aabb : Array[float]

@export var nodes : Array[NodeData]
@export var default_node : NodeData

func init(_region : StringName, _name : String, data : Dictionary) -> void:
	region = _region
	name = _name
	texture = get_room_texture()
	aabb = [
		data["extra"]["aabb"][0],
		data["extra"]["aabb"][1],
		data["extra"]["aabb"][2],
		data["extra"]["aabb"][3],
		data["extra"]["aabb"][4],
		data["extra"]["aabb"][5]
	]

func get_room_texture() -> Texture2D:
	return load("res://data/games/prime1/room_images/%s/%s.png" % [region, name])

func clear_nodes() -> void:
	nodes.clear()
	default_node = null
