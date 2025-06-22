class_name RoomData extends Resource

var game : Game = null
var region : StringName
var name : String
var extra : Dictionary
var texture : Texture2D

# Set by [GameMap]
var nodes : Array[NodeData]
var default_node : NodeData

func _init(_game : Game, _region : StringName, _name : String, _data : Dictionary) -> void:
	game = _game
	region = _region
	name = _name
	
	# Texture must be set by game
	game.init_room_data(self, _data)

func clear_nodes() -> void:
	nodes.clear()
	default_node = null
