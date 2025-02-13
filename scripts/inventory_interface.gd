class_name PrimeInventoryInterface extends UITab

signal inventory_changed()

const MISSILE_EXPANIONS_MAX : int = 49
const MISSILE_VALUE : int = 5
const PB_MAX : int = 8
const MAIN_PB_VALUE : int = 4
const PB_VALUE : int = 1

const ON_COLOR := Color("aaffaa")
const OFF_COLOR := Color("ffaaaa")

@export var randovania_interface : RandovaniaInterface
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

static var inventory : PrimeInventory = null

static func _static_init() -> void:
	inventory = PrimeInventory.new()
static func get_inventory() -> PrimeInventory:
	return inventory

func _ready() -> void:
	super()
	connect_signals()
	init_item_buttons()
	
	set_inventory.call_deferred(inventory)

func connect_signals() -> void:
	# Internal
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
	
	all_button.pressed.connect(all_pressed)
	none_button.pressed.connect(none_pressed)
	
	# External
	randovania_interface.rdvgame_loaded.connect(set_inventory.bind(inventory))

func all_pressed() -> void:
	inventory.all()
	set_inventory(inventory)

func none_pressed() -> void:
	const NONE_ITEMS : Array[String] = [
		"Power Suit",
		"Combat Visor",
		"Scan Visor",
		"Power Beam"
	]
	
	inventory.init_state(NONE_ITEMS)
	set_inventory(inventory)

func init_item_buttons() -> void:
	var item_btn_pressed := func(_btn : Button, _name : String) -> void:
		var value : int = inventory.state[_name]
		inventory.state[_name] = 0 if value > 0 else 1
		change_button_border_color(_btn, inventory.state[_name] > 0)
		inventory_changed.emit()
	
	# HACK
	# I don't like relying on node names, but it's what I could come up with at the time
	for btn in item_buttons:
		btn.pressed.connect(item_btn_pressed.bind(btn, btn.name))
	
	update_item_buttons()

func update_item_buttons() -> void:
	for btn in item_buttons:
		var item_name : String = btn.name
		change_button_border_color(btn, inventory.state[item_name] > 0)

func set_inventory(new_inventory : PrimeInventory) -> void:
	assert(new_inventory != null)
	inventory = new_inventory
	
	dragged_missile_slider(true, false)
	dragged_pb_slider(true, false)
	dragged_etank_slider(true, false)
	dragged_artifact_slider(true, false)
	
	update_missle_pb_settings()
	update_artifact_colors()
	update_item_buttons()
	
	inventory_changed.emit()

func missile_slider_changed(new_value : float) -> void:
	update_missile_count()

func dragged_missile_slider(changed : bool, _emit_signal : bool = true) -> void:
	if not changed:
		return
	
	var value := int(missile_slider.get_value())
	inventory.set_missile_expanions(value)
	update_missile_count()
	
	if _emit_signal:
		inventory_changed.emit()

func pb_slider_changed(new_value : float) -> void:
	update_pb_count()

func dragged_pb_slider(changed : bool, _emit_signal : bool = true) -> void:
	if not changed:
		return
	
	var value := int(pb_slider.get_value())
	inventory.set_power_bomb_expanions(value)
	update_pb_count()
	
	if _emit_signal:
		inventory_changed.emit()

func update_missile_count() -> void:
	var expansions : int = missile_slider.get_value()
	var launcher : int = 1 if inventory.has_launcher() else 0
	var total : int = expansions + launcher
	var game_total : int = (expansions * MISSILE_VALUE) + (launcher * MISSILE_VALUE)
	var text := "%d/%d (%d)" % [total, MISSILE_EXPANIONS_MAX + 1, game_total]
	missile_label.set_text(text)

func update_pb_count() -> void:
	var expansions : int = pb_slider.get_value()
	var main : int = 1 if inventory.has_main_pb() else 0
	var current : int = expansions + (main * MAIN_PB_VALUE)
	var text := "%d/%d" % [current, PB_MAX]
	pb_label.set_text(text)

func update_missle_pb_settings() -> void:
	set_button_color(require_launcher_button, inventory.requires_launcher)
	set_button_color(has_launcher_button, inventory.has_launcher())
	set_button_color(require_main_pb_button, inventory.requires_main_pb)
	set_button_color(has_main_pb_button, inventory.has_main_pb())

func set_button_color(button : Button, enabled : bool) -> void:
	button.self_modulate = ON_COLOR if enabled else OFF_COLOR

func require_launcher_toggled() -> void:
	inventory.requires_launcher = !inventory.requires_launcher
	update_missle_pb_settings()
	inventory_changed.emit()

func has_launcher_toggled() -> void:
	inventory.set_launcher(0 if inventory.has_launcher() else 1)
	update_missile_count()
	update_missle_pb_settings()
	inventory_changed.emit()

func require_main_pb_toggled() -> void:
	inventory.requires_main_pb = !inventory.requires_main_pb
	update_missle_pb_settings()
	inventory_changed.emit()

func has_main_pb_toggled() -> void:
	inventory.set_main_pb(0 if inventory.has_main_pb() else 1)
	update_pb_count()
	update_missle_pb_settings()
	inventory_changed.emit()

func etank_slider_changed(new_value : float) -> void:
	etank_label.set_text("%d/%d" % [int(new_value), PrimeInventory.ETANK_MAX])

func dragged_etank_slider(changed : bool, _emit_signal : bool = true) -> void:
	if not changed:
		return
	
	inventory.set_etanks(int(etank_slider.get_value()))
	etank_label.set_text("%d/%d" % [inventory.get_etanks(), PrimeInventory.ETANK_MAX])
	
	if _emit_signal:
		inventory_changed.emit()

func artifact_slider_changed(new_value : float) -> void:
	artifact_label.set_text("%d/%d" % [int(new_value), PrimeInventory.Artifact.MAX])
	update_artifact_colors()

func dragged_artifact_slider(changed : bool, _emit_signal : bool = true) -> void:
	if not changed:
		return
	
	var value := int(artifact_slider.get_value())
	for i in range(PrimeInventory.Artifact.MAX):
		inventory.set_artifact(i, i < value)
	
	update_artifact_colors()
	artifact_label.set_text("%d/%d" % [value, PrimeInventory.Artifact.MAX])
	
	if _emit_signal:
		inventory_changed.emit()

func update_artifact_colors() -> void:
	var value := int(artifact_slider.get_value())
	for i in range(PrimeInventory.Artifact.MAX):
		artifact_container.set_artifact_color(i, ArtifactContainer.ORANGE if i < value else ArtifactContainer.BLUE)

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
