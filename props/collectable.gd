extends Area2D

var t := 0.0
@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	t += delta
	scale.x = sin(t * PI)

func _on_body_entered(body: Node2D) -> void:
	if body is Spinner:
		body.grow()
		audio.play()
		audio.finished.connect(queue_free)
		hide()
