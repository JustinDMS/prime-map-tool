class_name World extends Control

signal map_drawn(elevator_data : Dictionary)
signal map_resolved(visited_nodes : Dictionary)
signal inventory_initialized(inv : PrimeInventory)

enum Region {
	FRIGATE,
	CHOZO,
	PHENDRANA,
	TALLON,
	MINES,
	MAGMOOR,
	CRATER,
	MAX
}
enum {
	MINES_1,
	MINES_2,
	MINES_3,
	MINES_MAX
}

const ROOM_DATA : Array[String] = [
	"res://data/Frigate Orpheon.json",
	"res://data/Chozo Ruins.json",
	"res://data/Phendrana Drifts.json",
	"res://data/Tallon Overworld.json",
	"res://data/Phazon Mines.json",
	"res://data/Magmoor Caverns.json",
	"res://data/Impact Crater.json"
]
const REGION_OFFSET : Array[Vector2] = [
	Vector2(0, -900),
	Vector2(2250, -300),
	Vector2(500, 0),
	Vector2(2500, 700),
	Vector2(1250, 1100),
	Vector2(1000, -500),
	Vector2(700, -900)
]
const REGION_NAME : Array[String] = [
	"Frigate Orpheon",
	"Chozo Ruins",
	"Phendrana Drifts",
	"Tallon Overworld",
	"Phazon Mines",
	"Magmoor Caverns",
	"Impact Crater"
]
const MINES_OFFSET : Array[Vector2] = [
	Vector2(500, 0),
	Vector2(0, -200),
	Vector2(250, -650)
]

@export var ui : Control

var region_data : Array[Dictionary] = []
var world_data := {
	REGION_NAME[Region.FRIGATE] : {},
	REGION_NAME[Region.CHOZO] : {},
	REGION_NAME[Region.PHENDRANA] : {},
	REGION_NAME[Region.TALLON] : {},
	REGION_NAME[Region.MINES] : {},
	REGION_NAME[Region.MAGMOOR] : {},
	REGION_NAME[Region.CRATER] : {}
}
var room_map := {}
var region_map := {}
var inventory : PrimeInventory = null
var start_node : NodeData = null

func _ready() -> void:
	ui.rdvgame_loaded.connect(load_rdv)
	ui.inventory_changed.connect(resolve_map)
	inventory_initialized.connect(ui.init_inventory_display)
	inventory_initialized.connect(ui.init_tricks_display)
	
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
		
		for j in region_data[i]["areas"].keys():
			var room_data := make_room_data(i, j, region_data[i]["areas"][j])
			world_data[REGION_NAME[i]][j] = room_data
			room_data.default_node = get_node_data(REGION_NAME[i], j, region_data[i]["areas"][j]["default_node"])
			
			var room := draw_room(room_data)
			room.started_hover.connect(ui.room_hover)
			room.stopped_hover.connect(ui.room_stop_hover)
			
			room_map[room_data] = room
			
			if not i == Region.MINES:
				region.add_child(room)
			else:
				var sub_region := determine_mines_region(room_data.aabb[2])
				var sub_region_node : Control = region.get_child(sub_region)
				sub_region_node.add_child(room)
				sub_region_node.position = MINES_OFFSET[sub_region]
			
			for n in room_data.nodes:
				if n.coordinates == Vector3.ZERO:
					continue
				var node_marker := draw_node(n)
				node_marker.room_size = Vector2(
					abs(room_data.aabb[3] - room_data.aabb[0]),
					abs(room_data.aabb[4] - room_data.aabb[1])
				)
				room.add_child(node_marker)
			
			room.set_name(j) # Set name in SceneTree
		
		region.position = REGION_OFFSET[i]
		
		if i in [Region.FRIGATE, Region.CRATER]:
			region.hide()
	
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

func get_region_data(region : Region) -> Dictionary:
	var raw_json : JSON = load(ROOM_DATA[region])
	return raw_json.data

