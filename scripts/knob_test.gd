extends Node2D

# --- CONFIG ---
var target_angle = 90.0
var tolerance = 25.0
var max_volume = -15.0

# --- LORE AUDIO (Assign these in the Inspector) ---
@export var night_1_ogg: AudioStream
@export var night_2_ogg: AudioStream

# --- REFS ---
@onready var static_sound = $"../StaticSound"
@onready var rescue_voice = $"../RescueVoice"
@onready var area_2d = $Area2D

# --- STATE ---
var is_dragging = false
var has_won_this_night = false

func _ready():
	area_2d.input_event.connect(_on_area_input)
	
	# Load the correct audio file for the current night
	_setup_nightly_audio()

func _setup_nightly_audio():
	match GameManager.current_state:
		GameManager.State.DAY_1_EVENING:
			rescue_voice.stream = night_1_ogg
		GameManager.State.DAY_2_EVENING:
			rescue_voice.stream = night_2_ogg
	
	# Start playing (but they'll be silent until the knob is turned)
	rescue_voice.play()
	static_sound.play()

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false
		
	if is_dragging and event is InputEventMouseMotion:
		look_at(get_global_mouse_position())
		rotation_degrees += 90 
		update_audio()

func update_audio():
	var current_rot = wrapf(rotation_degrees, 0, 360)
	var dist = abs(current_rot - target_angle)
	if dist > 180: dist = 360 - dist
		
	if dist < tolerance:
		var strength = 1.0 - (dist / tolerance)
		rescue_voice.volume_db = linear_to_db(strength) + max_volume
		static_sound.volume_db = linear_to_db(1.0 - strength) + max_volume
		
		# --- WIN CONDITION ---
		# If they hold it steady near the target, count it as "heard"
		if strength > 0.9 and not has_won_this_night:
			_register_radio_discovery()
	else:
		rescue_voice.volume_db = -80
		static_sound.volume_db = max_volume

func _register_radio_discovery():
	has_won_this_night = true
	
	# Update the global count for the endings
	if GameManager.current_state == GameManager.State.DAY_1_EVENING:
		if GameManager.heard_radio_count == 0:
			GameManager.heard_radio_count = 1
			print("Radio: Night 1 Log Unlocked")
			
	elif GameManager.current_state == GameManager.State.DAY_2_EVENING:
		if GameManager.heard_radio_count == 1:
			GameManager.heard_radio_count = 2
			print("Radio: Night 2 Log Unlocked")
