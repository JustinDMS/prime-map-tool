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
@export_category("Tricks")
@export var tricks_panel : Panel
@export var max_button : Button
@export var none_button : Button
@export var tricks_container : VBoxContainer
@export_category("Randovania")
@export var randovania_panel : Panel
@export var import_rdvgame_button : Button
@export var file_dialog : HTML5FileDialog
@export var import_status_label : Label
@export var misc_settings_container : VBoxContainer

var etank_buttons : Array[TextureButton] = []
var import_status_tween : Tween
var last_hovered_node : NodeMarker

func _ready() -> void:
	match OS.get_name():
		"Web":
			import_rdvgame_button.pressed.connect(file_dialog.show)
			file_dialog.file_selected.connect(web_file_uploaded)
		"Windows":
			import_rdvgame_button.pressed.connect(
				func():
					var native_file_dialog := FileDialog.new()
					native_file_dialog.title = "Import .rdvgame"
					native_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
					native_file_dialog.filters = ["*.rdvgame"]
					native_file_dialog.use_native_dialog = true
					native_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
					
					add_child(native_file_dialog)
					native_file_dialog.file_selected.connect(file_uploaded)
					native_file_dialog.close_requested.connect(native_file_dialog.queue_free)
					
					native_file_dialog.show()
			)
	
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

func web_file_uploaded(file : HTML5FileHandle) -> void:
	var text : String = await file.as_text()
	rdv_imported(text)

func file_uploaded(path : String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	rdv_imported(file.get_as_text())

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
