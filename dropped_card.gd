extends Area2D
class_name DroppedCard

@export var card: Card

func pickup_card(player: Player):
	pass

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	
