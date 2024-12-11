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

func has_morph() -> bool:
	return state["Morph Ball"] > 0

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
			push_error("Unhandled door weakness")
	
	return false
