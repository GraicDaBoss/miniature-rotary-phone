class_name bodypulse
extends Node

@export var core_meshes: Array[Node3D] = []
@export var body_light: OmniLight3D
@export var brain: CreatureBrain

var base_energy: float = 1.5
var pulse_timer: float = 0.0


const COLOUR_HAPPY  = Color(0.1, 0.9, 0.8)   # teal
const COLOUR_CURIOUS = Color(0.9, 0.85, 0.1)  # yellow
const COLOUR_ANGRY  = Color(1.0, 0.15, 0.1)   # red

var current_colour: Color = COLOUR_HAPPY

func _process(delta):
	pulse_timer += delta

	# Smoothly lerp toward target emotion colour
	var target_colour: Color
	if brain.is_angry():
		target_colour = COLOUR_ANGRY
	elif brain.is_curious():
		target_colour = COLOUR_CURIOUS
	else:
		target_colour = COLOUR_HAPPY

	current_colour = current_colour.lerp(target_colour, delta * 2.0)
	body_light.light_color = current_colour

	# Pulse rate and intensity
	var rate = lerp(1.0, 4.0, brain.energy)
	var pulse = (sin(pulse_timer * rate) + 1.0) / 1.50

	# Angry state pulses harder and faster
	var intensity_multiplier = 7.0
	if brain.is_angry():
		intensity_multiplier = 14.0

	body_light.light_energy = base_energy + pulse * brain.energy * intensity_multiplier

	# Scale all segments
	var scale_val = 1.0 + pulse * 0.3 * brain.energy
	for mesh in core_meshes:
		if is_instance_valid(mesh):
			mesh.scale = Vector3(scale_val, scale_val, scale_val)

	if brain.is_performing:
		var sway = sin(pulse_timer * rate * 0.5) * brain.energy * 0.15
		get_parent().rotation.z = sway
