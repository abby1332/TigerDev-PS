extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	var stime := Timer.new()
	player.set_process_input(false)
	add_child(stime)
	stime.one_shot = true
	stime.autostart = false
	stime.wait_time = 1.2
	stime.timeout.connect(func(): player.set_process_input(true))
	var rebound_velocity: int
	if player.velocity.x > 0:
		if player.velocity.x > 600:
			if player.velocity.x > 1000:
				player.velocity.x += 400
				player.velocity.y *= -1
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, stime.time_left)
			else:
				player.velocity.x = 1000
				player.velocity.y *= -1
				player.velocity.y -= 100
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, stime.time_left)
		else:
			player.velocity.x = 800
			player.velocity.y = -600
			stime.start()
			rebound_velocity = player.velocity.x
			player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, stime.time_left)
	else:
		if player.velocity.x < -600:
			if player.velocity.x < -1000:
				player.velocity.x -= 400
				player.velocity.y *= -1
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, stime.time_left)
			else:
				player.velocity.x = -1000
				player.velocity.y *= -1
				player.velocity.y += 100
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, stime.time_left)
		else:
			player.velocity.x = 800
			player.velocity.y = 600
			stime.start()
			rebound_velocity = player.velocity.x
			player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, stime.time_left)
