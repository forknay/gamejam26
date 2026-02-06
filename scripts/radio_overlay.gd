extends CanvasLayer

@export var night1_voice : AudioStream
@export var night2_voice : AudioStream

@onready var audio1 = $RadioGame/StaticSound
@onready var audio2 = $RadioGame/RescueVoice

func _ready():
	visible = false # Start hidden

func show_overlay():
	visible = true
	# Unlock mouse so you can click dials
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	AudioManager.mute_ambience()
	
	# Play static
	audio1.play()
	# Check for voice
	var stream_voice = null
	match GameManager.current_state:
		GameManager.State.DAY_1_EVENING:
			stream_voice = night1_voice
		GameManager.State.DAY_2_EVENING:
			stream_voice = night2_voice
	
	if stream_voice:
		audio2.stream = stream_voice
		audio2.play(0.0) # Restart

func hide_overlay():
	visible = false
	if audio1 or audio2:
		audio1.stop()
		audio2.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	AudioManager.unmute_ambience()
	
func _input(event):
	if visible:
		# Close on ESC or E
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact") or event.is_action_pressed("ui_select"):
			get_viewport().set_input_as_handled()
			hide_overlay()
