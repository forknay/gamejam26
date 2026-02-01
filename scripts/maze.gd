extends Node2D

@onready var spawn = $Spawn
@onready var finish_area = $Finish 
const PLAYER_SCENE = preload("res://Scenes/maze_player.tscn")

var started = false
var deaths = 0 # Track deaths here
var current_player = null # Keep a reference to delete it later

signal level_cleared

func _input(event):
	# Only allow start if game is NOT running
	if event.is_action_pressed("start") and not started:
		spawn_player()
		started = true

func _ready():
	if finish_area:
		finish_area.reached_end.connect(_on_finish_line_reached)
	else:
		print("ERROR COULD NOT FIND FINISHAREA")

func _on_finish_line_reached():
	print("child said we won")
	level_cleared.emit()

func spawn_player():
	var player = PLAYER_SCENE.instantiate()
	player.position = spawn.position
	# Player tells maze he died, maze tells game_playlist manager 
	player.i_died.connect(_on_i_died)
	
	add_child(player)
	current_player = player # Save reference

func _on_i_died():
	deaths += 1
	print("Died! Total Deaths: ", deaths)
	
	# 1. Delete the dead player
	if current_player:
		current_player.queue_free()
	
	# 2. Reset the "started" flag so you can press D again
	started = false
	
	call_deferred("spawn_player")
	started = true
