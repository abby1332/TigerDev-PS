extends Node

#region Typing

enum PlayState {
	MainMenu,
	InLevel,
}

enum CurrentLevel {
	None,
	Forest0,
	Forest1,
}

#endregion

#region Vars

var play_state: PlayState = PlayState.MainMenu;
var current_level: CurrentLevel = CurrentLevel.None;

#endregion

#region Node Funcs

func _ready() -> void:
	pass

#endregion

#region Funcs

func quit() -> void:
	get_tree().quit();

func load_main_menu() -> void:
	play_state = PlayState.MainMenu;
	current_level = CurrentLevel.None;

	get_tree().change_scene_to_file(&"res://Scenes/Menus/MainMenu.tscn");

func load_level_forest_0() -> void:
	play_state = PlayState.InLevel;
	current_level = CurrentLevel.Forest0;

	get_tree().change_scene_to_file(&"res://Scenes/Levels/Forest_0.tscn");

func load_level_forest_1() -> void:
	play_state = PlayState.InLevel;
	current_level = CurrentLevel.Forest1;

	get_tree().change_scene_to_file(&"res://Scenes/Levels/Forest_1.tscn");

#endregion
