class_name NodeConnection extends Line2D

enum State {
	INIT = -1,
	UNREACHED,
	REACHED
}

const WIDTH := 1.5
const PRECISION := 2
const Z_INDEX := 0
const POINT_POSITION_LERP_WEIGHT : float = 0.3
const PADDING_FROM := 0
const PADDING_TO := 4.0

var state := State.INIT
var _from_marker : NodeMarker = null
var _to_marker : NodeMarker = null
var _logic : Dictionary = {}

var anim_tween : Tween = null
var from_target := Vector2.ZERO
var to_target := Vector2.ZERO

func _init(from : NodeMarker, to : NodeMarker, logic : Dictionary) -> void:
	_from_marker = from
	_to_marker = to
	_logic = logic
	
	set_z_index(Z_INDEX)
	set_name( "%s to %s" % [_from_marker.data.name, _to_marker.data.name] )
	
	set_width(0)
	set_begin_cap_mode(Line2D.LINE_CAP_ROUND)
	set_end_cap_mode(Line2D.LINE_CAP_ROUND)
	set_round_precision(PRECISION)

func _ready() -> void:
	var from_pos := get_global_center(_from_marker)
	var to_pos := get_global_center(_to_marker)
	var direction := (to_pos - from_pos).normalized()
	
	from_target = to_local(from_pos + (direction * PADDING_FROM))
	to_target = to_local(to_pos - (direction * PADDING_TO))
	
	add_point(from_target)
	add_point(to_target)
	
	change_state(State.REACHED)

func change_state(new_state : State) -> void:
	state = new_state
	
	match state:
		State.UNREACHED:
			set_self_modulate( Color.INDIAN_RED )
		State.REACHED:
			set_self_modulate( Color.GREEN )

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

func show_connection() -> void:
	const DURATION := 0.1
	const MARKER_SCALE_DELAY := 0.1
	
	if anim_tween and anim_tween.is_valid():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	anim_tween.tween_method(set_width, 0.0, WIDTH, DURATION)
	anim_tween.tween_callback(_to_marker._set_scale.bind(_to_marker.data.get_hover_scale())).set_delay(MARKER_SCALE_DELAY)

func hide_connection() -> void:
	const DURATION : float = 0.3
	
	if anim_tween and anim_tween.is_valid():
		anim_tween.kill()
	
	anim_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	anim_tween.tween_callback(_to_marker._set_scale.bind(_to_marker.data.get_scale()))
	anim_tween.tween_method(set_width, WIDTH, 0.0, DURATION)

func set_to_marker_scale(new_scale : Vector2) -> void:
	_to_marker.scale = new_scale
