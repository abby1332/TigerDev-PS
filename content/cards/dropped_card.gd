extends Area2D
class_name DroppedCard
## Manages collision with player to provide a card

## Card that will be granted when the player touches the Area2D
@export var card: Card


## Picks up the card and adds it to the players hand, destroying this object in the process
func pickup_card(player: Player) -> void:
	if player.card_manager.give_card(card):
		if get_parent() is CardSpawner:
			player.card_manager.used_card_spawners.append(get_parent().name)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if !player.card_manager.is_full():
		pickup_card(player)
