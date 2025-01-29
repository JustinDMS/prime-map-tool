extends Panel

signal tricks_changed()

const TRICK_NAME_MAP : Dictionary = {
	"all" : "Set All Tricks",
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

@export var tricks_container : VBoxContainer

var inventory : PrimeInventory = null
var trick_slider_map : Dictionary = {}

func _gui_input(event: InputEvent) -> void:
	# Capture the scroll event
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()

func set_inventory(new_inventory : PrimeInventory) -> void:
	inventory = new_inventory
	
	trick_slider_map.clear()
	for node in tricks_container.get_children():
		node.queue_free()
	
	var all_container := new_trick("all", PrimeInventory.TrickLevel.HYPERMODE)
	tricks_container.add_child(all_container)
	var all_slider : HSlider = trick_slider_map["all"]
	all_slider.drag_ended.connect(
		func(changed : bool) -> void:
			if not changed:
				return
			
			var new_value := int(all_slider.get_value())
			for key in inventory.tricks.keys():
				inventory.tricks[key] = new_value
				trick_slider_map[key].value = new_value
			
			tricks_changed.emit()
	)
	
	for key in inventory.tricks.keys():
		var container := new_trick(key, inventory.tricks[key])
		tricks_container.add_child(container)
		
		var slider : HSlider = trick_slider_map[key]
		slider.drag_ended.connect(
			func(changed : bool) -> void:
				if not changed:
					return
				
				inventory.tricks[key] = int(slider.get_value())
				tricks_changed.emit()
		)

func new_trick(_name : String, _difficulty : int) -> Control:
	var vbox := VBoxContainer.new()
	
	var name_label := Label.new()
	name_label.text = TRICK_NAME_MAP[_name]
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	vbox.add_child(name_label)
	
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	vbox.add_child(hbox)
	
	var difficulty_label := Label.new()
	difficulty_label.text = TRICK_LEVEL_NAME[PrimeInventory.TrickLevel.HYPERMODE]
	difficulty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_label.size_flags_stretch_ratio = 0.7
	
	var slider := HSlider.new()
	slider.tick_count = PrimeInventory.TrickLevel.HYPERMODE
	slider.ticks_on_borders = true
	slider.max_value = PrimeInventory.TrickLevel.HYPERMODE
	slider.value = PrimeInventory.TrickLevel.HYPERMODE
	slider.rounded = true
	slider.focus_mode = Control.FOCUS_NONE
	slider.scrollable = false
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_END
	
	trick_slider_map[_name] = slider
	
	slider.value_changed.connect(
		func(new_value : float) -> void:
			difficulty_label.text = TRICK_LEVEL_NAME[int(new_value)]
	)
	
	hbox.add_child(difficulty_label)
	hbox.add_child(slider)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.size_flags_stretch_ratio = 0.1
	
	hbox.add_child(spacer)
	
	var separator := HSeparator.new()
	separator.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	vbox.add_child(separator)
	
	return vbox
