extends Area2D

const ANGLES := {
	"up": 0.0,
	"right": PI / 2,
	"down": PI,
	"left": -PI / 2,
}

@export var pop_scale := 1.15

func _ready():
	rotation = ANGLES["up"]
	add_to_group("shield")

func _process(_delta):
	if Input.is_action_just_pressed("up"):
		snap_to(ANGLES["up"])
	elif Input.is_action_just_pressed("right"):
		snap_to(ANGLES["right"])
	elif Input.is_action_just_pressed("down"):
		snap_to(ANGLES["down"])
	elif Input.is_action_just_pressed("left"):
		snap_to(ANGLES["left"])

func snap_to(angle: float) -> void:
	rotation = angle

	# Tiny pop
	scale = Vector2.ONE * pop_scale
	await get_tree().process_frame
	scale = Vector2.ONE
