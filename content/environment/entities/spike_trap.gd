extends Area2D
class_name SpikeTrap
## Spike Trap that causes bodily harm to the player
## https://medlineplus.gov/ency/article/000043.htm

## When the player enters the spike trap kill them instantly
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	player.die()
