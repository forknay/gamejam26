#extends Container
#
#@export var minigame_scene : PackedScene
#var current_game_instance : Node = null
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var game = minigame_scene.instantiate()
	#add_child(game)
#
#func spawn_new_game():
	#current_game_instance = minigame_scene.instantiate()
	#add_child(current_game_instance)
	#
	#current_game_instance.please_reset_me.connect(on_please_reset_me)
	#
#func on_please_reset_me():
	#if current_game_instance:
		#current_game_instance.queue_free()
	#await get_tree().process_frame
	#spawn_new_game()
	#print("container reset game")
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
