extends CanvasLayer

var is_active: bool = false:
	set(state):
		is_active = state;
		get_tree().paused = state;
		visible = state;

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		is_active = !is_active;

func _on_resume_pressed() -> void:
	is_active = !is_active;


func _on_quit_pressed() -> void:
	get_tree().quit();
