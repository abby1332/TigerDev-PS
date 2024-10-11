extends CharacterBody2D
class_name Player

@export var card_manager: CardManager

@export var spawn_point: SpawnPoint
var respawn_point: RespawnPoint = null

@export var animation_manager: AnimatedSprite2D
@export var animation_idle: String = "default"
@export var animation_crouch: String = "crouch"

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

@export var regular_collider: CollisionShape2D
@export var crouching_collider: CollisionShape2D

@export var sliding_particles: GPUParticles2D
@export var death_particles: GPUParticles2D

@export var death_text: RichTextLabel

@export var death_plane: DeathPlane

@export var camera_manager: CameraManager

@onready var camera: Camera2D = get_viewport().get_camera_2d()

#region Wall Jumping

enum WallDirection {
	NONE,
	LEFT,
	RIGHT
}

@export var jump_from_wall_directional_velocity: float = 350.0

@export var climbable_wall_layer: int = 2

@export var wall_slow_multiplier: float = 0.1
@export var leaving_wall_jump_grace_period: float = 0.15

@export var max_sliding_stamina: int = 50

@export var jump_cut_strength: float = 0.5
@export var jump_input_buffer_time: float = 0.125

var sliding_on_wall: WallDirection = WallDirection.NONE

var sliding_stamina: int = max_sliding_stamina

var wall_jumping: bool = false
var wall_jumping_from: WallDirection = WallDirection.NONE
var leaving_wall: WallDirection = WallDirection.NONE

@warning_ignore("untyped_declaration") #reasoning: type of var is unknown until runtime
var last_wall_clinged_to = null

#endregion

var time_since_last_jump_input: float = 0.0
var has_jump_cut: bool = false

#region Crouching/Sliding

enum CrouchState {
	NORMAL, 
	CROUCHING, 
	SLIDING
}

var crouch_state: CrouchState = CrouchState.NORMAL

var crouch_speed_multiplier: float = 0.5

var time_sliding: float = 0.0

#endregion

var dead: bool = false

var direction: float = 0.0
var last_direction: float = 0.0

func respawn(point: RespawnPoint = respawn_point) -> void:
	death_particles.hide()
	death_particles.emitting = false
	if point != null:
		point.spawn_point.teleport(self)
	else:
		spawn_point.teleport(self)
	animation_manager.show()
	death_text.hide()
	dead = false
	velocity = Vector2(0.0, 0.0)
	
func die() -> void:
	if dead:
		return
	death_particles.show()
	death_particles.emitting = true
	death_particles.restart()
	animation_manager.hide()
	death_text.show()
	dead = true

# Checks which side of the player is sliding on a wall.
func sliding_on_wall_check() -> WallDirection:
	var space := get_world_2d().direct_space_state
	var left_query := PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(5, 0), climbable_wall_layer)
	var left_intersect := space.intersect_ray(left_query)
	if not left_intersect.is_empty():
		# Reset stamina if we fall off one wall then cling onto another
		if last_wall_clinged_to != left_intersect["collider"]:
			sliding_stamina = max_sliding_stamina
		if direction < 0 and sliding_stamina > 0:
			last_wall_clinged_to = left_intersect["collider"]
			return WallDirection.LEFT
	var right_query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(5, 0), climbable_wall_layer)
	var right_intersect := space.intersect_ray(right_query)
	if not right_intersect.is_empty():
		# Reset stamina if we fall off one wall then cling onto another
		if last_wall_clinged_to != right_intersect["collider"]:
			sliding_stamina = max_sliding_stamina
		if direction > 0 and sliding_stamina > 0:
			last_wall_clinged_to = right_intersect["collider"]
			return WallDirection.RIGHT
	if sliding_on_wall != WallDirection.NONE:
		leaving_wall = sliding_on_wall
		var leaving_wall_timer := Timer.new()
		add_child(leaving_wall_timer)
		leaving_wall_timer.wait_time = leaving_wall_jump_grace_period
		leaving_wall_timer.one_shot = true
		leaving_wall_timer.timeout.connect(_reset_leaving_wall)
		leaving_wall_timer.start()
	return WallDirection.NONE

# Resets the player's wall jumping variables.
func _reset_wall_jumping() -> void:
	wall_jumping = false
	wall_jumping_from = WallDirection.NONE
	
func _reset_leaving_wall() -> void:
	leaving_wall = WallDirection.NONE
	
#Checks the jump with input buffering
func _check_jump_input() -> bool:
	if time_since_last_jump_input > 0.0:
		return true
	else:
		return false

func crouch_state_check() -> CrouchState:
	if not Input.is_action_pressed("crouch"):
		var space := get_world_2d().direct_space_state
		var top_left_query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(-4, -5))
		var top_left_intersect := space.intersect_ray(top_left_query)
		var top_right_query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(4, -5))
		var top_right_intersect := space.intersect_ray(top_right_query)
		if (not top_left_intersect.is_empty() or not top_right_intersect.is_empty()) and crouch_state != CrouchState.NORMAL:
			return CrouchState.CROUCHING
		return CrouchState.NORMAL
	elif abs(velocity.x) > 1 and crouch_state != CrouchState.CROUCHING and is_on_floor():
		return CrouchState.SLIDING
	else:
		if sliding_on_wall != WallDirection.NONE:
			return CrouchState.NORMAL
		return CrouchState.CROUCHING
		
