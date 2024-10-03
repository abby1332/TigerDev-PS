extends Node2D
class_name CardSpawner

@export var dropped_card_scene: PackedScene
@export var card_scene: PackedScene

var spawned_dropped_card: DroppedCard = null

func spawn() -> bool:
	if spawned_dropped_card != null and spawned_dropped_card.get_parent() == self:
		return false
	spawned_dropped_card = dropped_card_scene.instantiate() as DroppedCard
	add_child(spawned_dropped_card)
	var spawned_card := card_scene.instantiate() as Card
	spawned_dropped_card.add_child(spawned_card)
	spawned_dropped_card.card = spawned_card
	return true

func _ready() -> void:
	spawn()
