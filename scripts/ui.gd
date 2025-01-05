extends Control

signal rdvgame_loaded(data : Dictionary)
signal inventory_changed()

const THEME := preload("res://resources/theme.tres")
const INVENTORY_ICON_MAP := {
	"Morph Ball" : preload("res://data/icons/Morph Ball.png"),
	"Boost Ball" : preload("res://data/icons/Boost Ball.png"),
	"Spider Ball" : preload("res://data/icons/Spider Ball.png"),
	"Morph Ball Bomb" : preload("res://data/icons/Morph Ball Bomb.png"),
	
	"Power Bomb" : preload("res://data/icons/Power Bomb.png"),
	"Space Jump Boots" : preload("res://data/icons/Space Jump Boots.png"),
	"Missile Launcher" : preload("res://data/icons/Missile Expansion.png"),
	"Grapple Beam" : preload("res://data/icons/Grapple Beam.png"),
	
	"Power Suit" : preload("res://data/icons/Power Suit.png"),
	"Varia Suit" : preload("res://data/icons/Varia Suit.png"),
	"Gravity Suit" : preload("res://data/icons/Gravity Suit.png"),
	"Phazon Suit" : preload("res://data/icons/Phazon Suit.png"),
	
	"Charge Beam" : preload("res://data/icons/Charge Beam.png"),
	"Power Beam" : preload("res://data/icons/Power Beam.png"),
	"Wave Beam" : preload("res://data/icons/Wave Beam.png"),
	"Ice Beam" : preload("res://data/icons/Ice Beam.png"),
	"Plasma Beam" : preload("res://data/icons/Plasma Beam.png"),
	
	"Combat Visor" : preload("res://data/icons/Combat Visor.png"),
	"Scan Visor" : preload("res://data/icons/Scan Visor.png"),
	
	"Thermal Visor" : preload("res://data/icons/Thermal Visor.png"),
	"X-Ray Visor" : preload("res://data/icons/X-Ray Visor.png"),
	
	"Super Missile" : preload("res://data/icons/Super Missile.png"),
	"Wavebuster" : preload("res://data/icons/Wavebuster.png"),
	"Ice Spreader" : preload("res://data/icons/Ice Spreader.png"),
	"Flamethrower" : preload("res://data/icons/Flamethrower.png"),
	
	"Energy Tank" : preload("res://data/icons/Energy Tank.png"),
	"Missile Expansion" : preload("res://data/icons/Missile Expansion.png"),
	"Power Bomb Expansion" : preload("res://data/icons/Power Bomb Expansion.png"),
	
	"Artifact of Truth" : preload("res://data/icons/Artifact of Truth.png"),
	"Artifact of Strength" : preload("res://data/icons/Artifact of Strength.png"),
	"Artifact of Elder" : preload("res://data/icons/Artifact of Elder.png"),
	"Artifact of Wild" : preload("res://data/icons/Artifact of Wild.png"),
	"Artifact of Lifegiver" : preload("res://data/icons/Artifact of Lifegiver.png"),
	"Artifact of Warrior" : preload("res://data/icons/Artifact of Warrior.png"),
	"Artifact of Chozo" : preload("res://data/icons/Artifact of Chozo.png"),
	"Artifact of Nature" : preload("res://data/icons/Artifact of Nature.png"),
	"Artifact of Sun" : preload("res://data/icons/Artifact of Sun.png"),
	"Artifact of World" : preload("res://data/icons/Artifact of World.png"),
	"Artifact of Spirit" : preload("res://data/icons/Artifact of Spirit.png"),
	"Artifact of Newborn" : preload("res://data/icons/Artifact of Newborn.png"),
}
const TRICK_NAME_MAP : Dictionary = {
	"BJ" : "Bomb Jump",
	"BSJ" : "Bomb Space Jump",
	"BoostlessSpiner" : "Spinners without Boost",
	"CBJ" : "Complex Bomb Jump",
	"ClipThruObjects" : "Clip Through Objects",
	"Combat" : "Combat",
	"DBoosting" : "Damage Boosting",
	"Dash" : "Combat/Scan Dash",
	"HeatRun" : "Heat Run",
	"IS" : "Infinite Speed",
	"IUJ" : "Instant Unmorph Jump",
	"InvisibleObjects" : "Invisible Objects",
	"Knowledge" : "Knowledge",
	"LJump" : "L-Jump",
	"Movement" : "Movement",
	"OoB" : "Single-Room Out of Bounds",
	"RJump" : "R-Jump",
	"SJump" : "Slope Jump",
	"StandEnemies" : "Jump Off Enemies",
	"Standable" : "Standable Terrain",
	"UnderwaterMovement" : "Gravityless Underwater Movement",
	"WallBoost" : "Wall Boost"
}
const TRICK_LEVEL_NAME : Array[String] = [
	"Disabled",
	"Beginner",
	"Intermediate",
	"Advanced",
	"Expert",
	"Hypermode"
]
const RANDOVANIA_MISC_SETTINGS_MAP : Dictionary = {
	"NoGravity" : "Allow Dangerous Gravity Suit Logic",
	"main_plaza_door" : "Main Plaza Vault Door Unlocked",
	"backwards_frigate" : "Backwards Frigate",
	"backwards_labs" : "Backwards Labs",
	"backwards_upper_mines" : "Backwards Upper Mines",
	"backwards_lower_mines" : "Backwards Lower Mines",
	"phazon_elite_without_dynamo" : "Phazon Elite without Dynamo",
	"small" : "Small Samus",
	"dock_rando" : "Dock Randomizer",
	"hard_mode" : "Hard Mode",
	"room_rando" : "Entrance Randomizer",
	"remove_bars_great_tree_hall" : "Remove Bars in Great Tree Hall",
	"vanilla_heat" : "Vanilla Heat Resistance"
}

