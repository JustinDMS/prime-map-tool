class_name World extends Control

signal map_drawn(elevator_data : Dictionary)
signal map_resolved(reached_nodes : Array[NodeData])
signal inventory_initialized(inv : PrimeInventory)
signal rdv_load_success(rdvgame : RDVGame)
signal rdv_load_failed(error_message : String)

enum Region {
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

const ROOM_DATA : Array[String] = [
	"res://data/Chozo Ruins.json",
	"res://data/Phendrana Drifts.json",
	"res://data/Tallon Overworld.json",
	"res://data/Phazon Mines.json",
	"res://data/Magmoor Caverns.json",
]
const REGION_OFFSET : Array[Vector2] = [
	Vector2(2250, -300),
	Vector2(500, 0),
	Vector2(2500, 700),
	Vector2(1490, 1350),
	Vector2(1000, -500),
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
@export var inventory_interface : Panel
@export var trick_interface : Panel
@export var randovania_interface : Panel

var region_data : Array[Dictionary] = []
var world_data := {
	REGION_NAME[Region.CHOZO] : {},
	REGION_NAME[Region.PHENDRANA] : {},
	REGION_NAME[Region.TALLON] : {},
	REGION_NAME[Region.MINES] : {},
	REGION_NAME[Region.MAGMOOR] : {},
}
var node_map := {}
var room_map := {}
var region_map := {}
var inventory : PrimeInventory = null
var start_node : NodeData = null
var rdv_game : RDVGame = null

func _ready() -> void:
	inventory_initialized.connect(inventory_interface.set_inventory)
	inventory_initialized.connect(trick_interface.set_inventory)
	inventory_interface.inventory_changed.connect(resolve_map)
	trick_interface.tricks_changed.connect(resolve_map)
	rdv_load_failed.connect(randovania_interface.rdvgame_load_failed)
	rdv_load_success.connect(randovania_interface.rdvgame_load_success)
	randovania_interface.rdvgame_loaded.connect(load_rdv)
	
	draw_map()
	
	init_current_inventory()
	inventory_initialized.emit(inventory)

func draw_map() -> void:
	for i in range(Region.MAX):
		region_data.append(get_region_data(i))
		
		var region := Control.new()
		region_map[REGION_NAME[i]] = region
		add_child(region)
		region.set_name(region_data[i]["name"])
		region.scale.y = -1
		
		if i == Region.MINES:
			for n in range(MINES_MAX):
				var sub_region := Control.new()
				region.add_child(sub_region)
				sub_region.name = "Mines Level %d" % n
		elif i == Region.PHENDRANA:
			for n in range(PHEN_MAX):
				var sub_region := Control.new()
				region.add_child(sub_region)
				sub_region.name = "Phendrana Level %d" % n
		
		for j in region_data[i]["areas"].keys():
			var room_data := make_room_data(i, j, region_data[i]["areas"][j])
			world_data[REGION_NAME[i]][j] = room_data
			room_data.default_node = get_node_data(REGION_NAME[i], j, region_data[i]["areas"][j]["default_node"])
			
			var room := draw_room(room_data)
			room.started_hover.connect(ui.room_hover)
			room.stopped_hover.connect(ui.room_stop_hover)
			
			room_map[room_data] = room
			
			if i == Region.MINES:
				var sub_region := determine_mines_region(room_data.aabb[2])
				var sub_region_node : Control = region.get_child(sub_region)
				sub_region_node.add_child(room)
				sub_region_node.position = MINES_OFFSET[sub_region]
			elif i == Region.PHENDRANA:
				var sub_region := determine_phendrana_region(room_data.name)
				var sub_region_node : Control = region.get_child(sub_region)
				sub_region_node.add_child(room)
				sub_region_node.position = PHENDRANA_OFFSET[sub_region]
			else:
				region.add_child(room)
			
			for n in room_data.nodes:
				if n.coordinates == Vector3.ZERO:
					continue
				var node_marker := draw_node(n)
				node_marker.started_hover.connect(ui.node_hover)
				node_marker.stopped_hover.connect(ui.node_stop_hover)
				if i == Region.MINES:
					var sub_region := determine_mines_region(room_data.aabb[2])
					var sub_region_node : Control = region.get_child(sub_region)
					sub_region_node.add_child(node_marker)
				elif i == Region.PHENDRANA:
					var sub_region := determine_phendrana_region(room_data.name)
					var sub_region_node : Control = region.get_child(sub_region)
					sub_region_node.add_child(node_marker)
				else:
					region.add_child(node_marker)
				room.node_markers.append(node_marker)
				node_map[n] = node_marker
			
			room.set_name(j) # Set name in SceneTree
		
		region.position = REGION_OFFSET[i]
	
	# Now that every room and its nodes have been
	# created, finish initializing node connections
	for i in range(Region.MAX):
		for j in region_data[i]["areas"].keys():
			for k in region_data[i]["areas"][j]["nodes"].keys():
				var node_data := get_node_data(REGION_NAME[i], j, k)
				var connections : Array[NodeData] = []
				for l in region_data[i]["areas"][j]["nodes"][k]["connections"]:
					var new_connection := get_node_data(REGION_NAME[i], j, l)
					connections.append(new_connection)
				node_data.connections.assign(connections)
				
				var default_connection_data = region_data[i]["areas"][j]["nodes"][k].get("default_connection", null)
				if default_connection_data and default_connection_data["region"] in REGION_NAME:
					var default_connection := get_node_data(
						default_connection_data["region"],
						default_connection_data["area"],
						default_connection_data["node"]
					)
					node_data.default_connection = default_connection
	
	map_drawn.emit()

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

func get_region_data(region : Region) -> Dictionary:
	var raw_json : JSON = load(ROOM_DATA[region])
	return raw_json.data

func make_room_data(region : Region, room_name : String, data : Dictionary) -> RoomData:
	var room_data := RoomData.new()
	room_data.texture = get_room_texture(REGION_NAME[region], room_name)
	room_data.region = region
	room_data.name = room_name
	room_data.aabb = [
		data["extra"]["aabb"][0],
		data["extra"]["aabb"][1],
		data["extra"]["aabb"][2],
		data["extra"]["aabb"][3],
		data["extra"]["aabb"][4],
		data["extra"]["aabb"][5]
	]
	
	make_node_data(room_data, data["nodes"])
	
	return room_data

func make_node_data(room_data : RoomData, data : Dictionary) -> void:
	var nodes : Array[NodeData] = []
	
	for node in data.keys():
		var node_data := NodeData.new()
		node_data.region = room_data.region
		node_data.room_name = room_data.name
		node_data.display_name = node
		node_data.node_type = data[node]["node_type"]
		node_data.heal = true if (node_data.node_type == "generic" and data[node]["heal"]) else false
		
		if node_data.node_type == "dock":
			node_data.dock_type = data[node]["dock_type"]
			node_data.default_dock_weakness = data[node]["default_dock_weakness"]
		elif node_data.node_type == "event":
			node_data.event_id = region_data[node_data.region]["areas"][node_data.room_name]["nodes"][node_data.display_name]["event_name"]
		
		if data[node]["extra"].has("world_position"):
			node_data.coordinates = Vector3(
				data[node]["extra"]["world_position"][0],
				data[node]["extra"]["world_position"][1],
				data[node]["extra"]["world_position"][2]
			)
			
			if data[node]["extra"].has("world_rotation"):
				node_data.rotation = Vector3(
				data[node]["extra"]["world_rotation"][0],
				data[node]["extra"]["world_rotation"][1],
				data[node]["extra"]["world_rotation"][2]
			)
		
		nodes.append(node_data)
	
	for i in range(len(nodes)):
		for j in range(len(nodes)):
			if nodes[i] == nodes[j]:
				continue
			nodes[i].connections.append(nodes[j])
	
	room_data.nodes = nodes

func get_room_data(region_name : String, room_name : String) -> RoomData:
	return world_data[region_name][room_name]

func get_node_data(region_name : String, room_name : String, node_name : String) -> NodeData:
	var room_data := get_room_data(region_name, room_name)
	for i in room_data.nodes:
		if i.display_name == node_name:
			return i
	
	return null

func draw_room(room_data : RoomData) -> Room:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	const OUTLINE_SHADER := preload("res://resources/highlight_shader.tres")
	
	var room := BASE_ROOM.instantiate()
	room.data = room_data
	room.double_clicked.connect(set_start_node)
	room.material = OUTLINE_SHADER.duplicate()
	
	return room

func draw_node(node_data : NodeData) -> NodeMarker:
	const BASE_NODE_MARKER : PackedScene = preload("res://resources/node_marker.tscn")
	
	var node_marker := BASE_NODE_MARKER.instantiate()
	node_marker.data = node_data
	
	return node_marker

func load_rdv(data : Dictionary) -> void:
	const SUPPORTED_VERSIONS : Array[String] = [
		"8.7.1",
	]
	if not (data.has("info") and data["info"].has("randovania_version")):
		rdv_load_failed.emit("Failed to read .rdvgame\nPlease report this along with the file")
		return
	
	rdv_game = RDVGame.new()
	rdv_game.parse(data)
	
	if rdv_game._game != "prime1":
		rdv_load_failed.emit("Not a Prime .rdvgame")
		return
	if rdv_game._version not in SUPPORTED_VERSIONS:
		rdv_load_failed.emit("Randovania version %s not supported!" % rdv_game._version)
		return
	
	init_current_inventory(rdv_game._starting_pickups)
	inventory.init_tricks(rdv_game._trick_levels)
	inventory.init_misc_settings(rdv_game._config)
	
	inventory_initialized.emit(inventory)
	
	start_node = get_node_data(
		rdv_game._start_region_name, 
		rdv_game._start_room_name, 
		rdv_game._start_node_name
		)
	
	var start_room_data : RoomData = world_data[rdv_game._start_region_name][rdv_game._start_room_name]
	var _start_room : Room = room_map[start_room_data]
	
	map_drawn.emit(rdv_game._dock_connections)
	
	resolve_map()

func init_current_inventory(data : Array = []) -> void:
	inventory = PrimeInventory.new()
	
	if not data.is_empty():
		inventory.clear()
		for i in data:
			if inventory.state.has(i):
				inventory.state[i] += 1

func get_room_obj(region : Region, room_name : String) -> Room:
	var data : RoomData = world_data[REGION_NAME[region]][room_name]
	return room_map[data]

func set_all_unreachable() -> void:
	for key in room_map.keys():
		room_map[key].set_state(Room.State.UNREACHABLE)
		for node in room_map[key].node_markers:
			node.self_modulate = Room.UNREACHABLE_COLOR

func resolve_map() -> void:
	print_debug("---\nResolving map\n---")
	
	if not start_node:
		start_node = get_node_data(REGION_NAME[Region.TALLON], "Landing Site", "Ship")
	
	set_all_unreachable()
	
	inventory.set_energy_full()
	inventory.clear_events()
	
	var queue : Array[NodeData] = []
	queue.append(start_node)
	for n in start_node.connections:
		queue.append(n)
	
	var reached_nodes : Array[NodeData] = []
	var unreached_nodes := {}
	var visited_rooms := {
		REGION_NAME[Region.CHOZO] : [],
		REGION_NAME[Region.PHENDRANA] : [],
		REGION_NAME[Region.TALLON] : [],
		REGION_NAME[Region.MINES] : [],
		REGION_NAME[Region.MAGMOOR] : [],
	}
	
	reached_nodes.append(start_node)
	while len(queue) > 0:
		var node : NodeData = queue.pop_front()
		
		if not node.room_name in visited_rooms[REGION_NAME[node.region]]:
			visited_rooms[REGION_NAME[node.region]].append(node.room_name)
		
		var default_connection : NodeData = node.default_connection
		if default_connection:
			if not default_connection in reached_nodes and can_reach_external(node, default_connection):
				reached_nodes.append(default_connection)
				queue.insert(0, default_connection)
		
		for n in node.connections:
			if n in reached_nodes:
				continue
			
			var event_queue : Array = []
			
			if can_reach_internal(node, n):
				reached_nodes.append(n)
				
				if n.node_type == "event":
					inventory.set_event_status(n.event_id, true)
					
					if unreached_nodes.has(n.event_id):
						while len(unreached_nodes[n.event_id]) > 0:
							event_queue.append(unreached_nodes[n.event_id].pop_front())
						unreached_nodes.erase(n.event_id)
				
				if n.heal:
					inventory.set_energy_full()
				
				while len(event_queue) > 0:
					var tmp = event_queue.pop_front()
					var from_node : NodeData = tmp[0]
					var to_node : NodeData = tmp[1]
					
					if to_node in reached_nodes:
						continue
					
					if can_reach_internal(from_node, to_node):
						reached_nodes.append(to_node)
						queue.append(to_node)
						
						if to_node.node_type == "event":
							var marker : NodeMarker = node_map[to_node]
							marker.set_color(marker.target_color)
							
							inventory.set_event_status(to_node.event_id, true)
							if unreached_nodes.has(to_node.event_id):
								while len(unreached_nodes[to_node.event_id]) > 0:
									event_queue.append(unreached_nodes[to_node.event_id].pop_front())
								unreached_nodes.erase(to_node.event_id)
						
						if to_node.heal:
							inventory.set_energy_full()
					else:
						if not unreached_nodes.has(inventory.last_failed_event_id):
							unreached_nodes[inventory.last_failed_event_id] = []
						unreached_nodes[inventory.last_failed_event_id].append([from_node, to_node])
				
				queue.append(n)
				continue
			
			#
			# Failed to reached
			#
			if n.node_type == "event":
				var marker : NodeMarker = node_map[n]
				marker.set_color(marker.target_color)
			
			if inventory.last_failed_event_id.is_empty():
				continue
			
			if not unreached_nodes.has(inventory.last_failed_event_id):
				unreached_nodes[inventory.last_failed_event_id] = []
			unreached_nodes[inventory.last_failed_event_id].append([node, n])
	
	for i in range(Region.MAX):
		for j in visited_rooms[REGION_NAME[i]]:
			var room_obj := get_room_obj(i, j)
			room_obj.set_state(Room.State.DEFAULT)
	
	for key in node_map.keys():
		match key.node_type:
			"pickup":
				node_map[key].set_pickup_reachable(key in reached_nodes)
				node_map[key].set_color(node_map[key].target_color)
			"event":
				node_map[key].set_color(Color.SEA_GREEN if key in reached_nodes else node_map[key].target_color)
			_:
				node_map[key].set_color(node_map[key].target_color)
	
	var starter_room := get_room_obj(start_node.region, start_node.room_name)
	starter_room.set_state(Room.State.STARTER)
	
	map_resolved.emit(reached_nodes)

func can_reach_internal(from_node : NodeData, to_node : NodeData) -> bool:
	#print("Checking %s (%s) to %s (%s)" % [from_node.display_name, from_node.room_name, to_node.display_name, to_node.room_name])
	inventory.last_failed_event_id = ""
	var logic : Dictionary = region_data[from_node.region]["areas"][from_node.room_name]["nodes"][from_node.display_name]["connections"][to_node.display_name]
	return inventory.can_reach(logic)

func can_reach_external(from_node : NodeData, to_node : NodeData) -> bool:
	return inventory.can_pass_dock(from_node.default_dock_weakness) and inventory.can_pass_dock(to_node.default_dock_weakness)

func get_room_texture(region_name : String, room_name : String) -> Texture2D:
	return load("res://data/room_images/%s/%s.png" % [region_name, room_name])

func set_start_node(new_node : NodeData) -> void:
	start_node = new_node
	resolve_map()
