extends CanvasLayer

@onready var text_box = $DialogueOverlay/TextBox
@onready var dialogue_label = $DialogueOverlay/TextBox/MarginContainer/DialogueText
@onready var choice_container = $DialogueOverlay/ChoiceContainer
@onready var e_corner = $DialogueOverlay/e_corner

var dialogue_lines: Array = []
var current_line_index = 0
var is_typing = false
var can_advance = false
var custom_font = load("res://Assets/Fonts/insanity.ttf")
# Ending choices
var pending_choices: Array = []
var pending_callback: Callable

func _ready():
	text_box.visible = false
	choice_container.visible = false
	e_corner.visible = false

# Accepts choices AND a "callback" function to run when done
func start_dialogue(lines: Array, choices: Array = [], callback: Callable = Callable()):
	dialogue_lines = lines
	pending_choices = choices
	pending_callback = callback
	
	current_line_index = 0
	text_box.visible = true
	choice_container.visible = false 
	e_corner.visible = true
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
		
	if (event.is_action_pressed("back") or event.is_action_pressed("ui_accept")) and text_box.visible:
		if is_typing:
			# Skip typing animation
			var tween = get_tree().create_tween()
			tween.kill()
			dialogue_label.visible_ratio = 1.0
			is_typing = false
			can_advance = true
			
		elif can_advance:
			current_line_index += 1
			if current_line_index >= dialogue_lines.size():				
				if pending_choices.size() > 0:
					# Case A: Show Buttons
					show_choices()
				else:
					# Case B: Standard Dialogue Finished
					close_dialogue()
					
					if pending_callback.is_valid():
						pending_callback.call() 
			else:
				# Show next line
				show_text()

func show_choices():
	can_advance = false 
	choice_container.visible = true
	
	for child in choice_container.get_children():
		child.queue_free()
	
	for i in range(pending_choices.size()):
		var btn = Button.new()
		btn.add_theme_font_override("font", custom_font)
		btn.add_theme_font_size_override("font_size", 24)
		btn.text = pending_choices[i]
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
		btn.add_theme_stylebox_override("normal", style)
		
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_choice_clicked.bind(i))
		choice_container.add_child(btn)

func _on_choice_clicked(index):
	choice_container.visible = false
	close_dialogue()
	if pending_callback.is_valid():
		pending_callback.call(index)

func close_dialogue():
	text_box.visible = false
	can_advance = false
	e_corner.visible = false
