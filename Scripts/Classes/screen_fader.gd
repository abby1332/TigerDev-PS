class_name ScreenFader
extends CanvasModulate

#region Exports

@export var animation_player: AnimationPlayer;
@export var fade_in_animation: StringName;
@export var fade_out_animation: StringName;

#endregion

#region Funcs

func fade_out() -> void:
	animation_player.play(fade_in_animation);
	await animation_player.animation_finished;

func fade_in() -> void:
	animation_player.play(fade_out_animation);
	await animation_player.animation_finished;
