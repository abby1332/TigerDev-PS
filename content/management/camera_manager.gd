extends Node2D
class_name CameraManager
## Manages the Camera
##
## Perhaps in another life this class was finished...

var camera: Camera2D


func start() -> void:
	# What the actual **** is this???
	# Why is this a thing???
	camera = Player.player.camera
	camera.reparent(self)
