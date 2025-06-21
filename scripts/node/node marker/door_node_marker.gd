class_name DoorNodeMarker extends NodeMarker

const DOOR_MARKER_OFFSET : float = 50.0

func init_node() -> void:
	super()
	
	if data.is_vertical_door():
		marker_offset.y = DOOR_MARKER_OFFSET
	else:
		rotation_degrees = data.rotation.z
		marker_offset.x = -DOOR_MARKER_OFFSET
	
	offset = marker_offset
