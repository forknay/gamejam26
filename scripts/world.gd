extends Node3D

@onready var radio_overlay = $RadioOverlay
@export var camera : Camera3D
@export var target_computer : Marker3D
@export var target_closet : Marker3D
@export var opening_camera : Camera3D
# Vars for start position
var start_transform : Transform3D
var end_anim : Transform3D
var is_computer = false
var is_closet = false
var is_window = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$openingCam_v04.anim_done.connect(_on_anim_done)
	if not camera or not target_computer:
		print("ERROR: Please assign Camera and Target in the Inspector!")
	else:
		# Save camera position at start
		start_transform = camera.global_transform
		
		
func _on_anim_done():
	print(start_transform)
	$overlay.remove_overlay()
	#var tween = create_tween()
	#var target_pos = Vector3(-2.22, 1.388, 0.971)
	#var target_rot = Vector3(0, deg_to_rad(-46.7), 0) # Convert Y to radians
	camera.make_current()
	# Create a new Transform with this basis (rotation) and origin (position)
	#var trans = Transform3D(Basis.from_euler(target_rot), target_pos)
	#cubic = cinematic
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	
	#tween.tween_property(camera, "global_transform", trans, 1.0)
func _input(event):
	# Temp use SPACE
	if event.is_action_pressed("ui_accept"):
		if is_closet:
			zoom_out_closet()
			is_closet = false
		elif is_computer:
			zoom_out_computer()
			is_closet = false
		elif is_window:
			zoom_out_window()
			is_closet = false

func zoom_out_closet():
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", false)
	$defaultRadio_v04.radio_anim_back()
func zoom_out_computer():
	$defaultComputer_v04.comp_anim_back()
func zoom_out_window():
	$defaultWindow_v04.window_anim_back()
	
func zoom_in_computer():
	is_computer = true
	var tween = create_tween()
	
	#cubic = cinematic
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	tween.tween_property(camera, "global_transform", target_computer.global_transform, 1.5)
	
func zoom_in_closet():
	is_closet = true
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	var tween = create_tween()
	
	#cubic = cinematic
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	# match camera over 1.5s
	tween.tween_property(camera, "global_transform", target_closet.global_transform, 1.5)

func zoom_out():
	#is_zoomed_in = false

	var tween_out = create_tween()
	
	tween_out.set_trans(Tween.TRANS_CUBIC)
	tween_out.set_ease(Tween.EASE_IN_OUT)
	
	tween_out.tween_property(camera, "global_transform", start_transform, 1.5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_static_body_3d_input_event_computer(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_computer:
			print("COMPUTER CLICKED!")
			#zoom_in_computer()
			is_computer = true
			$defaultComputer_v04.comp_anim()


func _on_static_body_3d_input_event_closet(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_closet:
			print("CLOSET CLICKED!")
			is_closet = true
			$defaultRadio_v04.radio_anim()


func _on_static_body_3d_input_event_radio(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_closet:
		radio_overlay.show_overlay()

func change_scene(path):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		print("Failed to change scene:", error)


func _on_static_body_3d_input_event_window(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_window:
			print("WINDOW CLICKED!")
			is_window = true
			$defaultWindow_v04.window_anim()


func _on_static_body_3d_input_event_bed(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	pass # Replace with function body.
