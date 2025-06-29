extends Camera2D

const ZOOM_RATE : float = 0.07
const MIN_ZOOM : float = 4.0
const MAX_ZOOM : float = 0.33
const START_ZOOM : float = MAX_ZOOM
const CENTER_ZOOM : float = 2.5
const ZOOM_WEIGHT : float = 5.0
const DRAG_WEIGHT : float = 15.0

# NOTE - Might be better to define these in the relative [Game] script
const X_MAX_POS := 3200.0
const X_MIN_POS := -50.0
const Y_MAX_POS := 2100.0
const Y_MIN_POS := -900.0
const Y_START_OFFSET := 50.0

var current_zoom : float = START_ZOOM
var target_pos : Vector2
var target_zoom : Vector2

func _ready() -> void:
	# Center of map based on bounds
	target_pos = Vector2(
		X_MIN_POS + X_MAX_POS,
		Y_MIN_POS + Y_MAX_POS + Y_START_OFFSET
	) * 0.5
	update_zoom(START_ZOOM)

func _process(delta: float) -> void:
	set_position( position.lerp(target_pos, DRAG_WEIGHT * delta) )
	handle_zoom(delta)

func _unhandled_input(event: InputEvent) -> void:
	handle_input(event)

func handle_input(event : InputEvent) -> void:
	if event.is_action("zoom_in"):
		update_zoom(current_zoom + (ZOOM_RATE * current_zoom))
	if event.is_action("zoom_out"):
		update_zoom(current_zoom - (ZOOM_RATE * current_zoom))
	
	if Input.is_action_pressed("press") and event is InputEventMouseMotion:
		move_map(event)

func handle_zoom(_delta : float) -> void:
	zoom = zoom.slerp(Vector2(current_zoom, current_zoom), ZOOM_WEIGHT * _delta)
	
	if target_pos.x > X_MAX_POS:
		target_pos.x = lerpf(target_pos.x, X_MAX_POS, 0.5)
	elif target_pos.x < X_MIN_POS:
		target_pos.x = lerpf(target_pos.x, X_MIN_POS, 0.5)
	if target_pos.y > Y_MAX_POS:
		target_pos.y = lerpf(target_pos.y, Y_MAX_POS, 0.5)
	elif target_pos.y < Y_MIN_POS:
		target_pos.y = lerpf(target_pos.y, Y_MIN_POS, 0.5)

func update_zoom(amount : float) -> void:
	current_zoom = clampf(amount, MAX_ZOOM, MIN_ZOOM)

func center_on_room(_room_data : RoomData, room : Room) -> void:
	move_to(room.get_global_center())
	update_zoom(CENTER_ZOOM)

func move_map(event : InputEventMouseMotion) -> void:
	target_pos -= (event.relative / current_zoom)

## Move to position in global space
func move_to(g_position : Vector2) -> void:
	target_pos = g_position
