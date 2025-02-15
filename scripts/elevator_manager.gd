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
const IGNORE_REGIONS : Array[String] = ["Frigate Orpheon", "Impact Crater", "End of Game"]
const LINE_WIDTH : float = 4.0
const LINE_CAPS := Line2D.LINE_CAP_ROUND
const Z_IDX : int = -1

@export var world_manager : World
@export var randovania_interface : RandovaniaInterface

var lines := {}
var color_map := {}

func _ready() -> void:
	world_manager.map_drawn.connect(init_elevators)
	world_manager.map_resolved.connect(update_lines_from_visited)
	randovania_interface.rdvgame_loaded.connect(rdvgame_loaded)
	randovania_interface.rdvgame_cleared.connect(rdvgame_cleared)

func init_elevators(dock_connections : Dictionary = VANILLA_ELEVATOR_DATA) -> void:
	const MINES_SUBREGIONS := {
		"Phazon Mines/Elevator B/Door to Elevator Access B" : "Phazon Mines/Elevator Access B/Door to Elevator B",
		"Phazon Mines/Phazon Processing Center/Door to Processing Center Access" : "Phazon Mines/Processing Center Access/Door to Phazon Processing Center",
		"Phazon Mines/Elevator Access A/Door to Elevator A" : "Phazon Mines/Elevator A/Door to Elevator Access A"
	}
	const PHEN_SUBREGIONS := {
		"Phendrana Drifts/Observatory/Door to West Tower Entrance" : "Phendrana Drifts/West Tower Entrance/Door to Observatory",
		"Phendrana Drifts/Research Lab Aether/Door to Aether Lab Entryway" : "Phendrana Drifts/Aether Lab Entryway/Door to Research Lab Aether",
	}
	
	for node in get_children():
		node.queue_free()
	lines.clear()
	color_map.clear()
	
	var connections := dock_connections.duplicate()
	connections.merge(MINES_SUBREGIONS.duplicate())
	connections.merge(PHEN_SUBREGIONS.duplicate())
	
	var drawn : Array[String] = []
	
	for key in connections:
		if key in drawn or connections[key] in drawn:
			continue
		
		var from : PackedStringArray = key.split("/")
		var to : PackedStringArray = connections[key].split("/")
		
		if from[0] in IGNORE_REGIONS or to[0] in IGNORE_REGIONS:
			continue
		
		var from_node_data := world_manager.get_node_data(from[0], from[1], from[2])
		var to_node_data := world_manager.get_node_data(to[0], to[1], to[2])
		
		var from_region : Control = world_manager.region_map[World.REGION_NAME[from_node_data.region]]
		var to_region : Control = world_manager.region_map[World.REGION_NAME[to_node_data.region]]
		
		var from_room : Room = world_manager.get_room_obj(from_node_data.region, from_node_data.room_name)
		var to_room : Room = world_manager.get_room_obj(to_node_data.region, to_node_data.room_name)
		
		var point_1 : Vector2 = from_region.position + Vector2(from_node_data.coordinates.x, -from_node_data.coordinates.y)
		var point_2 : Vector2 = to_region.position + Vector2(to_node_data.coordinates.x, -to_node_data.coordinates.y)
		
		if from_node_data.region == World.Region.MINES:
			var tmp : Vector2 = from_region.get_child(world_manager.determine_mines_region(from_room.data.aabb[2])).position
			tmp.y *= -1
			point_1 += tmp
		elif from_node_data.region == World.Region.PHENDRANA:
			var tmp : Vector2 = from_region.get_child(world_manager.determine_phendrana_region(from_room.data.name)).position
			tmp.y *= -1
			point_1 += tmp
		
		if to_node_data.region == World.Region.MINES:
			var tmp : Vector2 = to_region.get_child(world_manager.determine_mines_region(to_room.data.aabb[2])).position
			tmp.y *= -1
			point_2 += tmp
		elif to_node_data.region == World.Region.PHENDRANA:
			var tmp : Vector2 = from_region.get_child(world_manager.determine_phendrana_region(to_room.data.name)).position
			tmp.y *= -1
			point_1 += tmp
		
		var color := Room.ROOM_COLOR[from_node_data.region].lerp(Room.ROOM_COLOR[to_node_data.region], 0.5)
		var line2d := new_connection_line(
			point_1, 
			point_2, 
			color, 
			to_node_data.region == World.Region.MINES and not from_node_data.region == World.Region.MAGMOOR,
			100.0
			)
		lines[from_node_data] = line2d
		color_map[line2d] = color
		
		line2d.name = "%s to %s" % [from_node_data.room_name, to_node_data.room_name]
		
		drawn.append(key)
		drawn.append(connections[key])

func new_connection_line(global_from : Vector2, global_to : Vector2, line_color : Color, draw_midpoint : bool = false, midpoint_offset : float = 0.0) -> Line2D:
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
	
	if not draw_midpoint:
		return line2d
	
	var midpoint := Vector2(
		(local_from.x + local_to.x) / 2,
		(local_from.y + local_to.y) / 2
	)
	var direction : Vector2 = (local_to - local_from).normalized().rotated(PI/2)
	midpoint += direction * midpoint_offset
	line2d.add_point(midpoint, 1)
	
	return line2d

func update_lines_from_visited(reached_nodes : Array[NodeData]) -> void:
	for data in lines:
		lines[data].modulate = Room.UNREACHABLE_COLOR
	
	for node in reached_nodes:
		if node.is_teleporter():
			if node in lines:
				var line : Line2D = lines[node]
				line.modulate = color_map[line]

func rdvgame_loaded() -> void:
	var dock_connections := RandovaniaInterface.get_rdvgame().get_dock_connections()
	init_elevators(dock_connections)

func rdvgame_cleared() -> void:
	init_elevators()