func animation_state_machine_update() -> void:
	if crouch_state == CrouchState.NORMAL:
		animation_manager.play(animation_idle)
	else:
		animation_manager.play(animation_crouch)

func update_crouch_state(_old_state: CrouchState, new_state: CrouchState) -> void:
	time_sliding = 0.0
	if new_state == CrouchState.NORMAL:
		crouching_collider.disabled = true
		regular_collider.disabled = false
	elif new_state == CrouchState.SLIDING:
		crouching_collider.disabled = false
		regular_collider.disabled = true
	else:
		crouching_collider.disabled = false
		regular_collider.disabled = true

func _ready() -> void:
	camera_manager.start(self)

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_respawn"):
		respawn()
	elif Input.is_action_just_pressed("debug_die"):
		die()
	
	if dead:
		return
	
	if global_position.y > death_plane.global_position.y:
		die()
		return
	
	# Get input movement direction.
	direction = Input.get_axis("left", "right")
	if direction != 0.0:
		last_direction = direction
	
	sliding_on_wall = sliding_on_wall_check()
	
	var updated_crouch_state := crouch_state_check()
	if updated_crouch_state != crouch_state:
		update_crouch_state(crouch_state, updated_crouch_state)
	crouch_state = updated_crouch_state
	
	if crouch_state == CrouchState.SLIDING:
		time_sliding += delta
		if abs(velocity.x) > 5:
			sliding_particles.emitting = true
		else:
			sliding_particles.emitting = false
	else:
		sliding_particles.emitting = false
	
	#Handles jump input buffer times
	time_since_last_jump_input -= delta
	if Input.is_action_just_pressed("jump"):
		time_since_last_jump_input = jump_input_buffer_time

	# Add the gravity.
	if not is_on_floor():
		if sliding_on_wall == WallDirection.NONE:
			if Input.is_action_pressed("crouch"):
				velocity += get_gravity() * 2 * delta
			else:
				velocity += get_gravity() * delta
		else:
			if(velocity.y < 0):
				velocity.y *= 0.95
				velocity += get_gravity() * delta
			else:
				velocity += (get_gravity() * wall_slow_multiplier) * delta

	if is_on_floor():
		sliding_stamina = max_sliding_stamina
		#Disables jump-cutting
		has_jump_cut = false
	elif sliding_on_wall != WallDirection.NONE:
		sliding_stamina -= 1

	# Handle the movement/deceleration.
	if direction and not wall_jumping and crouch_state != CrouchState.SLIDING:
		if crouch_state == CrouchState.CROUCHING:
			velocity.x += direction * speed * crouch_speed_multiplier
			velocity.x = clampf(velocity.x, -speed * crouch_speed_multiplier, speed * crouch_speed_multiplier)
		else:
			velocity.x += direction * speed
			velocity.x = clampf(velocity.x, -speed, speed)
	elif wall_jumping_from != WallDirection.NONE:
		if wall_jumping_from == WallDirection.LEFT:
			velocity.x = move_toward(velocity.x, jump_from_wall_directional_velocity, speed)
		else:
			velocity.x = move_toward(velocity.x, -jump_from_wall_directional_velocity, speed)
	else:
		if crouch_state != CrouchState.SLIDING:
			velocity.x *= 0.6
		elif time_sliding > 0.5:
			velocity.x *= 0.95
		velocity.x += move_toward(velocity.x, 0, speed)
		
	# Handle jump.
	if _check_jump_input() and not wall_jumping:
		if is_on_floor():
			#Resets the jump input buffer time if successful jump performed
			time_since_last_jump_input = 0.0
			#Enables jump-cutting
			has_jump_cut = true
			
			velocity.y = jump_velocity
		# If we are sliding on a wall
		elif sliding_on_wall != WallDirection.NONE or leaving_wall != WallDirection.NONE:
			if ((direction < 0 and sliding_on_wall == WallDirection.LEFT) or leaving_wall == WallDirection.LEFT) or ((direction > 0 and sliding_on_wall == WallDirection.RIGHT) or leaving_wall == WallDirection.RIGHT):
				#Resets the jump input buffer time if successful jump performed
				time_since_last_jump_input = 0.0
				#Enables jump-cutting
				has_jump_cut = true
				
				sliding_stamina = max_sliding_stamina
				wall_jumping = true
				velocity.y = jump_velocity * 0.75
				if sliding_on_wall != WallDirection.NONE:
					wall_jumping_from = sliding_on_wall
				else:
					wall_jumping_from = leaving_wall
				var reset_wall_jumping_timer := Timer.new()
				add_child(reset_wall_jumping_timer)
				reset_wall_jumping_timer.wait_time = 0.25
				reset_wall_jumping_timer.one_shot = true
				reset_wall_jumping_timer.timeout.connect(_reset_wall_jumping)
				reset_wall_jumping_timer.start()
	
	#Jump-cuts if the jump input is released during jump
	if !Input.is_action_pressed("jump") and has_jump_cut and sliding_on_wall == WallDirection.NONE and velocity.y < 0 and not is_on_floor():
		velocity.y = velocity.y * jump_cut_strength
		#Disables jump-cutting
		has_jump_cut = false

	if abs(velocity.x) > speed:
		velocity.x *= 0.95

	animation_state_machine_update()

	move_and_slide()
