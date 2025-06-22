# meta-description: Base template for adding a new Game

class_name _CLASS_ extends _BASE_

func _init(rdv_header : Dictionary) -> void:
	super(rdv_header)
	
	# Set virtual members
	
	## Map of region names and their offsets in global space
	## Each region is required to have an offset, even if it's Vector2.ZERO
	region_offset = {} 
	
	## Map of region names that contain subregions and their offsets in local coordinates
	## Inner array expected type is Array[Vector2]
	subregion_offset = {}
	
	## Map of region names and room subregion indices
	## Inner dictionary expected type is Dictionary[StringName, int]
	## Defines what rooms are in a subregion
	subregion_map = {}
	
	## Map of room names and their z-indices
	## Use this if rooms need to be manually adjusted
	z_index_override = {}
	
	## Map of region names and their color
	region_color = {}
	
	## 2D Array describing how the inventory is displayed
	## Required to interact with the inventory, but not to display the map
	inventory_layout = []

## Override with Randovania's game ID
func get_game_id() -> StringName:
	return &""

## Override if your rooms need to be flipped horizontally or vertically
func get_region_scale() -> Vector2:
	return Vector2(1, 1)

## Collect and store data about rooms
## Room texture MUST be set
func init_room_data(_room_data : RoomData, _extra_data : Dictionary) -> void:
	var path := ""
	_room_data.texture = get_room_texture(path)
	pass

## Set properties on the room itself (position, minimum size, etc)
## Outline material and config MUST be set
func init_room(room : Room) -> void:
	var outline_config := Room.OutlineConfig.new(
		&"res://resources/highlight_shader.tres", # - Shader Path
		2, # - Outline thickness
		3, # - Outline thickness while hovered
		8  # - Outline thickness for starting room
	)
	room.material = load( outline_config.shader_path ).duplicate()
	room.config = outline_config

## Collect and store data about nodes
## Use setter functions from [NodeData] to maintain consistency
## The order in which properties are set isn't strict, but they are all required
## Certain node types have extra, required fields. They are separated by newline
func init_node_data(_node_data : NodeData, _extra_data : Dictionary) -> void:
	_node_data.set_type()
	_node_data.set_coords()
	
	match _node_data.get_type():
		&"dock":
			_node_data.set_dock_type()
			_node_data.set_dock_weakness()
			
			_node_data.set_color()
			_node_data.set_scale()
			_node_data.set_hover_scale()
			_node_data.set_texture()
		
		&"pickup":
			_node_data.set_item_name()
			
			_node_data.set_color()
			_node_data.set_scale()
			_node_data.set_hover_scale()
			_node_data.set_texture()
		
		&"generic":
			_node_data.set_heal()
			
			_node_data.set_color()
			_node_data.set_scale()
			_node_data.set_hover_scale()
			_node_data.set_texture()
		
		&"event":
			_node_data.set_event_id()
		
		# If your game has extra node types, add them here

## Set properties on the NodeMarker itself (offsets, horizontal/vertical flipping, etc)
func init_node_marker(_marker : NodeMarker) -> void:
	match _marker.data.get_type():
		&"dock": pass
		&"pickup": pass
		&"generic": pass
		&"event": pass
