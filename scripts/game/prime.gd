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
