class_name RandovaniaInterface extends UITab

static var rdvgame : RDVGame = null
static func get_rdvgame() -> RDVGame:
	return rdvgame

signal settings_changed()
signal rdvgame_loaded()

signal rdvgame_cleared()

@export var game_map : GameMap
@export var import_rdvgame_button : Button
@export var file_dialog : HTML5FileDialog
@export var import_status_label : Label
@export var clear_rdvgame_button : Button

@export_category("Post-load options")
@export var word_hash_label : Label
@export var rdv_options_container : ScrollContainer
@export var bool_options_container : VBoxContainer
@export var loaded_container : VBoxContainer

var import_status_tween : Tween
var starting_size := Vector2()

func _ready() -> void:
	super()
	starting_size = min_size
	init_settings()
	
	match OS.get_name():
		"Web":
			# Setting filters for HTML5FileDialog via the variable did not work
			# I instead added the following into js_snippet in HTML5FileDialog.gd:
			# input.setAttribute('accept', '.rdvgame');
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
	
	clear_rdvgame_button.pressed.connect(clear_rdvgame)
	game_map.new_game_loaded.connect(init_settings)

func init_settings() -> void:
	for node in bool_options_container.get_children():
		node.queue_free()
	
	var game := GameMap.get_game()
	rdvgame_loaded.connect(game.rdvgame_loaded)
	
	for s in game._misc:
		var setting := game.get_misc_setting(s)
		setting.changed.connect( game_map.resolve_map.unbind(1) )
		
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.text = setting.long_name
		set_button_color(setting, button)
		
		bool_options_container.add_child(button)
		button.set_disabled(setting.is_disabled())
		
		button.pressed.connect(setting.toggle)
		setting.changed.connect(set_button_color.bind(button))
	
	rdv_options_container.set_visible(true)

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
	
	parse_rdv(data)

func parse_rdv(data : Dictionary) -> void:
	if not (data.has("info") and data["info"].has("randovania_version")):
		rdvgame_load_failed("Failed to read .rdvgame\nPlease report this along with the file :^)")
		return
	
	rdvgame = RDVGame.new(data)
	
	if rdvgame.get_game() != "prime1":
		rdvgame_load_failed("The .rdvgame must be for Prime, not %s" % rdvgame.get_game())
		return
	
	if not rdvgame.is_supported_version():
		rdvgame_load_failed("Randovania %s not supported!" % rdvgame.get_version())
		return
	
	rdvgame_load_success()

func rdvgame_load_failed(error_message : String) -> void:
	rdvgame = null
	show_import_status_message(error_message)

func rdvgame_load_success() -> void:
	import_rdvgame_button.set_visible(false)
	loaded_container.set_visible(true)
	word_hash_label.set_text(rdvgame.get_word_hash())
	show_import_status_message("Import successful!")
	rdvgame_loaded.emit()

func clear_rdvgame() -> void:
	rdvgame = null
	import_rdvgame_button.set_visible(true)
	loaded_container.set_visible(false)
	rdvgame_cleared.emit()

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

func set_button_color(setting : Game.MiscSetting, button : Button) -> void:
	button.self_modulate = InventoryInterface.ON_COLOR if setting.is_enabled() else InventoryInterface.OFF_COLOR
