## Spike Trap that causes bodily harm to the player
## https://medlineplus.gov/ency/article/000043.htm
class_name SpikeTrap
extends Area2D


# TODO - Get rid of this.
# Reason - Because this has no reason to be  an entire class?? Just have the player check if they're colliding with spikes???
## When the player enters the spike trap kill them instantly
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	player.die()
