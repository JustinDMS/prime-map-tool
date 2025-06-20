class_name Game extends Resource
## Generic data container for Randovania games

var _header := {} ## Randovania data
var _items : Dictionary[String, Item] = {}
var _events : Dictionary[String, Event] = {}
var _tricks : Dictionary[String, Trick] = {}
var _misc : Dictionary[String, MiscSetting] = {}
var _templates := {}

var last_failed_event_id : String = "" ## Used when resolving

#region Virtual Members
## Map of region names and their offsets in global space
var region_offset : Dictionary[StringName, Vector2] = {}

## Map of region names that contain subregions and their offsets in local coordinates
## Inner array expected type is Array[Vector2]
var subregion_offset : Dictionary[StringName, Array] = {}

## Map of region names and room subregion indices
## Inner dictionary expected type is Dictionary[StrinName, int] 
var subregion_map : Dictionary[StringName, Dictionary] = {}

## Map of room names and their z-indices
var  z_index_override : Dictionary[StringName, int] = {}

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
func new_room_data() -> RoomData:
	return null
func init_room(_room : Room) -> void: 
	pass
#endregion

func _init(rdv_header : Dictionary) -> void:
	_header = rdv_header
	var resource_db : Dictionary = _header.resource_database
	
	for type in resource_db:
		match type:
			"items":
				for res in resource_db.items:
					_items[res] = Item.new(res, resource_db.items[res])
			"events":
				for res in resource_db.events:
					_events[res] = Event.new(res, resource_db.events[res])
			"tricks":
				for res in resource_db.tricks:
					_tricks[res] = Trick.new(res, resource_db.tricks[res])
			"misc":
				for res in resource_db.misc:
					_misc[res] = MiscSetting.new(res, resource_db.misc[res])
			"requirement_template":
				for res in resource_db.requirement_template:
					_templates[res] = resource_db.requirement_template[res].requirement
			_:
				continue

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

## Returns an [member Item] given its name. 
## Supports both short/long names for lookup.
func get_item(item_name : String) -> Item:
	if " " in item_name:
		return _get_item_from_long_name(item_name)
	return _get_item(item_name)

func _get_item(item_name : String) -> Item:
	assert(_items.has(item_name))
	return _items[item_name]

func _get_item_from_long_name(item_name : String) -> Item:
	# Ugly brute force lookup
	for i in _items:
		var item := _get_item(i)
		if item.long_name == item_name:
			return item
	return null

func set_items(names : Array[String]) -> void:
	clear()
	
	for n in names:
		get_item(n).set_capacity(1)

## Returns a [member Trick] given its name.
func get_trick(trick_name : String) -> Trick:
	assert(_tricks.has(trick_name))
	return _tricks[trick_name]

func set_tricks(tricks : Dictionary) -> void:
	for t in tricks:
		get_trick(t).set_level_no_signal(tricks[t])

## Returns a [member MiscSetting] given its name.
func get_misc_setting(setting_name : String) -> MiscSetting:
	assert(_misc.has(setting_name))
	return _misc[setting_name]

func set_misc_settings(settings : Dictionary) -> void:
	for s in settings:
		if not s in _misc:
			continue
		if not settings[s] is bool:
			continue
		
		get_misc_setting(s).set_enabled(settings[s])

func get_event(event_name : String) -> Event:
	assert(event_name in _events)
	return _events[event_name]
func set_event(event_name : String, b : bool) -> void:
	assert(event_name in _events)
	get_event(event_name).set_reached(b)
func clear_events() -> void:
	for key in _events:
		set_event(key, false)

func all() -> void:
	for i in _items:
		var item := _get_item(i)
		item.set_max()
func clear() -> void:
	for i in _items:
		var item := _get_item(i)
		item.set_capacity(0)

func can_pass_dock(type : String, weakness : String) -> bool:
	return can_reach(_header.dock_weakness_database.types[type].items[weakness].requirement)
func can_pass_lock(type : String, weakness : String) -> bool:
	# True if there is no lock
	var pass_lock : bool = _header.dock_weakness_database.types[type].items[weakness].lock == null
	if not pass_lock:
		pass_lock = can_reach(_header.dock_weakness_database.types[type].items[weakness].lock.requirement)
	return pass_lock

func rdvgame_loaded() -> void:
	var rdvgame := RandovaniaInterface.get_rdvgame()
	
	set_items(rdvgame.get_starting_pickups())
	set_tricks(rdvgame.get_trick_levels())
	set_misc_settings(rdvgame.get_config())

func has_resource(logic_data : Dictionary) -> bool:
	var type : String = logic_data.type
	var name : String = logic_data.name
	var amount : int = logic_data.amount
	var negate : bool = logic_data.negate
	var result := false
	
	match logic_data.type:
		"items":
			result = _get_item(name).has()
		"events":
			result = get_event(name).reached
			if not result and not negate:
				last_failed_event_id = name
		"tricks":
			result = get_trick(name).can_perform(amount)
		"damage": # TODO
			result = true
		"misc":
			result = get_misc_setting(name).is_enabled()
		_:
			push_error("Unhandled resource type: %s" % type)
	
	if negate:
		result = not result
	
	return result

func can_reach(logic : Dictionary, _depth : int = 0) -> bool:
	match logic.type:
		"and":
			if logic.data.items.is_empty():
				return true
			
			for i in range(logic.data.items.size()):
				if not can_reach(logic.data.items[i], _depth + 1):
					return false
			return true
		
		"or":
			for i in range(logic.data.items.size()):
				if can_reach(logic.data.items[i], _depth + 1):
					return true
			return false
		
		"resource":
			return has_resource(logic.data)
		
		"template":
			return can_reach(_templates[logic.data])
		
		_:
			push_error("Unhandled logic type: %s" % logic.type)
	
	return false

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
	
	const IGNORE : Array[String] = ["room_rando", "dock_rando"]
	
	var name : String = ""
	var long_name : String = ""
	var enabled : bool = false ## On/off
	var disabled : bool = true ## Can be turned on/ff
	
	func _init(_name : String, data : Dictionary) -> void:
		name = _name
		long_name = data.long_name
		disabled = name in IGNORE
	
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
