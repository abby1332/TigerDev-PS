extends Node

var active: bool = false

func freeze_frame(time_scale: float, duration: float) -> bool:
	active = true
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
	active = false
	return true
	
func zoom_frame(time_scale: float, duration: float, zoom_scale: float, flash: bool = true) -> bool:
	flash_frame(0.05)
	RespawnManager.player.camera.position_smoothing_enabled = false
	RespawnManager.player.camera.zoom *= Vector2(zoom_scale, zoom_scale)
	await freeze_frame(time_scale, duration)
	RespawnManager.player.camera.zoom /= Vector2(zoom_scale, zoom_scale)
	RespawnManager.player.camera.position_smoothing_enabled = true
	return true

func flash_frame(duration: float) -> void:
	RespawnManager.player.screen_flash_canvas_layer.show()
	await get_tree().create_timer(duration * Engine.time_scale).timeout
	RespawnManager.player.screen_flash_canvas_layer.hide()
