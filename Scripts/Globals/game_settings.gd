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

func _ready() -> void:
	var config_loader: ConfigFile = ConfigFile.new();
	if config_loader.load(&"user://options.cfg") == OK:
		for section: String in config_loader.get_sections():
			for key: String in config_loader.get_section_keys(section):
				pass

func _apply_settings() -> void:
	# Audio
	AudioServer.set_bus_mute(master_bus_index, is_game_muted);
	AudioServer.set_bus_volume_linear(master_bus_index, master_volume);

	# Graphics
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, borderless);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED);

func _confing_to_setting(section: String, key: String, config_file: ConfigFile) -> void:
	match section:
		"audio": match key:
			"master_volume":
				var val: Variant = config_file.get_value(section, key, 0.0);
				if val is float: master_volume = val as float;
