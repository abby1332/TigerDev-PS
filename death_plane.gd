extends Node2D
class_name DeathPlane

@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready() -> void:
	camera.limit_bottom = global_position.y
