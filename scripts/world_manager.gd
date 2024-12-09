extends Control

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
	Vector2(2100, -200),
	Vector2(200, 1200),
	Vector2(2500, 700),
	Vector2(1250, 1250),
	Vector2(1000, 600),
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

@export var ui : Control

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
var inventory : PrimeInventory = null

func _unhandled_input(event: InputEvent) -> void:
	# Debug use
	if event is InputEventKey and event.keycode == KEY_R and event.is_pressed() and not event.is_echo():
		_redraw_map()

func _redraw_map() -> void:
	for node in get_children():
		node.queue_free()
	draw_map()

func _ready() -> void:
	draw_map()
	ui.rdvgame_loaded.connect(load_rdv)

func draw_map() -> void:
	for i in range(Region.MAX):
		var region_data : Dictionary = get_region_data(i)
		
		var region := Control.new()
		add_child(region)
		region.set_name(region_data["name"])
		
		for j in region_data["areas"].keys():
			var room_data := make_room_data(i, j, region_data["areas"][j])
			world_data[REGION_NAME[i]][j] = room_data
			room_data.default_node = get_node_data(REGION_NAME[i], j, region_data["areas"][j]["default_node"])
			var room := draw_room(room_data)
			
			room.started_hover.connect(ui.room_hover)
			room.stopped_hover.connect(ui.room_stop_hover)
			
			room_map[room_data] = room
			
			region.add_child(room)
			room.set_name(j) # Set name in SceneTree
		
		region.position = REGION_OFFSET[i]
	
	# Now that every room and its nodes have been
	# created, finish initializing node connections
	for i in range(Region.MAX):
		var region_data : Dictionary = get_region_data(i)
		for j in region_data["areas"].keys():
			for k in region_data["areas"][j]["nodes"].keys():
				var node := get_node_data(REGION_NAME[i], j, k)
				var connections : Array[NodeData] = []
				for l in region_data["areas"][j]["nodes"][k]["connections"]:
					var new_connection := get_node_data(REGION_NAME[i], j, l)
					connections.append(new_connection)
				node.connections.assign(connections)
				
				var default_connection_data = region_data["areas"][j]["nodes"][k].get("default_connection", null)
				if default_connection_data and default_connection_data["region"] in REGION_NAME:
					var default_connection := get_node_data(
						default_connection_data["region"],
						default_connection_data["area"],
						default_connection_data["node"]
					)
					node.default_connection = default_connection

func get_region_data(region : Region) -> Dictionary:
	var raw_json : JSON = load(ROOM_DATA[region])
	return raw_json.data

func make_room_data(region : Region, room_name : String, data : Dictionary) -> RoomData:
	var room_data := RoomData.new()
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
		node_data.display_name = node
		node_data.node_type = data[node]["node_type"]
		
		if data[node]["coordinates"] != null:
			node_data.coordinates = Vector3(
				data[node]["coordinates"]["x"],
				data[node]["coordinates"]["y"],
				data[node]["coordinates"]["z"]
			)
		
		nodes.append(node_data)
	
	room_data.nodes = nodes

func get_node_data(region_name : String, room_name : String, node_name : String) -> NodeData:
	var room_data : RoomData = world_data[region_name][room_name]
	for i in room_data.nodes:
		if i.display_name == node_name:
			return i
	
	return null

func draw_room(room_data : RoomData) -> Room:
	const BASE_ROOM : PackedScene = preload("res://resources/base_room.tscn")
	
	var room := BASE_ROOM.instantiate()
	room.set_region(room_data.region)
	room.data = room_data
	
	return room

func load_rdv(data : Dictionary) -> void:
	var _version : String = data["info"]["randovania_version"]
	var game : String = data["game_modifications"][0]["game"]
	
	if game != "prime1":
		print_debug("Not a prime 1 rdvgame")
		return
	
	var start_inventory : Array = data["game_modifications"][0]["starting_equipment"]["pickups"]
	init_current_inventory(start_inventory)
	
	var start_location : PackedStringArray = data["game_modifications"][0]["starting_location"].split("/")
	var start_location_node : NodeData = get_node_data(start_location[0], start_location[1], start_location[2])
	
	var start_room_data : RoomData = world_data[start_location[0]][start_location[1]]
	var _start_room : Room = room_map[start_room_data]
	
	resolve_map(start_location_node)

func init_current_inventory(data : Array) -> void:
	inventory = PrimeInventory.new()
	
	if data.is_empty():
		return
	
	for i in data:
		if inventory.state.has(i):
			inventory.state[i] += 1

func resolve_map(start_node : NodeData) -> void:
	var region_data : Array[Dictionary] = []
	for i in range(Region.MAX):
		var data : Dictionary = get_region_data(i)
		region_data.append(data)
	
	# Need tricks in here somewhere :^)
	
	var queue : Array[NodeData] = []
	
	for node in start_node.connections:
		region_data[]
