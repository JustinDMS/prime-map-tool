class_name Game extends Resource
## Generic data container for Randovania games

const SHARED_NODE_TEXTURES : Dictionary[StringName, Texture2D] = {
	&"default" : preload("res://data/icons/node marker/node_marker.png"),
	&"door" : preload("res://data/icons/node marker/door.png"),
	&"event" : preload("res://data/icons/node marker/event_marker.png"),
	&"generic" : preload("res://data/icons/node marker/generic_marker.png"),
	&"teleporter" : preload("res://data/icons/node marker/teleporter_marker.png"),
}

const IGNORED_MISC_SETTINGS : Array[String] = ["small", "dock_rando", "room_rando"]

var _header := {} ## Randovania data
var _items : Dictionary[StringName, Item] = {}
var _events : Dictionary[StringName, Event] = {}
var _tricks : Dictionary[StringName, Trick] = {}
var _misc : Dictionary[StringName, MiscSetting] = {}
var _templates := {}

var item_long_name_map : Dictionary[StringName, Item] = {}
var event_long_name_map : Dictionary[StringName, Event] = {}

#region Virtual Members
## Map of region names and their offsets in global space
var region_offset : Dictionary[StringName, Vector2] = {}

## Map of region names that contain subregions and their offsets in local coordinates
## Inner array expected type is Array[Vector2]
var subregion_offset : Dictionary[StringName, Array] = {}

## Map of region names and room subregion indices
## Inner dictionary expected type is Dictionary[StringName, int] 
var subregion_map : Dictionary[StringName, Dictionary] = {}

## Map of room names and their z-indices
var z_index_override : Dictionary[StringName, int] = {}

## Map of region names and their color
var region_color : Dictionary[StringName, Color] = {}

## 2D Array describing how the inventory is displayed
var inventory_layout : Array[Array] = []
#endregion

#region Virtual Methods
## Game ID used by Randovania
func get_game_id() -> StringName:
	return &""
func get_region_scale() -> Vector2:
	return Vector2(1, 1)
func init_room_data(_room_data : RoomData, _extra_data : Dictionary) -> void:
	pass
func init_room(_room : Room) -> void: 
	pass
func init_node_data(_node_data : NodeData, _extra_data : Dictionary) -> void:
	pass
func init_node_marker(_marker : NodeMarker) -> void:
	pass
#endregion

func _init(rdv_header : Dictionary) -> void:
	_header = rdv_header
	var resource_db : Dictionary = _header.resource_database
	
	for type in resource_db:
		match type:
			"items":
				for res in resource_db.items:
					var item := Item.new(res, resource_db.items[res])
					_items[ StringName(res) ] = item
					item_long_name_map[ StringName(item.long_name) ] = item
			"events":
				for res in resource_db.events:
					var event := Event.new(res, resource_db.events[res])
					_events[ StringName(res) ] = event
					event_long_name_map[ StringName(event.long_name) ] = event
			"tricks":
				for res in resource_db.tricks:
					_tricks[ StringName(res) ] = Trick.new(res, resource_db.tricks[res])
			"misc":
				for res in resource_db.misc:
					_misc[ StringName(res) ] = MiscSetting.new(res, resource_db.misc[res])
			"requirement_template":
				for res in resource_db.requirement_template:
					_templates[ StringName(res) ] = resource_db.requirement_template[res].requirement
			_:
				continue

#region Game Data Accessor Methods
## Creates and returns logic database data if it exists
func get_region_data() -> Dictionary[StringName, Dictionary]:
	var data : Dictionary[StringName, Dictionary] = {}
	
	for r in _header.regions:
		var path := StringName("res://data/games/%s/%s" % [_header.game, r])
		if ResourceLoader.exists(path, "JSON"):
			var json := load(path)
			data[r.trim_suffix(".json")] = json.data
			continue
		
		push_warning("Could not find region data at %s" % path)
	
	return data

func has_region(region : StringName) -> bool:
	return region_offset.has(region)

func has_subregions(region : StringName) -> bool:
	return subregion_map.has(region)

func get_region_offset(region : StringName) -> Vector2:
	if not region in region_offset:
		push_warning("Failed to find region offset: %s" % region)
		return Vector2.ZERO
	return region_offset[region]

func get_subregion_offsets(region : StringName) -> Array[Vector2]:
	if not has_subregions(region):
		return [Vector2.ZERO]
	
	# Workaround since casting to
	# a nested type doesn't work
	var arr : Array[Vector2] = []
	arr.assign(subregion_offset[region])
	return arr

## Returns subregion index of a room, default 0
func get_room_subregion_index(region : StringName, room_name : StringName) -> int:
	if not has_subregions(region):
		return 0
	return subregion_map[region].get(room_name, 0)

func get_room_z_index(room_name : StringName) -> int:
	return z_index_override.get(room_name, 0)

func get_region_color(region : StringName) -> Color:
	return region_color.get(region, Color.WHITE)

func get_room_texture(path : String) -> Texture2D:
	if not ResourceLoader.exists(path, "Texture2D"):
		push_warning("Failed to find room image at:\n%s" % path)
		return null
	return load(path)

