extends Panel

signal rdvgame_loaded(data : Dictionary)

@export var import_rdvgame_button : Button
@export var file_dialog : HTML5FileDialog
@export var import_status_label : Label

var import_status_tween : Tween

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
	
	import_status_label.self_modulate = Color.TRANSPARENT
	
	if import_status_tween and import_status_tween.is_valid():
		import_status_tween.kill()
	
	import_status_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	import_status_tween.tween_callback(import_status_label.set_text.bind(text))
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.WHITE, DURATION)
	import_status_tween.tween_property(import_status_label, "self_modulate", Color.TRANSPARENT, DURATION).set_delay(DISPLAY_TIME)

func rdvgame_load_failed(error_message : String) -> void:
	show_import_status_message(error_message)

func rdvgame_load_success(rdvgame : RDVGame) -> void:
	show_import_status_message("Import successful!\n%s" % rdvgame._word_hash)
