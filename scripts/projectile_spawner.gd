extends Node2D

@export var projectile_scene: PackedScene
@export var spawn_distance := 600.0
@export var spawn_interval := 0.7

const DIRECTIONS := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

func _ready():
	if projectile_scene == null:
		push_error("Projectile scene not assigned!")
		return

	spawn_loop()

func spawn_loop() -> void:
	while true:
		var dir = DIRECTIONS.pick_random()
		spawn(dir)
		await get_tree().create_timer(spawn_interval).timeout

func spawn(dir: Vector2):
	var p = projectile_scene.instantiate()
	p.position = Vector2(960, 540) + dir * spawn_distance
	p.velocity = -dir
	get_parent().add_child(p)
