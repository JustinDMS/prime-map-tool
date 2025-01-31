extends Camera2D

const ZOOM_RATE : float = 0.07
const MIN_ZOOM : float = 4.0
const MAX_ZOOM : float = 0.35
const START_ZOOM : float = MAX_ZOOM
const ZOOM_WEIGHT : float = 0.15
const DRAG_WEIGHT : float = 0.3

const START_POS = Vector2(1800, 645)
const X_MAX_POS := 3200.0
const X_MIN_POS := -50.0
const Y_MAX_POS := 1600.0
const Y_MIN_POS := -900.0

var current_zoom : float = START_ZOOM:
	set(value):
		current_zoom = value
		#print("Zoom = %.2f" % value)
var target_pos : Vector2

func _ready() -> void:
	target_pos = START_POS
	update_zoom(START_ZOOM)

func _physics_process(delta: float) -> void:
	zoom = zoom.slerp(Vector2(current_zoom, current_zoom), ZOOM_WEIGHT)
	if target_pos.x > X_MAX_POS:
		target_pos.x = lerpf(target_pos.x, X_MAX_POS, 0.5)
	elif target_pos.x < X_MIN_POS:
		target_pos.x = lerpf(target_pos.x, X_MIN_POS, 0.5)
	if target_pos.y > Y_MAX_POS:
		target_pos.y = lerpf(target_pos.y, Y_MAX_POS, 0.5)
	elif target_pos.y < Y_MIN_POS:
		target_pos.y = lerpf(target_pos.y, Y_MIN_POS, 0.5)
	
	position = position.lerp(target_pos, DRAG_WEIGHT)

func _unhandled_input(event: InputEvent) -> void:
	handle_input(event)

func handle_input(event : InputEvent) -> void:
	if event.is_action("zoom_in"):
		update_zoom(current_zoom + (ZOOM_RATE * current_zoom))
	if event.is_action("zoom_out"):
		update_zoom(current_zoom - (ZOOM_RATE * current_zoom))
	
	if event is InputEventMagnifyGesture:
		current_zoom = lerpf(MAX_ZOOM, MIN_ZOOM, event.factor)
		update_zoom(current_zoom)
	
	if Input.is_action_pressed("press") and event is InputEventMouseMotion:
		move_map(event)

func update_zoom(amount : float) -> void:
	current_zoom = clampf(amount, MAX_ZOOM, MIN_ZOOM)

func move_map(event : InputEventMouseMotion) -> void:
	target_pos -= (event.relative / current_zoom)
