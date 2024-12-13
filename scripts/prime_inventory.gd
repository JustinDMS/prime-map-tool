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

func clear() -> void:
	for item in state.keys():
		state[item] = 0

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

func has_varia() -> bool:
	return state["Varia Suit"] > 0

func has_gravity() -> bool:
	return state["Gravity Suit"] > 0

func has_scan() -> bool:
	return state["Scan Visor"] > 0

func has_space_jump() -> bool:
	return state["Space Jump Boots"] > 0

func has_morph() -> bool:
	return state["Morph Ball"] > 0

func has_boost() -> bool:
	return state["Boost Ball"] > 0

func has_bombs() -> bool:
	return state["Morph Ball Bomb"] > 0

func has_spider() -> bool:
	return state["Spider Ball"] > 0

func has_missile() -> bool:
	return (state["Missile Launcher"] > 0 or state["Missile Expansion"] > 0)

func has_pb() -> bool:
	return (state["Power Bomb"] > 0 or state["Power Bomb Expansion"] > 0)

func has_grapple() -> bool:
	return state["Grapple Beam"] > 0

func has_charge() -> bool:
	return state["Charge Beam"] > 0

func has_supers() -> bool:
	return state["Super Missile"] > 0

func has_power_beam() -> bool:
	return state["Power Beam"] > 0

func has_wave() -> bool:
	return state["Wave Beam"] > 0

func can_shoot() -> bool:
	return (
		state["Combat Visor"] > 0 or
		state["Thermal Visor"] > 0 or 
		state["X-Ray Visor"] > 0
		) and (
			has_power_beam() or 
			state["Wave Beam"] > 0 or 
			state["Ice Beam"] > 0 or 
			state["Plasma Beam"] > 0
		)

func can_pass_dock(weakness : String) -> bool:
	match weakness:
		"Normal Door", "Circular Door":
			return can_shoot() or (has_morph() and (state["Morph Ball Bomb"] > 0 or has_pb()))
		"Missile Blast Shield":
			return can_shoot() and has_missile()
		"Wave Door":
			return can_shoot() and state["Wave Beam"] > 0
		"Ice Door":
			return can_shoot() and state["Ice Beam"] > 0
		"Plasma Door":
			return can_shoot() and state["Plasma Beam"] > 0
		"Teleporter", "Square Door":
			return true
		"Morph Ball Door":
			return has_morph()
		"Permanently Locked":
			return false
		_:
			push_error("Unhandled door weakness: %s" % weakness)
	
	return false

func parse_item_name(item_name : String) -> bool:
	match item_name:
		"SpaceJump":
			return has_space_jump()
		"Scan":
			return has_scan()
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
		"GravitySuit":
			return has_gravity()
		
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
					return true # TODO
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
				"Shoot Super Missile":
					return can_shoot() and has_missile() and has_charge() and has_supers()
				"Use Grapple Beam":
					return can_shoot() and has_grapple()
				"Heat-Resisting Suit":
					return has_varia()
				_:
					push_error("Unhandled template type: %s" % logic["data"])
		_:
			push_error("Unhandled logic type: %s" % logic["type"])
	
	return false
