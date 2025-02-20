class_name PrimeInventory extends Resource

enum Artifact {
	TRUTH,
	STRENGTH,
	ELDER,
	WILD,
	LIFEGIVER,
	WARRIOR,
	CHOZO,
	NATURE,
	SUN,
	WORLD,
	SPIRIT,
	NEWBORN,
	MAX
}
enum TrickLevel {
	DISABLED,
	BEGINNER,
	INTERMEDIATE,
	ADVANCED,
	EXPERT,
	HYPERMODE
}
const TRICK_VALUE_MAP : Dictionary = {
	"disabled" : TrickLevel.DISABLED,
	"beginner" : TrickLevel.BEGINNER,
	"intermediate" : TrickLevel.INTERMEDIATE,
	"advanced" : TrickLevel.ADVANCED,
	"expert" : TrickLevel.EXPERT,
	"hypermode": TrickLevel.HYPERMODE
}
const ETANK_MAX : int = 14
const MISSILE_EXPANSION_MAX : int = 49
const MISSILE_VALUE : int = 5
const PB_MAX : int = 8
const PB_EXPANSION_MAX : int = 4
const PB_EXPANSION_VALUE : int = 1
const MAIN_PB_VALUE : int = 4
const ENERGY_PER_TANK : int = 100

@export var requires_launcher := false
@export var requires_main_pb := false
@export var state := {
	"Energy Tank" : 14,
	
	"Missile Launcher" : 1,
	"Missile Expansion" : 49,
	"Power Bomb" : 1,
	"Power Bomb Expansion" : 4,
	
	"Morph Ball" : 1,
	"Morph Ball Bomb" : 1,
	"Boost Ball" : 1,
	"Spider Ball" : 1,
	
	"Power Suit" : 1,
	"Varia Suit" : 1,
	"Gravity Suit" : 1,
	"Phazon Suit" : 1,
	
	"Combat Visor" : 1,
	"Scan Visor" : 1,
	"Thermal Visor" : 1,
	"X-Ray Visor" : 1,
	
	"Power Beam" : 1,
	"Wave Beam" : 1,
	"Ice Beam" : 1,
	"Plasma Beam" : 1,
	
	"Super Missile" : 1,
	"Wavebuster" : 1,
	"Ice Spreader" : 1,
	"Flamethrower" : 1,
	
	"Space Jump Boots" : 1,
	"Charge Beam" : 1,
	"Grapple Beam" : 1,
	
	"Artifact of Truth" : 1,
	"Artifact of Strength" : 1,
	"Artifact of Elder" : 1,
	"Artifact of Wild" : 1,
	"Artifact of Lifegiver" : 1,
	"Artifact of Warrior" : 1,
	"Artifact of Chozo" : 1,
	"Artifact of Nature" : 1,
	"Artifact of Sun" : 1,
	"Artifact of World" : 1,
	"Artifact of Spirit" : 1,
	"Artifact of Newborn" : 1,
}
@export var tricks := {
	"BJ" : TrickLevel.HYPERMODE,
	"BSJ" : TrickLevel.HYPERMODE,
	"BoostlessSpiner" : TrickLevel.HYPERMODE,
	"CBJ" : TrickLevel.HYPERMODE,
	"ClipThruObjects" : TrickLevel.HYPERMODE,
	"Combat" : TrickLevel.HYPERMODE,
	"DBoosting" : TrickLevel.HYPERMODE,
	"Dash" : TrickLevel.HYPERMODE,
	"HeatRun" : TrickLevel.HYPERMODE,
	"IS" : TrickLevel.HYPERMODE,
	"IUJ" : TrickLevel.HYPERMODE,
	"InvisibleObjects" : TrickLevel.HYPERMODE,
	"Knowledge" : TrickLevel.HYPERMODE,
	"LJump" : TrickLevel.HYPERMODE,
	"Movement" : TrickLevel.HYPERMODE,
	"OoB" : TrickLevel.HYPERMODE,
	"RJump" : TrickLevel.HYPERMODE,
	"SJump" : TrickLevel.HYPERMODE,
	"StandEnemies" : TrickLevel.HYPERMODE,
	"Standable" : TrickLevel.HYPERMODE,
	"UnderwaterMovement" : TrickLevel.HYPERMODE,
	"WallBoost" : TrickLevel.HYPERMODE
}
@export var events := {
	"Event1" : 0,
	"Event2" : 0,
	"Event3" : 0,
	"Event4" : 0,
	"Event5" : 0,
	"Event6" : 0,
	"Event7" : 0,
	"Event8" : 0,
	"Event9" : 0,
	"Event10" : 0,
	"Event11" : 0,
	"Event12" : 0,
	"Event13" : 0,
	"Event14" : 0,
	"Event15" : 0,
	"Event16" : 0,
	"Event17" : 0,
	"Event18" : 0,
	"Event19" : 0,
	"Event20" : 0,
	"Event21" : 0,
	"Event22" : 0,
	"Event23" : 0,
	"Event24" : 0,
	"Event25" : 0,
	"Event26" : 0,
	"Event27" : 0,
	"Event28" : 0,
	"Event29" : 0,
	"Event30" : 0,
	"Event31" : 0,
	"Event32" : 0,
	"Event33" : 0,
	"Event34" : 0,
	"Event35" : 0,
	"Event36" : 0,
	"Event37" : 0,
	"Event38" : 0,
	"Event39" : 0,
	"Event40" : 0,
	"Event41" : 0,
	"Event42" : 0,
	"Event43" : 0,
	"Event44" : 0,
	"Event45" : 0,
	"Event46" : 0,
	"Event47" : 0,
	"Event48" : 0,
	"Event49" : 0,
	"Event50" : 0,
	"Event51" : 0,
	"Event52" : 0,
	"Event53" : 0,
	"Event54" : 0,
	"Event55" : 0,
	"Event56" : 0,
	"Event57" : 0,
}

