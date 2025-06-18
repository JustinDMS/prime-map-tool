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
	var arm_cannon := InventoryInterface.PickupButton.new(self, &"Arm Cannon", &"res://data/games/am2r/item_images/dna.png")
	var bombs := InventoryInterface.PickupButton.new(self, &"Bombs", &"res://data/games/am2r/item_images/morph_ball_bomb.png")
	var power_grip := InventoryInterface.PickupButton.new(self, &"Power Grip", &"res://data/games/am2r/item_images/power_grip.png")
	
	var spider := InventoryInterface.PickupButton.new(self, &"Spider Ball", &"res://data/games/am2r/item_images/spider_ball.png")
	var spring := InventoryInterface.PickupButton.new(self, &"Spring Ball", &"res://data/games/am2r/item_images/spring_ball.png")
	var screw := InventoryInterface.PickupButton.new(self, &"Screw Attack", &"res://data/games/am2r/item_images/screw_attack.png")
	var varia := InventoryInterface.PickupButton.new(self, &"Varia Suit", &"res://data/games/am2r/item_images/varia_suit.png")
	var space := InventoryInterface.PickupButton.new(self, &"Space Jump", &"res://data/games/am2r/item_images/space_jump.png")
	
	var speed := InventoryInterface.PickupButton.new(self, &"Speed Booster", &"res://data/games/am2r/item_images/speed_booster.png")
	var hj := InventoryInterface.PickupButton.new(self, &"Hi-Jump", &"res://data/games/am2r/item_images/hi_jump_boots.png")
	var grav := InventoryInterface.PickupButton.new(self, &"Gravity Suit", &"res://data/games/am2r/item_images/gravity_suit.png")
	var charge := InventoryInterface.PickupButton.new(self, &"Charge Beam", &"res://data/games/am2r/item_images/charge_beam.png")
	var ice := InventoryInterface.PickupButton.new(self, &"Ice Beam", &"res://data/games/am2r/item_images/ice_beam.png")
	
	var wave := InventoryInterface.PickupButton.new(self, &"Wave Beam", &"res://data/games/am2r/item_images/wave_beam.png")
	var spazer := InventoryInterface.PickupButton.new(self, &"Spazer Beam", &"res://data/games/am2r/item_images/spazer_beam.png")
	var plasma := InventoryInterface.PickupButton.new(self, &"Plasma Beam", &"res://data/games/am2r/item_images/plasma_beam.png")
	var morph := InventoryInterface.PickupButton.new(self, &"Morph Ball", &"res://data/games/am2r/item_images/morph_ball.png")
	var launcher := InventoryInterface.PickupButton.new(self, &"Missile Launcher", &"res://data/games/am2r/item_images/missile_launcher.png")
	var super_launcher := InventoryInterface.PickupButton.new(self, &"Super Missile Launcher", &"res://data/games/am2r/item_images/sm_launcher.png")
	var pb_launcher := InventoryInterface.PickupButton.new(self, &"Power Bomb Launcher", &"res://data/games/am2r/item_images/pb_launcher.png")
	
	var long := InventoryInterface.PickupButton.new(self, &"Long Beam", &"res://data/games/am2r/item_images/dna.png")
	var ibp := InventoryInterface.PickupButton.new(self, &"Infinite Bomb Propulsion", &"res://data/games/am2r/item_images/dna.png")
	var wjb := InventoryInterface.PickupButton.new(self, &"Walljump Boots", &"res://data/games/am2r/item_images/dna.png")
	var alpha := InventoryInterface.PickupButton.new(self, &"Alpha Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var gamma := InventoryInterface.PickupButton.new(self, &"Gamma Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var zeta := InventoryInterface.PickupButton.new(self, &"Zeta Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	var omega := InventoryInterface.PickupButton.new(self, &"Omega Metroid Lure", &"res://data/games/am2r/item_images/dna.png")
	
	var missiles := InventoryInterface.PickupSlider.new(self, &"Missiles", &"res://data/games/am2r/item_images/missile.png", 5, 50)
	var supers := InventoryInterface.PickupSlider.new(self, &"Super Missiles", &"res://data/games/am2r/item_images/super_missile.png", 1, 20)
	var etanks := InventoryInterface.PickupSlider.new(self, &"Energy Tank", &"res://data/games/am2r/item_images/energy_tank.png", 1, 10)
	var pbs := InventoryInterface.PickupSlider.new(self, &"Power Bombs", &"res://data/games/am2r/item_images/power_bomb.png", 1, 20)
	
	inventory_layout = [
		[_all, none, wjb, hj, space],
		[arm_cannon, launcher, power_grip, charge, super_launcher],
		[long, wave, ice, spazer, plasma],
		[morph, bombs, spring, spider, pb_launcher],
		[varia, grav, speed, screw, ibp],
		[alpha, gamma, zeta, omega],
		[missiles, supers],
		[etanks, pbs]
	]

func new_room_data() -> AM2RRoomData:
	return AM2RRoomData.new()
func new_room() -> AM2RRoom:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	const ROOM_SCRIPT : GDScript = preload("res://scripts/room/am2r/am2r_room.gd")
	
	var room := BASE_ROOM.instantiate()
	room.set_script(ROOM_SCRIPT)
	
	return room
