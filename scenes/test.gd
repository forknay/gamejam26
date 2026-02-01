extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.start_dialogue(["Hello!", "I am a global box."])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
