class_name listen extends State

var listen_timer: float = 0.0
var listen_duration: float = 0.0

func _enter():
	
	var brain = state_machine.boid.get_node("Brain")
	listen_duration = lerp(3.0, 1.2, brain.energy)
	listen_timer = 0.0
	print("Listening... duration: ", listen_duration)

func _think():
	listen_timer += get_process_delta_time()

	#chilling duirng the music 
	state_machine.boid.steering_force *= 0.1

	if listen_timer >= listen_duration:
		var brain = state_machine.boid.get_node("Brain")
		var next = brain.get_next_bell()
		if next:
			brain.current_target = next
			state_machine.change_state(seek_bell.new())
		else:
			# No more valid bells — performance ends
			brain.is_performing = false
			state_machine.change_state(WanderState.new())
