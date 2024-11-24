extends AudioStreamPlayer

func _ready() -> void:
	RespawnManager.player.death.connect(on_player_death)

func on_player_death() -> void:
	playing = false
