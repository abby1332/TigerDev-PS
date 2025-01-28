extends Node2D
class_name SpawnPoint
## Saves a position for teleportation


## Teleports something to this location
func teleport(obj: Node2D) -> void:
	obj.global_position = global_position