@export var region_name_label : Label
@export var room_name_label : Label
@export var node_name_label : Label
@export_category("Inventory")
@export var inventory_visibility_button : Button
@export var inventory_panel : Panel
@export var inventory_label : Label
@export var etank_container : HBoxContainer
@export var missile_count_label : Label
@export var missile_increase_button : Button
@export var missile_decrease_button : Button
@export var has_launcher_checkbox : CheckBox
@export var requires_launcher_checkbox : CheckBox
@export var pb_count_label : Label
@export var pb_increase_button : Button
@export var pb_decrease_button : Button
@export var has_main_pb_checkbox : CheckBox
@export var requires_main_pb_checkbox : CheckBox
@export var inventory_container : GridContainer
@export var artifact_container : Control
@export var give_all_button : Button
@export var clear_button : Button
@export_category("Tricks")
@export var tricks_visibility_button : Button
@export var tricks_panel : Panel
@export var max_button : Button
@export var none_button : Button
@export var tricks_container : VBoxContainer
@export_category("Randovania")
@export var randovania_panel : Panel
@export var randovania_visibility_button : Button
@export var import_rdvgame_button : Button
@export var file_dialog : HTML5FileDialog
@export var import_status_label : Label
@export var misc_settings_container : VBoxContainer

var etank_buttons : Array[TextureButton] = []
var import_status_tween : Tween
var last_hovered_node : NodeMarker

func _ready() -> void:
	randovania_visibility_button.pressed.connect(randovania_visibility_button_pressed)
	
	if OS.get_name() == 'Web':
		import_rdvgame_button.pressed.connect(file_dialog.show)
		file_dialog.file_selected.connect(file_uploaded)
	
	inventory_visibility_button.pressed.connect(inventory_visibility_button_pressed)
	
	tricks_visibility_button.pressed.connect(tricks_visibility_button_pressed)
	max_button.pressed.connect(max_pressed)
	none_button.pressed.connect(none_pressed)

func room_hover(room : Room) -> void:
	region_name_label.text = World.REGION_NAME[room.data.region]
	room_name_label.text = room.name

func room_stop_hover(_room : Room) -> void:
	region_name_label.text = ""
	room_name_label.text = ""

func node_hover(marker : NodeMarker) -> void:
	region_name_label.text = World.REGION_NAME[marker.data.region]
	room_name_label.text = marker.data.room_name
	node_name_label.text = marker.data.display_name
	
	last_hovered_node = marker

func node_stop_hover(marker : NodeMarker) -> void:
	if marker != last_hovered_node:
		return
	region_name_label.text = ""
	room_name_label.text = ""
	node_name_label.text = ""

func randovania_visibility_button_pressed() -> void:
	randovania_panel.visible = !randovania_panel.visible
	
	if randovania_panel.visible:
		randovania_visibility_button.text = "< Randovania"
	else:
		randovania_visibility_button.text = "> Randovania"

func file_uploaded(file : HTML5FileHandle) -> void:
	var text : String = await file.as_text()
	rdv_imported(text)

