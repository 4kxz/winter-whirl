class_name Spinner extends RigidBody2D

var previous_mouse_position: Vector2
var previous_movement: Vector2
var torque_strength: float = 2500
var torque: float = 0.0
var torque_smoothing: float = 0.25
var respawn: bool = false
var respawn_position: Vector2

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func grow() -> void:
	sprite.scale *= 1.02
	collision.shape.radius *= 1.02

func _ready() -> void:
	previous_mouse_position = DisplayServer.mouse_get_position()
	previous_movement = Vector2.ZERO

func _physics_process(delta):
	var mouse_position : Vector2 = DisplayServer.mouse_get_position()
	var current_movement := mouse_position - previous_mouse_position
	
	if current_movement.length() > 0 and previous_movement.length() > 0:
		var current_angle := current_movement.angle()
		var prev_angle := previous_movement.angle()
		
		var angle_diff = current_angle - prev_angle
		if angle_diff > PI:
			angle_diff -= 2 * PI
		elif angle_diff < -PI:
			angle_diff += 2 * PI
		
		var mouse_angular_velocity = angle_diff / delta
		var velocity_diff = mouse_angular_velocity - angular_velocity
		
		var target_torque = torque_strength * velocity_diff
		torque = lerp(torque, target_torque, torque_smoothing)
		apply_torque(torque)
		
	previous_movement = current_movement
	previous_mouse_position = mouse_position

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if respawn:
		global_position = respawn_position
		linear_velocity = Vector2.ZERO
		respawn = false
