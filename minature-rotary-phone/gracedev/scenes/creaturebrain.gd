class_name CreatureBrain
extends Node

var harmonic_system: HarmonicSystem
var bell_spawner: bellSpawner

var last_note: Bell.Note = Bell.Note.B
var energy: float = 0.0
var is_performing: bool = true
var current_target: Bell = null

# =========================
# EMOTION SYSTEM
# =========================
var satisfaction: float = 1.0
var anger_rate: float = 0.02

var rejected_bells: Array = []

func _ready():
	harmonic_system = get_tree().get_first_node_in_group("harmonic")
	bell_spawner = get_tree().get_first_node_in_group("spawner")

func _process(delta):
	energy = clamp(energy, 0.0, 1.0)
	satisfaction -= delta * anger_rate
	satisfaction = clamp(satisfaction, 0.0, 1.0)

# =========================
# BELL INTERACTION
# =========================
func on_bell_collected(bell: Bell):
	last_note = bell.get_note()
	energy = clamp(energy + 0.2, 0.0, 1.0)
	satisfaction = clamp(satisfaction + 0.3, 0.0, 1.0)

func on_bell_feedback(is_correct: bool):
	if is_correct:
		satisfaction = clamp(satisfaction + 0.25, 0.0, 1.0)
	else:
		satisfaction = clamp(satisfaction - 0.4, 0.0, 1.0)

# =========================
# DECISION HELPERS
# =========================
func get_next_bell() -> Bell:
	if not bell_spawner or not harmonic_system:
		return null
	var all_bells = bell_spawner.placed_bells
	return harmonic_system.get_nearest_valid_bell(
		get_parent().global_position,
		last_note,
		all_bells
	)

func get_nearest_any_bell() -> Bell:
	if not bell_spawner:
		return null
	var all_bells = bell_spawner.placed_bells
	var nearest = null
	var nearest_dist = INF
	for bell in all_bells:
		if not is_instance_valid(bell) or bell.collected:
			continue
		if bell in rejected_bells:
			continue
		var d = get_parent().global_position.distance_to(bell.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = bell
	return nearest

func is_bell_valid(bell: Bell) -> bool:
	if not harmonic_system:
		return false
	var next_note = harmonic_system.get_next_note(last_note)
	return bell.get_note() == next_note

func reject_bell(bell: Bell):
	if bell not in rejected_bells:
		rejected_bells.append(bell)
	await get_tree().create_timer(5.0).timeout
	rejected_bells.erase(bell)

# =========================
# AVOIDANCE LOGIC
# =========================
func get_avoidance_from_invalid_bells() -> Vector3:
	var force = Vector3.ZERO
	if not bell_spawner or not harmonic_system:
		return force
	var all_bells = bell_spawner.placed_bells
	var next_note = harmonic_system.get_next_note(last_note)
	for bell in all_bells:
		if not is_instance_valid(bell):
			continue
		if not bell.is_available():
			continue
		if bell.get_note() != next_note:
			var dist = get_parent().global_position.distance_to(bell.global_position)
			if dist < 4.0:
				var away = (get_parent().global_position - bell.global_position).normalized()
				force += away * (1.0 / max(dist, 0.1))
	return force * 2.0

# =========================
# EMOTION QUERY API
# =========================
func get_emotion_state() -> String:
	if satisfaction < 0.3:
		return "angry"
	elif satisfaction < 0.7:
		return "curious"
	else:
		return "happy"

func is_angry() -> bool:
	return satisfaction < 0.3

func is_curious() -> bool:
	return satisfaction >= 0.3 and satisfaction < 0.7

func is_happy() -> bool:
	return satisfaction >= 0.7
