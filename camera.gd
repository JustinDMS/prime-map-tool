extends Camera2D

const ZOOM_RATE : float = 0.05
const MIN_ZOOM : float = 2.5
const MAX_ZOOM : float = 0.35
const START_ZOOM : float = MAX_ZOOM

const START_POS = Vector2(1450, 200)

func _ready() -> void:
	position = START_POS
	update_zoom(START_ZOOM)

var current_zoom : float = START_ZOOM:
	set(value):
		current_zoom = value
		#print("Zoom = %.2f" % value)

func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		update_zoom(current_zoom + ZOOM_RATE)
	if event.is_action("zoom_out"):
		update_zoom(current_zoom - ZOOM_RATE)
	if Input.is_action_pressed("press") and event is InputEventMouseMotion:
		move_map(event)

func update_zoom(amount : float) -> void:
	const ZOOM_DURATION : float = 0.25
	
	current_zoom = clampf(amount, MAX_ZOOM, MIN_ZOOM)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "zoom", Vector2(current_zoom, current_zoom), ZOOM_DURATION)

func move_map(event : InputEventMouseMotion) -> void:
	position -= event.relative
