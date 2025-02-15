class_name NodeData extends Resource

@export var region : int = 0
@export var room_name : String
@export var display_name : String
@export var node_type : String
@export var heal : bool
@export var event_id : String
@export var dock_type : String
@export var default_dock_weakness : String
@export var coordinates : Vector3
@export var rotation : Vector3
@export var connections : Array[NodeData]
@export var default_connection : NodeData

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
