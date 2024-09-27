extends Card
class_name TestCard

@export var duration: float = 0.2

var active: bool = false

var player: Player
var last_direction: float

func _reset() -> void:
	active = false

func use(plyr: Player) -> void:
	active = true
	player = plyr
	last_direction = player.last_direction
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_reset)
	timer.start()

func _physics_process(delta: float) -> void:
	if active and not player.dead and abs(player.velocity.x) > 0:
		player.velocity.x += last_direction * player.speed * delta * 100
		player.move_and_slide()
