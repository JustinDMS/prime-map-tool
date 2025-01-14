extends TabContainer

enum Tabs {
	INVENTORY,
	RANDOVANIA,
	
	DEFAULT = -1
}

const TAB_MIN_SIZE : Array[Vector2] = [
	Vector2(650, 500),
	Vector2(450, 1000),
	Vector2(400, 0),
	
	Vector2(400, 0)
]

func _ready() -> void:
	tab_changed.connect(change_to_tab)
	set_current_tab(Tabs.DEFAULT)

func change_to_tab(tab : int) -> void:
	custom_minimum_size = TAB_MIN_SIZE[tab]
