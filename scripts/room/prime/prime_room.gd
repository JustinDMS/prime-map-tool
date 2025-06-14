class_name PrimeRoom extends Room

func init_room():
	create_bitmap_from_room_image(data.texture.get_image(), false, true)
	
	var x1 : float = data.aabb[0]
	var y1 : float = data.aabb[1]
	var _z1 : float = data.aabb[2]
	var x2 : float = data.aabb[3]
	var y2 : float = data.aabb[4]
	var _z2 : float = data.aabb[5]
	
	position.x = x1
	position.y = y1
	
	custom_minimum_size.x = abs(x2 - x1)
	custom_minimum_size.y = abs(y2 - y1)
	
	material = OUTLINE_SHADER.duplicate()
	material.set_shader_parameter(&"pattern", 1)
	material.set_shader_parameter(&"inside", true)
	
	super()
