extends TabContainer

const MIN_SIZE := Vector2(600, 0)

# Since we create the inventory dynamically,
# export dependencies here
@export var game_map : GameMap
@export var game_interface : GameInterface
@export var logic_interface : LogicInterface

var current_inventory_interface : InventoryInterface = null
var size_tween : Tween

func _ready() -> void:
	game_interface.game_selected.connect(make_inventory)
	
	for i in range( get_child_count() ):
		var ui_tab := get_child(i) as UITab
		ui_tab.size_changed.connect(change_to_size)
	
	make_inventory()
	tab_changed.connect(change_to_tab)
	set_current_tab(-1)

func make_inventory(_game_id : StringName = &"") -> void:
	if current_inventory_interface:
		current_inventory_interface.queue_free()
		await get_tree().process_frame # Wait for inventory to be freed
	
	# There might be a better place to put this
	var game := GameMap.get_game()
	current_inventory_interface = InventoryInterface.new(game.inventory_layout, Vector2(650, 500))
	current_inventory_interface.items_changed.connect(game_map.resolve_map)
	current_inventory_interface.items_changed.connect(logic_interface.display_data)
	current_inventory_interface.size_changed.connect(change_to_size)
	add_child(current_inventory_interface)
	move_child(current_inventory_interface, 1) # Make it the second tab

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
