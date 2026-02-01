extends CanvasLayer

# Connect these to your nodes in the inspector or use standard naming
@onready var text_box = $DialogueOverlay/TextBox
@onready var dialogue_label = $DialogueOverlay/TextBox/MarginContainer/DialogueText

# Data
var dialogue_lines: Array[String] = []
var current_line_index = 0

var is_typing = false
var can_advance = false

func _ready():
	# Hide the box when the game starts
	text_box.visible = false

func start_dialogue(lines: Array[String]):
	dialogue_lines = lines
	current_line_index = 0
	text_box.visible = true
	show_text()

func show_text():
	var next_text = dialogue_lines[current_line_index]
	dialogue_label.text = next_text
	
	# Reset visibility for the typing effect
	dialogue_label.visible_ratio = 0.0
	is_typing = true
	
	# Use a Tween to animate the text appearing (Typewriter effect)
	var tween = get_tree().create_tween()
	# Calculate duration based on text length (e.g., 0.05 seconds per character)
	var duration = next_text.length() * 0.05 
	
	tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	
	# When animation finishes
	tween.finished.connect(func(): 
		is_typing = false
		can_advance = true
	)

func _unhandled_input(event):
	# Check for "ui_accept" (usually Space or Enter) or a mouse click
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("click")) and text_box.visible:
		
		if is_typing:
			# OPTIONAL: If player clicks while typing, skip animation and show full text immediately
			var tween = get_tree().create_tween()
			tween.kill() # Stop the current tween
			dialogue_label.visible_ratio = 1.0
			is_typing = false
			can_advance = true
			
		elif can_advance:
			current_line_index += 1
			if current_line_index >= dialogue_lines.size():
				# End of dialogue
				text_box.visible = false
				can_advance = false
			else:
				show_text()
