extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cam: Camera3D = $Default_t_Window

signal anim_done

func window_anim():
	cam.make_current()
	anim.play(anim.get_animation_list()[0])
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func window_anim_back():
	cam.make_current()
	anim.play_backwards(anim.get_animation_list()[0])
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
func _on_animation_finished(anim_name):
	anim_done.emit()
	print("emitted")
