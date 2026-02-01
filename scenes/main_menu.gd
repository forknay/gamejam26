# main_menu.gd
extends Control

func _ready():
	# Ensure the mouse is visible so they can click Play
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	# Start the game loop
	GameManager.start_new_game()
