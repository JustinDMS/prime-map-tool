class_name NodeData extends Resource

@export var region : StringName
@export var room_name : String
@export var name : String
@export var coordinates : Vector3
@export var connections : Array[NodeData]

static func create_data_from_type(type : String) -> NodeData:
	var data : NodeData = null
	
	match type:
		"dock":
			data = DockNodeData.new()
		"pickup":
			data = PickupNodeData.new()
		"generic":
			data = GenericNodeData.new()
		"event":
			data = EventNodeData.new()
		_:
			assert(false, "Unhandled NodeData type: %s" % type)
	
	return data

func init(_name : String, room_data : RoomData, data : Dictionary) -> void:
	region = room_data.region
	room_name = room_data.name
	name = _name
	coordinates = Vector3(
		data["extra"]["world_position"][0],
		data["extra"]["world_position"][1],
		data["extra"]["world_position"][2]
	)

func get_color() -> Color:
	return Color.WHITE

func get_texture() -> Texture2D:
	return null

func get_scale() -> Vector2:
	const SCALE := Vector2(0.1, 0.1)
	return SCALE

func get_hover_scale() -> Vector2:
	const HOVER_SCALE := Vector2(0.15, 0.15)
	return HOVER_SCALE
