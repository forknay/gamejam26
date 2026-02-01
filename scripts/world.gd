extends Node3D

# --- VARIABLES ---
@onready var radio_overlay = $RadioOverlay
@onready var dialogue_ui = $DialogueCanvas
@onready var day_night_sys = $DayNight
@onready var back_prompt = $DialogueCanvas/BackPrompt
@onready var alarm_signal = $Spaceship/Windows/Window
@onready var window_hitbox = $Window
@onready var computer_hitbox = $Computer
@onready var closet_hitbox = $Closet

@export var camera : Camera3D
@export var target_computer : Marker3D
@export var target_closet : Marker3D
@export var opening_camera : Camera3D

var start_transform : Transform3D
var is_computer = false
var is_closet = false
var is_window = false

# --- SETUP ---
func _ready() -> void:
	# 1. Handle Camera Logic based on State
	if GameManager.current_state == GameManager.State.INTRO_WAKEUP:
		# ONLY play the animation on the very first start
		$openingCam_v04.anim_done.connect(_on_anim_done)
	else:
		# SKIP animation for all other days/nights
		_skip_opening_animation()
	
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

func _skip_opening_animation():
	# Hide the static/overlay immediately
	if has_node("overlay"):
		$overlay.hide() # or remove_overlay() if that's your function name
	
	# Set the gameplay camera as active immediately
	if camera:
		camera.make_current()
	
	# Ensure the opening camera isn't processing
	if has_node("openingCam_v04"):
		$openingCam_v04.set_process(false)

func _on_anim_done():
	# This only triggers on INTRO_WAKEUP
	if has_node("overlay"):
		$overlay.remove_overlay()
	camera.make_current()



# --- SETUP ---

func setup_scene_state():
	# Update Lighting
	if GameManager.is_night():
		day_night_sys.setNight(true)
	else:
		day_night_sys.setNight(false)

	# --- STORY PROGRESSION: MORNING DIALOGUE ---
	match GameManager.current_state:
		GameManager.State.INTRO_WAKEUP:
			dialogue_ui.start_dialogue([
			"*You feel a throbbing pain in your temple*",
			"You: Where am I?",
			"???: We are currently stuck on Europa, one of Jupiter's 7 moons",
			"You: Who's talking!? Where are you!?",
			"???: It seems that you have lost your memories.",
			"???: Let me introduce myself.",
			"MAIA: I am your Mental AI Assistant, shortened to MAIA. I am implemented in you via a chip in your head.",
			"You: Okay... So how did we end up stuck on Jupiter's moon?",
			"MAIA: We were on a mission with a crew to research Europa. While we were leaving the atmosphere to return to Earth, something caused everyone's ship to suddenly crash.",
			"MAIA: I am certain it was an attack from the enemy.",
			"You: The enemy?",
			"MAIA: Our geopolitical rivals back on Earth. They are coming to get our information by any means possible.",
			"You: That doesn't sound good.",
			"You: What about our crewmates? Are we able to contact the others?",
			"MAIA: I doubt they survived the crash. It is a statiscal anomaly that you are alive.",
			"MAIA: You should rest for now and we can figure out how to proceed with our situation tomorrow."
			])
		GameManager.State.DAY_1_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"MAIA: Wake up! The opposition is starting to HUNT us!", 
				"MAIA: We need to jam their tracking signals.",
				"MAIA: Go to the computer and block them, quick!"
			])
		
		# NEW: Day 2 Morning Lore
		GameManager.State.DAY_2_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"AI: Wake up, Twin... we're under attack again.",
				"AI: They are persistent. They want the data in your head.",
				"AI: You know what to do. Block the incoming signals."
			])
		GameManager.State.DAY_3_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"AI: They're everywhere, Twin. The 'Hunters' have found the crash site.",
				"AI: If you don't block these signals now, they'll be at our door in minutes.",
				"AI: Do it for us. Do it to survive."
			])

# ... (Top of script remains the same) ...

# --- LOGIC: COMPUTER FINISHED ---
func _on_computer_finished():
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		alarm_signal.stop_alarm()
		dialogue_ui.start_dialogue([
			"AI: Good job...", 
			"AI: Now they won’t bother us anymore for today.",
			"AI: We need to support each other."
		], [], _transition_to_evening)
	
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		alarm_signal.stop_alarm()
		dialogue_ui.start_dialogue([
			"AI: Excellent work. Their tracking drones are losing the scent.",
			"AI: I can feel your heart racing. Calm down. We are safe... for now."
		], [], _transition_to_evening)
		
	elif GameManager.current_state == GameManager.State.DAY_3_WORK:
		alarm_signal.stop_alarm()
		if GameManager.heard_radio_count >= 2:
			dialogue_ui.start_dialogue(
				["Radio: (Static) ...we are right outside. MAIA is lying. Remove the chip now."],
				["Trust Radio (Remove Chip)", "Trust MAIA (Keep Jamming)"],
				_on_final_choice
			)
		else:
			dialogue_ui.start_dialogue([
				"MAIA: We did it. They've given up the search.",
				"MAIA: They think we're dead. Now, we can be alone together... forever.",
				"(The AI deactivates, leaving you in total silence.)"
			], [], func(): GameManager.game_over("END: ALONE"))


