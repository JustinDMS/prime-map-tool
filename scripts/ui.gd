extends Control

signal rdvgame_loaded(data : Dictionary)
signal inventory_changed()

const THEME := preload("res://resources/theme.tres")
const REGION_DISPLAY_NAME : Array[String] = [
	"Frigate Orpheon",
	"Chozo Ruins",
	"Phendrana Drifts",
	"Tallon Overworld",
	"Phazon Mines",
	"Magmoor Caverns",
	"Impact Crater"
]
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

@export var region_name_label : Label
@export var room_name_label : Label
@export var import_rdv_button : Button
@export var rdv_game_hash_label : Label
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

var etank_buttons : Array[TextureButton] = []

@onready var display_panels : Array[Panel] = [inventory_panel, tricks_panel]

func _ready() -> void:
	import_rdv_button.pressed.connect(import_rdv_pressed)
	
	inventory_visibility_button.pressed.connect(inventory_visibility_button_pressed)
	give_all_button.pressed.connect(give_all_pressed)
	clear_button.pressed.connect(clear_pressed)
	
	tricks_visibility_button.pressed.connect(tricks_visibility_button_pressed)
	max_button.pressed.connect(max_pressed)
	none_button.pressed.connect(none_pressed)

func room_hover(room : Room) -> void:
	region_name_label.text = REGION_DISPLAY_NAME[room.data.region]
	room_name_label.text = room.name

func room_stop_hover(_room : Room) -> void:
	region_name_label.text = ""
	room_name_label.text = ""

func import_rdv_pressed() -> void:
	const MIN_DIALOG_SIZE := Vector2i(400, 100)
	var line_edit := LineEdit.new()
	line_edit.theme = THEME
	line_edit.shortcut_keys_enabled = true
	
	var accept_dialog := AcceptDialog.new()
	accept_dialog.min_size = MIN_DIALOG_SIZE
	accept_dialog.title = "Paste contents of .rdvgame"
	accept_dialog.ok_button_text = "Import"
	accept_dialog.get_ok_button().focus_mode = Control.FOCUS_NONE
	accept_dialog.close_requested.connect(func(): accept_dialog.queue_free())
	accept_dialog.confirmed.connect(
		func(): 
		rdv_imported(line_edit.text)
		accept_dialog.queue_free()
		)
	
	accept_dialog.add_child(line_edit)
	accept_dialog.register_text_enter(line_edit)
	
	add_child(accept_dialog)
	accept_dialog.popup_centered()

func rdv_imported(raw_text : String) -> void:
	var data = JSON.parse_string(raw_text)
	if typeof(data) != TYPE_DICTIONARY:
		return
	rdv_game_hash_label.set_text(data.info.word_hash)
	rdvgame_loaded.emit(data)

func init_inventory_display(inventory : PrimeInventory) -> void:
	for node in inventory_container.get_children():
		node.queue_free()
	
	for key in inventory.state.keys():
		var item_count : int = inventory.state[key]
		match key:
			"Missile Launcher":
				has_launcher_checkbox.button_pressed = inventory.state[key] > 0
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
				const MAX_EXPANSIONS : int = 49
				missile_increase_button.pressed.connect(
					func():
					inventory.state[key] += 1
					inventory.state[key] = clampi(inventory.state[key], 0, MAX_EXPANSIONS)
					update_missile_count(inventory)
					inventory_changed.emit()
				)
				missile_decrease_button.pressed.connect(
					func():
					inventory.state[key] -= 1
					inventory.state[key] = clampi(inventory.state[key], 0, MAX_EXPANSIONS)
					update_missile_count(inventory)
					inventory_changed.emit()
				)
				update_missile_count(inventory)
			"Power Bomb":
				has_main_pb_checkbox.button_pressed = inventory.state[key] > 0
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
				const MAX_EXPANSIONS : int = 4
				pb_increase_button.pressed.connect(
					func():
					inventory.state[key] += 1
					inventory.state[key] = clampi(inventory.state[key], 0, MAX_EXPANSIONS)
					update_pb_count(inventory)
					inventory_changed.emit()
				)
				pb_decrease_button.pressed.connect(
					func():
					inventory.state[key] -= 1
					inventory.state[key] = clampi(inventory.state[key], 0, MAX_EXPANSIONS)
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
	const MAX_TANKS : int = 14
	const SCALE : float = 0.095
	const EMPTY_TANK_TEXTURE : Texture2D = preload("res://data/icons/Empty Energy Tank.png")
	
	for i in range(MAX_TANKS):
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
			func(on : bool):
			if inventory.state["Energy Tank"] > i + 1:
				inventory.state["Energy Tank"] = i + 1
			elif inventory.state["Energy Tank"] < i + 1:
				inventory.state["Energy Tank"] = i + 1
			else:
				inventory.state["Energy Tank"] = i
			var text : String = "Energy Tank: %d" % inventory.state["Energy Tank"]
			set_inventory_text(text)
			update_etank_display_state(inventory, MAX_TANKS)
			inventory_changed.emit()
			)
		
		etank_container.add_child(texture_button)
		etank_buttons.append(texture_button)
	
	etank_container.custom_minimum_size.y = etank_container.size.y

func update_etank_display_state(inventory : PrimeInventory, max_count : int) -> void:
	for i in range(max_count):
		etank_buttons[i].set_pressed_no_signal(inventory.state["Energy Tank"] >= i + 1)

func add_artifact_button(texture : Texture2D, item_name : String, inventory : PrimeInventory) -> void:
	const NORMAL_COLOR := Color("#4CDAF5")
	const PRESSED_COLOR := Color("#F1A34C")
	const SCALE := 0.3
	const COLOR_CHANGE_DURATION : float = 0.2
	
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
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(
			texture_button, 
			"self_modulate", PRESSED_COLOR if on else NORMAL_COLOR,
			COLOR_CHANGE_DURATION
			)
		inventory_changed.emit()
	)
	texture_button.button_pressed = inventory.state[item_name] > 0

func inventory_visibility_button_pressed() -> void:
	inventory_panel.visible = !inventory_panel.visible
	
	if inventory_panel.visible:
		inventory_visibility_button.text = "> Inventory"
	else:
		inventory_visibility_button.text = "< Inventory"

func set_inventory_text(new_text : String) -> void:
	inventory_label.text = new_text

func give_all_pressed() -> void:
	for cb in inventory_container.get_children():
		cb.button_pressed = true

func clear_pressed() -> void:
	for cb in inventory_container.get_children():
		cb.button_pressed = false

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
		
		slider.value = inventory.tricks[key]

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
