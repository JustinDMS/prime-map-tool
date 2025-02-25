extends Control

@export var region_name_label : Label
@export var room_name_label : Label
@export var node_name_label : Label

var hovered_nodes : Array[NodeMarker] = []
var hovered_room : Room = null

func room_hover(room : Room) -> void:
	region_name_label.text = World.REGION_NAME[room.data.region]
	room_name_label.text = room.name
	
	hovered_room = room

func room_stop_hover(_room : Room) -> void:
	hovered_room = null
	
	if hovered_nodes.is_empty():
		region_name_label.text = ""
		room_name_label.text = ""
	else:
		region_name_label.text = World.REGION_NAME[hovered_nodes[-1].data.region]
		room_name_label.text = hovered_nodes[-1].data.room_name

func node_hover(marker : NodeMarker) -> void:
	hovered_nodes.append(marker)
	
	node_name_label.text = marker.data.name
	room_name_label.text = marker.data.room_name
	region_name_label.text = World.REGION_NAME[marker.data.region]

func node_stop_hover(marker : NodeMarker) -> void:
	hovered_nodes.erase(marker)
	
	if hovered_nodes.is_empty():
		node_name_label.text = ""
		if not hovered_room:
			room_name_label.text = ""
			region_name_label.text = ""
		return
	
	node_name_label.text = hovered_nodes[-1].data.name
	room_name_label.text = hovered_nodes[-1].data.room_name
	region_name_label.text = World.REGION_NAME[hovered_nodes[-1].data.region]
