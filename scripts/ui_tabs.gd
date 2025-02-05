extends TabContainer

const MIN_SIZE := Vector2(400, 0)

var size_tween : Tween

func _ready() -> void:
	tab_changed.connect(change_to_tab)
	
	for i in range(get_child_count()):
		var ui_tab := get_child(i) as UITab
		ui_tab.size_changed.connect(change_to_size)
	
	set_current_tab(-1)

func change_to_tab(tab : int) -> void:
	if tab == -1:
		custom_minimum_size = MIN_SIZE

func change_to_size(_size : Vector2) -> void:
	#print("Changing to size %s" % _size)
	const CHANGE_DURATION : float = 0.3
	
	if size_tween and size_tween.is_running():
		size_tween.kill()
	
	size_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	size_tween.tween_property(self, "custom_minimum_size", _size, CHANGE_DURATION)
