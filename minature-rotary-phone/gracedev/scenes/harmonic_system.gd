class_name HarmonicSystem extends Node3D

# Creature follows the scale in order — Do Re Mi Fa Sol La Ti Do
const SCALE = [
	Bell.Note.C,
	Bell.Note.D,
	Bell.Note.E,
	Bell.Note.F,
	Bell.Note.G,
	Bell.Note.A,
	Bell.Note.B,
]

func get_next_note(last_note: Bell.Note) -> Bell.Note:
	var index = SCALE.find(last_note)
	return SCALE[(index + 1) % SCALE.size()]

func get_nearest_valid_bell(
		creature_pos: Vector3,
		last_note: Bell.Note,
		all_bells: Array) -> Bell:

	var next_note = get_next_note(last_note)
	var nearest = null
	var nearest_dist = INF

	for bell in all_bells:
		if not is_instance_valid(bell):
			continue
		if bell.collected:
			continue
		if bell.get_note() != next_note:
			continue
		var d = creature_pos.distance_to(bell.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = bell
	return nearest
