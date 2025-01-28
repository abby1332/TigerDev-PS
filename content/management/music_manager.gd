extends AudioStreamPlayer
## Music manager for any played music. Short and simple.
##
## When the player dies it stops the music.

func _ready() -> void:
	RespawnManager.player.death.connect(on_player_death)


func on_player_death() -> void:
	playing = false
