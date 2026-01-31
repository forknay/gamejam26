extends CharacterBody2D

@export var speed := 130

var move_dir := Vector2.RIGHT

@onready var trail: Line2D = $Line2D

func _ready():
	trail.top_level = true
	trail.add_point(global_position)

func _physics_process(_delta):
	handle_input()

	velocity = move_dir * speed
	move_and_slide()

	if trail.get_point_count() == 0 \
	or trail.get_point_position(trail.get_point_count() - 1).distance_to(global_position) > 12:
		trail.add_point(global_position)
	
	var collided = move_and_slide()
	
	if collided:
		print("wall")
		get_tree().reload_current_scene() # Restart level

func handle_input():
	if Input.is_action_just_pressed("up") and move_dir != Vector2.DOWN:
		move_dir = Vector2.UP
	elif Input.is_action_just_pressed("down") and move_dir != Vector2.UP:
		move_dir = Vector2.DOWN
	elif Input.is_action_just_pressed("left") and move_dir != Vector2.RIGHT:
		move_dir = Vector2.LEFT
	elif Input.is_action_just_pressed("right") and move_dir != Vector2.LEFT:
		move_dir = Vector2.RIGHT
