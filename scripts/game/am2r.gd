class_name AM2R extends Game

const ROOM_WIDTH : int = 320
const ROOM_HEIGHT : int = 240
const ROOM_DIVISOR : int = 8

func _init(rdv_header : Dictionary) -> void:
	super(rdv_header)
	
	# Set virtual members
	# TODO: fix colors
	region_color = {
		&"Main Caves": Color.WHITE,
		&"Golden Temple": Color.WHITE,
		&"Hydro Station": Color.WHITE,
		&"Industrial Complex": Color.WHITE,
		&"The Tower": Color.WHITE,
		&"Distribution Center": Color.WHITE,
		&"The Depths": Color.WHITE,
		&"Genetics Laboratory": Color.WHITE,
		&"GFS Thoth": Color.WHITE,
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
	var arm_cannon := InventoryInterface.PickupButton.new(self, &"Arm Cannon", &"res://data/games/am2r/item_images/Arm Cannon.png")
	var power_grip := InventoryInterface.PickupButton.new(self, &"Power Grip", &"res://data/games/am2r/item_images/Power Grip.png")
	var wall_jump := InventoryInterface.PickupButton.new(self, &"Walljump Boots", &"res://data/games/am2r/item_images/Walljump Boots.png")
	
	var missile_launcher := InventoryInterface.PickupButton.new(self, &"Missile Launcher", &"res://data/games/am2r/item_images/Missile Launcher.png")
	var super_launcher := InventoryInterface.PickupButton.new(self, &"Super Missile Launcher", &"res://data/games/am2r/item_images/Super Missile Launcher.png")
	var pb_launcher := InventoryInterface.PickupButton.new(self, &"Power Bomb Launcher", &"res://data/games/am2r/item_images/Power Bomb Launcher.png")
	var charge := InventoryInterface.PickupButton.new(self, &"Charge Beam", &"res://data/games/am2r/item_images/Charge Beam.png")
	var varia := InventoryInterface.PickupButton.new(self, &"Varia Suit", &"res://data/games/am2r/item_images/Varia Suit.png")
	
	var hi_jump := InventoryInterface.PickupButton.new(self, &"Hi-Jump", &"res://data/games/am2r/item_images/Hi-Jump Boots.png")
	var space_jump := InventoryInterface.PickupButton.new(self, &"Space Jump", &"res://data/games/am2r/item_images/Space Jump.png")
	var speed_boost := InventoryInterface.PickupButton.new(self, &"Speed Booster", &"res://data/games/am2r/item_images/Speed Booster.png")
	var screw := InventoryInterface.PickupButton.new(self, &"Screw Attack", &"res://data/games/am2r/item_images/Screw Attack.png")
	var gravity := InventoryInterface.PickupButton.new(self, &"Gravity Suit", &"res://data/games/am2r/item_images/Gravity Suit.png")
	
	var morph := InventoryInterface.PickupButton.new(self, &"Morph Ball", &"res://data/games/am2r/item_images/Morph Ball.png")
	var bombs := InventoryInterface.PickupButton.new(self, &"Bombs", &"res://data/games/am2r/item_images/Bombs.png")
	var spider := InventoryInterface.PickupButton.new(self, &"Spider Ball", &"res://data/games/am2r/item_images/Spider Ball.png")
	var spring := InventoryInterface.PickupButton.new(self, &"Spring Ball", &"res://data/games/am2r/item_images/Spring Ball.png")
	var inf_bomb_propulsion := InventoryInterface.PickupButton.new(self, &"Infinite Bomb Propulsion", &"res://data/games/am2r/item_images/Infinite Bomb Propulsion.png")
	
	var long_beam := InventoryInterface.PickupButton.new(self, &"Long Beam", &"res://data/games/am2r/item_images/Long Beam.png")
	var wave := InventoryInterface.PickupButton.new(self, &"Wave Beam", &"res://data/games/am2r/item_images/Wave Beam.png")
	var ice := InventoryInterface.PickupButton.new(self, &"Ice Beam", &"res://data/games/am2r/item_images/Ice Beam.png")
	var spazer := InventoryInterface.PickupButton.new(self, &"Spazer Beam", &"res://data/games/am2r/item_images/Spazer Beam.png")
	var plasma := InventoryInterface.PickupButton.new(self, &"Plasma Beam", &"res://data/games/am2r/item_images/Plasma Beam.png")
	
	# Temporary icon paths
	var alpha := InventoryInterface.PickupButton.new(self, &"Alpha Metroid Lure", &"res://data/games/am2r/item_images/Unknown.png")
	var gamma := InventoryInterface.PickupButton.new(self, &"Gamma Metroid Lure", &"res://data/games/am2r/item_images/Unknown.png")
	var zeta := InventoryInterface.PickupButton.new(self, &"Zeta Metroid Lure", &"res://data/games/am2r/item_images/Unknown.png")
	var omega := InventoryInterface.PickupButton.new(self, &"Omega Metroid Lure", &"res://data/games/am2r/item_images/Unknown.png")
	
	var missiles := InventoryInterface.PickupSlider.new(self, &"Missiles", &"res://data/games/am2r/item_images/Missile Expansion.png", 5, 50)
	var supers := InventoryInterface.PickupSlider.new(self, &"Super Missiles", &"res://data/games/am2r/item_images/Super Missile Tank.png", 1, 20)
	var pbs := InventoryInterface.PickupSlider.new(self, &"Power Bombs", &"res://data/games/am2r/item_images/Power Bomb Tank.png", 1, 20)
	
	var dna_names : Array[StringName] = [&"Metroid DNA 1", &"Metroid DNA 2", &"Metroid DNA 3", &"Metroid DNA 4", &"Metroid DNA 5", &"Metroid DNA 6", &"Metroid DNA 7", &"Metroid DNA 8", &"Metroid DNA 9", &"Metroid DNA 10", &"Metroid DNA 11", &"Metroid DNA 12", &"Metroid DNA 13", &"Metroid DNA 14", &"Metroid DNA 15", &"Metroid DNA 16", &"Metroid DNA 17", &"Metroid DNA 18", &"Metroid DNA 19", &"Metroid DNA 20", &"Metroid DNA 21", &"Metroid DNA 22", &"Metroid DNA 23", &"Metroid DNA 24", &"Metroid DNA 25", &"Metroid DNA 26", &"Metroid DNA 27", &"Metroid DNA 28", &"Metroid DNA 29", &"Metroid DNA 30", &"Metroid DNA 31", &"Metroid DNA 32", &"Metroid DNA 33", &"Metroid DNA 34", &"Metroid DNA 35", &"Metroid DNA 36", &"Metroid DNA 37", &"Metroid DNA 38", &"Metroid DNA 39", &"Metroid DNA 40", &"Metroid DNA 41", &"Metroid DNA 42", &"Metroid DNA 43", &"Metroid DNA 44", &"Metroid DNA 45", &"Metroid DNA 46"]
	var dnas := InventoryInterface.MultiPickupSlider.new(self, dna_names, &"res://data/games/am2r/item_images/dna.png")
	var etanks := InventoryInterface.PickupSlider.new(self, &"Energy Tank", &"res://data/games/am2r/item_images/Energy Tank.png", 1, 10)
	
	inventory_layout = [
		[_all, none, arm_cannon, power_grip, wall_jump],
		[missile_launcher, super_launcher, pb_launcher, charge, varia],
		[hi_jump, space_jump, speed_boost, screw, gravity],
		[morph, bombs, spider, spring, inf_bomb_propulsion],
		[long_beam, wave, ice, spazer, plasma],
		[alpha, gamma, zeta, omega],
		[missiles, supers, pbs],
		[etanks, dnas]
	]

func get_game_id() -> StringName:
	return &"am2r"

@warning_ignore_start("integer_division") # https://github.com/godotengine/godot/issues/42966
func init_room_data(_room_data : RoomData, _extra_data : Dictionary) -> void:
	_room_data.extra.map_name = _extra_data.extra.map_name
	
	var all_x : Array[int] = []
	var all_y : Array[int] = []
	for ele in _extra_data.extra.minimap_data:
		all_x.append( int(ele.x) )
		all_y.append( int(ele.y) )
	all_x.sort()
	all_y.sort()
	
	if len(all_x) > 0:
		_room_data.extra.x_position = all_x[0] * (ROOM_WIDTH / ROOM_DIVISOR)
		_room_data.extra.y_position = all_y[0] * (ROOM_HEIGHT / ROOM_DIVISOR)
	else:
		_room_data.extra.x_position = 10
		_room_data.extra.y_position = 10
	
	# Set room texture
	var path := "res://data/games/%s/room_images/%s.png" % [get_game_id(), _room_data.extra.map_name]
	_room_data.texture = get_room_texture(path)
	
	_room_data.extra.image_width = _room_data.texture.get_width() / ROOM_DIVISOR
	_room_data.extra.image_height = _room_data.texture.get_height() / ROOM_DIVISOR
@warning_ignore_restore("integer_division")

func init_room(room : Room) -> void:
	room.position.x = room.data.extra.x_position
	room.position.y = room.data.extra.y_position
	
	room.custom_minimum_size.x = room.data.extra.image_width
	room.custom_minimum_size.y = room.data.extra.image_height
	
	var outline_config := Room.OutlineConfig.new(
		&"res://resources/highlight_shader.tres",
		0, 15, 25
	)
	room.material = load( outline_config.shader_path ).duplicate()
	room.config = outline_config
