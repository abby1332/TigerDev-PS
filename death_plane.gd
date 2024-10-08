extends Node2D
class_name DeathPlane

func _ready() -> void:
	get_viewport().get_camera_2d().limit_bottom = int(global_position.y)
		
