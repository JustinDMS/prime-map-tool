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
const INVENTORY_ICON_MAP := {
	"Morph Ball" : preload("res://data/icons/Morph Ball.png"),
	"Boost Ball" : preload("res://data/icons/Morph Ball.png"),
	"Spider Ball" : preload("res://data/icons/Spider Ball.png"),
	"Morph Ball Bomb" : preload("res://data/icons/Morph Ball Bomb.png"),
	
	"Power Bomb" : preload("res://data/icons/Power Bomb.png"),
	"Space Jump Boots" : preload("res://data/icons/Space Jump Boots.png"),
	"Missile Launcher" : preload("res://data/icons/Missile Expansion.png"),
	"Grapple Beam" : preload("res://data/icons/Grapple Beam.png"),
	
	"Power Suit" : preload("res://data/icons/Varia Suit.png"),
	"Varia Suit" : preload("res://data/icons/Varia Suit.png"),
	"Gravity Suit" : preload("res://data/icons/Gravity Suit.png"),
	"Phazon Suit" : preload("res://data/icons/Varia Suit.png"),
	
	"Charge Beam" : preload("res://data/icons/Charge Beam.png"),
	"Power Beam" : preload("res://data/icons/Power Beam.png"),
	"Wave Beam" : preload("res://data/icons/Wave Beam.png"),
	"Ice Beam" : preload("res://data/icons/Ice Beam.png"),
	"Plasma Beam" : preload("res://data/icons/Plasma Beam.png"),
	
	"Combat Visor" : preload("res://data/icons/Thermal Visor.png"),
	"Scan Visor" : preload("res://data/icons/Thermal Visor.png"),
	
	"Thermal Visor" : preload("res://data/icons/Thermal Visor.png"),
	"X-Ray Visor" : preload("res://data/icons/Thermal Visor.png"),
	
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

@export var region_name_label : Label
@export var room_name_label : Label
@export var import_rdv_button : Button
@export var rdv_game_hash_label : Label
@export var inventory_visibility_button : Button
@export var inventory_panel : Panel
@export var inventory_label : Label
@export var inventory_container : GridContainer
@export var apply_changes_button : Button
@export var give_all_button : Button
@export var clear_button : Button

func _ready() -> void:
	import_rdv_button.pressed.connect(import_rdv_pressed)
	inventory_visibility_button.pressed.connect(inventory_visibility_button_pressed)
	apply_changes_button.pressed.connect(apply_changes_button_pressed)
	give_all_button.pressed.connect(give_all_pressed)
	clear_button.pressed.connect(clear_pressed)

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
	const BUTTON_SIZE := Vector2(95, 70)
	const THEME := preload("res://resources/theme.tres")
	
	for key in inventory.state.keys():
		var checkbox := CheckBox.new()
		inventory_container.add_child(checkbox)
		checkbox.theme = THEME
		checkbox.icon = INVENTORY_ICON_MAP[key]
		checkbox.set_icon_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		checkbox.expand_icon = true
		checkbox.focus_mode = Control.FOCUS_NONE
		checkbox.custom_minimum_size = BUTTON_SIZE
		checkbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND 
		#checkbox.text = key
		checkbox.button_pressed = inventory.state[key] > 0
		checkbox.mouse_entered.connect(func(): set_inventory_text(key))
		checkbox.mouse_exited.connect(func(): set_inventory_text("Inventory"))
		checkbox.toggled.connect(func(on : bool): inventory.state[key] = 1 if on else 0)

func inventory_visibility_button_pressed() -> void:
	inventory_panel.visible = !inventory_panel.visible
	
	if inventory_panel.visible:
		inventory_visibility_button.text = ">"
	else:
		inventory_visibility_button.text = "<"

func apply_changes_button_pressed() -> void:
	inventory_changed.emit()

func set_inventory_text(new_text : String) -> void:
	inventory_label.text = new_text

func give_all_pressed() -> void:
	for cb in inventory_container.get_children():
		cb.button_pressed = true

func clear_pressed() -> void:
	for cb in inventory_container.get_children():
		cb.button_pressed = false
