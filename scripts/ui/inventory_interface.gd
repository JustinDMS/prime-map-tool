class_name InventoryInterface extends UITab

const ON_COLOR := Color("aaffaa")
const OFF_COLOR := Color("ffaaaa")

## Inner Array expected type is Array[Control]
var layout : Array[Array]

## Button for toggling items with 1 capacity
class PickupButton extends Button:
	signal item_changed()
	
	var item : Game.Item = null
	
	func _init(_game : Game, _item_name : StringName, _icon_path : StringName) -> void:
		item = _game.get_item(_item_name)
		
		init_button_border_color()
		set_button_icon( load(_icon_path) )
		self.set_focus_mode(Control.FOCUS_NONE) # Prevents outline around button on press
		self.set_name(_item_name) # Set button name in SceneTree
		
		item.changed.connect(update_border_color)
		pressed.connect(on_press)
	
	## Create new styleboxes
	func init_button_border_color() -> void:
		self.add_theme_stylebox_override("normal", self.get_theme_stylebox("normal").duplicate() )
		self.add_theme_stylebox_override("hover", self.get_theme_stylebox("hover").duplicate() )
		self.add_theme_stylebox_override("hover_pressed", self.get_theme_stylebox("hover_pressed").duplicate() )
		self.add_theme_stylebox_override("pressed", self.get_theme_stylebox("pressed").duplicate() )
		
		update_border_color()
	
	func update_border_color() -> void:
		var color := ON_COLOR if item.has() else OFF_COLOR
		self.get_theme_stylebox("normal").border_color = color
		self.get_theme_stylebox("hover").border_color = color
		self.get_theme_stylebox("hover_pressed").border_color = color
		self.get_theme_stylebox("pressed").border_color = color
	
	func on_press() -> void:
		item.set_capacity( 0 if item.has() else 1 )
		item_changed.emit()

## Container for an icon, label, and slider
## Used for items with > 1 capacity
class PickupSlider extends HBoxContainer:
	signal item_changed()
	
	var item : Game.Item = null
	var item_value : int = 1
	var _label : Label = null
	var _slider : HSlider = null
	
	func _init(
		_game : Game, _item_name : StringName, _icon_path : StringName, 
		_item_value : int = 1, _slider_ticks : int = 3, _ticks_on_borders : bool = true
		) -> void:
		item = _game.get_item(_item_name)
		item_value = _item_value
		
		self.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
		
		var texture_rect := TextureRect.new()
		texture_rect.set_texture( load(_icon_path) )
		texture_rect.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH)
		texture_rect.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		self.add_child(texture_rect)
		
		# Inner container for label and slider
		var vbox := VBoxContainer.new()
		vbox.set_alignment(BoxContainer.ALIGNMENT_CENTER)
		vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		self.add_child(vbox)
		
		_label = Label.new()
		_label.set_text( "%d/%d" % [item.get_capacity(), item.max_capacity] )
		vbox.add_child(_label)
		
		_slider = HSlider.new()
		_slider.set_ticks(_slider_ticks) # Number of vertical ticks shown on the slider
		_slider.set_ticks_on_border(_ticks_on_borders)
		_slider.set_rounded(true) # Value is rounded to nearest int
		_slider.set_min(0)
		_slider.set_max( item.max_capacity )
		_slider.set_value( item.get_capacity() )
		
		_slider.drag_ended.connect(slider_drag_ended)
		_slider.value_changed.connect(slider_value_changed)
	
	## Called after the slider grabber is released
	func slider_drag_ended(value_changed : bool) -> void:
		if not value_changed:
			return
		
		item.set_capacity( int(_slider.get_value()) )
		item_changed.emit()
	
	## Called continuously while dragging
	func slider_value_changed(value : float) -> void:
		var text : String = "%d/%d" % [item.get_capacity(), item.max_capacity]
		# Show in-game item value
		if item_value > 1:
			text += " (%d)" % [item.get_capacity() * item_value]
		
		_label.set_text(text)
