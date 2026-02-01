extends SubViewport

var playlist: Array[PackedScene] = []
var current_index = 0
var current_active_node = null

func _ready():
	# Do nothing. We wait for the Computer Script to tell us what to play.
	pass

# --- FUNCTION 1: PLAY A PLAYLIST (Day Mode) ---
func start_game_sequence(games: Array[PackedScene]):
	clear_screen() # Wipe anything existing
	
	playlist = games
	current_index = 0
	
	if playlist.size() > 0:
		load_level(0)

func load_level(index):
	# Safety check
	if index >= playlist.size():
		print("Viewport: All work finished.")
		return

	# 1. Spawn Game
	var game_scene = playlist[index]
	current_active_node = game_scene.instantiate()
	add_child(current_active_node)
	
	# 2. Listen for 'Win' Signal
	# IMPORTANT: Your minigame root node MUST have a signal called 'level_cleared'
	if current_active_node.has_signal("level_cleared"):
		current_active_node.level_cleared.connect(_on_level_cleared)

func _on_level_cleared():
	print("Viewport: Level Complete. Loading next...")
	
	# 1. Cleanup
	if current_active_node:
		current_active_node.queue_free()
	
	# 2. Wait one frame to prevent errors
	await get_tree().process_frame
	
	# 3. Next
	current_index += 1
	load_level(current_index)

# --- FUNCTION 2: SHOW ONE STATIC IMAGE (Night/Static Mode) ---
func show_single_scene(scene: PackedScene):
	clear_screen()
	if scene:
		current_active_node = scene.instantiate()
		add_child(current_active_node)

# --- HELPER ---
func clear_screen():
	for child in get_children():
		child.queue_free()
	current_active_node = null
