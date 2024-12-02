extends Area2D
#Dynamically adjust the velocity in the scene, it defaults to -1.1
@export var bounce_multiplier: float = -1.1


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	var stime := Timer.new()
	player.toggle_bounce()
	add_child(stime)
	stime.one_shot = true
	stime.autostart = false
	stime.wait_time = 0.4
	stime.timeout.connect(func(): player.toggle_bounce())
	stime.start()
	var rotato: float = get_rotation()
	var xrot: float = cos(rotato)
	var yrot: float = sin(rotato)
	
	# Handle vertical or horizontal bounce
	if xrot == 0:
		player.velocity.x *= bounce_multiplier
	elif yrot == 0:
		player.velocity.y *= bounce_multiplier
	# Handle diagonal bounce
	else:
		player.velocity.x = abs(player.velocity.x) * 2 * xrot
		if player.velocity.x * xrot < 0:  # Flip if moving against xrot
			player.velocity.x *= -1
		player.velocity.y = abs(player.velocity.y) * 2 * yrot
		if player.velocity.y * yrot < 0:  # Flip if moving against yrot
			player.velocity.y *= -1
