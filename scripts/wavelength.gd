extends Node2D

@onready var target_line = $TargetWave
@onready var player_line = $PlayerWave
@onready var freq_slider = $FreqSlider
@onready var button = $Button
@onready var amp_slider = $AmpSlider

@export var points_count := 250 
@export var wave_width := 800.0
@export var scroll_speed := 3.0  

# --- TARGET VARIABLES ---
var target_freq : float
var target_amp : float

var phase_shift := 0.0
var is_won := false

func _ready():
	# Randomize both Frequency and Amplitude goals
	target_freq = randf_range(0.5, 3.0)
	target_amp = randf_range(20.0, 90.0)
	
	# Match slider ranges
	freq_slider.min_value = 0.5
	freq_slider.max_value = 3.0
	amp_slider.min_value = 10.0
	amp_slider.max_value = 100.0
	
	target_line.antialiased = true
	player_line.antialiased = true

func _process(delta):
	if is_won: return 
		
	phase_shift += delta * scroll_speed
	
	# Get values from both sliders
	var current_freq = freq_slider.value
	var current_amp = amp_slider.value
	
	draw_wave(target_line, target_freq, target_amp, phase_shift)
	draw_wave(player_line, current_freq, current_amp, phase_shift)
	
	check_for_win(current_freq, current_amp)

# Added 'amp' as a parameter to the draw function
func draw_wave(line: Line2D, freq: float, amp: float, offset: float):
	line.clear_points()
	for i in range(points_count):
		var x = (float(i) / points_count) * wave_width
		# Math now uses the dynamic amplitude
		var y = sin((x * (freq * 0.02)) + offset) * amp
		line.add_point(Vector2(x, y))

func check_for_win(current_freq: float, current_amp: float):
	var freq_diff = abs(current_freq - target_freq)
	var amp_diff = abs(current_amp - target_amp)
	
	# Both must be within tolerance to "highlight" the wave
	# Tolerance for Amp is higher (5.0) because the scale is 10-100
	if freq_diff < 0.1 and amp_diff < 5.0:
		player_line.default_color = Color.GOLD 
		if button.button_pressed: 
			win_sequence()
	else:
		player_line.default_color = Color.CYAN

func win_sequence():
	is_won = true
	# Snap player wave to perfect values
	draw_wave(player_line, target_freq, target_amp, phase_shift) 
	print("win")
	get_tree().quit()	
