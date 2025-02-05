extends UITab

signal inventory_changed()

const MISSILE_EXPANIONS_MAX : int = 49
const MISSILE_VALUE : int = 5
const PB_MAX : int = 8
const MAIN_PB_VALUE : int = 4
const PB_VALUE : int = 1

const ON_COLOR := Color("aaffaa")
const OFF_COLOR := Color("ffaaaa")

@export var missile_label : Label
@export var missile_slider : HSlider
@export var pb_label : Label
@export var pb_slider : HSlider
@export var require_launcher_button : Button
@export var has_launcher_button : Button
@export var require_main_pb_button : Button
@export var has_main_pb_button : Button
@export var etank_label : Label
@export var etank_slider : HSlider
@export var artifact_label : Label
@export var artifact_slider : HSlider
@export var artifact_container : ArtifactContainer
@export var item_buttons : Array[Button]
@export var all_button : Button
@export var none_button : Button

var inventory : PrimeInventory = null

func _ready() -> void:
	super()
	
	missile_slider.value_changed.connect(missile_slider_changed)
	missile_slider.drag_ended.connect(dragged_missile_slider)
	pb_slider.value_changed.connect(pb_slider_changed)
	pb_slider.drag_ended.connect(dragged_pb_slider)
	
	require_launcher_button.pressed.connect(require_launcher_toggled)
	has_launcher_button.pressed.connect(has_launcher_toggled)
	require_main_pb_button.pressed.connect(require_main_pb_toggled)
	has_main_pb_button.pressed.connect(has_main_pb_toggled)
	
	etank_slider.value_changed.connect(etank_slider_changed)
	etank_slider.drag_ended.connect(dragged_etank_slider)
	artifact_slider.value_changed.connect(artifact_slider_changed)
	artifact_slider.drag_ended.connect(dragged_artifact_slider)
	
	all_button.pressed.connect(
		func():
		inventory.all()
		missile_slider.set_value_no_signal(MISSILE_EXPANIONS_MAX)
		pb_slider.set_value_no_signal(PB_MAX - MAIN_PB_VALUE)
		etank_slider.set_value_no_signal(PrimeInventory.ETANK_MAX)
		artifact_slider.set_value_no_signal(PrimeInventory.Artifact.MAX)
		set_inventory(inventory)
	)
	none_button.pressed.connect(
		func():
		inventory.clear()
		inventory.state["Power Suit"] = 1
		inventory.state["Combat Visor"] = 1
		inventory.state["Scan Visor"] = 1
		inventory.state["Power Beam"] = 1
		
		missile_slider.set_value_no_signal(0)
		pb_slider.set_value_no_signal(0)
		etank_slider.set_value_no_signal(0)
		artifact_slider.set_value_no_signal(0)
		set_inventory(inventory)
	)

func set_inventory(new_inventory : PrimeInventory) -> void:
	assert(new_inventory != null)
	
	await get_tree().physics_frame
	
	var flag : bool = not is_instance_valid(inventory) # Only true when inventory is first set
	inventory = new_inventory
	dragged_missile_slider(false)
	update_missile_count()
	dragged_pb_slider(false)
	update_pb_count()
	update_missle_pb_settings()
	dragged_etank_slider(false)
	dragged_artifact_slider(true)
	update_artifact_colors()
	
	if flag:
		init_item_buttons()
	update_item_buttons()

func missile_slider_changed(new_value : float) -> void:
	inventory.state["Missile Expansion"] = int(new_value)
	update_missile_count()

func dragged_missile_slider(changed : bool) -> void:
	if not changed:
		return
	
	var value := int(missile_slider.get_value())
	inventory.state["Missile Expansion"] = value
	update_missile_count()
	inventory_changed.emit()

func pb_slider_changed(new_value : float) -> void:
	inventory.state["Power Bomb Expansion"] = int(new_value)
	update_pb_count()

func dragged_pb_slider(changed : bool) -> void:
	if not changed:
		return
	
	var value := int(pb_slider.get_value())
	inventory.state["Power Bomb Expansion"] = value
	update_pb_count()
	inventory_changed.emit()

func update_missile_count() -> void:
	var expansions : int = inventory.state["Missile Expansion"]
	var launcher : int = inventory.state["Missile Launcher"]
	var total : int = expansions + launcher
	var game_total : int = (expansions * MISSILE_VALUE) + (launcher * MISSILE_VALUE)
	var text := "%d/%d (%d)" % [total, MISSILE_EXPANIONS_MAX + 1, game_total]
	missile_label.set_text(text)

