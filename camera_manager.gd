extends Node2D
class_name CameraManager

var player: Player
var camera: Camera2D

var left_threshhold: float
var right_threshhold: float

func start(plyr: Player) -> void:
	player = plyr
	camera = player.camera
	camera.reparent(self)
	
	reset_threshholds()

func is_within_threshholds() -> bool:
	return player.global_position.x > left_threshhold and player.global_position.x < right_threshhold

func reset_threshholds() -> void:
	left_threshhold = player.global_position.x - 60
	right_threshhold = player.global_position.x + 60
	print(Vector2(left_threshhold, right_threshhold))

func update_camera_position() -> void:
	if is_within_threshholds():
		position = Vector2(25 * player.last_direction, 0)
	else:
		reset_threshholds()
	

func _physics_process(_delta: float) -> void:
	update_camera_position()
