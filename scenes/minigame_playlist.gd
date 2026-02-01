extends SubViewport

# Signal to tell computer.gd that we are done
signal sequence_finished 

var playlist: Array[PackedScene] = []
var current_index = 0
var current_active_node = null

func _ready():
	pass

# --- PLAYLIST LOGIC ---
func start_game_sequence(games: Array[PackedScene]):
	clear_screen()
	playlist = games
	current_index = 0
	
	if playlist.size() > 0:
		load_level(0)

func load_level(index):
	# CHECK: Are we out of games?
	if index >= playlist.size():
		print("Viewport: Playlist complete.")
		sequence_finished.emit() # <--- CRITICAL: Triggers the "Good Job" dialogue
		return

	# Load the next game
	var game_scene = playlist[index]
	current_active_node = game_scene.instantiate()
	add_child(current_active_node)
	
	# Listen for the win signal
	if current_active_node.has_signal("level_cleared"):
		current_active_node.level_cleared.connect(_on_level_cleared)

func _on_level_cleared():
	print("Viewport: Level won. Cleaning up...")
	if current_active_node:
		current_active_node.queue_free()
	
	await get_tree().process_frame
	
	current_index += 1
	load_level(current_index)

# --- HELPER LOGIC ---
func show_single_scene(scene: PackedScene):
	clear_screen()
	if scene:
		current_active_node = scene.instantiate()
		add_child(current_active_node)

func clear_screen():
	for child in get_children():
		child.queue_free()
	current_active_node = null
