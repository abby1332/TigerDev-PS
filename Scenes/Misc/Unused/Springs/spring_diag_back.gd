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
				player.velocity.x *= -1
				player.velocity.x -= 400
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, .000001)
			else:
				player.velocity.x = -1200
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, .000001)
		else:
			player.velocity.x = -1000
			stime.start()
			rebound_velocity = player.velocity.x
			player.velocity.x = lerp(rebound_velocity, rebound_velocity + 400, .000001)
	else:
		if player.velocity.x < -600:
			if player.velocity.x < -1000:
				player.velocity.x = 1400
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, .000001)
			else:
				player.velocity.x = 1200
				stime.start()
				rebound_velocity = player.velocity.x
				player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, .000001)
		else:
			player.velocity.x = 1000
			stime.start()
			rebound_velocity = player.velocity.x
			player.velocity.x = lerp(rebound_velocity, rebound_velocity - 400, .000001)
	if player.velocity.y > 0:
		if player.velocity.y > 600:
			if player.velocity.y > 1000:
				player.velocity.y *= -1
			else:
				player.velocity.y *= -1
				player.velocity.y -= 100
		else:
			player.velocity.y = -600
	else:
		if player.velocity.y < -600:
			if player.velocity.y < -1000:
				player.velocity.y *= -1
			else:
				player.velocity.y *= -1
				player.velocity.y += 100
		else:
			player.velocity.y = 700
