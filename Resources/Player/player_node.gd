class_name PlayerNode
extends CharacterBody2D

#region Typing

## Player's Curent Movestate
enum MoveState {
	# Standing On Ground
	Grounded,
	# Holding Wall
	Grasping,
	# In Air | No Jump / Launch Used
	Falling,
	# In Air | Jumped
	Jumping,
	# In Air | Launched From Wall
	Launching,
	# Activating Card
	Carding,
}

#endregion

#region Sub Nodes

# This is used to get the mouse position.
@onready var viewport: Viewport = get_viewport();

# Children Nodes
@export_category("Child Nodes")
@export var sprite: PlayerSprite;
@export var camera: Camera2D;
@export var collider: CollisionShape2D;
@export var head_raycast: RayCast2D;
@export var leg_raycast: RayCast2D;

#endregion

#region Movement Vars

## Defines the current state of and restricions on the player's movements.
var move_state: MoveState = MoveState.Falling;

## Stores the relevant direction & magnitude of a move state.
var move_direction: Vector2 = Vector2.ZERO;

## Time spent in current movement state. (s)
var hang_time: float = 0.0;

## True when player can jump.
var can_jump: bool = false;

## True when player can grasp a wall.
var can_grasp: bool = false;

## True when player can launch from a wall.
var can_launch: bool = false;

#endregion

#region Input Vars

## Stores directional input between physics frames.
var movement_input: Vector2 = Vector2.ZERO;

## Stores most recent directional input.
## Currently only used for wall launch.
var fresh_movement_input: Vector2 = Vector2.ONE;

## Stores card action input as a time buffer.
var has_card_input: float = 0.0;

## Stores jump input as a time buffer.
var has_jump_input: float = 0.0;

## Stores card cycle inputs between physics frames.
var has_cycle_input: float = 0.0;

#endregion

#region Private Funcs

func _process(dt: float) -> void:
	# Movement Input
	movement_input += Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") * dt;

	# Fresh Movement Input
	if Input.is_action_just_pressed(&"move_up"):
		has_jump_input = Mechanics.PLAYER_JUMP_BUFFER;
		fresh_movement_input.y = -1.0;
	elif Input.is_action_just_pressed(&"move_down"):
		fresh_movement_input.y = 1.0;
	if Input.is_action_just_pressed(&"move_right"):
		fresh_movement_input.x = 1.0;
	elif Input.is_action_just_pressed(&"move_left"):
		fresh_movement_input.x = -1.0;

	# Card Input
	if Input.is_action_just_pressed(&"use_card"):
		has_card_input = Mechanics.PLAYER_CARD_BUFFER;
	if Input.is_action_just_pressed(&"cycle_card_next"):
		has_cycle_input += dt;
	if Input.is_action_just_pressed(&"cycle_card_prev"):
		has_cycle_input -= dt;

	# Debug Tools
	if Input.is_action_just_pressed(&"debug_freeze"):
		breakpoint

	#if Input.is_action_just_pressed(&"debug_give_card"):
		#the_cards.add_card(1);

#endregion

#region MoveState Methods

func _can_set_move_state_grounded() -> bool:
	match move_state:
		MoveState.Grounded, MoveState.Grasping:
			return false;

		MoveState.Jumping, MoveState.Falling:
			return is_on_floor();

		MoveState.Launching:
			return is_on_floor() && hang_time > Mechanics.PLAYER_LAUNCH_STATE_DURATION;

		MoveState.Carding:
			# TODO - Figure out how to handle card states.
			return false;

		_:
			return false;
