extends Camera2D

const ZOOM_RATE : float = 0.07
const MIN_ZOOM : float = 4.0
const MAX_ZOOM : float = 0.35
const START_ZOOM : float = MAX_ZOOM
const ZOOM_WEIGHT : float = 0.15
const DRAG_WEIGHT : float = 0.3

const START_POS = Vector2(1750, 550)

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
