extends Area2D

@export var speed := 260.0
var velocity := Vector2.ZERO
var dead := false

func _ready():
	add_to_group("projectile")
	monitoring = true
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	if dead:
		return
	position += velocity * speed * delta

func _on_area_entered(area: Area2D) -> void:
	print("Hit area:", area.name, "Groups:", area.get_groups())
	if dead:
		return

	# Shield blocks
	if area.is_in_group("shield"):
		die()
		return

	# Hit player
	if area.is_in_group("player"):
		area.take_damage(1)
		die()
		return

func die():
	dead = true
	monitoring = false
	visible = false
	call_deferred("queue_free")
