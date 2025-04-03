class_name World extends Control

signal map_drawn(elevator_data : Dictionary)
signal map_resolved(reached_nodes : Array[NodeData])

enum Region {
	NONE = -1,
	CHOZO,
	PHENDRANA,
	TALLON,
	MINES,
	MAGMOOR,
	MAX
}
enum {
	MINES_1,
	MINES_2,
	MINES_3,
	MINES_MAX
}
enum {
	PHEN_1,
	PHEN_2,
	PHEN_MAX
}

const REGION_OFFSET : Array[Vector2] = [
	Vector2(2250, -300),	# Chozo
	Vector2(500, 0), 		# Phendrana
	Vector2(2500, 700),		# Tallon
	Vector2(1490, 1350),	# Mines
	Vector2(1000, -500),	# Magmoor
]
const REGION_NAME : Array[String] = [
	"Chozo Ruins",
	"Phendrana Drifts",
	"Tallon Overworld",
	"Phazon Mines",
	"Magmoor Caverns",
]
const MINES_OFFSET : Array[Vector2] = [
	Vector2(230, 300),
	Vector2(0, -200),
	Vector2(180, -600)
]
const PHENDRANA_OFFSET : Array[Vector2] = [
	Vector2.ZERO,
	Vector2(100, 75)
]

@export var ui : Control
@export var inventory_interface : UITab
@export var trick_interface : UITab
@export var randovania_interface : UITab
@export var logic_interface : UITab
@export var camera : Camera2D

var rdv_logic : Array[Dictionary] = []
var region_nodes : Array[Control] = []
var world_data : Array[Dictionary] = []
var node_marker_map := {} ## NodeData : NodeMarker
var room_map := {} ## RoomData : Room
var start_node : NodeData = null

static func get_region_from_name(_name : String) -> Region:
	return REGION_NAME.find(_name) as Region

func _ready() -> void:
	inventory_interface.items_changed.connect(resolve_map)
	trick_interface.tricks_changed.connect(resolve_map)
	
	randovania_interface.settings_changed.connect(resolve_map)
	randovania_interface.rdvgame_loaded.connect(rdvgame_loaded)
	randovania_interface.rdvgame_cleared.connect(rdvgame_cleared)
	
	load_rdv_logic()
	init_map()
	init_nodes()

func load_rdv_logic() -> void:
	for i in range(Region.MAX):
		rdv_logic.append(get_region_data(i))

func get_region_data(region : Region) -> Dictionary:
	const ROOM_DATA : Array[String] = [
		"res://data/Chozo Ruins.json",
		"res://data/Phendrana Drifts.json",
		"res://data/Tallon Overworld.json",
		"res://data/Phazon Mines.json",
		"res://data/Magmoor Caverns.json"
	]
	
	var raw_json : JSON = load(ROOM_DATA[region])
	return raw_json.data

## Create region Control nodes and draw rooms
func init_map() -> void:
	for i in range(Region.MAX):
		var region := Control.new()
		var region_name := REGION_NAME[i]
		region_nodes.append(region)
		region.set_name(region_name)
		region.set_scale(Vector2(1, -1))
		add_child(region)
		region.set_position(REGION_OFFSET[i])
		
		if i == Region.PHENDRANA:
			add_subregions(region, PHEN_MAX, PHENDRANA_OFFSET)
		elif i == Region.MINES:
			add_subregions(region, MINES_MAX, MINES_OFFSET)
		
		world_data.append({})
		
		for j in rdv_logic[i]["areas"]:
			var room_data := RoomData.new()
			room_data.init(i, j, rdv_logic[i]["areas"][j])
			world_data[i][j] = room_data
			
			var room := draw_room(room_data)
			room_map[room_data] = room
			add_room_to_map(room)

func add_subregions(to_parent : Control, amount : int, offsets : Array[Vector2]) -> void:
	assert(offsets.size() == amount)
	
	for i in range(amount):
		var sub_region := Control.new()
		sub_region.name = "Level %d" % i
		to_parent.add_child(sub_region)
		sub_region.set_position(offsets[i])

