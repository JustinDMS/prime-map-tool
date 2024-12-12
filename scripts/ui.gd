extends Control

signal rdvgame_loaded(data : Dictionary)
signal inventory_changed()

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
@export var inventory_visibility_button : Button
@export var inventory_panel : Panel
@export var inventory_container : VBoxContainer
@export var apply_changes_button : Button

func _ready() -> void:
	import_rdv_button.pressed.connect(import_rdv_pressed)
	inventory_visibility_button.pressed.connect(inventory_visibility_button_pressed)
	apply_changes_button.pressed.connect(apply_changes_button_pressed)

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

func init_inventory_display(inventory : PrimeInventory) -> void:
	for key in inventory.state.keys():
		var checkbox := CheckBox.new()
		inventory_container.add_child(checkbox)
		
		checkbox.focus_mode = Control.FOCUS_NONE
		
		checkbox.text = key
		checkbox.button_pressed = inventory.state[key] > 0
		
		checkbox.toggled.connect(func(on : bool): inventory.state[key] = 1 if on else 0)

func inventory_visibility_button_pressed() -> void:
	inventory_panel.visible = !inventory_panel.visible
	
	if inventory_panel.visible:
		inventory_visibility_button.text = ">"
	else:
		inventory_visibility_button.text = "<"

func apply_changes_button_pressed() -> void:
	inventory_changed.emit()
