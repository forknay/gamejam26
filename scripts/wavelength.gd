extends Node2D

@onready var target_line = $TargetWave
@onready var player_line = $PlayerWave
@onready var input_box = $InputBox
@onready var handle = $InputBox/DragPoint

@export var points_count := 250 
@export var wave_width := 800.0
@export var scroll_speed := 3.0  

# Configuration Ranges
var min_f = 0.5; var max_f = 3.0
var min_a = 10.0; var max_a = 100.0

# State Variables
var target_freq : float
var target_amp : float
var phase_shift := 0.0
var is_won := false
var is_dragging := false

func _ready():
	# 1. Randomize goals
	target_freq = randf_range(min_f, max_f)
	target_amp = randf_range(min_a, max_a)
	
	# 2. Visual Polish
	target_line.antialiased = true
	player_line.antialiased = true
	
	# 3. Safety Check: Ensure the handle doesn't block the mouse
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	if is_won: return 
	
	# Update scrolling animation
	phase_shift += delta * scroll_speed
	
	# Handle dragging and calculations
	handle_mouse_input()
	
	# Mapping handle position to wave values
	var box_size_adj = input_box.size - handle.size
	# Prevent division by zero if box size isn't set
	if box_size_adj.x > 0 and box_size_adj.y > 0:
		var percent_x = handle.position.x / box_size_adj.x
		var percent_y = handle.position.y / box_size_adj.y
		
		var current_freq = lerp(min_f, max_f, percent_x)
		var current_amp = lerp(min_a, max_a, percent_y)
		
		# Draw the waves
		draw_wave(target_line, target_freq, target_amp, phase_shift)
		draw_wave(player_line, current_freq, current_amp, phase_shift)
		
		# Check if the player won
		check_for_win(current_freq, current_amp)

func handle_mouse_input():
	# 1. Get the mouse position relative to the InputBox
	var local_mouse = input_box.get_local_mouse_position()
	
	# 2. Check if we just started clicking inside the box
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var rect = Rect2(Vector2.ZERO, input_box.size)
		if rect.has_point(local_mouse) or is_dragging:
			is_dragging = true
	else:
		is_dragging = false

	# 3. If dragging, update the point and the WAVES
	if is_dragging:
		# Center the handle on the mouse
		var target_pos = local_mouse - (handle.size / 2)
		
		# Keep it inside the box
		handle.position.x = clamp(target_pos.x, 0, input_box.size.x - handle.size.x)
		handle.position.y = clamp(target_pos.y, 0, input_box.size.y - handle.size.y)
		
		# FORCE update the wave variables immediately
		update_wave_values()

func update_wave_values():
	var box_size_adj = input_box.size - handle.size
	if box_size_adj.x > 0 and box_size_adj.y > 0:
		var percent_x = handle.position.x / box_size_adj.x
		var percent_y = handle.position.y / box_size_adj.y
		
		var current_freq = lerp(min_f, max_f, percent_x)
		var current_amp = lerp(min_a, max_a, percent_y)
		
		draw_wave(player_line, current_freq, current_amp, phase_shift)
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
		# If they found the spot and let go, they win!
		if not is_dragging:
			win_sequence()
	else:
		player_line.default_color = Color.CYAN

func win_sequence():
	is_won = true
	# Lock the player wave to exactly match the target visually
	draw_wave(player_line, target_freq, target_amp, phase_shift)
	
	print("Match Successful! No UI found, quitting...")
	get_tree().quit()
