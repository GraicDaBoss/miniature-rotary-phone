class_name seek_bell extends State

var target: Bell

func _enter():
	var brain = state_machine.boid.get_node("Brain")
	target = brain.current_target
	if not is_instance_valid(target) or target.collected:
		state_machine.change_state(wander.new())

func _think():
	var boid = state_machine.boid
	var brain = boid.get_node("Brain")

	if not is_instance_valid(target) or target.collected:
		state_machine.change_state(wander.new())
		return

	boid.steering_force += boid.get_obstacle_avoidance()
	boid.steering_force += boid.arrive_force(target.global_position, 3.0)

	if boid.global_position.distance_to(target.global_position) < 2.5:
		if brain.is_bell_valid(target):
			target.ring()
			brain.on_bell_collected(target)
			target.collect()
			state_machine.change_state(listen.new())
		else:
			brain.reject_bell(target)
			brain.current_target = null
			state_machine.change_state(wander.new())
