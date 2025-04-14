extends Camera2D

const ZOOM_RATE : float = 0.07
const MIN_ZOOM : float = 4.0
const MAX_ZOOM : float = 0.33
const START_ZOOM : float = MAX_ZOOM
const CENTER_ZOOM : float = 2.5
const ZOOM_WEIGHT : float = 0.15
const DRAG_WEIGHT : float = 0.3

const X_MAX_POS := 3200.0
const X_MIN_POS := -50.0
const Y_MAX_POS := 2100.0
const Y_MIN_POS := -900.0
const Y_START_OFFSET := 50.0

var current_zoom : float = START_ZOOM:
	set(value):
		current_zoom = value
		#print("Zoom = %.2f" % value)
var target_pos : Vector2
var move_to_tween : Tween = null
var zoom_to_tween : Tween = null

func _ready() -> void:
	# Center of map based on bounds
	target_pos = Vector2(
		X_MIN_POS + X_MAX_POS,
		Y_MIN_POS + Y_MAX_POS + Y_START_OFFSET
	) * 0.5
	update_zoom(START_ZOOM)

func _physics_process(delta: float) -> void:
	handle_zoom(delta)
	
	if move_to_tween and move_to_tween.is_running():
		return
	position = position.lerp(target_pos, DRAG_WEIGHT)

func _unhandled_input(event: InputEvent) -> void:
	handle_input(event)

func handle_input(event : InputEvent) -> void:
	if event.is_action("zoom_in"):
		update_zoom(current_zoom + (ZOOM_RATE * current_zoom))
	if event.is_action("zoom_out"):
		update_zoom(current_zoom - (ZOOM_RATE * current_zoom))
	
	if Input.is_action_pressed("press") and event is InputEventMouseMotion:
		if move_to_tween and move_to_tween.is_running():
			target_pos = position
			move_to_tween.kill()
		
		move_map(event)

func handle_zoom(_delta : float) -> void:
	if zoom_to_tween and zoom_to_tween.is_valid():
		return
	
	zoom = zoom.slerp(Vector2(current_zoom, current_zoom), ZOOM_WEIGHT)
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

## Runs on Room double_clicked which passes node data
func center_on_room(_node_data : NodeData, room : Room) -> void:
	move_to(room.get_global_center())
	zoom_to(CENTER_ZOOM)

func move_map(event : InputEventMouseMotion) -> void:
	target_pos -= (event.relative / current_zoom)

func move_to(g_position : Vector2) -> void:
	const DURATION : float = 0.45
	
	if move_to_tween:
		move_to_tween.kill()
	
	move_to_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	move_to_tween.tween_property(self, "position", g_position, DURATION)
	move_to_tween.tween_callback(func(): target_pos = g_position)

func zoom_to(new_value : float) -> void:
	const DURATION : float = 1.0
	
	if zoom_to_tween:
		zoom_to_tween.kill()
	
	zoom_to_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	zoom_to_tween.tween_property(self, "zoom", Vector2.ONE * new_value, DURATION)
	zoom_to_tween.tween_callback(func(): current_zoom = zoom.x)
