## Player Spawn Points
class_name SpawnPoint
extends Node2D

## Teleports something to this location
func teleport(obj: Node2D) -> void:
	obj.global_position = global_position
