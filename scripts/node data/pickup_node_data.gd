class_name PickupNodeData extends NodeData

@export var item_name : String

func init(_name : String, room_data : RoomData, data : Dictionary) -> void:
	super(_name, room_data, data)
	
	parse_item_name()

func get_color() -> Color:
	return Color.WHITE

func get_texture() -> Texture2D:
	if is_nothing():
		return null
	
	return load("res://data/icons/%s.png" % item_name)

func get_scale() -> Vector2:
	const SCALE := Vector2(0.05, 0.05)
	return SCALE

func get_hover_scale() -> Vector2:
	const HOVER_SCALE := Vector2(0.07, 0.07)
	return HOVER_SCALE

func parse_item_name() -> void:
	var rdvgame := RandovaniaInterface.get_rdvgame()
	
	# HACK This is ugly
	item_name = name.split("(")[1].split(")")[0]
	if rdvgame:
		item_name = rdvgame.get_pickup_locations()[World.REGION_NAME[region]]["%s/%s" % [room_name, name]]
	
	match item_name:
		"Power Bomb":
			item_name = "Power Bomb Expansion"
		"Main Power Bombs":
			item_name = "Power Bomb"
		"Morph Ball Bombs":
			item_name = "Morph Ball Bomb"
		"Energy Transfer Module":
			item_name = "Nothing"
			return
	
	if item_name.contains("Missile") and not item_name.contains("Super"):
		item_name = "Missile Expansion"

func is_artifact() -> bool:
	return item_name.contains("Artifact")

func is_nothing() -> bool:
	return item_name == "Nothing"
