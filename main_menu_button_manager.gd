extends Control

@export var first_level_path: String

func _on_start_button_pressed() -> void:
	print("Button!")
	RespawnManager.load_scene(first_level_path)

func _on_option_button_pressed() -> void:
	pass # Replace with function body.

func _on_credit_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit()
