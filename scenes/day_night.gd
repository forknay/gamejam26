extends Node3D

@onready var sunMoon = $SunMoon
@onready var color_light = $Light
@onready var world_env = %WorldEnvironment

var currentMode : String = "day"

func _ready():
	if world_env == null:
		print("CRITICAL: The script cannot find a node named WorldEnvironment!")
	elif world_env.environment == null:
		print("CRITICAL: The node exists, but you forgot to create an Environment resource in the Inspector!")
	else:
		print("All systems go! Environment found.")
		 
func _input(_event):
	#if event.is_action_pressed("ui_right"):
	#	toggleCycle()
	pass
func toggleCycle():
	# Use single '=' for assignment!
	if currentMode == "day":
		currentMode = "night"
	else:
		currentMode = "day"
	
	apply_mode()
func setNight(b):
	if b:
		currentMode = "night"
	else:
		currentMode = "day"
	apply_mode()
	
func apply_mode():
	# Get the actual resource from the node
	
	if world_env == null or world_env.environment == null:
		print("Missing WorldEnvironment or Environment Resource!")
		return

	# 1. Get the Environment resource
	var envir = world_env.environment
	
	# 2. Get the Sky and its Material (where colors live)
	# This assumes you have a 'ProceduralSkyMaterial' set up!
	var sky_mat = envir.sky.sky_material as ProceduralSkyMaterial

	if sky_mat == null:
		print("Your Sky needs a ProceduralSkyMaterial to change colors!")
		return
	if currentMode == "day":
		sunMoon.light_color = Color("da7918")
		color_light.light_color = Color("da7918")# Warm White
		sunMoon.light_energy = 1.0
		sky_mat.sky_horizon_color = Color("8f5e2c")
		# Adjust the sky background
		
		
	else: # Night Mode
		sunMoon.light_color = Color(0.2, 0.3, 0.8) # Deep Blue
		color_light.light_color = Color(0.2, 0.3, 0.8)
		sunMoon.light_energy = 0.2
		sky_mat.sky_horizon_color = Color(0.062, 0.188, 0.556, 1.0)

		# Darken the world ambiently
		
