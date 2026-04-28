class_name bellSpawner extends Node3D

@export var bell_scene: PackedScene
@export var camera: Camera3D
@export var note_cycle: Array = [
	Bell.Note.C, Bell.Note.D, Bell.Note.E,
	Bell.Note.G, Bell.Note.A
]

var current_note_index: int = 0
var placed_bells: Array = []
var placement_active: bool = true

func _input(event):
	if not placement_active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_place_bell()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Cycle note manually
			current_note_index = (current_note_index + 1) % note_cycle.size()

func _place_bell():
	var mouse = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse)
	var ray_dir = camera.project_ray_normal(mouse)
	
	if ray_dir.y != 0:
		var t = (0.0 - ray_origin.y) / ray_dir.y
		var pos = ray_origin + ray_dir * t
		pos.y = 1.0
		var bell = bell_scene.instantiate()
		bell.note = note_cycle[current_note_index]
		bell.position = pos
		add_child(bell)
		placed_bells.append(bell)
		
		current_note_index = (current_note_index + 1) % note_cycle.size()

func start_performance():
	placement_active = false
