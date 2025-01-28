extends Node2D
class_name CameraManager

var camera: Camera2D

#var vertical_look: float = 0.0


func start() -> void:
	camera = Player.player.camera
	camera.reparent(self)

#func update_camera_position() -> void:
#vertical_look = max(-1, min(1, player.look_direction.y))
#
#position = Vector2(0, 75 * vertical_look)
#
#func _physics_process(_delta: float) -> void:
#update_camera_position()
