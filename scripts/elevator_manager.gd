extends Control

const VANILLA_ELEVATOR_DATA := {
	"Phendrana Drifts/Transport to Magmoor Caverns West/Teleporter to Magmoor Caverns": "Magmoor Caverns/Transport to Phendrana Drifts North/Teleporter to Phendrana Drifts",
	"Phendrana Drifts/Transport to Magmoor Caverns South/Teleporter to Magmoor Caverns": "Magmoor Caverns/Transport to Phendrana Drifts South/Teleporter to Phendrana Drifts",
	"Magmoor Caverns/Transport to Chozo Ruins North/Teleporter to Chozo Ruins": "Chozo Ruins/Transport to Magmoor Caverns North/Teleporter to Magmoor Caverns",
	"Magmoor Caverns/Transport to Phendrana Drifts North/Teleporter to Phendrana Drifts": "Phendrana Drifts/Transport to Magmoor Caverns West/Teleporter to Magmoor Caverns",
	"Magmoor Caverns/Transport to Tallon Overworld West/Teleporter to Tallon Overworld": "Tallon Overworld/Transport to Magmoor Caverns East/Teleporter to Magmoor Caverns",
	"Magmoor Caverns/Transport to Phazon Mines West/Teleporter to Phazon Mines": "Phazon Mines/Transport to Magmoor Caverns South/Teleporter to Magmoor Caverns",
	"Magmoor Caverns/Transport to Phendrana Drifts South/Teleporter to Phendrana Drifts": "Phendrana Drifts/Transport to Magmoor Caverns South/Teleporter to Magmoor Caverns",
	"Phazon Mines/Transport to Tallon Overworld South/Teleporter to Tallon Overworld": "Tallon Overworld/Transport to Phazon Mines East/Teleporter to Phazon Mines",
	"Phazon Mines/Transport to Magmoor Caverns South/Teleporter to Magmoor Caverns": "Magmoor Caverns/Transport to Phazon Mines West/Teleporter to Phazon Mines",
	"Tallon Overworld/Transport to Chozo Ruins West/Teleporter to Chozo Ruins": "Chozo Ruins/Transport to Tallon Overworld North/Teleporter to Tallon Overworld",
	"Tallon Overworld/Transport to Chozo Ruins East/Teleporter to Chozo Ruins": "Chozo Ruins/Transport to Tallon Overworld East/Teleporter to Tallon Overworld",
	"Tallon Overworld/Transport to Magmoor Caverns East/Teleporter to Magmoor Caverns": "Magmoor Caverns/Transport to Tallon Overworld West/Teleporter to Tallon Overworld",
	"Tallon Overworld/Transport to Chozo Ruins South/Teleporter to Chozo Ruins": "Chozo Ruins/Transport to Tallon Overworld South/Teleporter to Tallon Overworld",
	"Tallon Overworld/Transport to Phazon Mines East/Teleporter to Phazon Mines": "Phazon Mines/Transport to Tallon Overworld South/Teleporter to Tallon Overworld",
	"Chozo Ruins/Transport to Tallon Overworld North/Teleporter to Tallon Overworld": "Tallon Overworld/Transport to Chozo Ruins West/Teleporter to Chozo Ruins",
	"Chozo Ruins/Transport to Magmoor Caverns North/Teleporter to Magmoor Caverns": "Magmoor Caverns/Transport to Chozo Ruins North/Teleporter to Chozo Ruins",
	"Chozo Ruins/Transport to Tallon Overworld East/Teleporter to Tallon Overworld": "Tallon Overworld/Transport to Chozo Ruins East/Teleporter to Chozo Ruins",
	"Chozo Ruins/Transport to Tallon Overworld South/Teleporter to Tallon Overworld": "Tallon Overworld/Transport to Chozo Ruins South/Teleporter to Chozo Ruins"
}
const LINE_WIDTH : float = 5.0
const LINE_CAPS := Line2D.LINE_CAP_ROUND
const Z_IDX : int = 1
const LINE_COLOR := Color.WHITE

@export var world_manager : World

func _ready() -> void:
	world_manager.map_drawn.connect(init_elevators)

func init_elevators(dock_connections : Dictionary = VANILLA_ELEVATOR_DATA) -> void:
	const MINES_SUBREGIONS := {
		"Phazon Mines/Elevator B/Door to Elevator Access B" : "Phazon Mines/Elevator Access B/Door to Elevator B",
		"Phazon Mines/Phazon Processing Center/Door to Processing Center Access" : "Phazon Mines/Processing Center Access/Door to Phazon Processing Center",
		"Phazon Mines/Elevator A/Door to Elevator Access A" : "Phazon Mines/Elevator Access A/Door to Elevator A"
	}
	
	for node in get_children():
		node.queue_free()
	
	var connections := dock_connections.duplicate()
	connections.merge(MINES_SUBREGIONS.duplicate())
	
	var drawn : Array[String] = []
	
	for key in connections.keys():
		if key in drawn or connections[key] in drawn:
			continue
		
		var from : PackedStringArray = key.split("/")
		var to : PackedStringArray = connections[key].split("/")
		
		var from_node_data := world_manager.get_node_data(from[0], from[1], from[2])
		var to_node_data := world_manager.get_node_data(to[0], to[1], to[2])
		
		var from_room : Room = world_manager.get_room_obj(from_node_data.region, from_node_data.room_name)
		var to_room : Room = world_manager.get_room_obj(to_node_data.region, to_node_data.room_name)
		
		var point_1 := from_room.global_position
		var point_2 := to_room.global_position
		
		# Flip y coordinate because region Control scale.y == -1
		point_1.x += from_room.custom_minimum_size.x * 0.5
		point_1.y -= from_room.custom_minimum_size.y * 0.5
		
		point_2.x += to_room.custom_minimum_size.x * 0.5
		point_2.y -= to_room.custom_minimum_size.y * 0.5
		
		var color := Room.ROOM_COLOR[from_node_data.region].lerp(Room.ROOM_COLOR[to_node_data.region], 0.5)
		var line2d := new_connection_line(point_1, point_2, color)
		
		line2d.name = "%s to %s" % [from_node_data.room_name, to_node_data.room_name]
		
		drawn.append(key)
		drawn.append(connections[key])

func new_connection_line(global_from : Vector2, global_to : Vector2, line_color : Color) -> Line2D:
	var line2d := Line2D.new()
	line2d.width = LINE_WIDTH
	line2d.begin_cap_mode = LINE_CAPS
	line2d.end_cap_mode = LINE_CAPS
	line2d.z_index = Z_IDX
	line2d.modulate = line_color
	add_child(line2d)
	
	var local_from := line2d.to_local(global_from)
	var local_to := line2d.to_local(global_to)
	
	line2d.add_point(local_from)
	line2d.add_point(local_to)
	
	return line2d
