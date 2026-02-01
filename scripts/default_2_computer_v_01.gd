extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	cam.make_current()
	anim.play(anim.get_animation_list()[0])
