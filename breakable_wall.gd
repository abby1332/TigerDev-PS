extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func break_wall(player_position: Vector2):
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
	if body.kill_everything_mode:
		break_wall(body.global_position)
