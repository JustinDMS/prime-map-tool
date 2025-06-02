class_name UITab extends Panel

signal size_changed(_size : Vector2)

const BASE_MIN_SIZE := Vector2(500, 0)

@export var min_size : Vector2 = BASE_MIN_SIZE

func _ready() -> void:
	visibility_changed.connect(
		func() -> void: if visible: size_changed.emit(min_size)
		)

func _gui_input(event: InputEvent) -> void:
	# Capture the scroll event
	if event is InputEventMouseButton or event.is_action("press"):
		get_viewport().set_input_as_handled()
