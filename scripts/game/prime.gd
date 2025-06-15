class_name Prime extends Game

func _init(rdv_header : Dictionary) -> void:
	super(rdv_header)
	
	# Set virtual members
	region_offset = {
		&"Chozo Ruins" :      Vector2(2250, -300),
		&"Phendrana Drifts" : Vector2(500, 0),
		&"Tallon Overworld" : Vector2(2500, 700),
		&"Phazon Mines" :     Vector2(1490, 1350),
		&"Magmoor Caverns" :  Vector2(1000, -500),
	}
	subregion_offset = {
		&"Phendrana Drifts" : [Vector2.ZERO, Vector2(100, 75)],
		&"Phazon Mines" :     [Vector2(230, 300), Vector2(0, -200), Vector2(180, -600)]
	}
	subregion_map = {
		&"Phendrana Drifts" : {
			&"West Tower Entrance" : 1, 
			&"West Tower" : 1, 
			&"Control Tower" : 1, 
			&"East Tower" : 1, 
			&"Aether Lab Entryway" : 1,
		},
		&"Phazon Mines" : {
			&"Elevator A" : 1,
			&"Elite Control Access" : 1,
			&"Elite Control" : 1,
			&"Maintenance Tunnel" : 1,
			&"Phazon Processing Center" : 1,
			&"Transport Access" : 1,
			&"Transport to Magmoor Caverns South" : 1,
			&"Ventilation Shaft" : 1,
			&"Omega Research" : 1,
			&"Map Station Mines" : 1,
			&"Dynamo Access" : 1,
			&"Central Dynamo" : 1,
			&"Save Station Mines B" : 1,
			&"Quarantine Access A" : 1,
			&"Metroid Quarantine A" : 1,
			&"Elevator Access B" : 1,
			
			&"Elevator B" : 2,
			&"Fungal Hall Access" : 2,
			&"Fungal Hall A" : 2,
			&"Phazon Mining Tunnel" : 2,
			&"Fungal Hall B" : 2,
			&"Missile Station Mines" : 2,
			&"Quarantine Access B" : 2,
			&"Metroid Quarantine B" : 2,
			&"Save Station Mines C" : 2,
			&"Elite Quarters Access" : 2,
			&"Elite Quarters" : 2,
			&"Processing Center Access" : 2,
		}
	}
	z_index_override = {
		&"Hall of the Elders" : 1,
		
		&"Upper Edge Tunnel" : 1,
		&"Frost Cave Access" : 1,
		
		&"Life Grove Tunnel" : 1,
		&"Frigate Crash Site" : 1,
	
		&"Main Quarry" : 1,
		&"Security Access B" : 1,
		&"Omega Research" : 1,
		&"Elite Control" : 1,
		&"Elite Research" : 1,
		
		&"Transport Tunnel C" : 1,
		&"Warrior Shrine" : 1,
		}
	region_color = {
		&"Chozo Ruins" : Color("#EA8C55"),
		&"Phendrana Drifts" : Color("#C9D6EA"),
		&"Tallon Overworld" : Color("#7FB685"),
		&"Phazon Mines" : Color("#BC96E6"),
		&"Magmoor Caverns" : Color("#A7333F"),
		}
	
	var _all := InventoryInterface.AllButton.new(self)
	var none := InventoryInterface.NoneButton.new(self)
	var space_jump := InventoryInterface.PickupButton.new(self, &"SpaceJump", &"res://data/games/prime1/item_images/Space Jump Boots.png")
	var charge_beam := InventoryInterface.PickupButton.new(self, &"Charge", &"res://data/games/prime1/item_images/Charge Beam.png")
	var grapple_beam := InventoryInterface.PickupButton.new(self, &"Grapple", &"res://data/games/prime1/item_images/Grapple Beam.png")
	
	var varia := InventoryInterface.PickupButton.new(self, &"VariaSuit", &"res://data/games/prime1/item_images/Varia Suit.png")
	var combat := InventoryInterface.PickupButton.new(self, &"Combat", &"res://data/games/prime1/item_images/Combat Visor.png")
	var morph := InventoryInterface.PickupButton.new(self, &"MorphBall", &"res://data/games/prime1/item_images/Morph Ball.png")
	var power := InventoryInterface.PickupButton.new(self, &"Power", &"res://data/games/prime1/item_images/Power Beam.png")
	var supers := InventoryInterface.PickupButton.new(self, &"Supers", &"res://data/games/prime1/item_images/Super Missile.png")
	
	var gravity := InventoryInterface.PickupButton.new(self, &"GravitySuit", &"res://data/games/prime1/item_images/Gravity Suit.png")
	var scan := InventoryInterface.PickupButton.new(self, &"Scan", &"res://data/games/prime1/item_images/Scan Visor.png")
	var bombs := InventoryInterface.PickupButton.new(self, &"Bombs", &"res://data/games/prime1/item_images/Morph Ball Bomb.png")
	var wave := InventoryInterface.PickupButton.new(self, &"Wave", &"res://data/games/prime1/item_images/Wave Beam.png")
	var wavebuster := InventoryInterface.PickupButton.new(self, &"Wavebuster", &"res://data/games/prime1/item_images/Wavebuster.png")
	
	var phazon := InventoryInterface.PickupButton.new(self, &"PhazonSuit", &"res://data/games/prime1/item_images/Phazon Suit.png")
	var thermal := InventoryInterface.PickupButton.new(self, &"Thermal", &"res://data/games/prime1/item_images/Thermal Visor.png")
	var boost := InventoryInterface.PickupButton.new(self, &"Boost", &"res://data/games/prime1/item_images/Boost Ball.png")
	var ice := InventoryInterface.PickupButton.new(self, &"Ice", &"res://data/games/prime1/item_images/Ice Beam.png")
	var ice_spreader := InventoryInterface.PickupButton.new(self, &"IceSpreader", &"res://data/games/prime1/item_images/Ice Spreader.png")
	
	var spacer := InventoryInterface.Spacer.new()
	var xray := InventoryInterface.PickupButton.new(self, &"X-Ray", &"res://data/games/prime1/item_images/X-Ray Visor.png")
	var spider := InventoryInterface.PickupButton.new(self, &"Spider", &"res://data/games/prime1/item_images/Spider Ball.png")
	var plasma := InventoryInterface.PickupButton.new(self, &"Plasma", &"res://data/games/prime1/item_images/Plasma Beam.png")
	var flamethrower := InventoryInterface.PickupButton.new(self, &"Flamethrower", &"res://data/games/prime1/item_images/Flamethrower.png")
	
	var missiles := InventoryInterface.PickupSlider.new(self, &"Missile", &"res://data/games/prime1/item_images/Missile Expansion.png", 5, 50)
	var etanks := InventoryInterface.PickupSlider.new(self, &"EnergyTank", &"res://data/games/prime1/item_images/Energy Tank.png", 1, 14)
	var pbs := InventoryInterface.PickupSlider.new(self, &"PowerBomb", &"res://data/games/prime1/item_images/Power Bomb Expansion.png", 1, 8)
	
	var artifact_names : Array[StringName] = [
		&"Truth",
		&"Strength",
		&"Elder",
		&"Wild",
		&"Lifegiver",
		&"Warrior",
		&"Chozo",
		&"Nature",
		&"Sun",
		&"World",
		&"Spirit",
		&"Newborn"
	]
	var artifact_icon_paths : Array[StringName] = [
		&"res://data/games/prime1/item_images/Artifact of Truth.png",
		&"res://data/games/prime1/item_images/Artifact of Strength.png",
		&"res://data/games/prime1/item_images/Artifact of Elder.png",
		&"res://data/games/prime1/item_images/Artifact of Wild.png",
		&"res://data/games/prime1/item_images/Artifact of Lifegiver.png",
		&"res://data/games/prime1/item_images/Artifact of Warrior.png",
		&"res://data/games/prime1/item_images/Artifact of Chozo.png",
		&"res://data/games/prime1/item_images/Artifact of Nature.png",
		&"res://data/games/prime1/item_images/Artifact of Sun.png",
		&"res://data/games/prime1/item_images/Artifact of World.png",
		&"res://data/games/prime1/item_images/Artifact of Spirit.png",
		&"res://data/games/prime1/item_images/Artifact of Newborn.png"
	]
	var artifacts := InventoryInterface.ArtifactSlider.new(self, artifact_names, artifact_icon_paths, Color("#F1A34C"), Color("#4CDAF5"))
	
	inventory_layout = [
		[_all, none, space_jump, charge_beam, grapple_beam],
		[varia, combat, morph, power, supers],
		[gravity, scan, bombs, wave, wavebuster],
		[phazon, thermal, boost, ice, ice_spreader],
		[spacer, xray, spider, plasma, flamethrower],
		[missiles, etanks],
		[pbs, artifacts]
	]

func new_room_data() -> PrimeRoomData:
	return PrimeRoomData.new()
func new_room() -> PrimeRoom:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	const PRIME_ROOM_SCRIPT : GDScript = preload("res://scripts/room/prime/prime_room.gd")
	
	var room := BASE_ROOM.instantiate()
	room.set_script(PRIME_ROOM_SCRIPT)
	
	return room
