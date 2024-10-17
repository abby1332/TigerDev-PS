extends Node2D
class_name CameraManager

var player: Player
var camera: Camera2D

var vertical_look: float = 0.0

func start(plyr: Player) -> void:
	player = plyr
	camera = player.camera
	camera.reparent(self)

func update_camera_position() -> void:
	if player.crouch_state == player.CrouchState.CROUCHING:
		vertical_look = 1
	else:
		vertical_look = 0
	
	position = Vector2(0, 75 * vertical_look)

func _physics_process(_delta: float) -> void:
	update_camera_position()
