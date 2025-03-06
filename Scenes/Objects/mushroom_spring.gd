extends Area2D
class_name spring_vert
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player

	#Trigger bounce animation
	sprite.play("boing")
	sfx.play()

	if player.velocity.y > 0:
		if player.velocity.y > 600:
			if player.velocity.y > 1000:
				player.velocity.y *= -1
			else:
				player.velocity.y *= -1
				player.velocity.y -= 100
		else:
			player.velocity.y = -600
	else:
		if player.velocity.y < -600:
			if player.velocity.y < -1000:
				player.velocity.y *= -1
			else:
				player.velocity.y *= -1
				player.velocity.y += 100
		else:
			player.velocity.y = 700
