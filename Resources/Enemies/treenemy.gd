extends CharacterBody2D
class_name BasicEnemy

#1/4 as fast as the player
@export var speed: float = 50

#Is the enemy currently chasing the player? Will only chase if theyre close
var is_chasing: bool = true
#Wander around when not attacking the player
var is_roaming: bool = false
#Is the player close enough to chase
var player_in_range = false

var movement_disabled = false

#Distance where enemy will start chasing
@export var start_chase_distance: float = 100
#Distance to stop chasing
@export var stop_chase_distance: float = 150

#When hit, the enemy will be knocked backwards
var knockback_force = -20

var dead: bool = false

#Halt other animations/actions when attacked
var taking_damage: bool = false
#Trigger damage animation
var is_dealing_damage: bool = false

#It can go left or right no jumping
var dir: Vector2

@onready var player: Player = Player.player

@onready var damage_zone = $DealDamageArea

@onready var general_area: Area2D = $GeneralCollision
@onready var general_collider: CollisionShape2D = $GeneralCollision/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta):
	if !is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	check_player_distance()
	move(delta)
	move_and_slide()
	update_animation()


#Update animation based on direction
func update_animation() -> void:
	if dir.x < 0:  #Move left
		sprite.play("L_tree")
	else:
		sprite.play("R_tree")


# -1 for approaching left edge, 0 for none, 1 for approaching right edge
func approaching_edge() -> int:
	if !is_on_floor():
		return 0
	var space := get_world_2d().direct_space_state
	var rect := general_collider.shape.get_rect().size
	var left_query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(-rect.x / 2 - 1, rect.y / 2 + 1),
		general_area.collision_mask
	)
	var left_intersect := space.intersect_ray(left_query)
	if left_intersect.is_empty():
		return -1
	var right_query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(rect.x / 2 + 1, rect.y / 2 + 1),
		general_area.collision_mask
	)
	var right_intersect := space.intersect_ray(right_query)
	if right_intersect.is_empty():
		return 1
	return 0


#Determines if the enemy should be chasing, roaming, or dying
func move(delta) -> void:
	if !is_instance_valid(player):
		return
	if movement_disabled:
		if abs(velocity.x) > speed:
			velocity.x *= 0.95
		return
	if !dead:
		if !is_chasing:
			if is_on_wall():  #Switch directions every time it hits a wall
				dir.x *= -1
				velocity.x += dir.x * speed
		#If the enemy is taking damage it wont be moving
		elif is_chasing and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			#Don't let it chase player through the air
			velocity.x += dir_to_player.x
			velocity.x = clampf(velocity.x, -speed, speed)
			#Makes character turn left or right
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x += knockback_dir.x
			is_roaming = true
	else:
		#Removes sliding when dead
		velocity.x = 0
	if abs(velocity.x) > speed:
		velocity.x *= 0.95
	var edge = approaching_edge()
	if is_chasing and player.global_position.y <= global_position.y:
		if edge < 0:
			velocity.x = max(0, velocity.x)
		elif edge > 0:
			velocity.x = min(0, velocity.x)
	elif !is_chasing:
		if edge < 0:
			velocity.x = max(0, velocity.x)
			dir *= -1
		elif edge > 0:
			velocity.x = min(0, velocity.x)
			dir *= -1


func disable_movement(seconds: float) -> void:
	movement_disabled = true
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = seconds
	timer.one_shot = true
	var timeout := func() -> void: movement_disabled = false
	timer.timeout.connect(timeout)
	timer.start()


var being_murdered: bool = false


func die() -> void:
	queue_free()


# Reverse direction when hitting a spike trap
#func _on_spike_trap_area_entered(body: Node2D) -> void:
#if body == self:  # Ensure it is the enemy itself that hit the spike
#dir.x *= -1  # Reverse direction on spike hit
#velocity.x = dir.x * speed  # Update velocity after direction change


#If player enterse the damage collision zone, player dies
func _on_deal_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var player := body as Player
		if player.kill_everything_mode and not being_murdered:
			being_murdered = true
			await FreezeFrameManager.zoom_frame(0.05, 0.5, 1.5)
			PlayerSoundMachine.main.stream("EnemyHitSound").play()
			die()
			return
		player.die()


# Check the distance between enemy and player to determine chasing/roaming
func check_player_distance() -> void:
	if !is_instance_valid(player):
		return
	#Chase player when it gets too close
	if player and !dead:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player < start_chase_distance:
			is_chasing = true
		#Start roaming when the player is dead or leaves area
		elif (distance_to_player > stop_chase_distance) or player.dead:
			is_chasing = false
			is_roaming = true


func _on_general_collision_area_entered(area: Area2D) -> void:
	if area is SpikeTrap:
		# Reverse direction
		dir.x *= -1
		# Update velocity
		velocity.x += dir.x * speed * -knockback_force / 3
		disable_movement(0.5)
