class_name Bell
extends Node3D

enum Note { C, D, E, F, G, A, B }

@export var bell_sample: AudioStream
@export var note: Note = Note.C

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

# Floating motion
var float_timer: float = 0.0
var base_y: float = 0.0

# Cooldown system (reuses "collected")
var cooldown: float = 0.0
var on_cooldown: bool = false
var collected: bool = false  # NOW means "temporarily unavailable"

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

func _process(delta):
	# Floating animation
	float_timer += delta
	position.y = base_y + sin(float_timer * 1.2) * 0.15
	
	# Cooldown handling
	if collected:
		cooldown += delta
		if cooldown >= COOLDOWN_DURATION:
			collected = false
			on_cooldown = false
			cooldown = 0.0

func ring():
	# Prevent re-trigger during cooldown
	if collected:
		return
	
	audio.play()
	
	# Mark as unavailable
	collected = true
	on_cooldown = true
	
	# Glow flash effect
	var tween = create_tween()
	tween.tween_property(glow, "light_energy", 4.0, 0.1)
	tween.tween_property(glow, "light_energy", 1.5, 0.8)
func collect():
	# Just mark as unavailable (same as ring, but without audio)
	if collected:
		return
	
	collected = true
	on_cooldown = true
func is_available() -> bool:
	return not collected

func get_note() -> Note:
	return note
