class_name CreatureBrain extends Node

@onready var harmonic_system: HarmonicSystem = get_tree().get_first_node_in_group("harmonic")
@onready var bell_spawner: bellSpawner = get_tree().get_first_node_in_group("spawner")

var last_note: Bell.Note = Bell.Note.C
var energy: float = 0.0          # rises as more bells collected
var is_performing: bool = false
var current_target: Bell = null

func start_performance():
	is_performing = true
	energy = 0.0

func on_bell_collected(bell: Bell):
	last_note = bell.get_note()
	energy = clamp(energy + 0.2, 0.0, 1.0)

func get_next_bell() -> Bell:
	var all_bells = bell_spawner.placed_bells
	return harmonic_system.get_nearest_valid_bell(
		get_parent().global_position,
		last_note,
		all_bells
	)
