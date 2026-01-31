extends Node2D

# --- CONFIG ---
var target_angle = 90.0  # The "Winning" angle (0 to 360)
var tolerance = 25.0     # How close you need to be
var max_volume = -15.0
# --- REFS ---
# If these paths fail, delete them and drag the nodes from the tree into the script!
@onready var static_sound = $"../StaticSound"
@onready var rescue_voice = $"../RescueVoice"
@onready var area_2d = $Area2D

# --- STATE ---
var is_dragging = false

func _ready():
	# Connect the input signal via code (safest method)
	area_2d.input_event.connect(_on_area_input)

func _on_area_input(_viewport, event, _shape_idx):
	# Detect if we clicked the knob
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed

func _input(event):
	# Stop dragging if we let go of the mouse anywhere
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false
		
	# Handle Rotation
	if is_dragging and event is InputEventMouseMotion:
		look_at(get_global_mouse_position())
		rotation_degrees += 90 # Remove this line if your knob points sideways by default!
		
		update_audio()

func update_audio():
	# 1. Get current angle (0-360)
	var current_rot = wrapf(rotation_degrees, 0, 360)
	
	# 2. Distance to target
	var dist = abs(current_rot - target_angle)
	if dist > 180: dist = 360 - dist # Handle wrap-around
		
	# 3. Mix Volume
	if dist < tolerance:
		# Close to target: Voice loud, Static quiet
		var strength = 1.0 - (dist / tolerance)
		rescue_voice.volume_db = linear_to_db(strength) + max_volume
		static_sound.volume_db = linear_to_db(1.0 - strength) + max_volume
	else:
		# Far away: Static loud, Voice silent
		rescue_voice.volume_db = -80
		static_sound.volume_db = max_volume
		
