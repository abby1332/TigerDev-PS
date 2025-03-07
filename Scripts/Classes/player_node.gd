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
	# Charging Card
	Charging,
	# Activating Card
	Releasing,
}

#endregion

#region References

# This is used to get the mouse position.
@onready var viewport: Viewport = get_viewport();

#endregion
