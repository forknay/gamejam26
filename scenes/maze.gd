extends Node2D

@onready var spawn = $Spawn
const PLAYER_SCENE = preload("res://scenes/maze_player.tscn")

func _ready():
	spawn_player()

func spawn_player():
	var player = PLAYER_SCENE.instantiate()
	
	# Set the player's position to the Marker2D's position
	player.position = spawn.position
	
	add_child(player)