var rdv_config : Dictionary = {}
var energy : int = ENERGY_PER_TANK
var last_failed_event_id : String

func has_morph() -> bool:
	return state["Morph Ball"] > 0

func has_boost() -> bool:
	return state["Boost Ball"] > 0

func has_spider() -> bool:
	return state["Spider Ball"] > 0

func has_bombs() -> bool:
	return state["Morph Ball Bomb"] > 0

func set_main_pb(on : bool) -> void:
	state["Power Bomb"] = 1 if on else 0
func has_main_pb() -> bool:
	return state["Power Bomb"]

func has_space_jump() -> bool:
	return state["Space Jump Boots"] > 0

func has_charge() -> bool:
	return state["Charge Beam"] > 0

func has_grapple() -> bool:
	return state["Grapple Beam"] > 0

func has_power_suit() -> bool:
	return state["Power Suit"] > 0

func has_varia() -> bool:
	return state["Varia Suit"] > 0

func has_gravity() -> bool:
	return state["Gravity Suit"] > 0

func has_phazon() -> bool:
	return state["Phazon Suit"] > 0

func has_power_beam() -> bool:
	return state["Power Beam"] > 0

func has_wave() -> bool:
	return state["Wave Beam"] > 0

func has_ice_beam() -> bool:
	return state["Ice Beam"] > 0

func has_plasma() -> bool:
	return state["Plasma Beam"] > 0

func has_combat_visor() -> bool:
	return state["Combat Visor"] > 0

func has_scan() -> bool:
	return state["Scan Visor"] > 0

func has_thermal() -> bool:
	return state["Thermal Visor"] > 0

func has_xray() -> bool:
	return state["X-Ray Visor"] > 0

func has_supers() -> bool:
	return state["Super Missile"] > 0

func has_wavebuster() -> bool:
	return state["Wavebuster"] > 0

func has_ice_spreader() -> bool:
	return state["Ice Spreader"] > 0

func has_flamethrower() -> bool:
	return state["Flamethrower"] > 0

func set_launcher(on : bool) -> void:
	state["Missile Launcher"] = 1 if on else 0
func has_launcher() -> bool:
	return state["Missile Launcher"] > 0

