class_name PrimeDockNodeData extends DockNodeData

const TEXTURE_MAP : Dictionary[StringName, Texture2D] = {
	&"door" : preload("res://data/icons/node marker/door.png"),
	&"teleporter" : preload("res://data/icons/node marker/teleporter_marker.png"),
	&"morph_ball" : preload("res://data/icons/node marker/node_marker.png")
}
const DOOR_COLOR_MAP : Dictionary[StringName, Color] = {
	&"Normal Door" : Color.DEEP_SKY_BLUE,
	&"Normal Door (Forced)" : Color.DEEP_SKY_BLUE,
	&"Ice Door" : Color.ALICE_BLUE,
	&"Wave Door" : Color.MEDIUM_PURPLE,
	&"Plasma Door" : Color.ORANGE_RED,
	&"Power Beam Only Door" : Color.GOLD,
	&"Missile Blast Shield" : Color.DARK_GRAY,
	&"Missile Blast Shield (randomprime)" : Color.DARK_GRAY,
	&"Permanently Locked" : Color.DIM_GRAY,
	&"Circular Door" : Color.DEEP_SKY_BLUE,
	&"Square Door" : Color.DEEP_SKY_BLUE,
	&"Super Missile Blast Shield" : Color.LAWN_GREEN,
	&"Power Bomb Blast Shield" : Color.ORANGE,
	&"Wavebuster Blast Shield" : Color.WEB_PURPLE,
	&"Ice Spreader Blast Shield" : Color.DEEP_SKY_BLUE,
	&"Flamethrower Blast Shield" : Color.DARK_RED,
	&"Charge Beam Blast Shield" : Color.CADET_BLUE,
	&"Bomb Blast Shield" : Color.LIGHT_SALMON
}
const COLOR_MAP : Dictionary[StringName, Color] = {
	&"teleporter" : Color.PURPLE,
	&"morph_ball" : Color.ORCHID,
}

func init(_game : Game, _name : String, _room_data : RoomData, _data : Dictionary) -> void:
	super(_game, _name, _room_data, _data)
	
	if is_door():
		rotation = Vector3(
			_data.extra.world_rotation[0],
			_data.extra.world_rotation[1],
			_data.extra.world_rotation[2]
		)

func get_texture() -> Texture2D:
	return TEXTURE_MAP[type]

func get_color() -> Color:
	if is_door():
		return DOOR_COLOR_MAP[default_dock_weakness]
	return COLOR_MAP[type]
