extends Node2D
class_name CardSpawner
## Simple class that spawns in a dropped card.
##
## Spawns in dropped_card_scene with card_scene at the current position when the scene is loaded and this cardspawner is not used.

## The dropped_card_scene which will hold the card_scene
@export var dropped_card_scene: PackedScene
## The card to spawn
@export var card_scene: PackedScene

## The spawned dropped_card_scene
var spawned_dropped_card: DroppedCard = null


## Actually spawns in the card
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
	if RespawnManager.current_save != null:
		if not name in RespawnManager.current_save.used_card_spawners:
			spawn()
	else:
		spawn()
