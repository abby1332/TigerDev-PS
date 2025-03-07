extends Node

#region Audio

@onready var master_bus_index: int = AudioServer.get_bus_index(&"Master");

## Master Volume (%)
var master_volume: float = 0.75;

## Music Volume (%)
var music_volume: float = 1.0;

## Sound Effects Volume (%)
var sfx_volume: float = 1.0;

## I really hope I don't need to explain this one.
var is_game_muted: bool = false;

#endregion

#region Graphics

## Enables and disables fullscreen mode.
var fullscreen: bool = false;

## Enables and disables borderless window.
var borderless: bool = false;

## Enables and disables VSync.
var vsync_enabled: bool = true;

#endregion

#region Config

@onready var save_data: SaveData = SaveData.load_data();

func _ready() -> void:
	save_data.pull_data();
	_apply_settings();

func _apply_settings() -> void:
	# Audio
	AudioServer.set_bus_mute(master_bus_index, is_game_muted);
	AudioServer.set_bus_volume_linear(master_bus_index, master_volume);

	# Graphics
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, borderless);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED);
