extends TabContainer

const MIN_SIZE := Vector2(500, 0)

# Since we create the inventory dynamically,
# export dependencies here
@export var game_map : GameMap
@export var logic_interface : LogicInterface

var size_tween : Tween

func _ready() -> void:
	# Create inventory
	# There might be a better place to put this
	var inventory_interface := InventoryInterface.new(GameMap.get_game().inventory_layout, Vector2(650, 500))
	inventory_interface.items_changed.connect(game_map.resolve_map)
	inventory_interface.items_changed.connect(logic_interface.display_data)
	add_child(inventory_interface)
	move_child(inventory_interface, 0)
	
	for i in range(get_child_count()):
		var ui_tab := get_child(i) as UITab
		ui_tab.size_changed.connect(change_to_size)
	
	tab_changed.connect(change_to_tab)
	set_current_tab(-1)

func change_to_tab(tab : int) -> void:
	if tab == -1:
		change_to_size(MIN_SIZE)

func change_to_size(_size : Vector2) -> void:
	#print("Changing to size %s" % _size)
	const CHANGE_DURATION : float = 0.3
	
	if size_tween and size_tween.is_valid():
		size_tween.kill()
	
	size_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	size_tween.tween_property(self, "custom_minimum_size", _size, CHANGE_DURATION)
