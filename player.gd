extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var jump_from_wall_directional_velocity: float = 350.0

@export var climbable_wall_layer: int = 2

@export var wall_slow_multiplier: float = 0.1
@export var leaving_wall_jump_grace_period: float = 0.15

@export var max_sliding_stamina: int = 50

@export var jump_cut_strength: float = 0.5
@export var jump_input_buffer_time: float = 0.125

var time_since_last_jump_input: float = 0.0

# 0 = no wall, 1 = left wall, 2 = right wall
var sliding_on_wall: int = 0

var sliding_stamina: int = max_sliding_stamina

var _wall_jumping: bool = false
var has_jump_cut: bool = false
# 0 = no wall, 1 = left wall, 2 = right wall
var _wall_jumping_from: int = 0
var _leaving_wall: int = 0

@warning_ignore("untyped_declaration") #reasoning: type of var is unknown until runtime
var _last_wall_clinged_to = null

# Checks which side of the player is sliding on a wall.
func sliding_on_wall_check(direction: float) -> int:
	var space := get_world_2d().direct_space_state
	var left_query := PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(5, 0), climbable_wall_layer)
	var left_intersect := space.intersect_ray(left_query)
	if not left_intersect.is_empty():
		# Reset stamina if we fall off one wall then cling onto another
		if _last_wall_clinged_to != left_intersect["collider"]:
			sliding_stamina = max_sliding_stamina
		if direction < 0 and sliding_stamina > 0:
			_last_wall_clinged_to = left_intersect["collider"]
			return 1
	var right_query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(5, 0), climbable_wall_layer)
	var right_intersect := space.intersect_ray(right_query)
	if not right_intersect.is_empty():
		# Reset stamina if we fall off one wall then cling onto another
		if _last_wall_clinged_to != right_intersect["collider"]:
			sliding_stamina = max_sliding_stamina
		if direction > 0 and sliding_stamina > 0:
			_last_wall_clinged_to = right_intersect["collider"]
			return 2
	if sliding_on_wall != 0:
		_leaving_wall = sliding_on_wall
		var leaving_wall_timer := Timer.new()
		add_child(leaving_wall_timer)
		leaving_wall_timer.wait_time = leaving_wall_jump_grace_period
		leaving_wall_timer.one_shot = true
		leaving_wall_timer.timeout.connect(_reset_leaving_wall)
		leaving_wall_timer.start()
	return 0

# Resets the player's wall jumping variables.
func _reset_wall_jumping() -> void:
	_wall_jumping = false
	_wall_jumping_from = 0
	
func _reset_leaving_wall() -> void:
	_leaving_wall = 0
	
#Checks the jump with input buffering
func _check_jump_input() -> bool:
	if time_since_last_jump_input > 0.0:
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	# Get input movement direction.
	var direction := Input.get_axis("left", "right")
	
	sliding_on_wall = sliding_on_wall_check(direction)
	
	#Handles jump input buffer times
	time_since_last_jump_input -= delta
	if Input.is_action_just_pressed("jump"):
		time_since_last_jump_input = jump_input_buffer_time

	# Add the gravity.
	if not is_on_floor():
		if sliding_on_wall == 0:
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
	elif sliding_on_wall != 0:
		sliding_stamina -= 1

	# Handle the movement/deceleration.
	if direction and not _wall_jumping:
		velocity.x = direction * speed
	elif _wall_jumping_from != 0:
		if _wall_jumping_from == 1:
			velocity.x = move_toward(velocity.x, jump_from_wall_directional_velocity, speed)
		else:
			velocity.x = move_toward(velocity.x, -jump_from_wall_directional_velocity, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	# Handle jump.
	if _check_jump_input() and not _wall_jumping:
		if is_on_floor():
			#Resets the jump input buffer time if successful jump performed
			time_since_last_jump_input = 0.0
			#Enables jump-cutting
			has_jump_cut = true
			
			velocity.y = jump_velocity
		# If we are sliding on a wall
		elif sliding_on_wall != 0 or _leaving_wall != 0:
			if ((direction < 0 and sliding_on_wall == 1) or _leaving_wall == 1) or ((direction > 0 and sliding_on_wall == 2) or _leaving_wall == 2):
				#Resets the jump input buffer time if successful jump performed
				time_since_last_jump_input = 0.0
				#Enables jump-cutting
				has_jump_cut = true
				
				sliding_stamina = max_sliding_stamina
				_wall_jumping = true
				velocity.y = jump_velocity * 0.75
				if sliding_on_wall != 0:
					_wall_jumping_from = sliding_on_wall
				else:
					_wall_jumping_from = _leaving_wall
				var reset_wall_jumping_timer := Timer.new()
				add_child(reset_wall_jumping_timer)
				reset_wall_jumping_timer.wait_time = 0.25
				reset_wall_jumping_timer.one_shot = true
				reset_wall_jumping_timer.timeout.connect(_reset_wall_jumping)
				reset_wall_jumping_timer.start()
	
	#Jump-cuts if the jump input is released during jump
	if !Input.is_action_pressed("jump") and has_jump_cut and sliding_on_wall == 0 and velocity.y < 0 and not is_on_floor():
		velocity.y = velocity.y * jump_cut_strength
		#Disables jump-cutting
		has_jump_cut = false;

	move_and_slide()
