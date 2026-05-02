class_name SpineAnimator
extends Node

@export var bones: Array[Node3D] = []
@export var iterations: int = 4
@export var stiffness: float = 1.0
@export var angular_damping: float = 8.0

var positions: Array = []
var prev_positions: Array = []
var distances: Array = []

func _ready():
	if bones.size() < 2:
		return

	for b in bones:
		positions.append(b.global_transform.origin)
		prev_positions.append(b.global_transform.origin)

	for i in range(bones.size() - 1):
		distances.append(bones[i].global_transform.origin.distance_to(bones[i + 1].global_transform.origin))

func _physics_process(delta):
	if bones.size() < 2:
		return

	positions[0] = bones[0].global_transform.origin

	for i in range(1, positions.size()):
		var current = positions[i]
		var prev = prev_positions[i]
		var velocity = (current - prev) * 0.98
		prev_positions[i] = current
		positions[i] += velocity

	for j in range(iterations):
		positions[0] = bones[0].global_transform.origin

		for i in range(positions.size() - 1):
			var p1 = positions[i]
			var p2 = positions[i + 1]

			var delta_vec = p2 - p1
			var dist = delta_vec.length()

			if dist == 0:
				continue

			var diff = (dist - distances[i]) / dist
			var correction = delta_vec * 0.5 * stiffness * diff

			if i != 0:
				positions[i] += correction

			positions[i + 1] -= correction

	for i in range(1, bones.size()):
		bones[i].global_transform.origin = positions[i]

	for i in range(bones.size() - 1):
		var curr = bones[i]
		var next = bones[i + 1]

		var dir = (positions[i + 1] - positions[i]).normalized()

		if dir.length() > 0.0001:
			var right = Vector3.UP.cross(dir).normalized()
			var up = dir.cross(right).normalized()

			var target_basis = Basis(right, up, dir)
			var t = 1.0 - exp(-angular_damping * delta)

			#curr.global_transform.basis = curr.global_transform.basis.slerp(target_basis, t).orthonormalized()
