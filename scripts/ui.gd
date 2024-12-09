extends Control

signal rdvgame_loaded(data : Dictionary)

const REGION_DISPLAY_NAME : Array[String] = [
	"Frigate Orpheon",
	"Chozo Ruins",
	"Phendrana Drifts",
	"Tallon Overworld",
	"Phazon Mines",
	"Magmoor Caverns",
	"Impact Crater"
]

@export var region_name_label : Label
@export var room_name_label : Label
@export var import_rdv_button : Button
@export var rdv_game_hash_label : Label

func _ready() -> void:
	if import_rdv_button:
		import_rdv_button.pressed.connect(import_rdv_pressed)

func room_hover(room : Room) -> void:
	region_name_label.text = REGION_DISPLAY_NAME[room.data.region]
	room_name_label.text = room.name

func room_stop_hover(_room : Room) -> void:
	region_name_label.text = ""
	room_name_label.text = ""

func import_rdv_pressed() -> void:
	const MIN_DIALOG_SIZE := Vector2i(300, 100)
	var line_edit := LineEdit.new()
	
	var accept_dialog := AcceptDialog.new()
	accept_dialog.min_size = MIN_DIALOG_SIZE
	accept_dialog.title = "Paste contents of .rdvgame"
	accept_dialog.ok_button_text = "Import"
	accept_dialog.close_requested.connect(func(): accept_dialog.queue_free())
	accept_dialog.confirmed.connect(func(): rdv_imported(line_edit.text))
	
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
