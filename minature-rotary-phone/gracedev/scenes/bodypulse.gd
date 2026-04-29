class_name bodypulse extends Node

@export var core_mesh: CSGSphere3D
@export var body_light: OmniLight3D
@export var brain: CreatureBrain

var base_energy: float = 1.5
var pulse_timer: float = 0.0

func _process(delta):
	pulse_timer += delta

	var rate = lerp(1.0, 4.0, brain.energy)
	var pulse = (sin(pulse_timer * rate) + 1.0) / 2.0  # 0 to 1

	
	body_light.light_energy = base_energy + pulse * brain.energy * 2.0

	
	var scale_val = 1.0 + pulse * 0.2 * brain.energy
	core_mesh.scale = Vector3(scale_val, scale_val, scale_val)

	# is this working???
	if brain.is_performing:
		var sway = sin(pulse_timer * rate * 0.5) * brain.energy * 0.15
		get_parent().rotation.z = sway
