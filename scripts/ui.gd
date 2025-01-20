extends Control

@export var region_name_label : Label
@export var room_name_label : Label
@export var node_name_label : Label

var last_hovered_node : NodeMarker

func room_hover(room : Room) -> void:
	region_name_label.text = World.REGION_NAME[room.data.region]
	room_name_label.text = room.name

func room_stop_hover(_room : Room) -> void:
	region_name_label.text = ""
	room_name_label.text = ""

func node_hover(marker : NodeMarker) -> void:
	region_name_label.text = World.REGION_NAME[marker.data.region]
	room_name_label.text = marker.data.room_name
	node_name_label.text = marker.data.display_name
	
	last_hovered_node = marker

func node_stop_hover(marker : NodeMarker) -> void:
	if marker != last_hovered_node:
		return
	region_name_label.text = ""
	room_name_label.text = ""
	node_name_label.text = ""
