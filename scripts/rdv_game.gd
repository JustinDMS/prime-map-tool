class_name RDVGame extends Resource

@export var _schema_version : int
@export var _version : String
@export var _permalink : String
@export var _seed : String
@export var _hash : String
@export var _word_hash : String
@export var _game : String
@export var _trick_levels : Dictionary = {}
@export var _start_region_name : String
@export var _start_room_name : String
@export var _start_node_name : String
@export var _starting_pickups : Array[String]
@export var _config : Dictionary = {}
@export var _dock_connections : Dictionary = {}
@export var _dock_weaknesses : Dictionary = {}
@export var _pickup_locations : Dictionary = {}

func parse(rdvgame_data : Dictionary) -> void:
	_schema_version = rdvgame_data["schema_version"]
	_version = rdvgame_data["info"]["randovania_version"]
	_permalink = rdvgame_data["info"]["permalink"]
	_seed = str(rdvgame_data["info"]["seed"])
	_hash = rdvgame_data["info"]["hash"]
	_word_hash = rdvgame_data["info"]["word_hash"]
	_game = rdvgame_data["info"]["presets"][0]["game"]
	
	var trick_levels : Dictionary = rdvgame_data["info"]["presets"][0]["configuration"]["trick_level"]["specific_levels"]
	for trick in trick_levels:
		_trick_levels[trick] = trick_levels[trick]
	
	var start_location : PackedStringArray = rdvgame_data["game_modifications"][0]["starting_location"].split("/")
	_start_region_name = start_location[0]
	_start_room_name = start_location[1]
	_start_node_name = start_location[2]
	
	_starting_pickups.assign(rdvgame_data["game_modifications"][0]["starting_equipment"]["pickups"])
	
	for setting in rdvgame_data["info"]["presets"][0]["configuration"]:
		if setting in [
			"trick_level",
			"starting_location",
			"available_locations",
			"standard_pickup_configuration",
			"ammo_pickup_configuration"
		]:
			continue
		_config[setting] = rdvgame_data["info"]["presets"][0]["configuration"][setting]
	
	_dock_connections = rdvgame_data["game_modifications"][0]["dock_connections"]
	_dock_weaknesses = rdvgame_data["game_modifications"][0]["dock_weakness"]
	_pickup_locations = rdvgame_data["game_modifications"][0]["locations"]

#region Accessor Functions

func get_schema_version() -> int:
	return _schema_version

func get_version() -> String:
	return _version

func get_permalink() -> String:
	return _permalink

func get_seed() -> String:
	return _seed

func get_hash() -> String:
	return _hash

func get_word_hash() -> String:
	return _word_hash

func get_game() -> String:
	return _game

func get_trick_levels() -> Dictionary:
	return _trick_levels.duplicate()

func get_start_region_name() -> String:
	return _start_region_name

func get_start_room_name() -> String:
	return _start_room_name

func get_start_node_name() -> String:
	return _start_node_name

func get_starting_pickups() -> Array[String]:
	return _starting_pickups.duplicate()

func get_config() -> Dictionary:
	return _config.duplicate()

func get_dock_connections() -> Dictionary:
	return _dock_connections.duplicate()

func get_dock_weaknesses() -> Dictionary:
	return _dock_weaknesses.duplicate()

func get_pickup_locations() -> Dictionary:
	return _pickup_locations.duplicate()

#endregion
