extends Card
class_name StompCard

var active: bool = false

func use(player: Player) -> void:
	sprite.queue_free()
	active = true
	player.is_stomping = true
	player.kill_everything_mode = true

func _physics_process(delta: float) -> void:
	if (active or Player.player.is_stomping) and Player.player.is_on_floor():
		Player.player.is_stomping = false
		active = false
		Player.player.kill_everything_mode = false
