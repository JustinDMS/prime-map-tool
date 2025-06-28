class_name Prime extends Game

const DOCK_COLOR_MAP : Dictionary[StringName, Color] = {
	&"teleporter" : Color.PURPLE,
	&"morph_ball" : Color.ORCHID,
	
	&"Normal Door" : Color.DEEP_SKY_BLUE,
	&"Normal Door (Forced)" : Color.DEEP_SKY_BLUE,
	&"Circular Door" : Color.DEEP_SKY_BLUE,
	&"Square Door" : Color.DEEP_SKY_BLUE,
	
	&"Charge Beam Blast Shield" : Color.CADET_BLUE,
	
	&"Power Beam Only Door" : Color.GOLD,
	&"Super Missile Blast Shield" : Color.LAWN_GREEN,
	
	&"Wave Door" : Color.MEDIUM_PURPLE,
	&"Wavebuster Blast Shield" : Color.WEB_PURPLE,
	
	&"Ice Door" : Color.ALICE_BLUE,
	&"Ice Spreader Blast Shield" : Color.LIGHT_STEEL_BLUE,
	
	&"Plasma Door" : Color.ORANGE_RED,
	&"Flamethrower Blast Shield" : Color.DARK_RED,
	
	&"Missile Blast Shield" : Color.DARK_GRAY,
	&"Missile Blast Shield (randomprime)" : Color.DARK_GRAY,
	
	&"Permanently Locked" : Color.DIM_GRAY,
	
	&"Bomb Blast Shield" : Color.LIGHT_SALMON,
	&"Power Bomb Blast Shield" : Color.ORANGE,
}
const DOOR_OFFSET : float = 50.0
const ARTIFACT_BLUE := Color("#4CDAF5")
const ARTIFACT_ORANGE := Color("#F1A34C")