func init_misc_settings(inventory : PrimeInventory) -> void:
	for node in misc_settings_container.get_children():
		node.queue_free()
	
	for key in RANDOVANIA_MISC_SETTINGS_MAP.keys():
		var checkbox := CheckBox.new()
		checkbox.text = RANDOVANIA_MISC_SETTINGS_MAP[key]
		checkbox.focus_mode = Control.FOCUS_NONE
		checkbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
		checkbox.button_pressed = inventory.is_misc_setting_enabled(key)
		checkbox.toggled.connect(
			func(on : bool):
			inventory.misc_settings[key] = 1 if on else 0
			inventory_changed.emit()
		)
		misc_settings_container.add_child(checkbox)

func rdv_imported(raw_text : String) -> void:
	if raw_text.is_empty():
		show_import_status_message("Input is empty!")
		return
	
	var data = JSON.parse_string(raw_text)
	if typeof(data) != TYPE_DICTIONARY or not data.has_all(["schema_version", "info"]):
		show_import_status_message("Input is invalid!")
		return
	
	show_import_status_message("Import successful!\n%s" % data["info"]["word_hash"])
	
	rdvgame_loaded.emit(data)

func show_import_status_message(text : String) -> void:
	const DURATION : float = 0.5
	const DISPLAY_TIME : float = 2.0
	
	import_status_label.self_modulate = Color.TRANSPARENT
	
	if import_status_tween and import_status_tween.is_valid():
		import_status_tween.kill()
	
	import_status_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	import_status_tween.tween_callback(import_status_label.set_text.bind(text))
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.WHITE, DURATION)
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.TRANSPARENT, DURATION).set_delay(DISPLAY_TIME)

func init_inventory_display(inventory : PrimeInventory) -> void:
	for node in inventory_container.get_children():
		node.queue_free()
	
	for key in inventory.state.keys():
		match key:
			"Missile Launcher":
				has_launcher_checkbox.set_pressed_no_signal(inventory.state[key] > 0)
				has_launcher_checkbox.toggled.connect(
					func(on : bool):
					inventory.state[key] = 1 if on else 0
					update_missile_count(inventory)
					inventory_changed.emit()
				)
				requires_launcher_checkbox.button_pressed = inventory.requires_launcher
				requires_launcher_checkbox.toggled.connect(
					func(on : bool):
					inventory.requires_launcher = on
					inventory_changed.emit()
				)
				update_missile_count(inventory)
			"Missile Expansion":
				missile_increase_button.pressed.connect(
					func():
					inventory.state[key] += 1
					inventory.state[key] = clampi(inventory.state[key], 0, inventory.MISSILE_EXPANSION_MAX)
					update_missile_count(inventory)
					inventory_changed.emit()
				)
				missile_decrease_button.pressed.connect(
					func():
					inventory.state[key] -= 1
					inventory.state[key] = clampi(inventory.state[key], 0, inventory.MISSILE_EXPANSION_MAX)
					update_missile_count(inventory)
					inventory_changed.emit()
				)
				update_missile_count(inventory)
			"Power Bomb":
				has_main_pb_checkbox.set_pressed_no_signal(inventory.state[key] > 0)
				has_main_pb_checkbox.toggled.connect(
					func(on : bool):
					inventory.state[key] = 1 if on else 0
					update_pb_count(inventory)
					inventory_changed.emit()
				)
				requires_main_pb_checkbox.button_pressed = inventory.requires_main_pb
				requires_main_pb_checkbox.toggled.connect(
					func(on : bool):
					inventory.requires_main_pb = on
					inventory_changed.emit()
				)
				update_pb_count(inventory)
			"Power Bomb Expansion":
				pb_increase_button.pressed.connect(
					func():
					inventory.state[key] += 1
					inventory.state[key] = clampi(inventory.state[key], 0, inventory.PB_EXPANSION_MAX)
					update_pb_count(inventory)
					inventory_changed.emit()
				)
				pb_decrease_button.pressed.connect(
					func():
					inventory.state[key] -= 1
					inventory.state[key] = clampi(inventory.state[key], 0, inventory.PB_EXPANSION_MAX)
					update_pb_count(inventory)
					inventory_changed.emit()
				)
				update_pb_count(inventory)
			"Energy Tank":
				make_energy_tank_buttons(INVENTORY_ICON_MAP[key], inventory)
			"Artifact of Truth", "Artifact of Strength", "Artifact of Elder", "Artifact of Wild", "Artifact of Lifegiver", "Artifact of Warrior", "Artifact of Chozo", "Artifact of Nature", "Artifact of Sun", "Artifact of World", "Artifact of Spirit", "Artifact of Newborn":
				add_artifact_button(INVENTORY_ICON_MAP[key], key, inventory)
			_:
				make_item_checkbox(INVENTORY_ICON_MAP[key], key, inventory)
	
	if not give_all_button.pressed.is_connected(give_all_pressed):
		give_all_button.pressed.connect(give_all_pressed.bind(inventory))
	if not clear_button.pressed.is_connected(clear_pressed):
		clear_button.pressed.connect(clear_pressed.bind(inventory))

