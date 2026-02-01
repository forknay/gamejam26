extends SubViewport

# Drag your minigame scenes (.tscn) into this list in the Inspector
@export var playlist: Array[PackedScene]

var current_index = 0
var current_game = null

func _ready():
	print("Viewport Children Count: ", get_child_count())
	
	# Debug: See what node is actually inside
	if get_child_count() > 0:
		print("Existing node found: ", get_child(0).name)
	
	# SAFETY CHANGE:
	# Only treat it as an existing game if it's NOT a Camera or helper node
	if get_child_count() > 0 and get_child(0) is Node2D: 
		print("Hooking up existing game...")
		current_game = get_child(0)
		connect_signals(current_game)
	else:
		print("Viewport empty (or only has tools). Spawning Level 0...")
		load_level(0)

func load_level(index):
	# Check if we ran out of games
	if index >= playlist.size():
		print("ALL GAMES FINISHED!")
		return

	# 1. Instantiate the next game
	var game_scene = playlist[index]
	current_game = game_scene.instantiate()
	add_child(current_game)
	
	# 2. Connect the signals
	connect_signals(current_game)

func connect_signals(game_node):
	# This listens for the signal you added in Step 1
	if game_node.has_signal("level_cleared"):
		game_node.level_cleared.connect(_on_level_cleared)

func _on_level_cleared():
	print("Level won! Loading next...")
	
	# 1. Delete the old game
	if current_game:
		current_game.queue_free()
		
	# 2. Wait a frame for cleanup
	await get_tree().process_frame
	
	# 3. Load the next one
	current_index += 1
	load_level(current_index)
