extends UITab

signal rdvgame_loaded(data : Dictionary)
signal rdvgame_config_changed()

@export var import_rdvgame_button : Button
@export var file_dialog : HTML5FileDialog
@export var import_status_label : Label
@export var clear_rdvgame_button : Button

@export_category("Post-load options")
@export var word_hash_label : Label
@export var rdv_options_container : ScrollContainer
@export var bool_options_container : VBoxContainer
@export var numerical_options_container : VBoxContainer

var import_status_tween : Tween
var starting_size := Vector2()

func _ready() -> void:
	super()
	starting_size = min_size
	
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
	
	clear_rdvgame_button.pressed.connect(
		func() -> void:
			import_rdvgame_button.set_visible(true)
			
			for node in bool_options_container.get_children():
				node.queue_free()
			for node in numerical_options_container.get_children():
				node.queue_free()
			
			rdv_options_container.set_visible(false)
			min_size = starting_size
			size_changed.emit(min_size)
	)

func _gui_input(event: InputEvent) -> void:
	# Capture the scroll event
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()

func web_file_uploaded(file : HTML5FileHandle) -> void:
	var text : String = await file.as_text()
	rdv_imported(text)

func file_uploaded(path : String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	rdv_imported(file.get_as_text())

func rdv_imported(raw_text : String) -> void:
	if raw_text.is_empty():
		show_import_status_message("Input is empty!")
		return
	
	var data = JSON.parse_string(raw_text)
	if typeof(data) != TYPE_DICTIONARY or not data.has_all(["schema_version", "info"]):
		show_import_status_message("Input is invalid!")
		return
	
	rdvgame_loaded.emit(data)

func show_import_status_message(text : String) -> void:
	const DURATION : float = 0.5
	const DISPLAY_TIME : float = 3.0
	const OFFSET_X := 15.0
	
	print_debug("Import status message:\n%s" % text)
	
	import_status_label.position.x = min_size.x + OFFSET_X
	import_status_label.self_modulate = Color.TRANSPARENT
	
	if import_status_tween and import_status_tween.is_valid():
		import_status_tween.kill()
	
	import_status_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	import_status_tween.tween_callback(import_status_label.set_text.bind(text))
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.WHITE, DURATION)
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.TRANSPARENT, DURATION).set_delay(DISPLAY_TIME)

func rdvgame_load_failed(error_message : String) -> void:
	show_import_status_message(error_message)

func rdvgame_load_success(rdvgame : RDVGame, inventory : PrimeInventory) -> void:
	import_rdvgame_button.visible = false
	word_hash_label.text = rdvgame.get_word_hash()
	
	var config := rdvgame.get_config()
	
	for node in bool_options_container.get_children():
		node.queue_free()
	for node in numerical_options_container.get_children():
		node.queue_free()
	
	rdv_options_container.set_visible(true)
	
	for key in config.keys():
		var item = config[key]
		
		if item is bool:
			const FILTER : Array[String] = [
				"first_progression_must_be_local",
				"two_sided_door_lock_search",
				"single_set_for_pickups_that_solve",
				"staggered_multi_pickup_placement",
				"check_if_beatable_after_base_patches",
				"items_every_room",
				"random_boss_sizes",
				"legacy_mode",
			]
			
			if key in FILTER:
				continue
			
			var checkbox := CheckBox.new()
			checkbox.focus_mode = Control.FOCUS_NONE
			checkbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			checkbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
			checkbox.text = key
			bool_options_container.add_child(checkbox)
			checkbox.set_pressed_no_signal(item)
			checkbox.toggled.connect(
				func(on : bool):
					inventory.rdv_config[key] = on
					rdvgame_config_changed.emit()
			)
		
		elif item is int or item is float:
			const FILTER : Array[String] = [
				"minimum_available_locations_for_hint_placement",
				"minimum_location_weight_for_hint_placement",
				"artifact_target",
				"artifact_minimum_progression",
				"superheated_probability",
				"submerged_probability",
			]
			
			if key in FILTER:
				continue
			
			var hbox := HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			hbox.add_theme_constant_override("separation", 15.0)
			numerical_options_container.add_child(hbox)
			
			var line_edit := LineEdit.new()
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line_edit.size_flags_stretch_ratio = 0.25
			line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
			line_edit.placeholder_text = key
			line_edit.text = str(item)
			hbox.add_child(line_edit)
			
			var label := Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = key
			hbox.add_child(label)
	
	min_size = Vector2(500, 1000)
	size_changed.emit(min_size)
	
	show_import_status_message("Import successful!")
