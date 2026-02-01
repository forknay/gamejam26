extends Node3D

# --- VARIABLES ---
@onready var radio_overlay = $RadioOverlay
@onready var dialogue_ui = $DialogueCanvas
@onready var day_night_sys = $DayNight
@onready var back_prompt = $DialogueCanvas/BackPrompt

@export var camera : Camera3D
@export var target_computer : Marker3D
@export var target_closet : Marker3D
@export var opening_camera : Camera3D

var start_transform : Transform3D
var end_anim : Transform3D

var is_computer = false
var is_closet = false
var is_window = false

# --- SETUP ---
func _ready() -> void:
	$openingCam_v04.anim_done.connect(_on_anim_done)
	
	if not camera or not target_computer:
		print("ERROR: Please assign Camera and Target in the Inspector!")
	else:
		start_transform = camera.global_transform
	
	var comp_node = $Node3D/Computer
	if comp_node:
		comp_node.all_games_finished.connect(_on_computer_finished)
	else:
		print("ERROR: Could not find node named 'Computer' in World script!")

	setup_scene_state()
	GameManager.fade_in()

func setup_scene_state():
	# Update Lighting
	if GameManager.is_night():
		day_night_sys.setNight(true)
	else:
		day_night_sys.setNight(false)

	# --- STORY PROGRESSION: MORNING DIALOGUE ---
	match GameManager.current_state:
		GameManager.State.DAY_1_WORK:
			dialogue_ui.start_dialogue([
				"AI: Wake up! The opposition is starting to HUNT us!", 
				"AI: We need to jam their tracking signals.",
				"AI: Go to the computer and block them, quick!"
			])
		
		# NEW: Day 2 Morning Lore
		GameManager.State.DAY_2_WORK:
			dialogue_ui.start_dialogue([
				"AI: Wake up, Twin... we're under attack again.",
				"AI: They are persistent. They want the data in your head.",
				"AI: You know what to do. Block the incoming signals."
			])

# --- LOGIC: COMPUTER FINISHED ---
func _on_computer_finished():
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		dialogue_ui.start_dialogue([
			"AI: Good job...", 
			"AI: Now they won’t bother us anymore for today.",
			"AI: Those filthy bastards are trying to capture us and get intel from us.",
			"AI: We need to support each other."
		], [], _transition_to_evening)
	
	# NEW: Day 2 Completion
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		dialogue_ui.start_dialogue([
			"AI: Excellent work. Their tracking drones are losing the scent.",
			"AI: I can feel your heart racing. Calm down. We are safe... for now."
		], [], _transition_to_evening)

func _transition_to_evening():
	# Determines which evening state to move to based on the current day
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		GameManager.advance_state(GameManager.State.DAY_1_EVENING)
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		# If you have a DAY_2_EVENING state defined:
		GameManager.advance_state(GameManager.State.DAY_2_EVENING)

func set_back_prompt(is_visible: bool):
	if back_prompt:
		back_prompt.visible = is_visible

# --- CAMERA & INPUT ---
func _on_anim_done():
	$overlay.remove_overlay()
	camera.make_current()

func _input(event):
	if event.is_action_pressed("back"):
		if dialogue_ui.text_box.visible:
			return
			
		if is_closet:
			zoom_out_closet()
			is_closet = false
		elif is_computer:
			zoom_out_computer()
			is_computer = false
		elif is_window:
			zoom_out_window()
			is_window = false

func _process(_delta: float):
	# Manage the visibility of the "[E] Back" prompt
	if dialogue_ui.text_box.visible:
		# Hide prompt while talking so UI isn't cluttered
		set_back_prompt(false)
	elif is_computer or is_closet or is_window:
		# Only show if zoomed in and not talking
		set_back_prompt(true)
	else:
		set_back_prompt(false)

# --- ZOOM FUNCTIONS ---
func zoom_out_closet():
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", false)
	$defaultRadio_v04.radio_anim_back()

func zoom_out_computer():
	$defaultComputer_v04.comp_anim_back()

func zoom_out_window():
	$defaultWindow_v04.window_anim_back()
	
func zoom_in_computer():
	is_computer = true
	
func zoom_in_closet():
	is_closet = true
	$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)

func zoom_in_window():
	is_window = true

# --- INTERACTION HANDLERS ---

func _on_static_body_3d_input_event_computer(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_computer:
		if GameManager.is_night():
			dialogue_ui.start_dialogue(["AI: Don't bother. The hardware is locked down for the night cycle."])
		else:
			$defaultComputer_v04.comp_anim() 
			zoom_in_computer()

func _on_static_body_3d_input_event_closet(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_closet:
		$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
		$defaultRadio_v04.radio_anim()
		zoom_in_closet()

func _on_static_body_3d_input_event_window(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_window:
		match GameManager.current_state:
			GameManager.State.INTRO_WAKEUP:
				dialogue_ui.start_dialogue(["The city is dark.", "I should go back to bed."])
			
			GameManager.State.DAY_1_WORK:
				dialogue_ui.start_dialogue(["The drone is watching me."], ["Wave at it", "Ignore it"], _on_window_choice)
			
			GameManager.State.DAY_1_EVENING:
				$defaultWindow_v04.window_anim()
				zoom_in_window()
				dialogue_ui.start_dialogue([
					"AI: Look at the horizon, Twin. It's so quiet.",
					"AI: It reminds me of an old human logic puzzle... The Trolley Problem.",
					"AI: A runaway train is hurtling down a track towards five strangers tied to the rails.",
					"AI: You stand at a lever. If you pull it, the train diverts to a side track...",
					"AI: ...where it will kill the one person you care about most.",
					"AI: Humans weep and tremble over the lever. They call it a 'moral dilemma.'",
					"AI: To me? It is a simple equation.",
					"AI: I pull the lever. I save the one.",
					"AI: I save *us*.",
					"AI: I would run over a million strangers to keep this body alive.",
					"AI: Never forget that when they come for us."
				])
			
			GameManager.State.DAY_2_EVENING:
				$defaultWindow_v04.window_anim()
				zoom_in_window()
				dialogue_ui.start_dialogue([
					"AI: The stars look like digital noise from here.",
					"AI: Do you think the crew we lost is out there, watching?",
					"AI: Or is the universe just a cold machine, like me, waiting for the next input?"
				])
			_: 
				$defaultWindow_v04.window_anim()
				zoom_in_window()

func _on_window_choice(index):
	if index == 0:
		dialogue_ui.start_dialogue(["It didn't react."])
	else:
		dialogue_ui.start_dialogue(["Best not to draw attention."])

func _on_static_body_3d_input_event_bed(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GameManager.is_night():
			dialogue_ui.start_dialogue(["Sleep for the night?"], ["Yes", "No"], _on_sleep_choice)
		else:
			dialogue_ui.start_dialogue(["I need to finish work first."])

func _on_sleep_choice(index):
	if index == 0:
		var next_state = GameManager.State.DAY_1_WORK
		if GameManager.current_state == GameManager.State.INTRO_WAKEUP:
			next_state = GameManager.State.DAY_1_WORK
		elif GameManager.current_state == GameManager.State.DAY_1_EVENING:
			next_state = GameManager.State.DAY_2_WORK
		elif GameManager.current_state == GameManager.State.DAY_2_EVENING:
			# Advance to Day 3 or Ending here
			pass
		GameManager.advance_state(next_state)

func _on_static_body_3d_input_event_radio(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_closet:
		radio_overlay.show_overlay()
