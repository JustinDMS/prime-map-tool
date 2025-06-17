class_name AM2RRoom extends Room

func init_room():
	create_bitmap_from_room_image(data.texture.get_image(), false, true)
	
	position.x = data.x_position
	position.y = data.y_position
	
	custom_minimum_size.x = data.image_width
	custom_minimum_size.y = data.image_height
	
	material = OUTLINE_SHADER.duplicate()
	material.set_shader_parameter(&"pattern", 1)
	material.set_shader_parameter(&"inside", true)
	
	super()
