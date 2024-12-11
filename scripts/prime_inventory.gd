class_name PrimeInventory extends Resource

@export var state := {
	"Charge Beam" : 0,
	"Power Beam" : 0,
	"Wave Beam" : 0,
	"Ice Beam" : 0,
	"Plasma Beam" : 0,
	"Missile Launcher" : 0,
	"Grapple Beam" : 0,
	"Combat Visor" : 0,
	"Scan Visor" : 0,
	"Thermal Visor" : 0,
	"X-Ray Visor" : 0,
	"Space Jump Boots" : 0,
	"Energy Tank" : 0,
	"Morph Ball" : 0,
	"Morph Ball Bomb" : 0,
	"Boost Ball" : 0,
	"Spider Ball" : 0,
	"Power Bomb" : 0,
	"Power Suit" : 0,
	"Varia Suit" : 0,
	"Gravity Suit" : 0,
	"Phazon Suit" : 0,
	"Super Missile" : 0,
	"Wavebuster" : 0,
	"Ice Spreader" : 0,
	"Flamethrower" : 0,
	
	"Missile Expansion" : 0,
	"Power Bomb Expansion" : 0,
}

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

func can_shoot() -> bool:
	return (
		state["Combat Visor"] > 0 or
		state["Themal Visor"] > 0 or 
		state["X-Ray Visor"] > 0
		) and (
			state["Power Beam"] > 0 or 
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
		_:
			push_error("Unhandled item name: %s" % item_name)
	
	return true

func can_reach(logic : Dictionary) -> bool:
	var type : String = logic["type"]
	
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
				_:
					push_error("Unhandled template type: %s" % logic["data"])
		_:
			push_error("Unhandled logic type: %s" % logic["type"])
	
	return true
