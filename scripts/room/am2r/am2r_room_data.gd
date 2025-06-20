class_name AM2RRoomData extends RoomData

const ROOM_WIDTH : int = 320
const ROOM_HEIGHT : int = 240
const ROOM_DIVISOR : int = 8

var map_name : String
var x_position : float
var y_position : float
var image_width : int
var image_height : int

@warning_ignore_start("integer_division") # https://github.com/godotengine/godot/issues/42966
func init(_game : Game, _region : StringName, _name : String, _data : Dictionary) -> void:
	super(_game, _region, _name, _data)
	
	map_name = _data["extra"]["map_name"]
	
	texture = get_room_texture()
	image_width = texture.get_width() / ROOM_DIVISOR
	image_height = texture.get_height() / ROOM_DIVISOR
	
	var all_x : Array[int] = []
	var all_y : Array[int] = []
	for ele in _data["extra"]["minimap_data"]:
		all_x.append( int(ele.x) )
		all_y.append( int(ele.y) )
	all_x.sort()
	all_y.sort()
	
	if len(all_x) > 0:
		x_position = all_x[0] * (ROOM_WIDTH / ROOM_DIVISOR)
		y_position = all_y[0] * (ROOM_HEIGHT / ROOM_DIVISOR)
	else:
		x_position = 10
		y_position = 10

func get_room_texture() -> Texture2D:
	return load("res://data/games/am2r/room_images/%s.png" % map_name)
