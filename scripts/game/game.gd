class_name Game extends Resource
## Generic data container for Randovania games

static var HEADERS : Dictionary[String, Dictionary] = {
	"prime1" : preload("res://data/games/prime1/header.json").data,
}

static func create_from_game_name(name : String):
	var header : Dictionary = HEADERS.get(name, {})
	assert(not header.is_empty())
	return Game.new(header)

var _header := {} ## Randovania data
var _items : Dictionary[String, Item] = {}
var _events : Dictionary[String, bool] = {}
var _tricks : Dictionary[String, Trick] = {}
var _misc : Dictionary[String, MiscSetting] = {}
var _templates := {}

var last_failed_event_id : String = "" ## Used when resolving

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
					_events[res] = false
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

## Returns logic database data if it exists
func get_region_data() -> Dictionary[StringName, Dictionary]:
	var data : Dictionary[StringName, Dictionary] = {}
	
	for r in _header.regions:
		var path := StringName("res://data/games/%s/%s" % [_header.game, r])
		if ResourceLoader.exists(path, "JSON"):
			var json := load(path)
			data[r.rstrip(".json")] = json.data
			continue
		
		push_warning("Could not find region data at %s" % path)
	
	return data

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

func get_event(event_name : String) -> bool:
	assert(event_name in _events)
	return _events[event_name]
func set_event(event_name : String, occurred : bool) -> void:
	assert(event_name in _events)
	_events[event_name] = occurred
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
			result = get_event(name)
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
	var current_capacity : int = -1
	var max_capacity : int = -1
	
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
