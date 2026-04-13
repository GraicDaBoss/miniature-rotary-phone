class_name WanderState extends State

var noise_wander: NoiseWander
var time: float = 0.0

func _enter():
	# Reuse repo's NoiseWander
	noise_wander = NoiseWander.new()
	noise_wander.radius = 6.0
	noise_wander.frequency = 0.4
	state_machine.boid.add_child(noise_wander)

func _exit():
	if noise_wander:
		noise_wander.queue_free()

func _think():
	state_machine.boid.steering_force = noise_wander.calculate()

	var brain = state_machine.boid.get_node("Brain")
	if brain.is_performing:
		var next = brain.get_next_bell()
		if next:
			brain.current_target = next
			state_machine.change_state(seek_bell.new())
