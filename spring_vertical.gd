extends Area2D
class_name spring_vert

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if player.velocity.y > 0:
		if player.velocity.y > 600:
			player.velocity.y *= -1
			player.velocity.y -= 100
		else:
			player.velocity.y = -600
	else :
		if player.velocity.y < -600:
			player.velocity.y *= -1
			player.velocity.y += 100
		else:
			player.velocity.y = 700
