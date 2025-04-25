extends CanvasLayer

@export var animator: AnimationPlayer;

func _on_player_character_player_died() -> void:
	animator.play(&"PLAY");

func _on_player_character_load_checkpoint() -> void:
	animator.play(&"RESET");
