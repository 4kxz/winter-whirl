extends Marker2D

@export var target: RigidBody2D

var linear_velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	linear_velocity = lerp(linear_velocity, target.linear_velocity, 0.01)
	global_position = target.global_position + linear_velocity * Vector2(0.75, 0.25)
