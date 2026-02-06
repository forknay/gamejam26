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
@onready var start_prompt = $StartLayer/RichTextLabel

@export var camera : Camera3D

var waiting_for_start = false
var start_transform : Transform3D
var is_computer = false
var is_closet = false
var is_window = false

# --- SETUP ---
func _ready() -> void:
	GameManager.transition_overlay.color.a = 1.0
	if GameManager.current_state == GameManager.State.INTRO_WAKEUP:
		# ONLY play the animation on the very first start
		$openingCam_v04.anim_done.connect(_on_anim_done)
		# Pause
		$openingCam_v04.process_mode = Node.PROCESS_MODE_DISABLED
		if start_prompt:
			start_prompt.visible = true	
		waiting_for_start = true
	else:
		_skip_opening_animation()
		if start_prompt:
			start_prompt.visible = false
		GameManager.fade_in()
	
	var comp_node = $Node3D/Computer
	if comp_node:
		comp_node.all_games_finished.connect(_on_computer_finished)
	else:
		print("ERROR: Could not find node named 'Computer' in World script!")

	setup_scene_state()
	
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
	# This only triggers on INTRO_WAKEUP so you don't click on stuff before anim is done
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

	# --- STORY PROGRESSION ---
	match GameManager.current_state:
		GameManager.State.INTRO_WAKEUP:
			dialogue_ui.start_dialogue([
			"*You feel a throbbing pain in the back of your head*",
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
			"MAIA: Our geopolitical rival back on Earth. They are coming to get our information by any means possible.",
			"You: That doesn't sound good.",
			"You: What about our crewmates? Are we able to contact the others?",
			"MAIA: I doubt they survived the crash. It is a statiscal anomaly that you are alive.",
			"MAIA: You should rest for now and we can figure out how to proceed with our situation tomorrow."
			])
		GameManager.State.DAY_1_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"MAIA: Wake up. The enemy is trying to locate us.", 
				"MAIA: We need to jam their tracking signals.",
				"MAIA: Go to the computer and block them, quick!"
			])
		GameManager.State.DAY_1_EVENING:
			dialogue_ui.start_dialogue([
				"*You hear a faint sound coming from the closet*",
				"(You can interact with objects in the room)",
				"(Click on the window to talk to MAIA)",
				"(Click on the bed to end the day)",
			])
		GameManager.State.DAY_2_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"MAIA: Wake up. We're under attack again.",
				"MAIA: They are persistent. They really want the data we possess.",
				"MAIA: Block the incoming signals."
			])
		GameManager.State.DAY_2_EVENING:
			dialogue_ui.start_dialogue([
				"*You hear another sound from the closet*"
			])
		GameManager.State.DAY_3_WORK:
			alarm_signal.start_alarm()
			dialogue_ui.start_dialogue([
				"MAIA: This is an undesireable situation. They are closing in on our location.",
				"MAIA: If you don't block these signals now, they willl be at our door at any minute."
			])

func _on_computer_finished():
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		alarm_signal.stop_alarm()
		dialogue_ui.start_dialogue([
			"MAIA: Good job blocking their signal", 
			"MAIA: They won’t bother us anymore today but they will try to hunt us again so be on alert."
		], [], _transition_to_evening)
	
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		alarm_signal.stop_alarm()
		dialogue_ui.start_dialogue([
			"MAIA: Excellent work. Their drones lost our scent.",
			"MAIA: We are safe for now..."
		], [], _transition_to_evening)
		
	elif GameManager.current_state == GameManager.State.DAY_3_WORK:
		alarm_signal.stop_alarm()
		if GameManager.heard_radio_count >= 2:
			GameManager.play_climax_music()
			dialogue_ui.start_dialogue(
				["Radio: (Static) ...we are right outside. MAIA is lying. Remove the chip now."],
				["Trust Radio (Remove Chip)", "Trust MAIA (Jam Signal)"],
				_on_final_choice
			)
		else:
			dialogue_ui.start_dialogue([
				"MAIA: We did it. They've given up the search.",
				"MAIA: They think we're dead. Now, we can find a way to get back home.",
				"(The AI deactivates, leaving you in total silence.)"
			], [], func(): GameManager.game_over("END: ALONE"))