func get_pickup_texture(path : String) -> Texture2D:
	if not ResourceLoader.exists(path, "Texture2D"):
		push_warning("Failed to find pickup image at:\n%s" % path)
		return null
	return load(path)

func get_region_names() -> Array[StringName]:
	return region_offset.keys()
#endregion

#region Item Methods
## Returns an [member Item] given its name. 
func get_item(item_name : StringName) -> Item:
	# Short Name
	if _items.has(item_name):
		return _items[item_name]
	# Long Name
	if item_long_name_map.has(item_name):
		return item_long_name_map[item_name]
	
	assert(false, "Failed to find item: %s" % item_name)
	return null

func set_items(names : Array[String]) -> void:
	remove_all_items()
	
	for n in names:
		get_item(n).set_capacity(1)

func give_all_items() -> void:
	for i in _items:
		var item := get_item(i)
		item.set_max()
func remove_all_items() -> void:
	for i in _items:
		var item := get_item(i)
		item.set_capacity(0)
#endregion

#region Trick Methods
## Returns a [member Trick] given its name.
func get_trick(trick_name : StringName) -> Trick:
	assert(_tricks.has(trick_name))
	return _tricks[trick_name]

func set_tricks(tricks : Dictionary) -> void:
	for t in tricks:
		get_trick(t).set_level_no_signal(tricks[t])
#endregion

#region Misc Setting Methods
## Returns a [member MiscSetting] given its name.
func get_misc_setting(setting_name : StringName) -> MiscSetting:
	assert(_misc.has(setting_name))
	return _misc[setting_name]

func set_misc_settings(settings : Dictionary) -> void:
	for s in settings:
		if not s in _misc:
			continue
		if not settings[s] is bool:
			continue
		
		get_misc_setting(s).set_enabled(settings[s])
#endregion

#region Event Methods
func get_event(event_name : StringName) -> Event:
	assert(event_name in _events)
	return _events[event_name]

func get_event_from_long_name(event_name : StringName) -> Event:
	assert(event_name in event_long_name_map)
	return event_long_name_map[event_name]

func set_event(event_name : StringName, b : bool) -> void:
	assert(event_name in _events)
	get_event(event_name).set_reached(b)

func reset_events() -> void:
	for key in _events:
		set_event(key, false)
#endregion

func rdvgame_loaded() -> void:
	var rdvgame := RandovaniaInterface.get_rdvgame()
	
	set_items(rdvgame.get_starting_pickups())
	set_tricks(rdvgame.get_trick_levels())
	set_misc_settings(rdvgame.get_config())

class Item:
	signal changed(item : Item)
	
	var name : String = ""
	var long_name : String = ""
	var current_capacity : int = 0
	var max_capacity : int = 0
	
	func _init(_name : String, data : Dictionary) -> void:
		name = _name
		long_name = data.long_name
		max_capacity = data.max_capacity
	
	func set_max() -> void:
		current_capacity = max_capacity
		changed.emit(self)
	func set_max_no_signal() -> void:
		current_capacity = max_capacity
	
	func set_capacity(amount : int) -> void:
		current_capacity = clampi(amount, 0, max_capacity)
		changed.emit(self)
	func set_capacity_no_signal(amount : int) -> void:
		current_capacity = clampi(amount, 0, max_capacity)
	
	func has() -> bool:
		return current_capacity > 0
	
	func get_capacity() -> int:
		return current_capacity

class Event:
	var name : String = ""
	var long_name : String = ""
	var reached : bool = false
	
	func _init(_name : String, data : Dictionary) -> void:
		name = _name
		long_name = data.long_name
	
	func set_reached(b : bool) -> void:
		reached = b

class Trick:
	signal changed(trick : Trick)
	
	var level := TricksInterface.TrickLevel.DISABLED
	var name : String = ""
	var long_name : String = ""
	var description : String = ""
	
	func _init(_name : String, data : Dictionary) -> void:
		name = _name
		long_name = data.long_name
		description = data.description
	
	func get_level() -> TricksInterface.TrickLevel:
		return level
	func set_level(to : TricksInterface.TrickLevel) -> void:
		level = to
		changed.emit(self)
	func set_level_no_signal(to : TricksInterface.TrickLevel) -> void:
		level = to
	
	func can_perform(at_level : TricksInterface.TrickLevel) -> bool:
		return level >= at_level

class MiscSetting:
	signal changed(setting : MiscSetting)
	
	var name : String = ""
	var long_name : String = ""
	var enabled : bool = false ## On/off
	var disabled : bool = true ## Can be turned on/ff
	
	func _init(_name : String, data : Dictionary) -> void:
		name = _name
		long_name = data.long_name
		disabled = name in IGNORED_MISC_SETTINGS
	
	func toggle() -> void:
		enabled = !enabled
		changed.emit(self)
	
	## Is the setting turned on
	func is_enabled() -> bool:
		return enabled
	func set_enabled(on : bool) -> void:
		enabled = on
		changed.emit(self)
	func set_enabled_no_signal(on : bool) -> void:
		enabled = on
	
	## Is the setting not able to be turned on
	func is_disabled() -> bool:
		return disabled
