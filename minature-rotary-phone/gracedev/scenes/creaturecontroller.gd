class_name CreatureController extends CharacterBody3D

@export var max_speed: float = 4.0
@export var max_force: float = 2.5
@export var mass: float = 1.0
@export var bounds: float = 18.0

var steering_force: Vector3 = Vector3.ZERO

func _physics_process(delta):
	#print("steering: ", steering_force, " velocity: ", velocity)
	
	if global_position.length() > bounds:
			steering_force += seek_force(Vector3.ZERO) * 3.0

	velocity += (steering_force / mass) * delta
	velocity = velocity.limit_length(max_speed)
	steering_force = Vector3.ZERO

	if velocity.length() > 0.1:
		var look_target = global_position + velocity
		look_target.y = global_position.y  
		look_at(look_target, Vector3.UP)

	move_and_slide()

func seek_force(target_pos: Vector3) -> Vector3:
	var desired = (target_pos - global_position).normalized() * max_speed
	return (desired - velocity).limit_length(max_force)

func arrive_force(target_pos: Vector3, slowing_radius: float) -> Vector3:
	var to_target = target_pos - global_position
	var distance = to_target.length()
	var speed = max_speed * clamp(distance / slowing_radius, 0.0, 1.0)
	var desired = to_target.normalized() * speed
	return (desired - velocity).limit_length(max_force)

func flee_force(target_pos: Vector3) -> Vector3:
	var desired = (global_position - target_pos).normalized() * max_speed
	return (desired - velocity).limit_length(max_force)
