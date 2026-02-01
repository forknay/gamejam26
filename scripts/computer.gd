extends Node3D

# --- SIGNALS ---
signal all_games_finished 

# --- CONFIGURATION (Assign in Inspector) ---
@export_group("Screen Content")
@export var day_1_games: Array[PackedScene]
@export var day_2_games: Array[PackedScene] 
@export var day_3_games: Array[PackedScene] # <--- ADDED FOR CLIMAX
@export var screen_static: PackedScene      

# --- REFERENCES ---
@onready var node_viewport = $SubViewport
@onready var node_area = $Screen/Area3D

var is_mouse_inside = false

func _ready():
	# 1. Connect Mouse Logic
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)
	
	# 2. Connect the Signal Chain
	if not node_viewport.has_signal("sequence_finished"):
		print("ERROR: SubViewport script is missing the 'sequence_finished' signal!")
	else:
		node_viewport.sequence_finished.connect(_on_sequence_finished)
	
	# 3. Load content based on the Day
	load_day_content(GameManager.current_state)

func _on_sequence_finished():
	print("Computer: All minigames beaten. Alerting World.")
	all_games_finished.emit() 

func load_day_content(state):
	match state:
		GameManager.State.DAY_1_WORK:
			if day_1_games.size() > 0:
				node_viewport.start_game_sequence(day_1_games)
			else:
				print("Computer: No games assigned for Day 1!")
				
		GameManager.State.DAY_2_WORK: 
			if day_2_games.size() > 0:
				node_viewport.start_game_sequence(day_2_games)
			else:
				print("Computer: No games assigned for Day 2!")

		GameManager.State.DAY_3_WORK: # <--- ADDED CASE
			if day_3_games.size() > 0:
				node_viewport.start_game_sequence(day_3_games)
			else:
				# Fallback: if you haven't made Day 3 specific games, use Day 2
				node_viewport.start_game_sequence(day_2_games)
		_: 
			if screen_static:
				node_viewport.show_single_scene(screen_static)


# --- MOUSE INPUT LOGIC (Standard) ---
func _mouse_entered_area():
	is_mouse_inside = true

func _mouse_exited_area():
	is_mouse_inside = false

func _unhandled_input(event):
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			return
	node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
	# (Your existing coordinate conversion code goes here - removed for brevity but keep it!)
	# If you need me to paste the coordinate math again, let me know.
	pass
