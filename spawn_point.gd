extends Node2D
class_name SpawnPoint

func teleport(obj: Node2D) -> void:
	obj.global_position = global_position
