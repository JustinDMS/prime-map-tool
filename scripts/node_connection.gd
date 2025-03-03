class_name NodeConnection extends Node2D

const WIDTH := 1.5
const PRECISION := 2
const COLOR := Color.SKY_BLUE
const Z_INDEX := 1
const POINT_POSITION_LERP_WEIGHT : float = 0.3

var _from_marker : NodeMarker = null
var _to_marker : NodeMarker = null
var _logic : Dictionary = {}
var _logic_combinations : Array = []
var _line : Line2D = null

var anim_tween : Tween = null
var from_target := Vector2.ZERO
var to_target := Vector2.ZERO

func _init(from : NodeMarker, to : NodeMarker, logic : Dictionary) -> void:
	_from_marker = from
	_to_marker = to
	_logic = logic
	_logic_combinations = extract_combinations(logic)

func _ready() -> void:
	assert(_from_marker and _to_marker)
	
	z_index = Z_INDEX
	name = "%s to %s" % [_from_marker.data.name, _to_marker.data.name]
	
	_line = Line2D.new()
	_line.width = WIDTH
	_line.default_color = COLOR
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_line.round_precision = PRECISION
	
	set_targets()
	_line.add_point(from_target)
	_line.add_point(to_target)
	
	add_child(_line)
	retract_line()

func set_targets() -> void:
	const PADDING_FROM := 0
	const PADDING_TO := 4.0
	
	var from_pos := get_global_center(_from_marker)
	var to_pos := get_global_center(_to_marker)
	var direction := (to_pos - from_pos).normalized()
	
	from_target = to_local(from_pos + (direction * PADDING_FROM))
	to_target = to_local(to_pos - (direction * PADDING_TO))

func get_global_center(marker : NodeMarker) -> Vector2:
	const THRESHOLD := 1.0
	
	var offset := marker.offset
	if abs(marker.rotation_degrees) < THRESHOLD:
		offset *= -1
	if PI/2 - abs(marker.rotation) < THRESHOLD and not marker.rotation < -PI/2:
		var tmp := offset
		offset.x = tmp.y * signf(marker.rotation)
		offset.y = tmp.x * signf(marker.rotation)
	
	offset *= marker.scale
	return marker.global_position - offset

func extend_line() -> void:
	const DURATION := 0.7
	const MARKER_SCALE_DELAY := 0.1
	
	if anim_tween and anim_tween.is_running():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	anim_tween.tween_callback(set_visible.bind(true))
	anim_tween.tween_method(_line.set_width, 0.0, WIDTH, DURATION)
	anim_tween.tween_method(set_line_end_pos, from_target, to_target, DURATION)
	anim_tween.tween_method(set_to_marker_scale, _to_marker.data.get_scale(), _to_marker.data.get_hover_scale(), DURATION).set_delay(MARKER_SCALE_DELAY)

func retract_line() -> void:
	const DURATION : float = 0.3
	
	if anim_tween and anim_tween.is_running():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	anim_tween.tween_method(set_line_end_pos, to_target, from_target, DURATION)
	anim_tween.tween_method(_line.set_width, WIDTH, 0.0, DURATION)
	anim_tween.tween_method(set_to_marker_scale, _to_marker.scale, _to_marker.data.get_scale(), DURATION)
	
	anim_tween.chain().tween_callback(set_visible.bind(false))

func set_line_end_pos(new_pos : Vector2) -> void:
	_line.set_point_position(1, new_pos)

func set_to_marker_scale(new_scale : Vector2) -> void:
	_to_marker.scale = new_scale

	#for i in reqs.size(): # i == combination number
	#	print("\t%d:" % i)
	#	for type in reqs[i]:
	#		print("\t\t%s: %s" % [type, reqs[i][type]])

func extract_combinations(logic : Dictionary) -> Array:
	if logic.type == "resource":
		return [{
			logic.data.type : {logic.data.name : logic.data.amount - (1 if logic.data.negate else 0)}
		}]
	
	var combinations = []
	
	if logic.type == "and":
		var all_items = []
		
		for item in logic.data.items:
			var sub_combinations = extract_combinations(item)
			
			if all_items.is_empty():
				all_items = sub_combinations
			else:
				var new_combinations = []
				for comb in all_items:
					for sub_comb in sub_combinations:
						var merged = {
							"items": comb.get("items", {}).duplicate(),
							"events": comb.get("events", {}).duplicate(),
							"tricks": comb.get("tricks", {}).duplicate(),
							"damage": comb.get("damage", {}).duplicate(),
							"misc": comb.get("misc", {}).duplicate()
						}
						for key in sub_comb:
							merged[key].merge(sub_comb[key])
						new_combinations.append(merged)
				all_items = new_combinations
		return all_items
	
	if logic.type == "or":
		for item in logic.data.items:
			combinations.append_array(extract_combinations(item))
	
	return combinations
