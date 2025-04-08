class_name TricksInterface extends UITab

signal tricks_changed()

enum TrickLevel {
	DISABLED,
	BEGINNER,
	INTERMEDIATE,
	ADVANCED,
	EXPERT,
	LUDICROUS
}

const TRICK_VALUE_MAP : Dictionary = {
	"disabled" : TrickLevel.DISABLED,
	"beginner" : TrickLevel.BEGINNER,
	"intermediate" : TrickLevel.INTERMEDIATE,
	"advanced" : TrickLevel.ADVANCED,
	"expert" : TrickLevel.EXPERT,
	"ludicrous": TrickLevel.LUDICROUS,
	"hypermode": TrickLevel.LUDICROUS
}
const TRICK_LEVEL_NAME : Array[String] = [
	"Disabled",
	"Beginner",
	"Intermediate",
	"Advanced",
	"Expert",
	"Ludicrous"
]

@export var world_manager : World
@export var randovania_interface : RandovaniaInterface
@export var tricks_container : VBoxContainer

var slider_map := {}

func _ready() -> void:
	super()
	init_sliders()
	randovania_interface.rdvgame_loaded.connect(
		func():
			await get_tree().process_frame
			update()
	)

func init_sliders() -> void:
	var inventory := PrimeInventoryInterface.get_inventory()
	
	var all_slider := new_trick("Set All", TrickLevel.DISABLED)
	all_slider.drag_ended.connect(
		func(_changed : bool):
			var value := int(all_slider.get_value()) as TrickLevel
			for t in inventory._tricks:
				var trick : PrimeInventory.Trick = inventory.get_trick(t)
				trick.set_level_no_signal(value)
				(slider_map[trick] as HSlider).set_value(value)
				
			tricks_changed.emit()
	)
	
	for t in inventory._tricks:
		var trick : PrimeInventory.Trick = inventory.get_trick(t)
		trick.changed.connect(world_manager.resolve_map.unbind(1))
		var slider := new_trick(trick.long_name, trick.get_level())
		slider.drag_ended.connect(func(_changed : bool): trick.set_level(int(slider.get_value()) as TrickLevel))
		slider_map[trick] = slider

func update() -> void:
	var inventory := PrimeInventoryInterface.get_inventory()
	
	for t in inventory._tricks:
		var trick : PrimeInventory.Trick = inventory.get_trick(t)
		(slider_map[trick] as HSlider).set_value(trick.get_level())

## Adds a new trick to tricks_container
## Returns a reference to the HSlider
func new_trick(_name : String, _difficulty : int) -> HSlider:
	var vbox := VBoxContainer.new()
	
	var name_label := Label.new()
	name_label.text = _name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	vbox.add_child(name_label)
	
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	vbox.add_child(hbox)
	
	var difficulty_label := Label.new()
	difficulty_label.text = TRICK_LEVEL_NAME[_difficulty]
	difficulty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_label.size_flags_stretch_ratio = 0.7
	
	var slider := HSlider.new()
	slider.tick_count = TrickLevel.LUDICROUS + 1
	slider.ticks_on_borders = true
	slider.max_value = TrickLevel.LUDICROUS
	slider.value = _difficulty
	slider.rounded = true
	slider.focus_mode = Control.FOCUS_NONE
	slider.scrollable = false
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_END
	
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
	tricks_container.add_child(vbox)
	
	return slider