func set_etanks(amount : int) -> void:
	state["Energy Tank"] = amount
func get_etanks() -> int:
	return state["Energy Tank"]

func set_missile_expanions(amount : int) -> void:
	state["Missile Expansion"] = amount
func get_missile_expansions() -> int:
	return state["Missile Expansion"]

func set_power_bomb_expanions(amount : int) -> void:
	state["Power Bomb Expansion"] = amount
func get_power_bomb_expansions() -> int:
	return state["Power Bomb Expansion"]

func has_artifact(a : Artifact) -> bool:
	match a:
		Artifact.TRUTH:
			return state["Artifact of Truth"] > 0
		Artifact.STRENGTH:
			return state["Artifact of Strength"] > 0
		Artifact.ELDER:
			return state["Artifact of Elder"] > 0
		Artifact.WILD:
			return state["Artifact of Wild"] > 0
		Artifact.LIFEGIVER:
			return state["Artifact of Lifegiver"] > 0
		Artifact.WARRIOR:
			return state["Artifact of Warrior"] > 0
		Artifact.CHOZO:
			return state["Artifact of Chozo"] > 0
		Artifact.NATURE:
			return state["Artifact of Nature"] > 0
		Artifact.SUN:
			return state["Artifact of Sun"] > 0
		Artifact.WORLD:
			return state["Artifact of World"] > 0
		Artifact.SPIRIT:
			return state["Artifact of Spirit"] > 0
		Artifact.NEWBORN:
			return state["Artifact of Newborn"] > 0
	
	return false

func get_artifact_from_name(name : String) -> Artifact:
	match name:
		"Artifact of Truth":
			return Artifact.TRUTH
		"Artifact of Strength":
			return Artifact.STRENGTH
		"Artifact of Elder":
			return Artifact.ELDER
		"Artifact of Wild":
			return Artifact.WILD
		"Artifact of Lifegiver":
			return Artifact.LIFEGIVER
		"Artifact of Warrior":
			return Artifact.WARRIOR
		"Artifact of Chozo":
			return Artifact.CHOZO
		"Artifact of Nature":
			return Artifact.NATURE
		"Artifact of Sun":
			return Artifact.SUN
		"Artifact of World":
			return Artifact.WORLD
		"Artifact of Spirit":
			return Artifact.SPIRIT
		"Artifact of Newborn":
			return Artifact.NEWBORN
	
	push_error("Couldn't find artifact from name: %s" % name)
	return Artifact.TRUTH

func set_artifact(a : Artifact, owned : bool) -> void:
	match a:
		Artifact.TRUTH:
			state["Artifact of Truth"] = 1 if owned else 0
		Artifact.STRENGTH:
			state["Artifact of Strength"] = 1 if owned else 0
		Artifact.ELDER:
			state["Artifact of Elder"] = 1 if owned else 0
		Artifact.WILD:
			state["Artifact of Wild"] = 1 if owned else 0
		Artifact.LIFEGIVER:
			state["Artifact of Lifegiver"] = 1 if owned else 0
		Artifact.WARRIOR:
			state["Artifact of Warrior"] = 1 if owned else 0
		Artifact.CHOZO:
			state["Artifact of Chozo"] = 1 if owned else 0
		Artifact.NATURE:
			state["Artifact of Nature"] = 1 if owned else 0
		Artifact.SUN:
			state["Artifact of Sun"] = 1 if owned else 0
		Artifact.WORLD:
			state["Artifact of World"] = 1 if owned else 0
		Artifact.SPIRIT:
			state["Artifact of Spirit"] = 1 if owned else 0
		Artifact.NEWBORN:
			state["Artifact of Newborn"] = 1 if owned else 0

func get_total_artifact_count() -> int:
	var total : int = 0
	for i in range(Artifact.MAX):
		total += 1 if has_artifact(i) else 0
	return total

########

func all() -> void:
	for item in state:
		match item:
			"Energy Tank":
				state[item] = ETANK_MAX
			"Missile Expansion":
				state[item] = MISSILE_EXPANSION_MAX
			"Power Bomb Expansion":
				state[item] = PB_EXPANSION_MAX
			_:
				state[item] = 1

