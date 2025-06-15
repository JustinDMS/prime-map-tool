class_name AM2R extends Game

func _init(rdv_header : Dictionary) -> void:
	super(rdv_header)
	
	# Set virtual members
	# TODO: fix colors
	region_color = {
		&"Chozo Ruins" : Color("#EA8C55"),
		&"Phendrana Drifts" : Color("#C9D6EA"),
		&"Tallon Overworld" : Color("#7FB685"),
		&"Phazon Mines" : Color("#BC96E6"),
		&"Magmoor Caverns" : Color("#A7333F"),
	}
	
	# TODO: Fix inventory
	var _all := InventoryInterface.AllButton.new(self)
	var none := InventoryInterface.NoneButton.new(self)
	var arm_cannon := InventoryInterface.PickupButton.new(self, &"Arm Cannon", &"res://data/games/prime1/item_images/Space Jump Boots.png")
	var bombs := InventoryInterface.PickupButton.new(self, &"Bombs", &"res://data/games/prime1/item_images/Charge Beam.png")
	var power_grip := InventoryInterface.PickupButton.new(self, &"Power Grip", &"res://data/games/prime1/item_images/Grapple Beam.png")
	
	var spider := InventoryInterface.PickupButton.new(self, &"Spider Ball", &"res://data/games/prime1/item_images/Varia Suit.png")
	var spring := InventoryInterface.PickupButton.new(self, &"Spring Ball", &"res://data/games/prime1/item_images/Combat Visor.png")
	var screw := InventoryInterface.PickupButton.new(self, &"Screw Attack", &"res://data/games/prime1/item_images/Morph Ball.png")
	var varia := InventoryInterface.PickupButton.new(self, &"Varia Suit", &"res://data/games/prime1/item_images/Power Beam.png")
	var space := InventoryInterface.PickupButton.new(self, &"Space Jump", &"res://data/games/prime1/item_images/Super Missile.png")
	
	var speed := InventoryInterface.PickupButton.new(self, &"Speed Booster", &"res://data/games/prime1/item_images/Gravity Suit.png")
	var hj := InventoryInterface.PickupButton.new(self, &"Hi-Jump", &"res://data/games/prime1/item_images/Scan Visor.png")
	var grav := InventoryInterface.PickupButton.new(self, &"Gravity Suit", &"res://data/games/prime1/item_images/Morph Ball Bomb.png")
	var charge := InventoryInterface.PickupButton.new(self, &"Charge Beam", &"res://data/games/prime1/item_images/Wave Beam.png")
	var ice := InventoryInterface.PickupButton.new(self, &"Ice Beam", &"res://data/games/prime1/item_images/Wavebuster.png")
	
	var wave := InventoryInterface.PickupButton.new(self, &"Wave Beam", &"res://data/games/prime1/item_images/Phazon Suit.png")
	var spazer := InventoryInterface.PickupButton.new(self, &"Spazer Beam", &"res://data/games/prime1/item_images/Thermal Visor.png")
	var plasma := InventoryInterface.PickupButton.new(self, &"Plasma Beam", &"res://data/games/prime1/item_images/Boost Ball.png")
	var morph := InventoryInterface.PickupButton.new(self, &"Morph Ball", &"res://data/games/prime1/item_images/Ice Beam.png")
	var launcher := InventoryInterface.PickupButton.new(self, &"Missile Launcher", &"res://data/games/prime1/item_images/Ice Spreader.png")
	var super_launcher := InventoryInterface.PickupButton.new(self, &"Super Missile Launcher", &"res://data/games/prime1/item_images/Ice Spreader.png")
	var pb_launcher := InventoryInterface.PickupButton.new(self, &"Power Bomb Launcher", &"res://data/games/prime1/item_images/Ice Spreader.png")
	
	var spacer := InventoryInterface.Spacer.new()
	var long := InventoryInterface.PickupButton.new(self, &"Long Beam", &"res://data/games/prime1/item_images/X-Ray Visor.png")
	var ibp := InventoryInterface.PickupButton.new(self, &"Infinite Bomb Propulsion", &"res://data/games/prime1/item_images/Spider Ball.png")
	var wjb := InventoryInterface.PickupButton.new(self, &"Walljump Boots", &"res://data/games/prime1/item_images/Plasma Beam.png")
	var alpha := InventoryInterface.PickupButton.new(self, &"Alpha Metroid Lure", &"res://data/games/prime1/item_images/Flamethrower.png")
	var gamma := InventoryInterface.PickupButton.new(self, &"Gamma Metroid Lure", &"res://data/games/prime1/item_images/Flamethrower.png")
	var zeta := InventoryInterface.PickupButton.new(self, &"Zeta Metroid Lure", &"res://data/games/prime1/item_images/Flamethrower.png")
	var omega := InventoryInterface.PickupButton.new(self, &"Omega Metroid Lure", &"res://data/games/prime1/item_images/Flamethrower.png")
	
	var missiles := InventoryInterface.PickupSlider.new(self, &"Missiles", &"res://data/games/prime1/item_images/Missile Expansion.png", 5, 50)
	var supers := InventoryInterface.PickupSlider.new(self, &"Super Missiles", &"res://data/games/prime1/item_images/Missile Expansion.png", 5, 50)
	var etanks := InventoryInterface.PickupSlider.new(self, &"Energy Tank", &"res://data/games/prime1/item_images/Energy Tank.png", 1, 14)
	var pbs := InventoryInterface.PickupSlider.new(self, &"Power Bombs", &"res://data/games/prime1/item_images/Power Bomb Expansion.png", 1, 8)
	
	#var truth := InventoryInterface.PickupButton.new(self, &"Truth", &"res://data/games/prime1/item_images/Artifact of Truth.png")
	#var strength := InventoryInterface.PickupButton.new(self, &"Strength", &"res://data/games/prime1/item_images/Artifact of Strength.png")
	#var elder := InventoryInterface.PickupButton.new(self, &"Elder", &"res://data/games/prime1/item_images/Artifact of Elder.png")
	#var wild := InventoryInterface.PickupButton.new(self, &"Wild", &"res://data/games/prime1/item_images/Artifact of Wild.png")
	#var lifegiver := InventoryInterface.PickupButton.new(self, &"Lifegiver", &"res://data/games/prime1/item_images/Artifact of Lifegiver.png")
	#var warrior := InventoryInterface.PickupButton.new(self, &"Warrior", &"res://data/games/prime1/item_images/Artifact of Warrior.png")
	#var chozo := InventoryInterface.PickupButton.new(self, &"Chozo", &"res://data/games/prime1/item_images/Artifact of Chozo.png")
	#var nature := InventoryInterface.PickupButton.new(self, &"Nature", &"res://data/games/prime1/item_images/Artifact of Nature.png")
	#var sun := InventoryInterface.PickupButton.new(self, &"Sun", &"res://data/games/prime1/item_images/Artifact of Sun.png")
	#var world := InventoryInterface.PickupButton.new(self, &"World", &"res://data/games/prime1/item_images/Artifact of World.png")
	#var spirit := InventoryInterface.PickupButton.new(self, &"Spirit", &"res://data/games/prime1/item_images/Artifact of Spirit.png")
	#var newborn := InventoryInterface.PickupButton.new(self, &"Newborn", &"res://data/games/prime1/item_images/Artifact of Newborn.png")
	
	inventory_layout = [
		[_all, none, arm_cannon, bombs, power_grip],
		[spider, spring, screw, varia, space],
		[speed, hj, grav, charge, ice],
		[wave, spazer, plasma, morph, launcher],
		[super_launcher, pb_launcher],
		[spacer, long, ibp, wjb, alpha],
		[alpha, gamma, zeta, omega],
		[missiles, supers, etanks, pbs],
		#[truth, strength, elder, wild, lifegiver, warrior],
		#[chozo, nature, sun, world, spirit, newborn]
	]

func new_room_data() -> AM2RRoomData:
	return AM2RRoomData.new()
func new_room() -> AM2RRoom:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	const ROOM_SCRIPT : GDScript = preload("res://scripts/room/am2r/am2r_room.gd")
	
	var room := BASE_ROOM.instantiate()
	room.set_script(ROOM_SCRIPT)
	
	return room
