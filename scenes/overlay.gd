extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_mouse_filter(MOUSE_FILTER_STOP)
	pass

func remove_overlay():
	print("removing overlay")
	set_mouse_filter(MOUSE_FILTER_IGNORE)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
