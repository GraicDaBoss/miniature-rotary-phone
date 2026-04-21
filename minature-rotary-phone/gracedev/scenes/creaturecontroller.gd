class_name CreatureController extends Node3D

@export var max_speed: float = 4.0
@export var max_force: float = 2.5
@export var mass: float = 1.0
@export var bounds: float = 18.0

var velocity: Vector3 = Vector3.ZERO
var steering_force: Vector3 = Vector3.ZERO

func _process(delta):
	if global_position.length() > bounds:
		steering_force += seek_force(Vector3.ZERO) * 3.0

	var force = steering_force.limit_length(max_force)
	velocity += (force / mass) * delta
	velocity = velocity.limit_length(max_speed)
	steering_force = Vector3.ZERO

	global_position += velocity * delta

	if velocity.length() > 0.1:
		var flat_vel = Vector3(velocity.x, 0.0, velocity.z)
		if flat_vel.length() > 0.05:
			var target_basis = Basis.looking_at(flat_vel.normalized(), Vector3.UP)
			# Rotate 180 degrees on Y to correct mesh facing direction
			target_basis = target_basis.rotated(Vector3.UP, PI)
			basis = basis.slerp(target_basis, delta * 3.0).orthonormalized()

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
