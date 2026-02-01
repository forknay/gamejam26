extends Node3D

# --- CONFIGURATION (Assign these in Inspector) ---
@export_group("Screen Content")
@export var day_1_games: Array[PackedScene] # Drag your Day 1 Minigames here
@export var screen_static: PackedScene      # Optional: Drag a "Static Noise" scene here for Night

# --- REFERENCES ---
@onready var node_viewport = $SubViewport
@onready var node_quad = $Quad
@onready var screen_mesh = $Screen
@onready var node_area = $Screen/Area3D

# --- STATE ---
var is_mouse_inside = false
var last_event_pos2D = null
var last_event_time: float = -1.0

func _ready():
	# 1. Connect Input Signals
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)
	
	# 2. Setup Screen based on Game State
	load_day_content(GameManager.current_state)

func load_day_content(state):
	match state:
		# --- DAY TIME (WORK) ---
		GameManager.State.DAY_1_WORK:
			if day_1_games.size() > 0:
				print("Computer: Starting Work Mode")
				node_viewport.start_game_sequence(day_1_games)
			else:
				print("Computer: No games assigned for Day 1!")

		# --- NIGHT TIME (OFF / STATIC) ---
		_: 
			# For Intro, Evening, or any other time:
			print("Computer: Night Mode (Off)")
			if screen_static:
				node_viewport.show_single_scene(screen_static)
			else:
				node_viewport.clear_screen()

# --- MOUSE INPUT LOGIC (Your existing implementation) ---
func _mouse_entered_area():
	is_mouse_inside = true

func _mouse_exited_area():
	is_mouse_inside = false

func _unhandled_input(event):
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			return
	node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	var quad_mesh_size = node_quad.mesh.size
	var event_pos3D = event_position
	var now: float = Time.get_ticks_msec() / 1000.0

	event_pos3D = node_quad.global_transform.affine_inverse() * event_pos3D

	var event_pos2D: Vector2 = Vector2()

	if is_mouse_inside:
		event_pos2D = Vector2(event_pos3D.x, -event_pos3D.y)
		event_pos2D.x = event_pos2D.x / quad_mesh_size.x
		event_pos2D.y = event_pos2D.y / quad_mesh_size.y
		event_pos2D.x += 0.5
		event_pos2D.y += 0.5
		event_pos2D.x *= node_viewport.size.x
		event_pos2D.y *= node_viewport.size.y

	elif last_event_pos2D != null:
		event_pos2D = last_event_pos2D

	event.position = event_pos2D
	if event is InputEventMouse:
		event.global_position = event_pos2D

	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if last_event_pos2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = event_pos2D - last_event_pos2D
			event.velocity = event.relative / (now - last_event_time)

	last_event_pos2D = event_pos2D
	last_event_time = now

	node_viewport.push_input(event)
