extends Control

@export var first_level_path: String

@export var credit_screen_parent: Control

func _on_start_button_pressed() -> void:
	if(credit_screen_parent.visible):
		return
	RespawnManager.load_scene(first_level_path)

func _on_option_button_pressed() -> void:
	if(credit_screen_parent.visible):
		return
	pass # Replace with function body.

func _on_credit_button_pressed() -> void:
	if(credit_screen_parent.visible):
		return
	credit_screen_parent.show()

func _on_credit_exit_button_pressed() -> void:
	if(!credit_screen_parent.visible):
		return
	credit_screen_parent.hide()

func _on_exit_button_pressed() -> void:
	if(credit_screen_parent.visible):
		return
	get_tree().quit()
