class_name Prime extends Game

## Region offsets in global coordinates
const OFFSET : Dictionary[StringName, Vector2] = {
	&"Chozo Ruins" :      Vector2(2250, -300),
	&"Phendrana Drifts" : Vector2(500, 0),
	&"Tallon Overworld" : Vector2(2500, 700),
	&"Phazon Mines" :     Vector2(1490, 1350),
	&"Magmoor Caverns" :  Vector2(1000, -500),
}

## Subregion offsets in local coordinates
const SUB_OFFSET : Dictionary[StringName, Array] = {
	&"Phendrana Drifts" : [Vector2.ZERO, Vector2(100, 75)],
	&"Phazon Mines" :     [Vector2(230, 300), Vector2(0, -200), Vector2(180, -600)]
}

## Subregion by region and room name
## If unspecified, assumed to be 0
## Nested dictionary type is [StringName, int]
const SUBREGION_MAP : Dictionary[StringName, Dictionary] = {
	&"Phendrana Drifts" : {
		&"West Tower Entrance" : 1, 
		&"West Tower" : 1, 
		&"Control Tower" : 1, 
		&"East Tower" : 1, 
		&"Aether Lab Entryway" : 1,
	},
	&"Phazon Mines" : {
	}
}
