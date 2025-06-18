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
	
	region_offset = {
		&"Main Caves": Vector2.ZERO,
		&"Golden Temple": Vector2.ZERO,
		&"Hydro Station": Vector2.ZERO,
		&"Industrial Complex": Vector2.ZERO,
		&"The Tower": Vector2.ZERO,
		&"Distribution Center": Vector2.ZERO,
		&"The Depths": Vector2.ZERO,
		&"Genetics Laboratory": Vector2.ZERO,
		&"GFS Thoth": Vector2.ZERO,
	}
	
	# TODO: Fix inventory
	var _all := InventoryInterface.AllButton.new(self)
	var none := InventoryInterface.NoneButton.new(self)
	var missile_launcher := InventoryInterface.PickupButton.new(self, &"Missile Launcher", &"res://data/games/am2r/item_images/Missile Launcher.png")
	var super_launcher := InventoryInterface.PickupButton.new(self, &"Super Missile Launcher", &"res://data/games/am2r/item_images/Super Missile Launcher.png")
	var pb_launcher := InventoryInterface.PickupButton.new(self, &"Power Bomb Launcher", &"res://data/games/am2r/item_images/Power Bomb Launcher.png")
	
	var charge := InventoryInterface.PickupButton.new(self, &"Charge Beam", &"res://data/games/am2r/item_images/Charge Beam.png")
	var wave := InventoryInterface.PickupButton.new(self, &"Wave Beam", &"res://data/games/am2r/item_images/Wave Beam.png")
	var spazer := InventoryInterface.PickupButton.new(self, &"Spazer Beam", &"res://data/games/am2r/item_images/Spazer Beam.png")
	var plasma := InventoryInterface.PickupButton.new(self, &"Plasma Beam", &"res://data/games/am2r/item_images/Plasma Beam.png")
	var ice := InventoryInterface.PickupButton.new(self, &"Ice Beam", &"res://data/games/am2r/item_images/Ice Beam.png")
	
	var morph := InventoryInterface.PickupButton.new(self, &"Morph Ball", &"res://data/games/am2r/item_images/Morph Ball.png")
	var bombs := InventoryInterface.PickupButton.new(self, &"Bombs", &"res://data/games/am2r/item_images/Bombs.png")
	var spider := InventoryInterface.PickupButton.new(self, &"Spider Ball", &"res://data/games/am2r/item_images/Spider Ball.png")
	var spring := InventoryInterface.PickupButton.new(self, &"Spring Ball", &"res://data/games/am2r/item_images/Spring Ball.png")
	var screw := InventoryInterface.PickupButton.new(self, &"Screw Attack", &"res://data/games/am2r/item_images/Screw Attack.png")
	
	var power_grip := InventoryInterface.PickupButton.new(self, &"Power Grip", &"res://data/games/am2r/item_images/Power Grip.png")
	var hi_jump := InventoryInterface.PickupButton.new(self, &"Hi-Jump", &"res://data/games/am2r/item_images/Hi-Jump Boots.png")
	var space_jump := InventoryInterface.PickupButton.new(self, &"Space Jump", &"res://data/games/am2r/item_images/Space Jump.png")
	var speed_boost := InventoryInterface.PickupButton.new(self, &"Speed Booster", &"res://data/games/am2r/item_images/Speed Booster.png")
	var spacer := InventoryInterface.Spacer.new()
	
	var varia := InventoryInterface.PickupButton.new(self, &"Varia Suit", &"res://data/games/am2r/item_images/Varia Suit.png")
	var gravity := InventoryInterface.PickupButton.new(self, &"Gravity Suit", &"res://data/games/am2r/item_images/Gravity Suit.png")
	var spacer2 := InventoryInterface.Spacer.new(0.74)
	var dna_names : Array[StringName] = [&"Metroid DNA 1", &"Metroid DNA 2", &"Metroid DNA 3", &"Metroid DNA 4", &"Metroid DNA 5", &"Metroid DNA 6", &"Metroid DNA 7", &"Metroid DNA 8", &"Metroid DNA 9", &"Metroid DNA 10", &"Metroid DNA 11", &"Metroid DNA 12", &"Metroid DNA 13", &"Metroid DNA 14", &"Metroid DNA 15", &"Metroid DNA 16", &"Metroid DNA 17", &"Metroid DNA 18", &"Metroid DNA 19", &"Metroid DNA 20", &"Metroid DNA 21", &"Metroid DNA 22", &"Metroid DNA 23", &"Metroid DNA 24", &"Metroid DNA 25", &"Metroid DNA 26", &"Metroid DNA 27", &"Metroid DNA 28", &"Metroid DNA 29", &"Metroid DNA 30", &"Metroid DNA 31", &"Metroid DNA 32", &"Metroid DNA 33", &"Metroid DNA 34", &"Metroid DNA 35", &"Metroid DNA 36", &"Metroid DNA 37", &"Metroid DNA 38", &"Metroid DNA 39", &"Metroid DNA 40", &"Metroid DNA 41", &"Metroid DNA 42", &"Metroid DNA 43", &"Metroid DNA 44", &"Metroid DNA 45", &"Metroid DNA 46"]
	var dna := InventoryInterface.MultiPickupSlider.new(self, dna_names, &"res://data/games/am2r/item_images/dna.png")
	var spacer3 := InventoryInterface.Spacer.new(0.74)
	
	var alpha := InventoryInterface.PickupButton.new(self, &"Alpha Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var gamma := InventoryInterface.PickupButton.new(self, &"Gamma Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var zeta := InventoryInterface.PickupButton.new(self, &"Zeta Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var omega := InventoryInterface.PickupButton.new(self, &"Omega Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	
	var missiles := InventoryInterface.PickupSlider.new(self, &"Missiles", &"res://data/games/am2r/item_images/Missile Expansion.png", 5, 50)
	var supers := InventoryInterface.PickupSlider.new(self, &"Super Missiles", &"res://data/games/am2r/item_images/Super Missile Tank.png", 1, 20)
	var etanks := InventoryInterface.PickupSlider.new(self, &"Energy Tank", &"res://data/games/am2r/item_images/Energy Tank.png", 1, 10)
	var pbs := InventoryInterface.PickupSlider.new(self, &"Power Bombs", &"res://data/games/am2r/item_images/Power Bomb Tank.png", 1, 20)
	
	
	inventory_layout = [
		[_all, none, missile_launcher, super_launcher, pb_launcher],
		[charge, wave, spazer, plasma, ice],
		[morph, bombs, spider, spring, screw],
		[power_grip, hi_jump, space_jump, speed_boost, spacer],
		[varia, gravity, spacer2, dna, spacer3],
		[alpha, gamma, zeta, omega],
		[missiles, supers], 
		[etanks, pbs]
	]

func get_game_id() -> StringName:
	return &"am2r"
func new_room_data() -> AM2RRoomData:
	return AM2RRoomData.new()
func new_room() -> AM2RRoom:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	const ROOM_SCRIPT : GDScript = preload("res://scripts/room/am2r/am2r_room.gd")
	
	var room := BASE_ROOM.instantiate()
	room.set_script(ROOM_SCRIPT)
	
	return room
