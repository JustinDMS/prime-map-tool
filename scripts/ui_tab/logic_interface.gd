class_name LogicInterface extends UITab

const PRIME_HEADER : Dictionary = preload("res://data/header.json").data
const FAIL_COLOR := Color.INDIAN_RED
const PASS_COLOR := Color.LIME_GREEN

@export var inventory_interface : PrimeInventoryInterface
@export var tricks_interface : TricksInterface

var tree : Tree = null
var url_map : Dictionary = {}
var displayed_node : NodeMarker = null

func _gui_input(event: InputEvent) -> void:
	# Capture the scroll event
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()

func _ready() -> void:
	super()
	inventory_interface.inventory_changed.connect(update_data)
	tricks_interface.tricks_changed.connect(update_data)

func update_data() -> void:
	if is_instance_valid(displayed_node):
		display_data(displayed_node)

func display_data(node_marker : NodeMarker) -> void:
	displayed_node = node_marker
	
	if tree:
		tree.queue_free()
		url_map.clear()
	
	tree = Tree.new()
	tree.theme = preload("res://resources/theme.tres")
	tree.set_anchors_preset(Control.PRESET_FULL_RECT)
	tree.button_clicked.connect(open_url)
	var root := tree.create_item()
	root.set_text(0, "%s (%s)" % [node_marker.data.name, node_marker.data.room_name])
	root.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	root.set_custom_color(0, Room.ROOM_COLOR[node_marker.data.region])
	root.disable_folding = true
	
	for c in node_marker.node_connections:
		var room_root := tree.create_item(root, 0)
		room_root.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD)
		
		if c._logic.type == "and" and c._logic.data.items.is_empty():
			room_root.set_text(0, c._to_marker.data.name + " (Trivial)")
			room_root.set_custom_color(0, PASS_COLOR)
			continue
		
		room_root.set_text(0, c._to_marker.data.name)
		var reached := reach(c._logic, room_root, 0)
		room_root.set_custom_color(0, PASS_COLOR if reached else FAIL_COLOR)
		if reached:
			room_root.set_collapsed_recursive(true)
	
	add_child(tree)

# ALERT
# Re-implementation of a function that already exists in PrimeInventory
func reach(_d : Dictionary, _t : TreeItem, _z : int) -> bool:
	var tree_item := tree.create_item(_t)
	tree_item.set_autowrap_mode(_z, TextServer.AUTOWRAP_WORD)
	
	match _d.type:
		"and":
			tree_item.set_text(_z, "All of")
			var flag := true
			for i in range(_d.data.items.size()):
				if not reach(_d.data.items[i], tree_item, _z):
					flag = false
			
			if flag: tree_item.set_collapsed_recursive(true)
			tree_item.set_custom_color(_z, PASS_COLOR if flag else FAIL_COLOR)
			
			if _d.data.comment is String and _d.data.comment.contains("http"):
				tree_item.add_button(_z, load("res://data/icons/yt icon/yt_icon.png"))
				url_map[tree_item] = get_url(_d.data.comment)
			
			return flag
		"or":
			tree_item.set_text(_z, "One of:")
			var flag := false
			for i in range(_d.data.items.size()):
				if reach(_d.data.items[i], tree_item, _z):
					flag = true
			
			if flag: tree_item.set_collapsed_recursive(true)
			tree_item.set_custom_color(_z, PASS_COLOR if flag else FAIL_COLOR)
			
			if _d.data.comment is String and _d.data.comment.contains("http"):
				tree_item.add_button(_z, load("res://data/icons/yt icon/yt_icon.png"))
				url_map[tree_item] = get_url(_d.data.comment)
			
			return flag
		"resource":
			var type : String = _d.data.type
			var _name : String = _d.data.name
			var amount : int = _d.data.amount
			var negate : bool = _d.data.negate
			
			var text = "NOT " if negate else ""
			match type:
				"items":
					text += PRIME_HEADER.resource_database.items[_name].long_name
				"events":
					text += "%s (Event)" % PRIME_HEADER.resource_database.events[_name].long_name
				"tricks":
					text += "%s >= %s" % [PRIME_HEADER.resource_database.tricks[_name].long_name, TricksInterface.TRICK_LEVEL_NAME[amount]]
				"damage":
					text += "%s %s" % [amount, PRIME_HEADER.resource_database.damage[_name].long_name]
				"misc":
					text += "%s (Misc)" % PRIME_HEADER.resource_database.misc[_name].long_name
			tree_item.set_text(_z, text)
			var has : bool = PrimeInventoryInterface.get_inventory().has_resource(_d.data)
			tree_item.set_custom_color(_z, PASS_COLOR if has else FAIL_COLOR)
			return has
		
		"template":
			var display_name : String = PRIME_HEADER.resource_database.requirement_template[_d.data].display_name
			tree_item.set_text(_z, "%s (Template)" % display_name)
			var has : bool = reach(PRIME_HEADER.resource_database.requirement_template[display_name].requirement, tree_item, _z)
			tree_item.set_custom_color(_z, PASS_COLOR if has else FAIL_COLOR)
			tree_item.set_collapsed_recursive(true)
			return has
	
	return true

func get_url(from_string : String) -> String:
	return from_string.rsplit(" ", false, 1)[0]

func open_url(item : TreeItem, column : int, id : int, mouse_button_index : int) -> void:
	var err := OS.shell_open(url_map[item])
	if err != OK:
		push_error("Failed to open url: %s" % url_map[item])
