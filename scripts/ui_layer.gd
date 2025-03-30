extends CanvasLayer

@onready var root : Viewport = get_tree().root

func _ready() -> void:
	root.size_changed.connect(query_size_change)

## Called whenever the size of the main viewport changes
func query_size_change() -> void:
	# Placeholder for responsive UI implementation
	pass
