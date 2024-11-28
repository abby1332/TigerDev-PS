extends Area2D

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
	if xrot == 0:
		player.velocity.x *= -1.1
	elif yrot == 0:
		player.velocity.y *= -1.1
	elif xrot > 0 and yrot > 0:
		if player.velocity.x < 0:
			player.velocity.x *= -1
		player.velocity.x *= 2 * xrot
		if player.velocity.y < 0:
			player.velocity.y *= -1
		player.velocity.y *= 2 * yrot
	elif xrot < 0 and yrot > 0:
		if player.velocity.x > 0:
			player.velocity.x *= -1
		player.velocity.x *= 2 * xrot
		if player.velocity.y < 0:
			player.velocity.y *= -1
		player.velocity.y *= 2 * yrot
	elif xrot < 0 and yrot < 0:
		if player.velocity.x > 0:
			player.velocity.x *= -1
		player.velocity.x *= 2 * xrot
		if player.velocity.y < 0:
			player.velocity.y *= -1
		player.velocity.y *= 2 * yrot
		
