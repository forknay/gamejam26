extends CanvasLayer

@onready var text_box = $DialogueOverlay/TextBox
@onready var dialogue_label = $DialogueOverlay/TextBox/MarginContainer/DialogueText
@onready var choice_container = $DialogueOverlay/ChoiceContainer

var dialogue_lines: Array = []
var current_line_index = 0
var is_typing = false
var can_advance = false

# Storage for the choices to show at the end
var pending_choices: Array = []
var pending_callback: Callable

func _ready():
	text_box.visible = false
	choice_container.visible = false

# Updated Function: Now accepts choices and a "callback" function
func start_dialogue(lines: Array, choices: Array = [], callback: Callable = Callable()):
	dialogue_lines = lines
	pending_choices = choices
	pending_callback = callback
	
	current_line_index = 0
	text_box.visible = true
	choice_container.visible = false # Hide choices initially
	show_text()

func show_text():
	var next_text = dialogue_lines[current_line_index]
	dialogue_label.text = next_text
	dialogue_label.visible_ratio = 0.0
	is_typing = true
	
	var tween = get_tree().create_tween()
	var duration = next_text.length() * 0.03 
	tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	
	tween.finished.connect(func(): 
		is_typing = false
		can_advance = true
	)

func _unhandled_input(event):
	if not text_box.visible:
		return
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and text_box.visible:
		if is_typing:
			# Skip typing
			var tween = get_tree().create_tween()
			tween.kill()
			dialogue_label.visible_ratio = 1.0
			is_typing = false
			can_advance = true
			
		elif can_advance:
			current_line_index += 1
			if current_line_index >= dialogue_lines.size():
				# Text finished. Do we have choices?
				if pending_choices.size() > 0:
					show_choices()
				else:
					close_dialogue()
			else:
				show_text()

func show_choices():
	can_advance = false # Stop Spacebar from breaking things
	choice_container.visible = true
	
	# Clear old buttons
	for child in choice_container.get_children():
		child.queue_free()
	
	# Create new buttons
	for i in range(pending_choices.size()):
		var btn = Button.new()
		btn.text = pending_choices[i]
		
		btn.focus_mode = Control.FOCUS_NONE
		# Connect click to our handler, passing the index
		btn.pressed.connect(_on_choice_clicked.bind(i))
		choice_container.add_child(btn)

func _on_choice_clicked(index):
	choice_container.visible = false
	close_dialogue()
	
	# Trigger the logic back in the World script
	if pending_callback.is_valid():
		pending_callback.call(index)

func close_dialogue():
	text_box.visible = false
	can_advance = false
