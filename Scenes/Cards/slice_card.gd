extends Card
class_name SliceCard
## Slice/Slash/Dash/Whatever card that launches the character and damages enemies

## Duration that force will kept being applied to the player
@export var duration: float = 0.1

## If the card is active and being applied
var active: bool = false

var player: Player
var last_look_direction: Vector2


## Resets and destroys the object
func _reset() -> void:
	active = false
	player.is_ignoring_gravity = false

	queue_free()


## Uses the card
func use(plyr: Player) -> void:
	plyr.activate_kill_everything_mode(duration * 4)
	plyr.animation_machine.set_animation_special_state(
		PlayerAnimationMachine.SpecialState.DASH, duration * 4
	)
	plyr.animation_machine.sprite.frame = 0
	var slice = plyr.get_node("Sounds/Slash")
	slice.play()

	plyr.is_stomping = false

	active = true
	player = plyr
	last_look_direction = player.last_look_direction
	player.is_ignoring_gravity = true
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_reset)
	timer.start()

	sprite.queue_free()


func _physics_process(delta: float) -> void:
	# Applies force to the player while the card is active
	if active and not player.dead:
		player.velocity.x += last_look_direction.x * player.speed * delta * 10
		player.velocity.y += last_look_direction.y * player.speed * delta * 10
		if last_look_direction.y <= 0 and player.velocity.y >= 0:
			player.velocity.y = 0
		player.move_and_slide()
