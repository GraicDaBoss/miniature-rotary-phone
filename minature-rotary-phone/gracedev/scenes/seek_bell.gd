class_name seek_bell
extends State

var target: Bell

func _enter():
	var brain = state_machine.boid.get_node("Brain")
	target = brain.current_target

	# Immediate validation
	if not is_instance_valid(target) or target.collected:
		brain.current_target = null
		state_machine.change_state(wander.new())

func _think():
	var boid = state_machine.boid
	var brain = boid.get_node("Brain")
	
	boid.steering_force += boid.get_obstacle_avoidance()

	# Re-check validity every frame
	if not is_instance_valid(target) or target.collected:
		brain.current_target = null
		state_machine.change_state(wander.new())
		return

	# Steering
	boid.steering_force += brain.get_avoidance_from_invalid_bells()
	boid.steering_force += boid.arrive_force(target.global_position, 3.0)

	# Arrival
	if boid.global_position.distance_to(target.global_position) < 2.5:
		target.ring()
		brain.on_bell_collected(target)

		# REMOVE collect() call ❌
		# target.collect()

		state_machine.change_state(listen.new())
