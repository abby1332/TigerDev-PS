extends StaticBody2D
var bodies_inside: Array = []  #Used to parse over the player
signal wall_broken(position: Vector2)
var is_breaking: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("wall_broken", Callable(self, "_on_neighbor_wall_broken"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Continuously check if the player is in kill mode while inside area
	check_break_condition()


func break_wall(player_position: Vector2):
	#Prevent infinite recursion
	if is_breaking:
		return

	is_breaking = true
	#Emit a signal to notify neighboring walls
	emit_signal("wall_broken", global_position)

	var particles = $WallBreakParticles

	# Calculate the direction opposite to the player's entry
	var entry_vector = global_position - player_position
	var opposite_vector = entry_vector.normalized()

	# Set the rotation of the particles to face the opposite direction
	particles.rotation = opposite_vector.angle()

	$WallBreakParticles.emitting = true  # Start the particles
	$PhysicalShape.queue_free()  # Remove the collision shape
	$Area2D.queue_free()
	$Sprite2D.visible = false  # Hide the wall's sprite
	#Wait for particles to finish then remove wall
	await get_tree().create_timer(1).timeout
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		bodies_inside.append(body)
		#Start checking for condition
		set_process(true)
		check_break_condition()


func _on_area_2d_body_exited(body: Node2D) -> void:
	bodies_inside.erase(body)
	#Stop checking
	set_process(false)


#Keep track of the kill mode
func check_break_condition():
	for body in bodies_inside:
		if body.kill_everything_mode or body.is_stomping:
			print("We break now")
			break_wall(body.global_position)


#Break nearby walls
func _on_neighbor_wall_broken(broken_position: Vector2):
	if (global_position - broken_position).length() < 100:  #Adjust as needed
		break_wall(broken_position)