func _init(rdv_header : Dictionary) -> void:
	super(rdv_header)
	
	# Set virtual members
	region_offset = {
		&"Chozo Ruins" :      Vector2(2250, -300),
		&"Phendrana Drifts" : Vector2(600, 0),
		&"Tallon Overworld" : Vector2(2500, 700),
		&"Phazon Mines" :     Vector2(1490, 1270),
		&"Magmoor Caverns" :  Vector2(1000, -500),
	}
	subregion_offset = {
		&"Phendrana Drifts" : [Vector2.ZERO, Vector2(100, 75)],
		&"Phazon Mines" :     [Vector2(230, 300), Vector2(230, -140), Vector2(-50, -670)]
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
		
		&"Control Tower" : 1,
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

func get_game_id() -> StringName:
	return &"prime1"
func get_region_scale() -> Vector2:
	return Vector2(1, -1)

func init_room_data(_room_data : RoomData, _extra_data : Dictionary) -> void:
	# Float array of size 6
	# x_min, y_min, z_min, x_max, y_max, z_max
	_room_data.extra.aabb = [
		_extra_data.extra.aabb[0],
		_extra_data.extra.aabb[1],
		_extra_data.extra.aabb[2],
		_extra_data.extra.aabb[3],
		_extra_data.extra.aabb[4],
		_extra_data.extra.aabb[5]
		]
	
	# Set room texture
	var path := "res://data/games/%s/room_images/%s/%s.png" % \
	[get_game_id(), _room_data.region, _room_data.name]
	_room_data.texture = get_room_texture(path)

func init_room(room : Room) -> void:
	room.create_bitmap()
	
	var x1 : float = room.data.extra.aabb[0]
	var y1 : float = room.data.extra.aabb[1]
	var x2 : float = room.data.extra.aabb[3]
	var y2 : float = room.data.extra.aabb[4]
	
	room.position.x = x1
	room.position.y = y1
	
	room.custom_minimum_size.x = abs(x2 - x1)
	room.custom_minimum_size.y = abs(y2 - y1)
	
	var outline_config := Room.OutlineConfig.new(
		5, # - Outline thickness while hovered
		8  # - Outline thickness for starting room
	)
	room.config = outline_config
	room._material = outline_config.SHADER.duplicate()

func init_node_data(_node_data : NodeData, _extra_data : Dictionary) -> void:
	_node_data.set_type(_extra_data.node_type)
	_node_data.set_coords(Vector2(
		_extra_data.extra.world_position[0],
		_extra_data.extra.world_position[1]
		))
	
	match _node_data.type:
		&"dock":
			_node_data.set_scale( Vector2(0.1, 0.1) )
			_node_data.set_hover_scale( Vector2(0.15, 0.15) )
			
			_node_data.set_dock_type(_extra_data.dock_type)
			_node_data.set_dock_weakness(_extra_data.default_dock_weakness)
			
			if _node_data.is_door():
				_node_data.set_dock_rotation(Vector3(
					_extra_data.extra.world_rotation[0],
					_extra_data.extra.world_rotation[1],
					_extra_data.extra.world_rotation[2]
					))
			
			_node_data.set_color(
				DOCK_COLOR_MAP[_node_data.extra.dock_type] if not _node_data.is_door() \
				else DOCK_COLOR_MAP[_node_data.extra.dock_weakness]
			)
			
			_node_data.set_texture(SHARED_NODE_TEXTURES.get(
				_node_data.extra.dock_type,
				SHARED_NODE_TEXTURES["default"]
				))
		
		&"pickup":
			_node_data.set_scale( Vector2(0.0375, 0.0375) )
			_node_data.set_hover_scale( Vector2(0.05, 0.05) )
			
			# Logic db names don't match pickup long names so
			# we need to parse it
			# This is for pickup texture lookup
			
			# Get what is in the parenthesis
			var item_name : StringName = _node_data.name.split("(")[1].split(")")[0]
			if _extra_data.location_category == "minor":
				if item_name.contains(&"Missile"):
					item_name = &"Missile Expansion"
				else:
					match item_name:
						&"Power Bomb":
							item_name = &"Power Bomb Expansion"
						&"Energy Transfer Module":
							item_name = &"Nothing"
			# Majors
			else:
				if is_artifact( item_name ):
					item_name = &"Artifacts"
					_node_data.set_color( ARTIFACT_BLUE )
				match item_name:
					&"Main Power Bombs":
						item_name = &"Power Bomb"
					&"Morph Ball Bombs":
						item_name = &"Morph Ball Bomb"
					&"Missile Launcher":
						item_name = &"Missile Expansion"
			
			_node_data.set_item_name(item_name)
			
			var path := "res://data/games/%s/item_images/%s.png" % \
			[get_game_id(), _node_data.get_item_name()]
			_node_data.set_texture( get_pickup_texture(path) )
		
		&"generic":
			_node_data.set_scale( Vector2(0.1, 0.1) )
			_node_data.set_hover_scale( Vector2(0.15, 0.15) )
			_node_data.set_color(Color.WHEAT)
			_node_data.set_texture( SHARED_NODE_TEXTURES[_node_data.type] )
			_node_data.set_heal(_extra_data.heal)
		
		&"event":
			_node_data.set_scale( Vector2(0.1, 0.1) )
			_node_data.set_hover_scale( Vector2(0.15, 0.15) )
			_node_data.set_color(Color.LIME_GREEN)
			_node_data.set_texture( SHARED_NODE_TEXTURES[_node_data.type] )
			_node_data.set_event_id(_extra_data.event_name)

func init_node_marker(_marker : NodeMarker) -> void:
	match _marker.data.get_type():
		&"dock":
			var offset := Vector2()
			
			if _marker.data.is_door():
				offset.x = -DOOR_OFFSET
				if is_vertical_door( _marker.data.get_dock_rotation() ):
					offset.y = DOOR_OFFSET
				else:
					_marker.rotation_degrees = _marker.data.get_dock_rotation().z
			
			_marker.set_offset(offset)
		
		&"pickup": 
			_marker.set_flip_v(true)
		
		&"generic": pass
		&"event": pass

# Prime-specific methods

func is_vertical_door(rotation : Vector3) -> bool:
	const THRESHOLD := 20.0
	return abs(rotation.x) > THRESHOLD

func is_artifact(item_name : StringName) -> bool:
	return &"Artifact" in item_name