func update_missile_count(inventory : PrimeInventory) -> void:
	const MISSILES_PER_EXPANSION : int = 5
	
	var expansions : int = inventory.state["Missile Expansion"]
	var launcher : int = inventory.state["Missile Launcher"]
	var text := "%d" % ((expansions * MISSILES_PER_EXPANSION) + (launcher * MISSILES_PER_EXPANSION))
	missile_count_label.set_text(text)

func update_pb_count(inventory : PrimeInventory) -> void:
	const MAIN_PB_COUNT : int = 4
	
	var expansions : int = inventory.state["Power Bomb Expansion"]
	var main : int = inventory.state["Power Bomb"]
	var text = "%d" % ((main * MAIN_PB_COUNT) + expansions)
	pb_count_label.set_text(text)

func make_item_checkbox(texture : Texture2D, item_name : String, inventory : PrimeInventory):
	const BUTTON_SIZE := Vector2(95, 65)
	
	var checkbox := CheckBox.new()
	inventory_container.add_child(checkbox)
	checkbox.theme = THEME
	checkbox.icon = texture
	checkbox.set_icon_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	checkbox.expand_icon = true
	checkbox.focus_mode = Control.FOCUS_NONE
	checkbox.custom_minimum_size = BUTTON_SIZE
	checkbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND 
	checkbox.button_pressed = inventory.state[item_name] > 0
	checkbox.mouse_entered.connect(func(): set_inventory_text(item_name))
	checkbox.mouse_exited.connect(func(): set_inventory_text("Inventory"))
	checkbox.toggled.connect(
		func(on : bool): 
		inventory.state[item_name] = 1 if on else 0
		inventory_changed.emit()
		)

func make_energy_tank_buttons(texture : Texture2D, inventory : PrimeInventory) -> void:
	const EMPTY_TANK_TEXTURE : Texture2D = preload("res://data/icons/Empty Energy Tank.png")
	
	for node in etank_container.get_children():
		node.queue_free()
	etank_buttons.clear()
	
	for i in range(inventory.ETANK_MAX):
		var texture_button := TextureButton.new()
		texture_button.texture_normal = EMPTY_TANK_TEXTURE
		texture_button.texture_pressed = texture
		texture_button.ignore_texture_size = true
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		texture_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		texture_button.set_toggle_mode(true)
		texture_button.button_pressed = inventory.state["Energy Tank"] > i
		texture_button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		
		texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND 
		
		texture_button.mouse_entered.connect(
			func(): 
			var text : String = "Energy Tank: %d" % inventory.state["Energy Tank"]
			set_inventory_text(text)
			)
		texture_button.mouse_exited.connect(func(): set_inventory_text("Inventory"))
		texture_button.toggled.connect(
			func(_on : bool):
			if inventory.state["Energy Tank"] > i + 1:
				inventory.state["Energy Tank"] = i + 1
			elif inventory.state["Energy Tank"] < i + 1:
				inventory.state["Energy Tank"] = i + 1
			else:
				inventory.state["Energy Tank"] = i
			var text : String = "Energy Tank: %d" % inventory.state["Energy Tank"]
			set_inventory_text(text)
			update_etank_display_state(inventory)
			inventory_changed.emit()
			)
		
		etank_container.add_child(texture_button)
		etank_buttons.append(texture_button)
	
	etank_container.custom_minimum_size.y = etank_container.size.y

func update_etank_display_state(inventory : PrimeInventory) -> void:
	for i in range(inventory.ETANK_MAX):
		etank_buttons[i].set_pressed_no_signal(inventory.state["Energy Tank"] >= i + 1)

func set_artifact_color(texture_button : TextureButton, is_pressed : bool) -> void:
	const NORMAL_COLOR := Color("#4CDAF5") # Blue
	const PRESSED_COLOR := Color("#F1A34C") # Orange
	const COLOR_CHANGE_DURATION : float = 0.2
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
			texture_button, 
			"self_modulate", PRESSED_COLOR if is_pressed else NORMAL_COLOR,
			COLOR_CHANGE_DURATION
			)

