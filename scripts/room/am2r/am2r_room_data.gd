class_name AM2RRoomData extends RoomData

@export var map_name: String
@export var x_position: float
@export var y_position: float
@export var image_width: float
@export var image_height: float

@export var ROOM_WIDTH = 320
@export var ROOM_HEIGHT = 240
@export var ROOM_DIVISOR = 8

func init(_game : Game, _region : StringName, _name : String, _data : Dictionary) -> void:
	map_name = _data["extra"]["map_name"]
	var all_x = []
	var all_y = []
	for ele in _data["extra"]["minimap_data"]:
		all_x.append(ele["x"])
		all_y.append(ele["y"])
	all_x.sort()
	all_y.sort()
	
	@warning_ignore_start("integer_division")
	if len(all_x) > 0:
		x_position = all_x[0] * (ROOM_WIDTH / ROOM_DIVISOR)
		y_position = all_y[0] * (ROOM_HEIGHT / ROOM_DIVISOR)
	else:
		x_position = 10
		y_position = 10
	
	# Call initializes texture - HACK?
	super(_game, _region, _name, _data)
	
	image_width = texture.get_width() / ROOM_DIVISOR
	image_height = texture.get_height() / ROOM_DIVISOR
	
func get_room_texture() -> Texture2D:
	return load("res://data/games/am2r/room_images/%s.png" % [map_name])
