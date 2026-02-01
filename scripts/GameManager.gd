# GameManager.gd (Autoload)
extends Node

# --- STATE DEFINITIONS ---
enum State {
	INTRO_WAKEUP,    # Night 0
	DAY_1_WORK,      # Day 1 Morning
	DAY_1_EVENING,   # Day 1 Night
	DAY_2_WORK,
	DAY_2_EVENING,
	ENDING
}

var current_state = State.INTRO_WAKEUP
var transition_overlay : ColorRect
var canvas_layer : CanvasLayer

func _ready():
	# Create a persistent black screen for fading
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Always on top
	add_child(canvas_layer)
	
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color.BLACK
	transition_overlay.color.a = 0.0 # Start invisible
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE # Let clicks through when invisible
	canvas_layer.add_child(transition_overlay)

# --- TRANSITION LOGIC ---
func advance_state(new_state):
	# 1. Block input & Fade Out
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP # Block clicks
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, 1.0) # Fade to Black
	await tween.finished
	
	# 2. Update State & Reload
	current_state = new_state
	get_tree().reload_current_scene()
	
	# 3. Wait for scene to load then Fade In
	await get_tree().create_timer(0.5).timeout
	fade_in()

func fade_in():
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, 1.0)
	await tween.finished
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

# --- HELPER ---
func is_night() -> bool:
	return current_state in [State.INTRO_WAKEUP, State.DAY_1_EVENING, State.DAY_2_EVENING]
