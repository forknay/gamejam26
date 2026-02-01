extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cam: Camera3D = $Default_t_Radio

signal anim_done

func radio_anim():
	cam.make_current()
	anim.play(anim.get_animation_list()[0])
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func radio_anim_back():
	cam.make_current()
	anim.play_backwards(anim.get_animation_list()[0])

func _on_animation_finished(anim_name):
	anim_done.emit()
	print("emitted")