func draw_room(room_data : RoomData) -> Room:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	
	var room := BASE_ROOM.instantiate()
	room.data = room_data
	room.double_clicked.connect(set_start_node)
	room.double_clicked.connect(camera.center_on_room.bind(room))
	room.started_hover.connect(ui.room_hover)
	room.stopped_hover.connect(ui.room_stop_hover)
	
	return room

func add_room_to_map(room : Room) -> void:
	var data := room.data
	var region_node := region_nodes[data.region]
	var sub_region : int = 0
	
	match data.region:
		Region.PHENDRANA:
			sub_region = determine_phendrana_region(data.name)
		Region.MINES:
			sub_region = determine_mines_region(data.aabb[2])
		_:
			region_node.add_child(room)
			return
	
	region_node.get_child(sub_region).add_child(room)

func determine_mines_region(z : float) -> int:
	const Z_LEVEL = [
		-6.6,
		-114.2,
	]
	
	if z >= Z_LEVEL[MINES_1]:
		return MINES_1
	elif z >= Z_LEVEL[MINES_2]:
		return MINES_2
	else:
		return MINES_3

func determine_phendrana_region(room_name : String) -> int:
	const UPPER_LEVEL_ROOM_NAMES : Array[String] = [
		"West Tower Entrance",
		"West Tower",
		"Control Tower",
		"East Tower",
		"Aether Lab Entryway"
	]
	
	if room_name in UPPER_LEVEL_ROOM_NAMES:
		return PHEN_2
	return PHEN_1

func init_nodes() -> void:
	# Clear existing node markers and node data
	for key in node_marker_map:
		node_marker_map[key].queue_free()
	node_marker_map.clear()
	
	var rdvgame := RandovaniaInterface.get_rdvgame()
	var dock_weaknesses : Dictionary = {} if not rdvgame else rdvgame.get_dock_weaknesses()
	var dock_connections : Dictionary = {} if not rdvgame else rdvgame.get_dock_connections()
	
	# Create new node data and add to respective room data
	for i in range(Region.MAX):
		for j in rdv_logic[i]["areas"]:
			var room_data : RoomData = world_data[i][j]
			room_data.clear_nodes()
			
			var default_node_name : String = rdv_logic[i]["areas"][j]["default_node"]
			var nodes : Array[NodeData] = []
			for k in rdv_logic[i]["areas"][j]["nodes"]:
				if k == "Pickup (Items Every Room)":
					continue
				
				var node_data := NodeData.create_data_from_type(rdv_logic[i]["areas"][j]["nodes"][k]["node_type"])
				nodes.append(node_data)
				node_data.init(k, room_data, rdv_logic[i]["areas"][j]["nodes"][k])
				
				var node_marker := draw_node_marker(node_data)
				node_marker_map[node_data] = node_marker
				add_marker_to_map(node_marker)
				
				if node_data is EventNodeData:
					node_data.event_id = rdv_logic[i]["areas"][j]["nodes"][k]["event_name"]
				
				if rdvgame:
					var format_string : String = "%s/%s/%s" % [REGION_NAME[i], j, k]
					if format_string in dock_weaknesses:
						node_data.default_dock_weakness = dock_weaknesses[format_string]["name"]
				
				if k == default_node_name:
					room_data.default_node = node_data
			room_data.nodes = nodes
	
	# Fill out node data connections
	for i in range(Region.MAX):
		for j in rdv_logic[i]["areas"]:
			for k in rdv_logic[i]["areas"][j]["nodes"]:
				var node_data := get_node_data(i, j, k)
				if not node_data:
					continue
				
				var connections : Array[NodeData] = []
				for l in rdv_logic[i]["areas"][j]["nodes"][k]["connections"]:
					var new_connection := get_node_data(i, j, l)
					connections.append(new_connection)
				node_data.connections.assign(connections)
				
				var default_connection_data = rdv_logic[i]["areas"][j]["nodes"][k].get("default_connection", null)
				if default_connection_data and default_connection_data["region"] in REGION_NAME:
					node_data.default_connection = get_node_data(
						get_region_from_name(default_connection_data["region"]),
						default_connection_data["area"],
						default_connection_data["node"]
					)
				
				add_node_connections.call_deferred(node_marker_map[node_data])
	
	if not rdvgame:
		map_drawn.emit()
		return
	
	for key in dock_connections:
		var from_split : PackedStringArray = key.split("/")
		var to_split : PackedStringArray = dock_connections[key].split("/")
		if not from_split[0] in REGION_NAME or not to_split[0] in REGION_NAME:
			continue
		var from_node := get_node_data(get_region_from_name(from_split[0]), from_split[1], from_split[2])
		var to_node := get_node_data(get_region_from_name(to_split[0]), to_split[1], to_split[2])
		from_node.default_connection = to_node
		to_node.default_connection = from_node
	
	map_drawn.emit(dock_connections)

