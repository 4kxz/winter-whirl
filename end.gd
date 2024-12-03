extends Area2D

const save_file: String = "user://best_time.data"

var elapsed_time: float = 0
var counting: bool = true

@onready var timer_canvas: CanvasLayer = $TimerCanvasLayer
@onready var timer_label: Label = %Timer
@onready var end_canvas: CanvasLayer = $EndCanvasLayer
@onready var end_label: Label = %EndLabel

func _process(delta):
	if counting:
		elapsed_time += delta
		timer_label.text = _format_time(elapsed_time)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_body_entered(body: Node2D) -> void:
	if body is Spinner:
		counting = false
		timer_canvas.hide()
		end_canvas.show()
		var best_time := elapsed_time
		if FileAccess.file_exists(save_file):
			var file = FileAccess.open(save_file, FileAccess.READ)
			var saved_time: float = file.get_var()
			if saved_time < best_time:
				best_time = saved_time
		var file = FileAccess.open(save_file, FileAccess.WRITE)
		file.store_var(best_time)
		end_label.text = "Best time:\n%s\nCurrent time:\n%s" % [
			_format_time(best_time),
			_format_time(elapsed_time),
		]

func _format_time(time) -> String:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
