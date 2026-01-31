extends Node3D

@export var camera : Camera3D
@export var target_computer : Marker3D
@export var target_closet : Marker3D
# Vars for start position
var start_transform : Transform3D
var is_zoomed_in = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not camera or not target_computer:
		print("ERROR: Please assign Camera and Target in the Inspector!")
	else:
		# Save camera position at start
		start_transform = camera.global_transform
	
func _input(event):
	# Temp use SPACE
	if event.is_action_pressed("ui_accept") and is_zoomed_in:
		zoom_out()
		
func zoom_in_computer():
	is_zoomed_in = true
	var tween = create_tween()
	
	#cubic = cinematic
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	tween.tween_property(camera, "global_transform", target_computer.global_transform, 1.5)
	
func zoom_in_closet():
	is_zoomed_in = true
	var tween = create_tween()
	
	#cubic = cinematic
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	tween.tween_property(camera, "global_transform", target_closet.global_transform, 1.5)

func zoom_out():
	is_zoomed_in = false
	var tween_out = create_tween()
	
	tween_out.set_trans(Tween.TRANS_CUBIC)
	tween_out.set_ease(Tween.EASE_IN_OUT)
	
	tween_out.tween_property(camera, "global_transform", start_transform, 1.5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_static_body_3d_input_event_computer(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_zoomed_in:
			print("COMPUTER CLICKED!")
			zoom_in_computer()


func _on_static_body_3d_input_event_closet(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_zoomed_in:
			print("CLOSET CLICKED!")
			zoom_in_closet()
