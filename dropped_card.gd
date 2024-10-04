extends Area2D
class_name DroppedCard

@export var card: Card

func pickup_card(player: Player) -> void:
	if player.card_manager.give_card(card):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if !player.card_manager.is_full():
		pickup_card(player)
