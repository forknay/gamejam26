extends CanvasLayer

@onready var audio1 = $RadioGame/StaticSound
@onready var audio2 = $RadioGame/RescueVoice


func _ready():
	visible = false # Start hidden

func show_overlay():
	visible = true
	# Unlock mouse so you can click dials
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func hide_overlay():
	visible = false
	if audio1 or audio2:
		audio1.stop()
		audio2.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if visible:
		# Close on ESC or E
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			hide_overlay()
