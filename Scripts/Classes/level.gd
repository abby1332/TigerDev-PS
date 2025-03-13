class_name Level
extends Node

#region Level Characteristics

@export_category("Level Characteristics")
@export var background_music: MusicMan.Song;
@export var tile_map: TileMapLayer;
@export var player: PlayerNode;
@export var screen_fader: ScreenFader;

#endregion

#region Gameplay Management

@export_category("Gameplay Management")
@export var current_checkpoint: Variant = null;
@export var current_time_scale: float = 1.0;

#endregion

#region Private Funcs

func _ready() -> void:
	MusicMan.end_song();
	MusicMan.set_song(background_music);
	MusicMan.start_song();

func _reset_time_scale() -> void:
	current_time_scale = 1.0;
	Engine.time_scale = current_time_scale;

func _fade_to_black() -> void:
	pass
	

#endregion

#region Public Funcs

## Sets the global time scale to `scale`.
## 1. The `duration` field is in real-time seconds.
## 2. This function does nothing if the time scale is currently modified.
## 3. This function does nothing if `scale` is either 1.0 or <= 0.0
func set_time_scale(scale: float, duration: float) -> void:
	if current_time_scale != 1.0 || scale == 1.0 || scale <= 0.0: return;
	
	current_time_scale = scale;
	Engine.time_scale = current_time_scale;
	await get_tree().create_timer(duration / scale).timeout;
	
	_reset_time_scale();
