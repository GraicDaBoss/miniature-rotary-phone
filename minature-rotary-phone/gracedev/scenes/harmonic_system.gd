class_name HarmonicSystem extends Node3D

# pentatonic evaluation done by claude not me 
const HARMONY_MAP = {
	Bell.Note.C: [Bell.Note.D, Bell.Note.E, Bell.Note.G, Bell.Note.A],
	Bell.Note.D: [Bell.Note.E, Bell.Note.G, Bell.Note.A],
	Bell.Note.E: [Bell.Note.G, Bell.Note.A, Bell.Note.C],
	Bell.Note.G: [Bell.Note.A, Bell.Note.C, Bell.Note.D],
	Bell.Note.A: [Bell.Note.C, Bell.Note.D, Bell.Note.E],
}

func get_valid_bells(last_note: Bell.Note, all_bells: Array) -> Array:
	var valid = []
	var allowed = HARMONY_MAP[last_note]
	for bell in all_bells:
		if not is_instance_valid(bell):
			continue
		if not bell.collected and bell.get_note() in allowed:
			valid.append(bell)
	return valid

func get_nearest_valid_bell(
		creature_pos: Vector3,
		last_note: Bell.Note,
		all_bells: Array) -> Bell:

	var valid = get_valid_bells(last_note, all_bells)
	if valid.is_empty():
		return null

	var nearest = null
	var nearest_dist = INF
	for bell in valid:
		if not is_instance_valid(bell):
			continue
		var d = creature_pos.distance_to(bell.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = bell
	return nearest
