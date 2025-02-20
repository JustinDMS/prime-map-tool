class_name NodeData extends Resource

@export var region : World.Region = 0
@export var room_name : String
@export var name : String
@export var node_type : String
@export var heal : bool
@export var event_id : String
@export var dock_type : String
@export var default_dock_weakness : String
@export var coordinates : Vector3
@export var rotation : Vector3
@export var connections : Array[NodeData]
@export var default_connection : NodeData

func init(_name : String, room_data : RoomData, data : Dictionary) -> void:
	region = room_data.region
	room_name = room_data.name
	name = _name
	
	node_type = data["node_type"]
	heal = true if (is_generic() and data["heal"]) else false
	
	if is_dock():
		dock_type = data["dock_type"]
		default_dock_weakness = data["default_dock_weakness"]
	
	if data["extra"].has("world_position"):
		coordinates = Vector3(
			data["extra"]["world_position"][0],
			data["extra"]["world_position"][1],
			data["extra"]["world_position"][2]
		)
			
		if data["extra"].has("world_rotation"):
			rotation = Vector3(
				data["extra"]["world_rotation"][0],
				data["extra"]["world_rotation"][1],
				data["extra"]["world_rotation"][2]
			)

func is_event() -> bool:
	return node_type == "event"

func is_pickup() -> bool:
	return node_type == "pickup"

func is_generic() -> bool:
	return node_type == "generic"

func is_dock() -> bool:
	return node_type == "dock"

func is_teleporter() -> bool:
	return dock_type == "teleporter"