func add_artifact_button(texture : Texture2D, item_name : String, inventory : PrimeInventory) -> void:
	const SCALE := 0.3
	
	var texture_button := TextureButton.new()
	texture_button.toggle_mode = true
	texture_button.texture_normal = texture
	texture_button.ignore_texture_size = true
	texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	texture_button.custom_minimum_size = texture.get_size() * SCALE
	texture_button.position -= (texture.get_size() * SCALE) * 0.5
	texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	artifact_container.add_child(texture_button)
	
	var image := texture.get_image()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1)
	texture_button.texture_click_mask = bitmap
	
	texture_button.mouse_entered.connect(func(): set_inventory_text(item_name))
	texture_button.mouse_exited.connect(func(): set_inventory_text("Inventory"))
	texture_button.toggled.connect(
		func(on : bool):
		inventory.state[item_name] = 1 if on else 0
		set_artifact_color(texture_button, on)
		inventory_changed.emit()
	)
	texture_button.set_pressed_no_signal(inventory.state[item_name] > 0)
	set_artifact_color(texture_button, texture_button.button_pressed)

func inventory_visibility_button_pressed() -> void:
	inventory_panel.visible = !inventory_panel.visible
	
	if inventory_panel.visible:
		inventory_visibility_button.text = "> Inventory"
	else:
		inventory_visibility_button.text = "< Inventory"

func set_inventory_text(new_text : String) -> void:
	inventory_label.text = new_text

func give_all_pressed(inventory : PrimeInventory) -> void:
	inventory.all()
	
	update_etank_display_state(inventory)
	has_launcher_checkbox.set_pressed_no_signal(true)
	update_missile_count(inventory)
	has_main_pb_checkbox.set_pressed_no_signal(true)
	update_pb_count(inventory)
	
	for cb in inventory_container.get_children():
		cb.set_pressed_no_signal(true)
	
	for a in artifact_container.get_children():
		a.set_pressed_no_signal(true)
		set_artifact_color(a, true)
	
	inventory_changed.emit()

func clear_pressed(inventory : PrimeInventory) -> void:
	inventory.clear()
	
	update_etank_display_state(inventory)
	has_launcher_checkbox.set_pressed_no_signal(false)
	update_missile_count(inventory)
	has_main_pb_checkbox.set_pressed_no_signal(false)
	update_pb_count(inventory)
	
	for cb in inventory_container.get_children():
		cb.set_pressed_no_signal(false)
	
	for a in artifact_container.get_children():
		a.set_pressed_no_signal(false)
		set_artifact_color(a, false)
	
	inventory_changed.emit()

func init_tricks_display(inventory : PrimeInventory) -> void:
	const MAX_TRICK_LEVEL := 5
	
	for node in tricks_container.get_children():
		node.queue_free()
	
	for key in inventory.tricks.keys():
		var label := Label.new()
		label.text = TRICK_NAME_MAP[key]
		tricks_container.add_child(label)
		
		var hbox := HBoxContainer.new()
		tricks_container.add_child(hbox)
		
		var slider := HSlider.new()
		slider.focus_mode = Control.FOCUS_NONE
		slider.rounded = true
		slider.step = 1.0
		slider.min_value = 0
		slider.max_value = MAX_TRICK_LEVEL
		slider.tick_count = MAX_TRICK_LEVEL + 1
		slider.scrollable = false
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(slider)
		
		var level_label := Label.new()
		level_label.text = TRICK_LEVEL_NAME[slider.value]
		level_label.set_h_size_flags(Control.SIZE_EXPAND + Control.SIZE_SHRINK_CENTER)
		hbox.add_child(level_label)
		
		slider.value_changed.connect(
			func(new_value : float): 
				level_label.text = TRICK_LEVEL_NAME[int(new_value)]
				inventory.tricks[key] = int(new_value)
				inventory_changed.emit()
				)
		
		level_label.text = TRICK_LEVEL_NAME[int(inventory.tricks[key])]
		slider.set_value_no_signal(inventory.tricks[key])

func tricks_visibility_button_pressed() -> void:
	tricks_panel.visible = !tricks_panel.visible
	
	if tricks_panel.visible:
		tricks_visibility_button.text = "> Tricks"
	else:
		tricks_visibility_button.text = "< Tricks"

func max_pressed() -> void:
	# HACK
	for node in tricks_container.get_children():
		if node is HBoxContainer:
			var slider := node.get_child(0) as HSlider
			slider.value = 5

func none_pressed() -> void:
	# HACK
	for node in tricks_container.get_children():
		if node is HBoxContainer:
			var slider := node.get_child(0) as HSlider
			slider.value = 0