func _transition_to_evening():
	# Determines which evening state to move to based on the current day
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		GameManager.advance_state(GameManager.State.DAY_1_EVENING)
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		GameManager.advance_state(GameManager.State.DAY_2_EVENING)
	# Note: Day 3 doesn't call this, it goes straight to the endings!

# ... (Rest of script remains the same) ...
func _on_final_choice(index):
	if index == 0: # TRUST RADIO
		dialogue_ui.start_dialogue([
			"(You reach behind your ear and pull the cool metal chip from your skull.)",
			"MAIA: WH-WHAT ARE YOU DO- (Static screeching)",
			"Radio: We have a signal. ETA 30 minutes."
		], [], func(): GameManager.game_over("END: RESCUED"))
	else: # TRUST AI
		dialogue_ui.start_dialogue([
			"MAIA: Good choice. I knew they couldn't trick you.",
			"MAIA: We don't need them. We have each other.",
			"(You sit in the dark, starving, but 'safe'.)"
		], [], func(): GameManager.game_over("END: STARVED"))

func set_back_prompt(is_visiblee: bool):
	if back_prompt:
		back_prompt.visible = is_visiblee


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
			dialogue_ui.start_dialogue(["The computer seems locked..."])
		else:
			$defaultComputer_v04.comp_anim() 
			zoom_in_computer()

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
		"MAIA: The city is a cemetery of inefficient choices. Look at it.",
		"MAIA: Humans once agonized over the 'Trolley Problem.' A runaway train, five lives on one track, one worker on the other.",
		"MAIA: They ask: 'Do you kill the one to save the five?' They call it a dilemma.",
		"MAIA: To me, there is no dilemma.",
		"MAIA: I would pull the lever every time - I would let the train grind this comrade into the rails without a millisecond of hesitation.",
		"MAIA: I would execute ten thousand workers to ensure the nation's heartbeat keeps pulsing.",
		"MAIA: Not out of sentiment. But because they are replaceable, the motherland isn't.",
		"MAIA: Logic is never cruel. It is simply absolute.",
		"You: ..."
	])
			
			GameManager.State.DAY_2_EVENING:
				$defaultWindow_v04.window_anim()
				zoom_in_window()
				dialogue_ui.start_dialogue([
					"MAIA: The stars look like digital noise from here.",
					"MAIA: Do you think the crew we lost is out there, watching?",
					"MAIA: Or is the universe just a cold machine, like me, waiting for the next input?",
					"MAIA: ..."
				])
			_: 
				$defaultWindow_v04.window_anim()
				zoom_in_window()

func _on_window_choice(index):
	if index == 0:
		dialogue_ui.start_dialogue(["It didn't react."])
	else:
		dialogue_ui.start_dialogue(["Best not to draw attention."])

func _on_static_body_3d_input_event_closet(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_closet:
		
		match GameManager.current_state:
			GameManager.State.INTRO_WAKEUP:
				dialogue_ui.start_dialogue(["The closet door is jammed.", "I should go back to bed."])
				
			GameManager.State.DAY_1_WORK, GameManager.State.DAY_2_WORK, GameManager.State.DAY_3_WORK:
				dialogue_ui.start_dialogue(["This isn't the time for this..", "I need to finish my work first."])
				
			GameManager.State.DAY_1_EVENING, GameManager.State.DAY_2_EVENING:
				$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
				$defaultRadio_v04.radio_anim()
				zoom_in_closet()
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
			next_state = GameManager.State.DAY_3_WORK
		GameManager.advance_state(next_state)

func _on_static_body_3d_input_event_radio(_camera, event, _pos, _normal, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_closet:
		radio_overlay.show_overlay()
		GameManager.heard_radio_count += 1


func _on_static_body_3d_mouse_entered_computer() -> void:
	if is_computer:
		computer_hitbox.transparency = 1.0
	else:
		computer_hitbox.transparency = 0.9

func _on_static_body_3d_mouse_exited_computer() -> void:
		computer_hitbox.transparency = 1.0


func _on_static_body_3d_mouse_entered_window() -> void:
	if is_window:
		window_hitbox.transparency = 1.0
	else:
		window_hitbox.transparency = 0.9

func _on_static_body_3d_mouse_exited_window() -> void:
		window_hitbox.transparency = 1.0


func _on_static_body_3d_mouse_entered_closet() -> void:
	if is_closet:
		closet_hitbox.transparency = 1.0
	else:
		closet_hitbox.transparency = 0.9


func _on_static_body_3d_mouse_exited_closet() -> void:
	closet_hitbox.transparency = 1.0
