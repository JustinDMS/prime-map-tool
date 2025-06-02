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
		&"Phazon Mines" : {}
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