func get_node_data(region : Region, room_name : String, node_name : String) -> NodeData:
	var room_data := get_room_data(region, room_name)
	for i in room_data.nodes:
		if i.name == node_name:
			return i
	
	return null

func get_room_data(region : Region, room_name : String) -> RoomData:
	return world_data[region][room_name]

func draw_node_marker(node_data : NodeData) -> NodeMarker:
	const BASE_NODE_MARKER : PackedScene = preload("res://resources/node_marker.tscn")
	
	var node_marker := BASE_NODE_MARKER.instantiate()
	
	if node_data is PickupNodeData:
		if node_data.is_artifact():
			node_marker.set_script(load("res://scripts/node marker/artifact_node_marker.gd"))
		else:
			node_marker.set_script(load("res://scripts/node marker/pickup_node_marker.gd"))
	elif node_data is DockNodeData and node_data.is_door():
		node_marker.set_script(load("res://scripts/node marker/door_node_marker.gd"))
	
	node_marker.data = node_data
	node_marker.started_hover.connect(ui.node_hover)
	node_marker.stopped_hover.connect(ui.node_stop_hover)
	node_marker.node_clicked.connect(logic_interface.update_data)
	
	return node_marker

func add_marker_to_map(node_marker : NodeMarker) -> void:
	var data := node_marker.data
	var room := get_room_obj(data.region, data.room_name)
	room.add_child(node_marker)
	
	var pos : Vector2 = region_nodes[data.region].global_position
	pos += Vector2(data.coordinates.x, -data.coordinates.y)
	
	match data.region:
		Region.PHENDRANA:
			pos += PHENDRANA_OFFSET[determine_phendrana_region(data.room_name)] * Vector2(1, -1)
		Region.MINES:
			pos += MINES_OFFSET[determine_mines_region(room.data.aabb[2])] * Vector2(1, -1)
	
	node_marker.global_position = pos

func get_room_obj(region : Region, room_name : String) -> Room:
	var data : RoomData = get_room_data(region, room_name)
	return room_map[data]

func add_node_connections(marker : NodeMarker) -> void:
	var room := get_room_obj(marker.data.region, marker.data.room_name)
	for c in marker.data.connections:
		var to_marker := node_marker_map[c] as NodeMarker
		var node_connection := NodeConnection.new(
			marker,
			to_marker,
			rdv_logic[marker.data.region]["areas"][marker.data.room_name]["nodes"][marker.data.name]["connections"][c.name]
			)
		room.add_child(node_connection)
		marker.node_connections.append(node_connection)

