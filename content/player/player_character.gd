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

## Stores jump input as a time buffer.
var has_jump_input: float = 0.0;

## Stores card cycle inputs between physics frames.
var has_cycle_input: float = 0.0;

#endregion
