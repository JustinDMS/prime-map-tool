class_name AM2RDockNodeData extends DockNodeData

const TEXTURE_MAP : Dictionary[StringName, Texture2D] = {
	&"door" : preload("res://data/icons/node marker/door.png"),
	&"vertical_dock" : preload("res://data/icons/node marker/door.png"),
	&"horizontal_dock" : preload("res://data/icons/node marker/door.png"),
	&"tunnel" : preload("res://data/icons/node marker/node_marker.png"),
	&"teleporter" : preload("res://data/icons/node marker/teleporter_marker.png"),
	&"other" : preload("res://data/icons/node marker/generic_marker.png")
}

func get_texture() -> Texture2D:
	return TEXTURE_MAP[type]
