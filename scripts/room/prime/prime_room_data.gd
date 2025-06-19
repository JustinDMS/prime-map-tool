class_name PrimeRoomData extends RoomData

## Float array of size 6
## x_min, y_min, z_min, x_max, y_max, z_max
@export var aabb : Array[float]

func init(_game : Game, _region : StringName, _name : String, _data : Dictionary) -> void:
	super(_game, _region, _name, _data)
	
	texture = get_room_texture()
	aabb = [
		_data.extra.aabb[0],
		_data.extra.aabb[1],
		_data.extra.aabb[2],
		_data.extra.aabb[3],
		_data.extra.aabb[4],
		_data.extra.aabb[5]
	]

func get_room_texture() -> Texture2D:
	return load("res://data/games/prime1/room_images/%s/%s.png" % [region, name])
