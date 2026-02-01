extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cam: Camera3D = $Opening_cam

func _ready():
	cam.make_current()
	anim.play(anim.get_animation_list()[0])
