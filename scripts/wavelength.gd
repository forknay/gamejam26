extends Node2D

@onready var target_line = $TargetWave
@onready var player_line = $PlayerWave
@onready var input_box = $InputBox
@onready var handle = $InputBox/DragPoint

@export var points_count := 250 
@export var wave_width := 800.0
@export var scroll_speed := 3.0
@export var handle_speed := 200.0 # New: Speed of the WASD movement

# Configuration Ranges
var min_f = 0.5; var max_f = 3.0
var min_a = 10.0; var max_a = 100.0

# State Variables
var target_freq : float
var target_amp : float
var phase_shift := 0.0
var is_won := false
var is_moving := false # Replaces is_dragging

func _ready():
	# 1. Randomize goals
	randomize()
	target_freq = randf_range(min_f, max_f)
	target_amp = randf_range(min_a, max_a)
	
	# 2. Visual Polish
	target_line.antialiased = true
	player_line.antialiased = true
	
	# 3. Handle setup (Start in center)
	if input_box.size != Vector2.ZERO:
		handle.position = (input_box.size / 2) - (handle.size / 2)

func _process(delta):
	if is_won: return 
	
	# Update scrolling animation
	phase_shift += delta * scroll_speed
	
	# Handle WASD and calculations
	handle_keyboard_input(delta)
	
	# Mapping handle position to wave values
	update_wave_values()

func handle_keyboard_input(delta):
	# 1. Get input vector (using the actions you defined in your maze game)
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		is_moving = true
		
		# 2. Move the handle
		handle.position += direction * handle_speed * delta
		
		# 3. Clamp inside box
		handle.position.x = clamp(handle.position.x, 0, input_box.size.x - handle.size.x)
		handle.position.y = clamp(handle.position.y, 0, input_box.size.y - handle.size.y)
	else:
		is_moving = false

func update_wave_values():
	var box_size_adj = input_box.size - handle.size
	
	if box_size_adj.x > 0 and box_size_adj.y > 0:
		var percent_x = handle.position.x / box_size_adj.x
		var percent_y = handle.position.y / box_size_adj.y
		
		var current_freq = lerp(min_f, max_f, percent_x)
		var current_amp = lerp(min_a, max_a, percent_y)
		
		# Draw waves
		draw_wave(target_line, target_freq, target_amp, phase_shift)
		draw_wave(player_line, current_freq, current_amp, phase_shift)
		
		# Check win
		check_for_win(current_freq, current_amp)

func draw_wave(line: Line2D, freq: float, amp: float, offset: float):
	line.clear_points()
	for i in range(points_count):
		var x = (float(i) / points_count) * wave_width
		# Multiplier (0.02) ensures long wavelengths
		var y = sin((x * (freq * 0.02)) + offset) * amp
		line.add_point(Vector2(x, y))

func check_for_win(f: float, a: float):
	var freq_match = abs(f - target_freq) < 0.12
	var amp_match = abs(a - target_amp) < 6.0

	if freq_match and amp_match:
		player_line.default_color = Color.GOLD 
		
		# WIN CONDITION: Matches AND player stopped moving keys
		if not is_moving:
			win_sequence()
	else:
		player_line.default_color = Color.CYAN

func win_sequence():
	is_won = true
	# Lock the player wave to exactly match the target visually
	draw_wave(player_line, target_freq, target_amp, phase_shift)
	
	print("Match Successful!")
	# Signal up to the Manager that we won
	if has_signal("level_cleared"):
		emit_signal("level_cleared")
