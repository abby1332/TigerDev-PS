extends CharacterBody2D

#region Typing

enum MoveState {
	Grounded, # On Ground; Free To Move
	Jumping, # Jumping; In Air
	Falling, # Falling; In Air But Didn't Jump (e.g. Walked Off Of Platform)
	Grasping, # Holding Wall
	Launching, # Jumped From Wall
	Slashing, # Slash Card
	Stomping, # Stomp Card
}

#endregion

#region Exports & Onreadys

@export_category("Level Dependant Items")
@export var spawn_point: SpawnPoint;

@export_category("Player Scene Items")
@export var cards: CardManager;
@export var sprite: PlayerSprite2D;
@export var camera: Camera2D;
@export var head_raycast: RayCast2D;
@export var leg_raycast: RayCast2D;

@onready var viewport: Viewport = get_viewport();

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

## Index of most recent card to be activated.
var last_active_card: int = 0;

## Stores jump input as a time buffer.
var has_jump_input: float = 0.0;

## Stores card cycle inputs between physics frames.
var has_cycle_input: float = 0.0;

#endregion

#region Node Funcs

func _ready() -> void:
	pass

#endregion

#region Internal Funcs

func check_input(dt: float) -> void:
	# Movement Input
	movement_input = Input.get_vector(&"left", &"right", &"up", &"crouch") * dt;

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

	# Takes card input when there isn't any buffered input.
	if last_active_card == 0:
		if Input.is_action_just_pressed(&"card_1"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card == 1;
		elif Input.is_action_just_pressed(&"card_2"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card == 2;
		elif Input.is_action_just_pressed(&"card_3"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card == 3;
		elif Input.is_action_just_pressed(&"card_4"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card == 4;
		elif Input.is_action_just_pressed(&"card_5"):
			has_card_input = Mechanics.PLAYER_CARD_BUFFER;
			last_active_card == 5;

	# Cycle Card Input
	if Input.is_action_just_pressed(&"send_top_card_to_back"):
		has_cycle_input += dt;
		if last_active_card != 0:
			last_active_card = 5 if last_active_card == 1 else last_active_card - 1;
	if Input.is_action_just_pressed(&"send_back_card_to_top"):
		has_cycle_input -= dt;
		if last_active_card != 0:
				last_active_card =1 if last_active_card == 5 else last_active_card + 1;

	if Input.is_action_just_pressed(&"debug_freeze"):
		breakpoint

#endregion
