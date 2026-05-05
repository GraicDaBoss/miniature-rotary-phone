class_name Bell
extends Node3D

enum Note { C, D, E, F, G, A, B }

@export var bell_sample: AudioStream
@export var note: Note = Note.C
@export var particles: GPUParticles3D

const COOLDOWN_DURATION: float = 8.0

var pitch_map = {
	Note.C: 1.0,
	Note.D: 1.122,
	Note.E: 1.260,
	Note.F: 1.335,
	Note.G: 1.498,
	Note.A: 1.682,
	Note.B: 1.888,
}

var colour_map = {
	Note.C: Color(0.4, 0.8, 1.0),
	Note.D: Color(0.5, 1.0, 0.8),
	Note.E: Color(0.8, 1.0, 0.5),
	Note.F: Color(0.6, 0.5, 1.0),
	Note.G: Color(1.0, 0.8, 0.4),
	Note.A: Color(1.0, 0.5, 0.8),
	Note.B: Color(1.0, 1.0, 0.6),
}

@onready var audio = $AudioStreamPlayer3D
@onready var glow = $GlowLight
@onready var mesh = $Mesh


var float_timer: float = 0.0
var base_y: float = 0.0
var cooldown: float = 0.0
var on_cooldown: bool = false
var collected: bool = false

func _ready():
	base_y = position.y
	audio.stream = bell_sample
	audio.pitch_scale = pitch_map[note]
	glow.light_color = colour_map[note]
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = colour_map[note]
	mat.emission_energy_multiplier = 2.0
	mat.albedo_color = colour_map[note]
	mesh.material = mat
	# Set particle colour to match note
	if particles:
		var particle_mat = particles.process_material as ParticleProcessMaterial
		if particle_mat:
			particle_mat.color = colour_map[note]

func _process(delta):
	float_timer += delta
	position.y = base_y + sin(float_timer * 1.2) * 0.15
	if collected:
		cooldown += delta
		if cooldown >= COOLDOWN_DURATION:
			collected = false
			on_cooldown = false
			cooldown = 0.0

func ring():
	print("ring() called")
	audio.play()
	if particles:
		particles.restart()
	var tween = create_tween()
	tween.tween_property(glow, "light_energy", 4.0, 0.1)
	tween.tween_property(glow, "light_energy", 1.5, 0.8)

func collect():
	if collected:
		return
	collected = true
	
	await get_tree().create_timer(1.5).timeout
	if not is_instance_valid(self):
		return
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.4)
	tween.tween_property(glow, "light_energy", 0.0, 0.4)
	tween.tween_callback(queue_free)

func is_available() -> bool:
	return not collected

func get_note() -> Note:
	return note