func update_pb_count() -> void:
	var expansions : int = inventory.state["Power Bomb Expansion"]
	var main : int = inventory.state["Power Bomb"]
	var current : int = expansions + (main * MAIN_PB_VALUE)
	var text := "%d/%d" % [current, PB_MAX]
	pb_label.set_text(text)

func update_missle_pb_settings() -> void:
	set_button_color(require_launcher_button, inventory.requires_launcher)
	set_button_color(has_launcher_button, inventory.state["Missile Launcher"] > 0)
	set_button_color(require_main_pb_button, inventory.requires_main_pb)
	set_button_color(has_main_pb_button, inventory.state["Power Bomb"] > 0)

func set_button_color(button : Button, enabled : bool) -> void:
	button.self_modulate = ON_COLOR if enabled else OFF_COLOR

func require_launcher_toggled() -> void:
	inventory.requires_launcher = !inventory.requires_launcher
	update_missle_pb_settings()
	inventory_changed.emit()

func has_launcher_toggled() -> void:
	var has_launcher : bool = inventory.state["Missile Launcher"] > 0
	inventory.state["Missile Launcher"] = 0 if has_launcher else 1
	update_missile_count()
	update_missle_pb_settings()
	inventory_changed.emit()

func require_main_pb_toggled() -> void:
	inventory.requires_main_pb = !inventory.requires_main_pb
	update_missle_pb_settings()
	inventory_changed.emit()

func has_main_pb_toggled() -> void:
	var has_main_pb : bool = inventory.state["Power Bomb"] > 0
	inventory.state["Power Bomb"] = 0 if has_main_pb else 1
	update_pb_count()
	update_missle_pb_settings()
	inventory_changed.emit()

func etank_slider_changed(new_value : float) -> void:
	etank_label.set_text("%d/%d" % [int(new_value), PrimeInventory.ETANK_MAX])

func dragged_etank_slider(changed : bool) -> void:
	if not changed:
		return
	
	inventory.state["Energy Tank"] = int(etank_slider.get_value())
	etank_label.set_text("%d/%d" % [inventory.state["Energy Tank"], PrimeInventory.ETANK_MAX])
	inventory_changed.emit()

func artifact_slider_changed(new_value : float) -> void:
	artifact_label.set_text("%d/%d" % [int(new_value), PrimeInventory.Artifact.MAX])
	update_artifact_colors()

func dragged_artifact_slider(changed : bool) -> void:
	if not changed:
		return
	
	var value := int(artifact_slider.get_value())
	for i in range(PrimeInventory.Artifact.MAX):
		inventory.set_artifact(i, i < value)
	update_artifact_colors()
	artifact_label.set_text("%d/%d" % [value, PrimeInventory.Artifact.MAX])
	inventory_changed.emit()

func update_artifact_colors() -> void:
	var value := int(artifact_slider.get_value())
	for i in range(PrimeInventory.Artifact.MAX):
		artifact_container.set_artifact_color(i, ArtifactContainer.ORANGE if i < value else ArtifactContainer.BLUE)

func init_item_buttons() -> void:
	var item_btn_pressed := func(_btn : Button, _name : String) -> void:
		var value : int = inventory.state[_name]
		inventory.state[_name] = 0 if value > 0 else 1
		change_button_border_color(_btn, inventory.state[_name] > 0)
		inventory_changed.emit()
	
	# HACK
	# I don't relying on node names, but it's what I could come up with at the time
	for btn in item_buttons:
		btn.pressed.connect(item_btn_pressed.bind(btn, btn.name))
	update_item_buttons()

func update_item_buttons() -> void:
	for btn in item_buttons:
		var item_name : String = btn.name
		change_button_border_color(btn, inventory.state[item_name] > 0)

func change_button_border_color(button : Button, on : bool) -> void:
	var normal := button.get_theme_stylebox("normal").duplicate()
	var hover := button.get_theme_stylebox("hover").duplicate()
	var hover_pressed := button.get_theme_stylebox("hover_pressed").duplicate()
	var pressed := button.get_theme_stylebox("pressed").duplicate()
	
	normal.border_color = ON_COLOR if on else OFF_COLOR
	hover.border_color = ON_COLOR if on else OFF_COLOR
	hover_pressed.border_color = ON_COLOR if on else OFF_COLOR
	pressed.border_color = ON_COLOR if on else OFF_COLOR
	
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("hover", hover_pressed)
	button.add_theme_stylebox_override("pressed", pressed)