func make_room_data(region : Region, room_name : String, data : Dictionary) -> RoomData:
	var room_data := RoomData.new()
	if not region in [Region.FRIGATE, Region.CRATER]:
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
		
		if node_data.node_type == "dock":
			node_data.dock_type = data[node]["dock_type"]
			node_data.default_dock_weakness = data[node]["default_dock_weakness"]
			
			if node_data.dock_type == "teleporter":
				node_data.coordinates = Vector3(
					room_data.aabb[0],
					room_data.aabb[1],
					room_data.aabb[2]
				)
		
		if data[node]["coordinates"] != null:
			node_data.coordinates = Vector3(
				data[node]["coordinates"]["x"],
				data[node]["coordinates"]["y"],
				data[node]["coordinates"]["z"]
			)
		
		
		nodes.append(node_data)
	
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
	
	var room := BASE_ROOM.instantiate()
	room.data = room_data
	room.double_clicked.connect(set_start_node)
	
	return room

func draw_node(node_data : NodeData) -> NodeMarker:
	const BASE_NODE_MARKER : PackedScene = preload("res://resources/node_marker.tscn")
	
	var node_marker := BASE_NODE_MARKER.instantiate()
	node_marker.data = node_data
	
	return node_marker

func load_rdv(data : Dictionary) -> void:
	var _version : String = data["info"]["randovania_version"]
	var game : String = data["game_modifications"][0]["game"]
	
	if game != "prime1":
		print_debug("Not a prime 1 rdvgame")
		return
	
	var start_inventory : Array = data["game_modifications"][0]["starting_equipment"]["pickups"]
	init_current_inventory(start_inventory)
	
	var tricks : Dictionary = data["info"]["presets"][0]["configuration"]["trick_level"]["specific_levels"]
	inventory.init_tricks(tricks)
	
	inventory_initialized.emit(inventory)
	
	var start_location : PackedStringArray = data["game_modifications"][0]["starting_location"].split("/")
	start_node = get_node_data(start_location[0], start_location[1], start_location[2])
	
	var start_room_data : RoomData = world_data[start_location[0]][start_location[1]]
	var _start_room : Room = room_map[start_room_data]
	
	map_drawn.emit(data["game_modifications"][0]["dock_connections"])
	
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

func resolve_map() -> void:
	if not start_node:
		start_node = get_node_data(REGION_NAME[Region.TALLON], "Landing Site", "Ship")
	
	set_all_unreachable()
	
	var queue : Array[NodeData] = []
	queue.append(start_node)
	for n in start_node.connections:
		queue.append(n)
	
	var visited_nodes := {}
	var visited_rooms := {
		REGION_NAME[Region.FRIGATE] : [],
		REGION_NAME[Region.CHOZO] : [],
		REGION_NAME[Region.PHENDRANA] : [],
		REGION_NAME[Region.TALLON] : [],
		REGION_NAME[Region.MINES] : [],
		REGION_NAME[Region.MAGMOOR] : [],
		REGION_NAME[Region.CRATER] : []
	}
	
	while len(queue) > 0:
		var node : NodeData = queue.pop_front()
		visited_nodes[node] = true
		if not node.room_name in visited_rooms[REGION_NAME[node.region]]:
			visited_rooms[REGION_NAME[node.region]].append(node.room_name)
		
		var default : NodeData = node.default_connection
		if default:
			if not visited_nodes.has(default) and can_reach_external(node, default):
				queue.append(default)
		
		for n in node.connections:
			if visited_nodes.has(n):
				continue
			if can_reach_internal(node, n):
				queue.append(n)
	
	for i in range(Region.MAX):
		for j in visited_rooms[REGION_NAME[i]]:
			var room_obj := get_room_obj(i, j)
			room_obj.set_state(Room.State.DEFAULT)
	
	var starter_room := get_room_obj(start_node.region, start_node.room_name)
	starter_room.set_state(Room.State.STARTER)
	
	map_resolved.emit(visited_nodes)

func can_reach_internal(from_node : NodeData, to_node : NodeData) -> bool:
	var logic : Dictionary = region_data[from_node.region]["areas"][from_node.room_name]["nodes"][from_node.display_name]["connections"][to_node.display_name]
	return inventory.can_reach(logic)

func can_reach_external(from_node : NodeData, to_node : NodeData) -> bool:
	return inventory.can_pass_dock(from_node.default_dock_weakness) and inventory.can_pass_dock(to_node.default_dock_weakness)

func get_room_texture(region_name : String, room_name : String) -> Texture2D:
	return load("res://data/room_images/%s/%s.png" % [region_name, room_name])

func set_start_node(new_node : NodeData) -> void:
	start_node = new_node
	resolve_map()
