class_name UITab extends Panel

signal size_changed(_size : Vector2)

const BASE_MIN_SIZE := Vector2(400, 0)

@export var min_size : Vector2 = BASE_MIN_SIZE

func _ready() -> void:
	visibility_changed.connect(
		func() -> void: if visible: size_changed.emit(min_size)
		)
