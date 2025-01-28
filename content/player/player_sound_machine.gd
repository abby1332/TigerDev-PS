extends Node
class_name PlayerSoundMachine

static var main: PlayerSoundMachine

var sound_players: Dictionary = {}


func _ready() -> void:
	main = self
	for child in get_children():
		if not child is AudioStreamPlayer2D:
			continue
		sound_players[child.name] = child as AudioStreamPlayer2D


func stream(name: String) -> AudioStreamPlayer2D:
	return sound_players[name]
