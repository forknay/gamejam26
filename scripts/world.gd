extends Node3D

# --- YOUR EXISTING VARIABLES ---
@onready var radio_overlay = $RadioOverlay
@onready var dialogue_ui = $DialogueCanvas
@onready var day_night_sys = $DayNight

@export var camera : Camera3D
@export var target_computer : Marker3D
@export var target_closet : Marker3D
@export var opening_camera : Camera3D

# Vars for start position
var start_transform : Transform3D
var end_anim : Transform3D

# State Flags (Still useful for the Spacebar check!)
var is_computer = false
var is_closet = false
var is_window = false

# --- NEW SETUP ---
func _ready() -> void:
	$openingCam_v04.anim_done.connect(_on_anim_done)
	
	if not camera or not target_computer:
		print("ERROR: Please assign Camera and Target in the Inspector!")
	else:
		# Save camera position at start
		start_transform = camera.global_transform

	# 1. APPLY THE STATE MACHINE SETTINGS
	setup_scene_state()
	
	# 2. Fade In (Visual polish)
	GameManager.fade_in()

func setup_scene_state():
	# This function sets the "Mood" (Lighting, blocked objects) based on the day
	
	# Example: Adjust Light Energy based on "Night" check
	if GameManager.is_night():
		day_night_sys.setNight(true)
	else:
		day_night_sys.setNight(false)

	# Example: Disable Bed if it's work time
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		# $Bed/StaticBody3D/CollisionShape3D.disabled = true
		pass

# --- YOUR EXISTING LOGIC (Unchanged) ---
func _on_anim_done():
	# Your existing opening cam logic
	$overlay.remove_overlay()
	camera.make_current()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Spacebar pressed! Closet State: ", is_closet) # <--- ADD THIS
	# Your existing "Spacebar to Exit" logic
	if event.is_action_pressed("ui_accept"):
		if is_closet:
			zoom_out_closet()
			is_closet = false
		elif is_computer:
			zoom_out_computer()
			is_computer = false
		elif is_window:
			zoom_out_window()
			is_window = false

# --- YOUR EXISTING ZOOM FUNCTIONS (Unchanged) ---
func zoom_out_closet():
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", false)
	$defaultRadio_v04.radio_anim_back()

func zoom_out_computer():
	$defaultComputer_v04.comp_anim_back()


func zoom_out_window():
	$defaultWindow_v04.window_anim_back()

	
func zoom_in_computer():
	is_computer = true
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(camera, "global_transform", target_computer.global_transform, 1.5)
	
func zoom_in_closet():
	is_closet = true
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(camera, "global_transform", target_closet.global_transform, 1.5)
func zoom_in_window():
	is_window = true

#func zoom_out():
	#var tween_out = create_tween()
	#tween_out.set_trans(Tween.TRANS_CUBIC)
	#tween_out.set_ease(Tween.EASE_IN_OUT)
	#tween_out.tween_property(camera, "global_transform", start_transform, 1.5)

# --- UPDATED INTERACTION HANDLERS (The Brains) ---

# 1. COMPUTER
func _on_static_body_3d_input_event_computer(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_computer:
		
		# LOGIC CHECK: Is the player allowed to use the PC right now?
		if GameManager.is_night():
			# If it's night, maybe they can't work?
			dialogue_ui.start_dialogue(["It's too late to work."])
		else:
			# If it's day, Run your EXISTING zoom function
			print("COMPUTER CLICKED!")
			# Tell the computer script WHICH game to load based on day
			# $defaultComputer_v04.load_day_content(GameManager.current_state)
			
			$defaultComputer_v04.comp_anim()
			zoom_in_computer()
 

# 2. CLOSET / RADIO
func _on_static_body_3d_input_event_closet(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_closet:
		print("CLOSET CLICKED!")
		$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
		$defaultRadio_v04.radio_anim()
		zoom_in_closet()


# 3. WINDOW (Updated with Dialogue Choices)
func _on_static_body_3d_input_event_window(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_window:
		
		# LOGIC CHECK: Different dialogue for Night vs Day
		match GameManager.current_state:
			GameManager.State.INTRO_WAKEUP:
				dialogue_ui.start_dialogue(["The city is dark.", "I should go back to bed."])
			
			GameManager.State.DAY_1_WORK:
				dialogue_ui.start_dialogue(
					["The drone is watching me."], 
					["Wave at it", "Ignore it"], 
					_on_window_choice # Callback function
				)
			
			_: # Default case (MUST be an underscore and colon)
				# Your existing default behavior
				print("WINDOW CLICKED!")
				$defaultWindow_v04.window_anim()
				zoom_in_window()
# Callback for the window choice
func _on_window_choice(index):
	if index == 0: # Waved
		dialogue_ui.start_dialogue(["It didn't react."])
	else:
		dialogue_ui.start_dialogue(["Best not to draw attention."])

# 4. BED (New interaction needed for sleeping!)
func _on_static_body_3d_input_event_bed(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		if GameManager.is_night():
			dialogue_ui.start_dialogue(
				["Sleep for the night?"],
				["Yes", "No"],
				_on_sleep_choice
			)
		else:
			dialogue_ui.start_dialogue(["I need to finish work first."])

func _on_sleep_choice(index):
	if index == 0: # Yes
		# Calculate next day
		var next_state = GameManager.State.DAY_1_WORK # Default
		
		# Simple State Advancement Logic
		if GameManager.current_state == GameManager.State.INTRO_WAKEUP:
			next_state = GameManager.State.DAY_1_WORK
		elif GameManager.current_state == GameManager.State.DAY_1_EVENING:
			next_state = GameManager.State.DAY_2_WORK
			
		GameManager.advance_state(next_state)

# 5. RADIO OVERLAY (Your existing Radio Click)
func _on_static_body_3d_input_event_radio(_camera, event, _pos, _normal, _idx):
	# Only open if we are zoomed into the closet
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_closet:
		radio_overlay.show_overlay()
