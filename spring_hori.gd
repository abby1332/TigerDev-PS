extends Area2D
class_name spring_hori

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if player.velocity.x > 0:
		if player.velocity.x > 600:
			if player.velocity.x > 1000:
				player.velocity.x *= -1
			else:
				player.velocity.x *= -1
				player.velocity.x -= 100
		else:
			player.velocity.x = -600
	else :
		if player.velocity.x < -600:
			if player.velocity.x < -1000:
				player.velocity.x *= -1
			else:
				player.velocity.x *= -1
				player.velocity.x += 100
		else:
			player.velocity.x = 600
	
