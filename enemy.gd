extends CharacterBody2D
class_name BasicEnemy

const speed = 10
var is_chase: bool = true #Is the enemy currently chasing the player? Will only chase if theyre close
var is_roaming: bool  = false #Wander around when not attacking the player
var dead: bool = false
var taking_damage: bool = false #Halt other animations/actions when attacked
var is_dealing_damage: bool = false #Trigger damage animation
var dir: Vector2 #He can go left or right no jumping
const gravity = 900 
var knockback_force = -20 #When hit, the enemy will be knocked backwards
@export var player: CharacterBody2D #Remember to set player in scene inspector
var player_in_range = false #Is the player close enough to chase
@onready var damage_zone = $DealDamageArea

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	move_and_slide()

#Determines if the enemy should be chasing, roaming, or dying
func move(delta):
	if !dead:
		if !is_chase:
			velocity += dir * speed * delta #wander if we arent chasing
		elif is_chase and !taking_damage: #If the enemy is taking damage it wont be moving
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x #Don't let him chase player through the air
			dir.x = abs(velocity.x) / velocity.x #Makes character turn left or right
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0 #No sliding around plz
		
#When the enemy is wandering, it will move back and forth at random
func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0 #No sliding plz
func choose(array):
	array.shuffle()
	return array.front()

func _on_deal_damage_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.die()