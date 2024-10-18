extends CharacterBody2D
class_name BasicEnemy

#1/4 as fast as the player
@export var speed: float = 50

#Is the enemy currently chasing the player? Will only chase if theyre close
var is_chasing: bool = true 
#Wander around when not attacking the player
var is_roaming: bool  = false 
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

@onready var player: Player = RespawnManager.player

@onready var damage_zone = $DealDamageArea

func _physics_process(delta):
	if !is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	check_player_distance()
	move(delta)
	move_and_slide()

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
			if is_on_wall(): #Switch directions every time it hits a wall
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

func disable_movement(seconds: float):
	movement_disabled = true
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = seconds
	timer.one_shot = true
	var timeout := func () -> void: movement_disabled = false
	timer.timeout.connect(timeout)
	timer.start()

# Reverse direction when hitting a spike trap
#func _on_spike_trap_area_entered(body: Node2D) -> void:
	#if body == self:  # Ensure it is the enemy itself that hit the spike
		#dir.x *= -1  # Reverse direction on spike hit
		#velocity.x = dir.x * speed  # Update velocity after direction change

#If player enterse the damage collision zone, player dies
func _on_deal_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var player := body as Player
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