func clear() -> void:
	for item in state:
		state[item] = 0

func set_energy_full() -> void:
	energy = ENERGY_PER_TANK + (get_etanks() * ENERGY_PER_TANK)

func has_missile() -> bool:
	if requires_launcher:
		return has_launcher()
	return (has_launcher() or get_missile_expansions() > 0)

func has_pb() -> bool:
	if requires_main_pb:
		return has_main_pb()
	return (has_main_pb() or get_power_bomb_expansions() > 0)

func can_use_arm_cannon() -> bool:
	return (
		has_combat_visor() or
		has_thermal() or 
		has_xray()
	)

func can_shoot_any_beam() -> bool:
	return (
		can_use_arm_cannon() and (
			has_power_beam() or 
			has_wave() or 
			has_ice_beam() or 
			has_plasma()
			)
		)

func set_event_status(event_name : String, occurred : bool) -> void:
	events[event_name] = 1 if occurred else 0

func has_event_occured(event_name : String) -> bool:
	if not events.has(event_name):
		events[event_name] = 0
		push_error("Unhandled event name: %s" % event_name)
	
	return events[event_name] > 0

func take_damage(amount : int) -> void:
	energy -= amount

func can_pass_dock(weakness : String) -> bool:
	match weakness:
		"Normal Door", "Circular Door", "Normal Door (Forced)":
			return can_shoot_any_beam() or (has_morph() and (has_bombs() or has_pb()))
		"Missile Blast Shield", "Missile Blast Shield (randomprime)":
			return can_shoot_any_beam() and has_missile()
		"Wave Door":
			return can_use_arm_cannon() and has_wave()
		"Ice Door":
			return can_use_arm_cannon() and has_ice_beam()
		"Plasma Door":
			return can_use_arm_cannon() and has_plasma()
		"Teleporter", "Square Door":
			return true
		"Morph Ball Door":
			return has_morph()
		"Permanently Locked":
			return false
		"Open Passage":
			return true
		"Closed Passage":
			return false
		_:
			push_error("Unhandled door weakness: %s" % weakness)
	
	return false

func can_perform_trick(type : String, value : int) -> bool:
	if tricks[type] >= value:
		return true
	return false

func parse_item_name(item_name : String) -> bool:
	match item_name:
		"SpaceJump":
			return has_space_jump()
		"Combat":
			return has_combat_visor()
		"Scan":
			return has_scan()
		"Thermal":
			return has_thermal()
		"X-Ray":
			return has_xray()
		"MorphBall":
			return has_morph()
		"Boost":
			return has_boost()
		"Bombs":
			return has_bombs()
		"Spider":
			return has_spider()
		"PowerBomb":
			return has_pb()
		"Missile":
			return has_missile()
		"Charge":
			return has_charge()
		"Grapple":
			return has_grapple()
		"GravitySuit":
			return has_gravity()
		"PhazonSuit":
			return has_phazon()
		"Power":
			return has_power_beam()
		"Ice":
			return has_ice_beam()
		"Plasma":
			return has_plasma()
		"Wave":
			return has_wave()
		"Wavebuster":
			return has_wavebuster()
		
		# Artifacts
		"Chozo":
			return has_artifact(Artifact.CHOZO)
		"Elder":
			return has_artifact(Artifact.ELDER)
		"Lifegiver":
			return has_artifact(Artifact.LIFEGIVER)
		"Nature":
			return has_artifact(Artifact.NATURE)
		"Newborn":
			return has_artifact(Artifact.NEWBORN)
		"Spirit":
			return has_artifact(Artifact.SPIRIT)
		"Strength":
			return has_artifact(Artifact.STRENGTH)
		"Sun":
			return has_artifact(Artifact.SUN)
		"Truth":
			return has_artifact(Artifact.TRUTH)
		"Warrior":
			return has_artifact(Artifact.WARRIOR)
		"Wild":
			return has_artifact(Artifact.WILD)
		"World":
			return has_artifact(Artifact.WORLD)
		
		_:
			push_error("Unhandled item name: %s" % item_name)
	
	return false

