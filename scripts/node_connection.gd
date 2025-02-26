class_name NodeConnection extends Node2D

const PADDING := 3.0
const WIDTH := 15.0
const COLOR := Color.SKY_BLUE
const Z_INDEX := 5
const POINT_POSITION_LERP_WEIGHT : float = 0.3

var _from_marker : NodeMarker = null
var _to_marker : NodeMarker = null
var _line : Line2D = null

func _init(from : NodeMarker, to : NodeMarker) -> void:
	_from_marker = from
	_to_marker = to
	z_index = Z_INDEX
	name = "to_%s" % _to_marker.data.name

func _ready() -> void:
	assert(_from_marker and _to_marker)
	
	_line = Line2D.new()
	_line.width = WIDTH
	_line.default_color = COLOR
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_line.add_point(Vector2.ZERO)
	_line.add_point(Vector2.ZERO)
	lerp_points_to_target(1)
	
	add_child(_line)

func _physics_process(_delta: float) -> void:
	if not visible or not _line:
		return
	
	lerp_points_to_target(POINT_POSITION_LERP_WEIGHT)

func lerp_points_to_target(weight : float) -> void:
	var from_pos := get_global_center(_from_marker)
	var to_pos := get_global_center(_to_marker)
	var padding := (to_pos - from_pos).normalized() * PADDING
	
	var from_target := to_local(from_pos + padding)
	var to_target := to_local(to_pos - padding)
	
	_line.set_point_position(0, _line.get_point_position(0).lerp(from_target, weight))
	_line.set_point_position(1, _line.get_point_position(1).lerp(to_target, weight))

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