func _transition_to_evening():
	if GameManager.current_state == GameManager.State.DAY_1_WORK:
		GameManager.advance_state(GameManager.State.DAY_1_EVENING)
	elif GameManager.current_state == GameManager.State.DAY_2_WORK:
		GameManager.advance_state(GameManager.State.DAY_2_EVENING)

func _on_final_choice(index):
	if index == 0: # TRUST RADIO
		dialogue_ui.start_dialogue([
			"(You reach behind your ear and pull the cool metal chip from your skull.)",
			"MAIA: WH-WHAT ARE YOU DOI- (Static screeching)",
            "Radio: We have a signal. ETA 30 minutes."
		], [], func(): GameManager.game_over("END: RESCUED"))
	else: # TRUST AI
		dialogue_ui.start_dialogue([
			"MAIA: Good choice. You did not let the enemy persuade you.",
			"MAIA: We are finally safe, I will try to contact to contact the Motherland.",
            "(You sit in the dark, starving.)"
		], [], func(): GameManager.game_over("END: STARVED"))

# Little corner [E] to go back
func set_back_prompt(is_visiblee: bool):
	if back_prompt:
		back_prompt.visible = is_visiblee

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

func _input(event):
	if waiting_for_start:
		if event.is_action_pressed("back"):
			_begin_intro_sequence()
		return
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

func _begin_intro_sequence():
	waiting_for_start = false
	GameManager.stop_music()
	
	start_prompt.hide()
	$openingCam_v04.process_mode = Node.PROCESS_MODE_INHERIT
	
	await get_tree().create_timer(0.5).timeout
	GameManager.fade_in()
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
	if dialogue_ui.text_box.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_computer:
		if GameManager.is_night():
			dialogue_ui.start_dialogue(["The computer is turned off..."])
		else:
			$defaultComputer_v04.comp_anim() 
			zoom_in_computer()

func _on_static_body_3d_input_event_window(_camera, event, _pos, _normal, _idx):
	if dialogue_ui.text_box.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_window:
		match GameManager.current_state:
			GameManager.State.INTRO_WAKEUP:
				dialogue_ui.start_dialogue(["Am I the only one here?", "I should go back to bed."])
			
			GameManager.State.DAY_1_WORK:
				dialogue_ui.start_dialogue(["The horse is watching me."], ["Wave at it", "Ignore it"], _on_window_choice)
			
			GameManager.State.DAY_1_EVENING:
				$defaultWindow_v04.window_anim()
				zoom_in_window()
				dialogue_ui.start_dialogue([
		"MAIA: You and your crewmates are all integrated with MAIA, since you humans have a tendency to put emotion into decisions.",
		"MAIA: There is a famous thought experiment, the 'Trolley Problem.' A runaway train, five lives on one track, one worker on the other.",
		"MAIA: They ask: 'Do you let the train run over the five or kill the one with your own hands to save the five?' They call it a dilemma.",
		"You: Hmm, I don't know let me thi...",
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
					"MAIA: Do you think the crew survied and is lost out there, watching?",
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
	if dialogue_ui.text_box.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_closet:
		
		match GameManager.current_state:
			GameManager.State.INTRO_WAKEUP:
				dialogue_ui.start_dialogue(["The closet only has junk.", "I should go back to bed."])
				
			GameManager.State.DAY_1_WORK, GameManager.State.DAY_2_WORK, GameManager.State.DAY_3_WORK:
				dialogue_ui.start_dialogue(["This isn't the time for this..", "I need to finish my work first."])
				
			GameManager.State.DAY_1_EVENING, GameManager.State.DAY_2_EVENING:
				$Closet/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
				$defaultRadio_v04.radio_anim()
				zoom_in_closet()

func _on_static_body_3d_input_event_bed(_camera, event, _pos, _normal, _idx):
	if dialogue_ui.text_box.visible:
		return
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
		GameManager.heard_radio_count += 1 # Keep track for diff endings

# --- Hitboxes to show interactible nature ---
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
