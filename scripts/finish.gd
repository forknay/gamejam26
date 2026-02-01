extends Area2D

signal reached_end

func _ready():
	self.body_entered.connect(self._on_body_entered)

func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		print("win")
		reached_end.emit()
