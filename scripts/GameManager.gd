extends Node

enum State {NIGHT_ALARM_START, DAY_WORK, NIGHT_CHILL, GOOD_END, BAD_END}

var current_day := 0
var current_state = State.NIGHT_ALARM_START

# Flags for progression
var flags = {
	"alarm_turned_off": false,
}

func advance_sequence():
	match current_state:
		State.NIGHT_ALARM_START:
			current_state = State.DAY_WORK
			current_day = 1
			# Reload the bedroom to apply Morning lighting
			get_tree().reload_current_scene()
		State.DAY_WORK:
			current_state = State.NIGHT_CHILL
			get_tree().reload_current_scene()
		State.NIGHT_CHILL:
			current_state = State.DAY_WORK
			current_day += 1
			get_tree().reload_current_scene()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
