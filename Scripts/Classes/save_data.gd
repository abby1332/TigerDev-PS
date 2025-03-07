class_name SaveData
extends Resource

#region Settings

# Audio
@export var master_volume: float;
@export var music_volume: float;
@export var sfx_volume: float;
@export var is_game_muted: bool;

# Graphics
@export var fullscreen: bool;
@export var borderless: bool;
@export var vsync_enabled: bool;

#endregion

#region Funcs

## Loads `SaveData` from a save file.
## Creates a fresh save from current game data if no save file exists.
static func load_data() -> SaveData:
	var saved_data: SaveData = load("user://save_data.tres") as SaveData;
	if saved_data == null:
		var out: SaveData = SaveData.new();
		out.master_volume = GameSettings.master_volume;
		out.music_volume = GameSettings.music_volume;
		out.sfx_volume = GameSettings.sfx_volume;
		out.is_game_muted = GameSettings.is_game_muted;

		out.fullscreen = GameSettings.fullscreen;
		out.borderless = GameSettings.borderless;
		out.vsync_enabled = GameSettings.vsync_enabled;

		return out;
	else:
		return saved_data;

## Pulls saved data into the game.
func pull_data() -> void:
	GameSettings.master_volume = master_volume;
	GameSettings.music_volume = music_volume;
	GameSettings.sfx_volume = sfx_volume;
	GameSettings.is_game_muted = is_game_muted;

	GameSettings.fullscreen = fullscreen;
	GameSettings.borderless = borderless;
	GameSettings.vsync_enabled = vsync_enabled;

## Stores data to a local file.
func save_data() -> void:
	ResourceSaver.save(self, "user://save_data.tres");
