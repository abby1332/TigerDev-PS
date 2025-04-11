extends Node2D
class_name MusicManager
## Music manager for any played music. Short and simple.
##
## When the player dies it stops the music.

static var instance = self

var audio_stream_players: Dictionary = {}

var level: String = "forest"
var current_level_track: int = 0

func get_active_track() -> AudioStreamPlayer:
	return audio_stream_players.get(level)[current_level_track]

func _ready() -> void:
	pass
	#if RespawnManager.player != null:
		#RespawnManager.player.death.connect(on_player_death)
	#else:
		#push_error("Player is unexpectedly null!")

	#for child in get_children():
		#if child is AudioStreamPlayer:
			#child.playing = false
			#var level_name = child.name.get_slice("_", 0).to_lower()
			#audio_stream_players.get_or_add(level_name, []).append(child)
#
	#current_level_track = randi_range(0, audio_stream_players.get(level).size() - 1)
#
	#get_active_track().playing = true

func on_player_death() -> void:
	get_active_track().playing = false
