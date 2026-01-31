extends Node2D

# Only emit this if you want the COMPUTER to close the window (e.g., Win or Total Failure)
signal please_reset_me 

@onready var spawn = $Spawn
const PLAYER_SCENE = preload("res://scenes/maze_player.tscn")

var started = false
var deaths = 0 
var current_player = null # Track the active player so we can delete them

func _input(event):
	# Debug print (Keep or remove as needed)
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.as_text())
		
	# Check input, ensure game isn't already running
	if event.is_action_pressed("start") and not started:
		started = true
		spawn_player()

func spawn_player():
	var player = PLAYER_SCENE.instantiate()
	player.position = spawn.position
	
	# Connect the Player's signal to our local handler function
	# Make sure your Player script has: signal player_died
	player.i_died.connect(_on_i_died)
	
	add_child(player)
	current_player = player

func _on_i_died():
	deaths += 1
	print("Died! Total deaths: ", deaths)
	
	# 1. Delete the dead player object
	if current_player:
		current_player.queue_free()
	
	# 2. Check for "Total Failure" (The 1000 death limit)
	if deaths >= 1000:
		print("Max deaths reached. Closing Minigame.")
		please_reset_me.emit() # Tell Computer to kill this window
	else:
		# 3. Soft Reset: Just allow the player to start again
		print("Try again...")
		started = false 
		# If you want INSTANT respawn without pressing D, uncomment below:
		# call_deferred("spawn_player")
		# started = true
