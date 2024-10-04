extends Control

var _is_paused:bool = false:
	set(value):
		_is_paused = value
		get_tree().paused = _is_paused
		visible = _is_paused

# Press escape to open and close pause menu
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_is_paused = !_is_paused

func _on_resume_btn_pressed() -> void:
	_is_paused = false

func _on_settings_btn_pressed() -> void:
	pass # We dont have any settings yet

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
