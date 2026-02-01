extends Area2D

@export var max_hp := 3
var hp := max_hp

func _ready():
	hp = max_hp
	position = Vector2(960, 540)
	add_to_group("player") # ensures we can find it safely

func take_damage(amount := 1):
	hp -= amount
	print("HP:", hp)
	if hp <= 0:
		die()

func die():
	print("PLAYER DEAD")
	queue_free()
