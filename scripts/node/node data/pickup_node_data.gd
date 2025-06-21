class_name PickupNodeData extends NodeData

@export var item_name : String

## Used to determine path for texture
var game : Game = null

func init(_game : Game, _name : String, room_data : RoomData, data : Dictionary) -> void:
	super(_game, _name, room_data, data)
	game = _game
	parse_item_name()

func get_color() -> Color:
	return Color.WHITE

func get_texture() -> Texture2D:
	if is_nothing() or is_artifact():
		return null
	
	var path := "res://data/games/%s/item_images/%s.png" % [game.get_game_id(), item_name]
	
	if not ResourceLoader.exists(path, "Texture2D"):
		push_warning("Failed to find texture for item: %s" % item_name)
		return load("res://data/games/am2r/item_images/Unknown.png")
	
	return load(path)

func get_scale() -> Vector2:
	const SCALE := Vector2(0.0375, 0.0375)
	return SCALE

func get_hover_scale() -> Vector2:
	const HOVER_SCALE := Vector2(0.05, 0.05)
	return HOVER_SCALE

# HACK - This is ugly
func parse_item_name() -> void:
	var rdvgame := RandovaniaInterface.get_rdvgame()
	
	item_name = name.split("(")[1].split(")")[0]
	if rdvgame:
		item_name = rdvgame.get_pickup_locations()[region]["%s/%s" % [room_name, name]]
	
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
