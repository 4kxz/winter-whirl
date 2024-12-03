class_name Spike extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area: Area2D = $Area2D

func drop() -> void:
	set_freeze_enabled.call_deferred(false)
	await get_tree().create_timer(0.5).timeout
	set_contact_monitor.call_deferred(true)
	await get_tree().create_timer(2.5).timeout
	queue_free()

func _ready() -> void:
	set_freeze_enabled(true)
	var random_scale := randf_range(1, 1.5)
	sprite_2d.set_scale(Vector2(random_scale, random_scale))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Spinner:
		body.respawn = true

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if is_instance_valid(area):
		audio.play()
		area.queue_free()
