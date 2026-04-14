class_name Bell extends Node3D

enum Note { C, D, E, G, A }

@export var note: Note = Note.C
@export var base_pitch: AudioStream  
var float_timer: float = 0.0
var base_y: float = 0.0

var pitch_map = {
	Note.C: 1.0,
	Note.D: 1.122,
	Note.E: 1.26,
	Note.G: 1.498,
	Note.A: 1.682
}

var colour_map = {
	Note.C: Color(0.4, 0.8, 1.0),   # blue
	Note.D: Color(0.5, 1.0, 0.8),   # teal
	Note.E: Color(0.8, 1.0, 0.5),   # lime
	Note.G: Color(1.0, 0.8, 0.4),   # amber
	Note.A: Color(1.0, 0.5, 0.8),   # pink
}

@onready var audio = $AudioStreamPlayer3D
@onready var glow = $GlowLight
@onready var mesh = $Mesh

var collected: bool = false

func _ready():
	audio.stream = base_pitch
	audio.pitch_scale = pitch_map[note]
	glow.light_color = colour_map[note]
	# match colour
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = colour_map[note]
	mat.emission_energy_multiplier = 2.0
	mat.albedo_color = colour_map[note]
	mesh.material = mat

func _process(delta):
	float_timer += delta
	position.y = base_y + sin(float_timer * 1.2) * 0.15

func ring():
	audio.play()
	# Flash brighter on ring
	var tween = create_tween()
	tween.tween_property(glow, "light_energy", 4.0, 0.1)
	tween.tween_property(glow, "light_energy", 1.5, 0.6)
	


	


func collect():
	collected = true
	# Fade out 
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.4)
	tween.tween_property(glow, "light_energy", 0.0, 0.4)
	tween.tween_callback(queue_free)

func get_note() -> Note:
	return note
