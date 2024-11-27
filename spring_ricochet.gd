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
	player.velocity.y = 700 * sin(rotato)
	player.velocity.x += 400 * cos(rotato)
