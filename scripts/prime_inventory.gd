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
	NEWBORN
}

const TRICK_VALUE_MAP : Dictionary = {
	"disabled" : 0,
	"beginner" : 1,
	"intermediate" : 2,
	"advanced" : 3,
	"expert" : 4,
	"hypermode": 5
}

@export var requires_launcher := false
@export var requires_main_pb := false
@export var state := {
	"Morph Ball" : 1,
	"Boost Ball" : 1,
	"Spider Ball" : 1,
	"Morph Ball Bomb" : 1,
	
	"Power Bomb" : 1,
	"Space Jump Boots" : 1,
	"Charge Beam" : 1,
	"Grapple Beam" : 1,
	
	"Power Suit" : 1,
	"Varia Suit" : 1,
	"Gravity Suit" : 1,
	"Phazon Suit" : 1,
	
	"Power Beam" : 1,
	"Wave Beam" : 1,
	"Ice Beam" : 1,
	"Plasma Beam" : 1,
	
	"Combat Visor" : 1,
	"Scan Visor" : 1,
	"Thermal Visor" : 1,
	"X-Ray Visor" : 1,
	
	"Super Missile" : 1,
	"Wavebuster" : 1,
	"Ice Spreader" : 1,
	"Flamethrower" : 1,
	
	"Missile Launcher" : 1,
	"Energy Tank" : 14,
	"Missile Expansion" : 49,
	"Power Bomb Expansion" : 4,
	
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
	"BJ" : TRICK_VALUE_MAP["disabled"],
	"BSJ" : TRICK_VALUE_MAP["disabled"],
	"BoostlessSpiner" : TRICK_VALUE_MAP["disabled"],
	"CBJ" : TRICK_VALUE_MAP["disabled"],
	"ClipThruObjects" : TRICK_VALUE_MAP["disabled"],
	"Combat" : TRICK_VALUE_MAP["disabled"],
	"DBoosting" : TRICK_VALUE_MAP["disabled"],
	"Dash" : TRICK_VALUE_MAP["disabled"],
	"HeatRun" : TRICK_VALUE_MAP["disabled"],
	"IS" : TRICK_VALUE_MAP["disabled"],
	"IUJ" : TRICK_VALUE_MAP["disabled"],
	"InvisibleObjects" : TRICK_VALUE_MAP["disabled"],
	"Knowledge" : TRICK_VALUE_MAP["disabled"],
	"LJump" : TRICK_VALUE_MAP["disabled"],
	"Movement" : TRICK_VALUE_MAP["disabled"],
	"OoB" : TRICK_VALUE_MAP["disabled"],
	"RJump" : TRICK_VALUE_MAP["disabled"],
	"SJump" : TRICK_VALUE_MAP["disabled"],
	"StandEnemies" : TRICK_VALUE_MAP["disabled"],
	"Standable" : TRICK_VALUE_MAP["disabled"],
	"UnderwaterMovement" : TRICK_VALUE_MAP["disabled"],
	"WallBoost" : TRICK_VALUE_MAP["disabled"]
}

func has_morph() -> bool:
	return state["Morph Ball"] > 0

func has_boost() -> bool:
	return state["Boost Ball"] > 0

func has_spider() -> bool:
	return state["Spider Ball"] > 0

func has_bombs() -> bool:
	return state["Morph Ball Bomb"] > 0

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

func has_launcher() -> bool:
	return state["Missile Launcher"] > 0

func get_etanks() -> int:
	return state["Energy Tank"]

func get_missile_expansions() -> int:
	return state["Missile Expansion"]

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

########

func clear() -> void:
	for item in state.keys():
		state[item] = 0

func has_missile() -> bool:
	if requires_launcher:
		return has_launcher()
	return (has_launcher() or get_missile_expansions() > 0)

func has_pb() -> bool:
	if requires_main_pb:
		return has_main_pb()
	return (has_main_pb() or get_power_bomb_expansions() > 0)

func can_shoot() -> bool:
	return (
		has_combat_visor() or
		has_thermal() or 
		has_xray()
		) and (
			has_power_beam() or 
			has_wave() or 
			has_ice_beam() or 
			has_plasma()
		)

func can_pass_dock(weakness : String) -> bool:
	match weakness:
		"Normal Door", "Circular Door":
			return can_shoot() or (has_morph() and (has_bombs() or has_pb()))
		"Missile Blast Shield":
			return can_shoot() and has_missile()
		"Wave Door":
			return can_shoot() and has_wave()
		"Ice Door":
			return can_shoot() and has_ice_beam()
		"Plasma Door":
			return can_shoot() and has_plasma()
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

func can_reach(logic : Dictionary) -> bool:
	match logic["type"]:
		"and":
			if logic["data"]["items"].is_empty():
				return true
			
			for i in range(logic["data"]["items"].size()):
				if not can_reach(logic["data"]["items"][i]):
					return false
			return true
		
		"or":
			for i in range(logic["data"]["items"].size()):
				if can_reach(logic["data"]["items"][i]):
					return true
			return false
		
		"resource":
			match logic["data"]["type"]:
				"items":
					return parse_item_name(logic["data"]["name"])
				"events":
					return true # TODO
				"tricks":
					return can_perform_trick(logic["data"]["name"], logic["data"]["amount"])
				"damage":
					return true # TODO
				"misc":
					return true # TODO
				_:
					push_error("Unhandled resource type: %s" % logic["data"]["type"])
		
		"template":
			match logic["data"]:
				"Shoot Any Beam":
					return can_shoot()
				"Shoot Power Beam":
					return can_shoot() and has_power_beam()
				"Shoot Wave Beam":
					return can_shoot() and has_wave()
				"Shoot Ice Beam":
					return can_shoot() and has_ice_beam()
				"Shoot Plasma Beam":
					return can_shoot() and has_plasma()
				"Have all Beams":
					return has_power_beam() and has_wave() and has_ice_beam() and has_plasma()
				"Shoot Super Missile":
					return can_shoot() and has_missile() and has_charge() and has_supers()
				"Use Grapple Beam":
					return can_shoot() and has_grapple()
				"Heat-Resisting Suit":
					return has_varia()
				"Move Past Scatter Bombu":
					return true
				_:
					push_error("Unhandled template type: %s" % logic["data"])
		_:
			push_error("Unhandled logic type: %s" % logic["type"])
	
	return false

func init_tricks(data : Dictionary) -> void:
	for key in data.keys():
		var value : String = data[key]
		tricks[key] = TRICK_VALUE_MAP[value]

func can_perform_trick(type : String, value : int) -> bool:
	if tricks[type] >= value:
		return true
	return false
