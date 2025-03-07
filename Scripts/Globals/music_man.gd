extends AudioStreamPlayer

#region Typing

enum Song {
	Silence,
	ForestLvl,
}

#endregion

#region Consts

var SONG_FOREST_LVL: AudioStreamOggVorbis = preload("res://Assets/Audio/Music/forest_level.ogg");

#endregion

#region Vars

var current_song: Song = Song.Silence;

#endregion

#region Funcs

## Sets the current song.
## (Doesn't Overwrite Pause)
func set_song(song: Song) -> void:
	current_song = song;
	match song:
		Song.Silence: stream = null;
		Song.ForestLvl: stream = SONG_FOREST_LVL;
		_: pass

## Pauses the music.
## Opposite of `resume_music()`
func pause_music() -> void:
	stream_paused = true;

## Resumes the music.
## Opposite of `pause_music()`
func resume_music() -> void:
	stream_paused = false;

## Starts the current song from the beggining if not already playing.
## Opposite of `end_song()`
func start_song() -> void:
	playing = true;

## Ends the current song.
## Opposite of `start_song()`
func end_song() -> void:
	playing = false;

## Sets the volume to `db` (Decibal)
func set_volume(db: float) -> void:
	volume_db = db;

#endregion