func resolve_map() -> void:
	print("---Resolving map---")
	#print_stack()
	
	if not start_node:
		start_node = get_node_data(Region.TALLON, "Landing Site", "Ship")
	
	set_all_unreachable()
	
	var inventory := PrimeInventoryInterface.get_inventory()
	inventory.clear_events()
	
	var queue : Array[NodeData] = []
	var reached_nodes : Array[NodeData] = []
	var unreached_nodes := {}
	
	var visited_rooms : Array[Array] = []
	for i in range(Region.MAX):
		visited_rooms.append([])
	
	queue.append(start_node)
	reached_nodes.append(start_node)
	
	while len(queue) > 0:
		var node : NodeData = queue.pop_front()
		
		if not node.room_name in visited_rooms[node.region]:
			visited_rooms[node.region].append(node.room_name)
		
		var default_connection : NodeData = null if not node is DockNodeData else node.default_connection
		if (
			is_instance_valid(default_connection) and
			not default_connection in reached_nodes and
			can_reach_external(inventory, node, default_connection)
		):
			reached_nodes.append(default_connection)
			queue.append(default_connection)
		
		for n in node.connections:
			if n in reached_nodes:
				continue
			
			if can_reach_internal(inventory, node, n):
				reached_nodes.append(n)
				
				if n is EventNodeData:
					inventory.set_event(n.event_id, true)
					
					if unreached_nodes.has(n.event_id):
						queue.append_array(unreached_nodes[n.event_id])
						unreached_nodes.erase(n.event_id)
				
				queue.append(n)
				continue
			
			# Failed to reached
			if not inventory.last_failed_event_id.is_empty():
				if not unreached_nodes.has(inventory.last_failed_event_id):
					unreached_nodes[inventory.last_failed_event_id] = []
				unreached_nodes[inventory.last_failed_event_id].append(node)
	
	for i in range(Region.MAX):
		for j in visited_rooms[i]:
			var room_obj := get_room_obj(i, j)
			room_obj.set_state(Room.State.DEFAULT)
	
	for key in node_marker_map:
		var reached : bool = key in reached_nodes
		var marker : NodeMarker = node_marker_map[key]
		if marker is PickupNodeMarker or marker is ArtifactNodeMarker:
			marker.set_reachable(reached)
		marker.set_state(NodeMarker.State.DEFAULT if reached else NodeMarker.State.UNREACHABLE)
		for c in marker.node_connections:
			match c._to_marker.state:
				NodeMarker.State.DEFAULT:
					c.modulate = Color.GREEN
				NodeMarker.State.UNREACHABLE:
					c.modulate = Color.RED
	
	var starter_room := get_room_obj(start_node.region, start_node.room_name)
	starter_room.set_state(Room.State.STARTER)
	
	map_resolved.emit(reached_nodes)

func set_all_unreachable() -> void:
	for key in room_map:
		room_map[key].set_state(Room.State.UNREACHABLE)
		for node in room_map[key].node_markers:
			node.self_modulate = Room.UNREACHABLE_COLOR

func can_reach_external(inventory : PrimeInventory, from_node : DockNodeData, to_node : DockNodeData) -> bool:
	return (
		inventory.can_pass_dock(from_node.type, from_node.default_dock_weakness) and 
		inventory.can_pass_lock(from_node.type, from_node.default_dock_weakness)
		) and (
			inventory.can_pass_dock(from_node.type, from_node.default_dock_weakness) and 
			inventory.can_pass_lock(to_node.type, to_node.default_dock_weakness)
			)

func can_reach_internal(inventory : PrimeInventory, from_node : NodeData, to_node : NodeData) -> bool:
	#print("Checking %s (%s) to %s (%s)" % [from_node.display_name, from_node.room_name, to_node.display_name, to_node.room_name])
	inventory.last_failed_event_id = ""
	var logic : Dictionary = rdv_logic[from_node.region]["areas"][from_node.room_name]["nodes"][from_node.name]["connections"][to_node.name]
	return inventory.can_reach(logic)

func rdvgame_loaded() -> void:
	init_nodes()
	
	var rdvgame := RandovaniaInterface.get_rdvgame()
	var r := get_region_from_name(rdvgame.get_start_region_name())
	set_start_node(get_node_data(
		r, 
		rdvgame.get_start_room_name(), 
		rdvgame.get_start_node_name()
		))

func set_start_node(new_node : NodeData) -> void:
	start_node = new_node
	camera.center_on_room(start_node, get_room_obj(start_node.region, start_node.room_name))
	resolve_map()

func rdvgame_cleared() -> void:
	start_node = null
	
	var inventory := PrimeInventoryInterface.get_inventory()
	inventory.all()
	
	init_nodes()
	resolve_map()
	
	camera.center_on_room(start_node, get_room_obj(start_node.region, start_node.room_name))
