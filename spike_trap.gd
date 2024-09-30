extends Node2D
class_name SpikeTrap

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	player.die()
		
