class_name NodeData extends Resource

# NOTE - Might be better to move this to a dedicated factory class?
static func create_data_from_type(game : Game, type : String) -> NodeData:
	match type:
		"dock":
			if game is Prime:
				return PrimeDockNodeData.new()
			if game is AM2R:
				return AM2RDockNodeData.new()
			return DockNodeData.new()
		"pickup":
			return PickupNodeData.new()
		"generic":
			return GenericNodeData.new()
		"event":
			return EventNodeData.new()
		"hint":
			return GenericNodeData.new() # TODO
		_:
			assert(false, "Unhandled NodeData type: %s" % type)
	
	return null

@export var region : StringName
@export var room_name : String
@export var name : String
@export var coordinates : Vector3
@export var connections : Array[NodeData]

func init(_game : Game, _name : String, _room_data : RoomData, _data : Dictionary) -> void:
	region = _room_data.region
	room_name = _room_data.name
	name = _name
	
	# Populate coordinates depending on how the game's logic database is structured
	if _game is Prime:
		coordinates = Vector3(
			_data.extra.world_position[0],
			_data.extra.world_position[1],
			_data.extra.world_position[2]
		)
	
	if _game is AM2R:
		var x_coord = _room_data.extra.x_position
		x_coord += (_data["coordinates"]["x"] / _game.ROOM_DIVISOR)
		
		var y_coord = _room_data.extra.y_position
		y_coord += _room_data.texture.get_height() / _game.ROOM_DIVISOR
		y_coord -= (_data["coordinates"]["y"] / _game.ROOM_DIVISOR)
		coordinates = Vector3(
			x_coord,
			y_coord,
			0
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