func parse_config(setting_name : String) -> bool:
	if not rdv_config:
		if setting_name == "NoGravity":
			return true
		return false
	
	if setting_name in rdv_config:
		if typeof(rdv_config[setting_name]) == TYPE_BOOL:
			return rdv_config[setting_name]
	
	match setting_name:
		"hard_mode":
			return rdv_config["ingame_difficulty"] == "Hard"
		"dock_rando": # TODO
			return false
		"room_rando": # TODO
			return false
		"NoGravity":
			return rdv_config["allow_underwater_movement_without_gravity"]
		_:
			push_error("Unhandled setting_name: %s" % setting_name)
		
	return false

func can_reach(logic : Dictionary, _depth : int = 0) -> bool:
	match logic["type"]:
		"and":
			if logic["data"]["items"].is_empty():
				return true
			
			for i in range(logic["data"]["items"].size()):
				if not can_reach(logic["data"]["items"][i], _depth + 1):
					return false
			return true
		
		"or":
			for i in range(logic["data"]["items"].size()):
				if can_reach(logic["data"]["items"][i], _depth + 1):
					return true
			return false
		
		"resource":
			match logic["data"]["type"]:
				"items":
					var negate : bool = logic["data"]["negate"]
					var has_item := parse_item_name(logic["data"]["name"])
					if negate:
						has_item = not has_item
					return has_item
				"events":
					var negate : bool = logic["data"]["negate"]
					var has_occured := has_event_occured(logic["data"]["name"])
					if not has_occured and not negate:
						last_failed_event_id = logic["data"]["name"]
					if negate:
						has_occured = not has_occured
					return has_occured
				"tricks":
					return can_perform_trick(logic["data"]["name"], logic["data"]["amount"])
				"damage": # TODO
					return energy > logic["data"]["amount"]
				"misc":
					return parse_config(logic["data"]["name"])
				_:
					push_error("Unhandled resource type: %s" % logic["data"]["type"])
		
		"template":
			# Manually entered data from Randovania's header.json
			match logic["data"]:
				"Shoot Super Missile":
					return can_use_arm_cannon() and has_power_beam() and has_missile() and has_charge() and has_supers()
				"Have all Beams":
					return has_power_beam() and has_wave() and has_ice_beam() and has_plasma()
				"Heat-Resisting Suit":
					return has_varia()
				"Can Use Arm Cannon":
					return can_use_arm_cannon()
				"Shoot Any Beam":
					return can_shoot_any_beam()
				"Shoot Power Beam":
					return can_use_arm_cannon() and has_power_beam()
				"Shoot Wave Beam":
					return can_use_arm_cannon() and has_wave()
				"Shoot Ice Beam":
					return can_use_arm_cannon() and has_ice_beam()
				"Shoot Plasma Beam":
					return can_use_arm_cannon() and has_plasma()
				"Use Grapple Beam":
					return can_use_arm_cannon() and has_grapple()
				"Open Normal Door":
					return can_shoot_any_beam() or (has_morph() and has_bombs() and has_scan())
				"Move Past Scatter Bombu":
					return true
				_:
					push_error("Unhandled template type: %s" % logic["data"])
		_:
			push_error("Unhandled logic type: %s" % logic["type"])
	
	return false

func init_state(starting_pickups : Array[String]) -> void:
	clear()
	
	for p in starting_pickups:
		assert(p in state)
		state[p] += 1

func init_tricks(data : Dictionary) -> void:
	for key in data:
		var value : String = data[key]
		tricks[key] = TRICK_VALUE_MAP[value]

func init_from_rdvgame(_rdvgame : RDVGame) -> void:
	rdv_config.clear()
	rdv_config = _rdvgame.get_config()
	
	init_state(_rdvgame.get_starting_pickups())
	init_tricks(_rdvgame.get_trick_levels())

func clear_events() -> void:
	for key in events:
		set_event_status(key, false)
