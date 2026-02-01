# GameManager.gd (Autoload)
extends Node

enum State {
	INTRO_WAKEUP,
	DAY_1_WORK,
	DAY_1_EVENING,
	DAY_2_WORK,
	DAY_2_EVENING,
	DAY_3_WORK, # Added Day 3
	ENDING
}

var current_state = State.INTRO_WAKEUP
var transition_overlay : ColorRect
var canvas_layer : CanvasLayer
var ending_label : Label # New: To show ending text on screen
var heard_radio_count = 0
# Inside GameManager.gd

# Add this at the top to store the menu path
var menu_scene_path = "res://scenes/main_menu.tscn" # Adjust to your actual path
var world_scene_path = "res://scenes/game.tscn"      # Adjust to your actual path

func start_new_game():
	current_state = State.INTRO_WAKEUP
	heard_radio_count = 0
	get_tree().change_scene_to_file(world_scene_path)

func game_over(ending_type: String):
	await fade_out()
	
	var msg = ""
	match ending_type:
		"END: RESCUED": msg = "THE CHIP IS REMOVED.\nYOU ARE FREE."
		"END: STARVED": msg = "THE HUNTERS WERE BLOCKED.\nYOU DIED IN THE DARK, SAFE AND ALONE."
		"END: ALONE":   msg = "SIGNAL LOST.\nAI DEACTIVATED.\nSYSTEM FAILURE."
	
	ending_label.text = msg
	var tween = create_tween()
	tween.tween_property(ending_label, "modulate:a", 1.0, 2.0)
	
	await get_tree().create_timer(6.0).timeout
	
	# --- CHANGE HERE: Back to Menu instead of Reload ---
	ending_label.modulate.a = 0.0
	get_tree().change_scene_to_file(menu_scene_path)
func _ready():
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 
	add_child(canvas_layer)
	
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color.BLACK
	transition_overlay.color.a = 0.0
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	canvas_layer.add_child(transition_overlay)
	
	# Create a label for ending messages
	ending_label = Label.new()
	ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ending_label.set_anchors_preset(Control.PRESET_CENTER)
	ending_label.modulate.a = 0.0 # Start invisible
	canvas_layer.add_child(ending_label)


# --- TRANSITION LOGIC ---

func fade_out():
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, 1.0)
	await tween.finished

func fade_in():
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, 1.0)
	await tween.finished
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func advance_state(new_state):
	await fade_out()
	current_state = new_state
	get_tree().reload_current_scene()
	
	# Wait a bit for scene to settle
	await get_tree().create_timer(0.5).timeout
	fade_in()

func is_night() -> bool:
	return current_state in [State.INTRO_WAKEUP, State.DAY_1_EVENING, State.DAY_2_EVENING]
