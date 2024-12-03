extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var tree := get_tree()
	if body is Spinner:
		for child in get_children():
			if child is Spike:
				child.drop()
				await tree.create_timer(.05).timeout
