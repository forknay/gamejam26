extends Node2D

signal please_reset_me

@onready var spawn = $Spawn
const PLAYER_SCENE = preload("res://scenes/maze_player.tscn")
var started = false
static var deaths = 0 # Need to set to 0 for each day


func game_over():
	if deaths == 1000:
		print("Resetting, game over")
	else:
		deaths += 1
		please_reset_me.emit()
func _input(event):
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.as_text())
		
	if event.is_action_pressed("start") and not started:
		started = true
		spawn_player()
func _ready():
	#spawn_player()
	pass

func spawn_player():
	var player = PLAYER_SCENE.instantiate()
	
	# Set the player's position to the Marker2D's position
	player.position = spawn.position
	
	add_child(player)
