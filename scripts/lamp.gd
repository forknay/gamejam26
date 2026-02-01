extends MeshInstance3D

# This looks for a child node named exactly "OmniLight3D"
@onready var light_node = $Alarm 

var is_alarm_on: bool = false
var tween: Tween

func _ready():
	pass

func _input(_event):
	pass

func start_alarm():
	is_alarm_on = true
	_run_pulse()

func stop_alarm():
	is_alarm_on = false
	if tween:
		tween.kill()
	# Reset values to 0
	_set_energy(0.0)

func _run_pulse():
	if not is_alarm_on: return
	
	var mat = get_active_material(0)
	if not mat: return

	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Pulse ON
	tween.tween_method(_set_energy, 0.0, 5.0, 0.2)
	# Pulse OFF
	tween.tween_method(_set_energy, 5.0, 0.0, 0.8)
	
	# Loop the function
	tween.finished.connect(_run_pulse)

# Helper function to update both the material and the light node at once
func _set_energy(value: float):
	# Update the bulb glow
	var mat = get_active_material(0)
	if mat:
		mat.emission_energy_multiplier = value
	
	# Update the room light
	if light_node:
		light_node.light_energy = value
