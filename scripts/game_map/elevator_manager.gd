extends Control
## Displays lines between regions and subregions

const LINE_WIDTH : float = 4.0
const LINE_CAPS := Line2D.LINE_CAP_ROUND
const Z_IDX : int = -1
const SUBREGION_ALPHA := 0.5

@export var game_map : GameMap

var lines := {}
var color_map := {}

func _ready() -> void:
	game_map.map_drawn.connect(init_elevators)
	game_map.map_resolved.connect(update_lines_from_visited)

## Draws a line between every pair of nodes in dock_connections
func init_elevators(dock_connections : Dictionary[NodeMarker, NodeMarker]) -> void:
	# Clear existing data
	for node in get_children():
		node.queue_free()
	lines.clear()
	color_map.clear()
	
	# nf = node from
	for nf in dock_connections:
		var from_data := nf.data
		var from_region : Control = game_map.region_nodes[from_data.region]
		var from_point : Vector2 = from_region.position + Vector2(from_data.coordinates.x, -from_data.coordinates.y)
		
		var to_data := dock_connections[nf].data
		var to_region : Control = game_map.region_nodes[to_data.region]
		var to_point : Vector2 = to_region.position + Vector2(to_data.coordinates.x, -to_data.coordinates.y)
		
		# Add additional offset if either room is part of a subregion
		if game_map.game.has_subregions(from_data.region):
			from_point += from_region.get_child( game_map.game.get_room_subregion_index(from_data.region, from_data.room_name) ).position * Vector2(1, -1)
		if game_map.game.has_subregions(to_data.region):
			to_point += to_region.get_child( game_map.game.get_room_subregion_index(to_data.region, to_data.room_name) ).position * Vector2(1, -1)
		
		# Interpolate between region colors
		var color := game_map.game.get_region_color(from_data.region).lerp(game_map.game.get_region_color(to_data.region), 0.5)
		if from_data.region == to_data.region:
			color.a = SUBREGION_ALPHA
			
		var line2d := new_connection_line(from_point, to_point, color)
		lines[from_data] = line2d
		color_map[line2d] = color
		
		line2d.name = "%s to %s" % [from_data.room_name, to_data.room_name]

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

func update_lines_from_visited(reached_nodes : Array[NodeData]) -> void:
	for data in lines:
		lines[data].modulate = Room.UNREACHABLE_COLOR
	
	for node in reached_nodes:
		if not node is DockNodeData:
			continue
		if node in lines:
			var line : Line2D = lines[node]
			line.modulate = color_map[line]
