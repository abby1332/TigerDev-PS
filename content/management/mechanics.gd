## Values of gameplay mechanics.

extends Node

#region Asset Consts

const PLAYER_SPRITE_WIDTH: float = 14.0;

const PLAYER_SPRITE_HEIGHT: float = 32.0;

const  VIEWPORT_WIDTH: float = 1280;

const VIEWPORT_HEIGHT: float = 720;

const PLAYER_SIDE_RAY_LENGTH: float = 8.0;

#endregion

#region Physics Values

## Maximum speed under standard movement conditions. (px/s)
const PLAYER_TERMINAL_VELOCITY: Vector2 = Vector2(1960.0, 450.0);

## Player gravitatonal acceleration. (px/s^2)
const PLAYER_GRAVITY: float = 980.0;

## Maximum run speed. (px/s)
const PLAYER_TOP_HORIZONTAL_SPEED: float = 300.0;

## Acceleration of player while running. (px/s^2)
const PLAYER_HORIZONTAL_ACCELERATION: float = 600.0;

## Slash ability speed. (px/s)
const PLAYER_SLASH_SPEED: float = 450.0;

## Wall slide vertical speed. (px/s)
const PLAYER_WALL_SLIDE_SPEED: float = 50.0;

## Initial vertical speed of jump. (px/s)
const PLAYER_JUMP_FORCE: float = -300.0;

## Initial velocity of wall launch. (px/s)
const PLAYER_LAUNCH_FORCE: Vector2 = Vector2(300.0, -300.0);

#endregion

#region Buffers

## Maximum period after touching ground that player can jump. (s)
const PLAYER_GROUNDED_BUFFER: float = 0.1;

## Maximum period after grasping wall that player can re-grasp. (s)
const PLAYER_GRASPING_BUFFER: float = 0.1;

## Maximum period after grasping wall that player can launch. (s)
const PLAYER_LAUNCHING_BUFFER: float = 0.2;

## Maximum period jump input is buffered for. (s)
const PLAYER_JUMP_BUFFER: float = 0.2;

## Maximum period card input is buffered for. (s)
const PLAYER_CARD_BUFFER: float = 0.1;

#endregion

#region Timers & Durations

## Maximum duration player can hold space for while jumping to continue rising. (s)
const PLAYER_JUMP_HOLD_DURATION: float = 0.5;

## Maximum duration player can grasp a wall for. (s)
const PLAYER_WALL_GRASP_DURATION: float = 0.25;

## Maximum duration of `Grasping` state. (s)
## Doesn't stack with `PLAYER_WALL_GRASP_DURATION`
const PLAYER_WALL_SLIDE_DURATION: float = 1.0;

## Maximum duration of `Launching` state. (s)
const PLAYER_LAUNCH_STATE_DURATION: float = 0.1;

## Maximum duration of `Slashing` state. (s)
const PLAYER_SLASH_STATE_DURATION: float = 0.25;

#endregion

#region Thresholds & Ratios & Multipliers

## Minimum required dot product between the slash direction and a surface
## for the player to slide over the surface.
const PLAYER_SLASH_SLIDE_THRESHOLD: float = -0.9;

## Modifier to player horizontall acceleration while in air.
const PLAYER_AIR_STRAFE_MULTIPLIER: float = 0.5;

## Player gravitatonal acceleration modifier while holding jump.
const PLAYER_JUMP_FLOAT_RATIO: float = 0.5;

## Rate of passive player horizontall deceleration compared to acceleration.
const PLAYER_DECELERATION_RATIO: float = 0.9;

#endregion
