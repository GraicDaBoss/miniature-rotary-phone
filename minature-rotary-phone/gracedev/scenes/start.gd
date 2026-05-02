extends Node

@export var bell_spawner: bellSpawner
@export var creature_brain: CreatureBrain

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_clear_bells()

func _clear_bells():
	for bell in bell_spawner.placed_bells:
		if is_instance_valid(bell):
			bell.queue_free()
	bell_spawner.placed_bells.clear()
	#creature_brain.energy = 0.0
	#creature_brain.last_note = Bell.Note.C
	print("Bells cleared")
