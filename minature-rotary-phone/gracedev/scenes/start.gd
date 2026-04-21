extends Node

@export var creature: CreatureController
@export var bell_spawner: bellSpawner

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			bell_spawner.start_performance()
			creature.get_node("Brain").start_performance()
