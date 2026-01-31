extends Node3D

@onready var camera = $Camera3D
@onready var target = $Marker3D

# Vars for start position
var start_transform : Transform3D
var is_zoomed_in = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Save camera position at start
	start_transform = camera.global_transform
	
func _input(event):
	# Temp use SPACE
	if event.is_action_pressed("ui_accept"):
		if is_zoomed_in:
			zoom_out()
		else:
			zoom_in()
func zoom_in():
	is_zoomed_in = true
	var tween = create_tween()
	
	#cubic = cinematic
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	tween.tween_property(camera, "global_transform", target.global_transform, 1.5)
	
func zoom_out():
	is_zoomed_in = false
	var tween_out = create_tween()
	
	tween_out.set_trans(Tween.TRANS_CUBIC)
	tween_out.set_ease(Tween.EASE_IN_OUT)
	
	tween_out.tween_property(camera, "global_transform", start_transform, 1.5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
