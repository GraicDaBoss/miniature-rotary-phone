class_name wander extends State

var timer: float = 0.0
var wander_target: Vector3 = Vector3.ZERO

func _enter():
	print("Wandering")
	_pick_new_target()

func _think():
	var boid = state_machine.boid
	var brain = boid.get_node("Brain")

	# Steer away from invalid bells
	boid.steering_force += brain.get_avoidance_from_invalid_bells()

	timer += get_process_delta_time()
	if timer > 3.0:
		_pick_new_target()
		timer = 0.0

	boid.steering_force += boid.seek_force(wander_target)
	
	if brain.is_angry():
		var cam = get_viewport().get_camera_3d()
		boid.steering_force += boid.seek_force(cam.global_position)

	# Always looking for next valid bell
	var next = brain.get_next_bell()
	if next:
		brain.current_target = next
		state_machine.change_state(seek_bell.new())

func _pick_new_target():
	wander_target = Vector3(
		randf_range(-10.0, 10.0),
		0.0,
		randf_range(-10.0, 10.0)
	)
