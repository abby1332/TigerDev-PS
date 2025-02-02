extends Node
class_name PlayerSoundMachine
## Provides easy access to audio streams that are connected to the player

@export var mute: bool = false

static var main: PlayerSoundMachine

var sound_players: Dictionary = {}


func _ready() -> void:
	main = self
	for child in get_children():
		if child is AudioStreamPlayer2D:
			sound_players[child.name] = child as AudioStreamPlayer2D

# name = sound effect name you want to play
# Call this function inside of the player action to trigger the sound effect
func play_sound(name: String) -> void:
	if sound_players.has(name):
		sound_players[name].play()
	else:
		print_debug("Sound '" + name + "' not found in player sound manager")
