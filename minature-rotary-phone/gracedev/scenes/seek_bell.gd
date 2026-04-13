class_name seek_bell extends State

var target: Bell

func _enter():
	target = state_machine.boid.get_node("Brain").current_target
	print("Seeking bell: ", target.note)

func _think():
	if not target or target.collected:
		state_machine.change_state(WanderState.new())
		return

	var boid = state_machine.boid
	boid.steering_force = boid.arrive_force(target.global_position, 3.0)

	# Arrived
	if boid.global_position.distance_to(target.global_position) < 1.0:
		target.ring()
		state_machine.boid.get_node("Brain").on_bell_collected(target)
		target.collect()
		state_machine.change_state(listen.new())
