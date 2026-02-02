# AudioManager.gd
extends Node

@onready var ambience = $AmbienceTrack

# We use a "Tween" to fade sound in/out smoothly instead of abrupt cuts
func mute_ambience():
	var tween = create_tween()
	tween.tween_property(ambience, "volume_db", -80.0, 1.0) # Fade to silence in 1 sec

func unmute_ambience():
	# Only play if it's not already playing (or just restore volume)
	if not ambience.playing:
		ambience.play()
	
	var tween = create_tween()
	tween.tween_property(ambience, "volume_db", 0.0, 1.0) # Fade back to normal

func stop_completely():
	ambience.stop()
