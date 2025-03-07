class_name Level
extends Node

#region Level Characteristics

@export var background_music: MusicMan.Song = MusicMan.Song.Silence;
@export var tile_map: TileMapLayer;
@export var player: Variant = null;

#endregion

#region Vars

@export var checkpoint: Variant = null;


#endregion

#region Funcs

func _ready() -> void:
	MusicMan.end_song();
	MusicMan.set_song(background_music);
	MusicMan.start_song();
