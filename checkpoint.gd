extends Area2D

@onready var spawn_point = $SpawnPoint
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body is Spinner:
		body.respawn_position = spawn_point.global_position
		audio.play()
