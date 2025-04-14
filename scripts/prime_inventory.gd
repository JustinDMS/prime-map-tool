class_name PrimeInventory extends Resource

const PRIME_HEADER := preload("res://data/header.json").data
const ARTIFACT_NAMES : Array[String] = ["Truth", "Strength", "Elder", "Wild", "Lifegiver", "Warrior", "Chozo", "Nature", "Sun", "World", "Spirit", "Newborn"]

var last_failed_event_id : String

var _items := {}
var _events := {}
var _tricks := {}
var _misc := {}
var _templates := {}

func _init() -> void:
	for type in PRIME_HEADER.resource_database:
		match type:
			"items":
				for res in PRIME_HEADER.resource_database.items:
					_items[res] = Item.new(res, PRIME_HEADER.resource_database.items[res])
			"events":
				for res in PRIME_HEADER.resource_database.events:
					_events[res] = false
			"tricks":
				for res in PRIME_HEADER.resource_database.tricks:
					_tricks[res] = Trick.new(res, PRIME_HEADER.resource_database.tricks[res])
			"misc":
				for res in PRIME_HEADER.resource_database.misc:
					_misc[res] = MiscSetting.new(res, PRIME_HEADER.resource_database.misc[res])
			"requirement_template":
				for res in PRIME_HEADER.resource_database.requirement_template:
					_templates[res] = PRIME_HEADER.resource_database.requirement_template[res].requirement
			_:
				continue

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

func get_total_artifact_count() -> int:
	var total : int = 0
	for n in ARTIFACT_NAMES:
		total += _get_item(n).get_capacity()
	return total

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
	return can_reach(PRIME_HEADER.dock_weakness_database.types[type].items[weakness].requirement)
func can_pass_lock(type : String, weakness : String) -> bool:
	# True if there is no lock
	var pass_lock : bool = PRIME_HEADER.dock_weakness_database.types[type].items[weakness].lock == null
	if not pass_lock:
		pass_lock = can_reach(PRIME_HEADER.dock_weakness_database.types[type].items[weakness].lock.requirement)
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
			match name:
				"Missile":
					var launcher := _get_item("MissileLauncher").has()
					var missile := _get_item(name).has()
					result = missile or launcher
				"PowerBomb":
					var main := _get_item("MainPB").has()
					var pbs := _get_item(name).has()
					result = pbs or main
				_:
					result = _get_item(name).has()
		"events":
			result = get_event(name)
			if not result and not negate:
				last_failed_event_id = name
		"tricks":
			result = get_trick(name).can_perform(amount)
		"damage": # TODO
			result = max(_get_item("EnergyTank").get_capacity() * PrimeInventoryInterface.ENERGY_PER_TANK, PrimeInventoryInterface.ENERGY_PER_TANK) > amount
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
