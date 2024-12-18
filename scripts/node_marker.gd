class_name NodeMarker extends TextureButton

var data : NodeData = null
var room_size := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if not data:
		return
	
	if is_hovered() and event.is_action("press") and event.is_pressed():
		node_clicked()

func _ready() -> void:
	if data:
		name = "n_%s" % data.display_name
		init_node()

func init_node() -> void:
	position.x += data.coordinates.x + (room_size.x * 0.5) - ((size.x * scale.x) * 0.5)
	position.y += data.coordinates.y + (room_size.y * 0.5) - ((size.y * scale.y) * 0.5)

func node_clicked() -> void:
	print(data.display_name)
