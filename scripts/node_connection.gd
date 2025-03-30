class_name NodeConnection extends Node2D

const WIDTH := 1.5
const PRECISION := 2
const Z_INDEX := 0
const POINT_POSITION_LERP_WEIGHT : float = 0.3

var _from_marker : NodeMarker = null
var _to_marker : NodeMarker = null
var _logic : Dictionary = {}
var _line : Line2D = null

var anim_tween : Tween = null
var from_target := Vector2.ZERO
var to_target := Vector2.ZERO

func _init(from : NodeMarker, to : NodeMarker, logic : Dictionary) -> void:
	_from_marker = from
	_to_marker = to
	_logic = logic

func _ready() -> void:
	assert(_from_marker and _to_marker)
	
	z_index = Z_INDEX
	name = "%s to %s" % [_from_marker.data.name, _to_marker.data.name]
	
	_line = Line2D.new()
	_line.width = WIDTH
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_line.round_precision = PRECISION
	
	set_targets()
	_line.add_point(from_target)
	_line.add_point(to_target)
	
	add_child(_line)
	retract_line.call_deferred()

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
	const DURATION := 0.1
	const MARKER_SCALE_DELAY := 0.1
	
	if anim_tween and anim_tween.is_valid():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	anim_tween.tween_callback(set_visible.bind(true))
	anim_tween.tween_method(_line.set_width, 0.0, WIDTH, DURATION)
	anim_tween.tween_method(set_line_end_pos, from_target, to_target, DURATION)
	anim_tween.tween_callback(_to_marker.node_hover).set_delay(MARKER_SCALE_DELAY)

func retract_line() -> void:
	const DURATION : float = 0.3
	
	if anim_tween and anim_tween.is_valid():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	anim_tween.tween_callback(_to_marker.node_stop_hover)
	anim_tween.tween_method(set_line_end_pos, to_target, from_target, DURATION)
	anim_tween.tween_method(_line.set_width, WIDTH, 0.0, DURATION)
	
	anim_tween.chain().tween_callback(set_visible.bind(false))

func set_line_end_pos(new_pos : Vector2) -> void:
	_line.set_point_position(1, new_pos)

func set_to_marker_scale(new_scale : Vector2) -> void:
	_to_marker.scale = new_scale
