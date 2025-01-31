extends CanvasLayer
class_name CardManager
## Card Manager masterclass
##
## "Any code of your own that you haven't looked at for six or more months might as well have been written by someone else."
## - Eagleson's Law
##
## Manages the mechanics and animations of cards.

## The initial relative position of the cards on the screen. This should be in the bottom leftish area
@export var initial_card_position: Node2D
## The distance between cards in pixels
@export var distance_between_cards: float = 50

## Maximum amount of cards the player can hold at any given time
@export var max_cards: int = 5

## Default multiplier for card scale
@export var card_scale: Vector2 = Vector2(0.5, 0.5)

## Current cards in the players hand
var cards: Array[Card] = []

## The player.
@onready var player: Player = get_parent()

## Cards currently being animated & how long their animations have been playing. Would be a typed dictionary if we were using 4.4.
var animated_cards: Dictionary = {}

## If the player can use the scroll wheel, prevents spamming
var scroll_ready: bool = true

## Keeps track of which card spawners are depleted for the respawn manager.
var used_card_spawners: Array[String] = []


## Class that handles all the animations for a specific card
class CardAnimationInstance:
	## The card being animated
	var animated_card: Card
	## The sprite of the card being animated
	var animated_card_sprite: Sprite2D
	## The type of animation to be performed
	var animation_type: String
	## A quick reference for the card manager
	var cm: CardManager

	@warning_ignore("untyped_declaration")  #reasoning: constructors cannot have explicit return types

	## The type parameter is the animation type. No idea why it's not an enum but I don't care anymore.
	func _init(card: Card, type: String, card_manager: CardManager) -> void:
		animated_card = card
		animated_card_sprite = card.sprite
		animation_type = type
		cm = card_manager

	## Based on the animation type, get the position a card should be at when 0<=t<=1
	func get_position_at_time(t: float, anim_type: String = animation_type) -> Vector2:
		match anim_type:
			# When a card is being moved from the front of the hand to the back
			"scroll_to_back":
				return get_point_on_bezier_at_time(
					cm.initial_card_position.position,
					(
						cm.initial_card_position.position
						+ Vector2(cm.distance_between_cards * (cm.cards.size() - 1), 0)
					),
					Vector2(
						cm.initial_card_position.position.x,
						cm.initial_card_position.position.y - cm.initial_card_position.position.x
					),
					Vector2(
						(
							cm.initial_card_position.position.x
							+ cm.distance_between_cards * (cm.cards.size() - 1)
						),
						cm.initial_card_position.position.y - cm.initial_card_position.position.x
					),
					t
				)
			# Reverse of scroll_to_back, i.e. when a card is being moved from the back to the front
			# Uses the scroll_to_back animation but reversed
			"scroll_to_front":
				animated_card.z_index = 0
				return get_position_at_time(1 - t, "scroll_to_back")
			# When a card is picked up and is rising from offscreen into the hand
			"rise":
				return get_point_for_rise(min(1, t * 2))
			# When the card is sliding left in the hand
			"slide_left":
				return get_point_for_slide_left(min(1, t * 3))
			# When the card is sliding right in the hand
			"slide_right":
				return get_point_for_slide_right(min(1, t * 3))
			# If the anim_type is unknown made the card do a little jig
			_:
				return Vector2(
					cm.initial_card_position.x * t * 25, cm.initial_card_position.y * t * 25
				)

	## Updates the position of a card based on its animation type and how long the animation has been playing
	func animate_card_sprite_pos(t: float) -> void:
		if animated_card_sprite == null:
			return
		animated_card_sprite.position = get_position_at_time(t)

	## Bezier curve function with 4(?) points. I don't remember how it works.
	# Heisted from: https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html
	func get_point_on_bezier_at_time(
		p1: Vector2, p2: Vector2, c1: Vector2, c2: Vector2, t: float
	) -> Vector2:
		var q0 := p1.lerp(c1, t)
		var q1 := c1.lerp(c2, t)
		var q2 := c2.lerp(p2, t)

		var r0 := q0.lerp(q1, t)
		var r1 := q1.lerp(q2, t)

		return r0.lerp(r1, t)

	## Animation for rising
	func get_point_for_rise(t: float) -> Vector2:
		return Vector2(
			(
				cm.initial_card_position.position.x
				+ cm.distance_between_cards * cm.cards.find(animated_card)
			),
			cm.initial_card_position.position.y + ((1 - t) * animated_card_sprite.get_rect().size.y)
		)

	## Animation for sliding left
	func get_point_for_slide_left(t: float) -> Vector2:
		var i := cm.cards.find(animated_card)
		return Vector2(
			(
				cm.initial_card_position.position.x
				+ (cm.distance_between_cards * (i + 1) - cm.distance_between_cards * t)
			),
			cm.initial_card_position.position.y
		)

	## Animation for sliding right
	func get_point_for_slide_right(t: float) -> Vector2:
		var i := cm.cards.find(animated_card)
		return Vector2(
			(
				cm.initial_card_position.position.x
				+ (cm.distance_between_cards * (i - 1) + cm.distance_between_cards * t)
			),
			cm.initial_card_position.position.y
		)


## Adds the card to the dictionary of animated cards
func add_card_to_animated_cards(card: Card, type: String) -> void:
	# Erases any CardAnimationInstances that have this card
	for ca: CardAnimationInstance in animated_cards:
		if ca.animated_card == card:
			animated_cards.erase(ca)
			break
	animated_cards[CardAnimationInstance.new(card, type, self)] = 0
	update_card_order()


## If the hand is full returns true
func is_full() -> bool:
	return cards.size() >= max_cards


## If the hand is empty returns false
func is_empty() -> bool:
	return cards.size() == 0


## Gives the player a card and places it in their hand. Returns false if the player already has the max cards
func give_card(card: Card) -> bool:
	# If the player has max cards then fail
	if cards.size() >= max_cards:
		return false
	card.reparent(self)
	# IMPORTANT: take note of how the sprite is the only thing actually being scaled or animated. The card itself is not affected.
	var sprite := card.sprite
	sprite.reparent(self)
	sprite.position = initial_card_position.position
	sprite.position.x += distance_between_cards * cards.size()
	sprite.scale = card_scale
	sprite.show()
	cards.push_back(card)
	add_card_to_animated_cards(card, "rise")
	return true


## Do not use this function except for when the cards need to have their positions updated instantly (which should be never)
func instant_update_card_positions() -> void:
	for i in range(0, cards.size()):
		cards[i].sprite.position.x = initial_card_position.position.x + (distance_between_cards * i)


## Fixes the z_index of each of the cards
func update_card_order() -> void:
	for i in range(0, cards.size()):
		if is_instance_valid(cards[i]):
			if is_instance_valid(cards[i].sprite):
				cards[i].sprite.z_index = cards.size() - i


## Uses a card and destroys it, shifting all cards that were to the right of the card to the left
func use_card(card_index: int) -> bool:
	if card_index >= cards.size() or cards[card_index] == null:
		return false
	var card := cards[card_index]
	card.use(player)
	cards.remove_at(card_index)
	# Do the stupid shuffle as the kids say
	for i in range(card_index, cards.size()):
		add_card_to_animated_cards(cards[i], "slide_left")
	return true


## Moves the "top" (leftmost) card to the "back" (right end) and animates it accordingly
func send_top_card_to_back() -> void:
	if cards.size() < 2:
		return
	var card := cards.pop_front() as Card
	cards.push_back(card)
	for c: Card in cards:
		if c == card:
			continue
		add_card_to_animated_cards(c, "slide_left")
	add_card_to_animated_cards(card, "scroll_to_back")


## Moves the "back" (rightmost) card to the "top" (left end) and animates it accordingly
func send_back_card_to_top() -> void:
	if cards.size() < 2:
		return
	var card := cards.pop_back() as Card
	cards.push_front(card)
	for c: Card in cards:
		if c == card:
			continue
		add_card_to_animated_cards(c, "slide_right")
	add_card_to_animated_cards(card, "scroll_to_front")


## Gets the card input being pressed this frame.
##If multiple are being pressed at once, it prioritizes the leftmost one (lower numbers on the keyboard)
func get_card_input() -> int:
	# This looks more elegant than 5 if statements but is probably less efficient.
	for i in range(1, max_cards + 1):
		if Input.is_action_just_pressed("card_" + str(i)):
			return i
	return -1


## Resets the scroll, after begin_scroll_reset_timer()
func reset_scroll() -> void:
	scroll_ready = true


## Resets the scroll after a 0.2 sec delay
func begin_scroll_reset_timer() -> void:
	scroll_ready = false
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(reset_scroll)
	timer.start()


func _ready() -> void:
	show()


func _process(delta: float) -> void:
	# Updates the animations for each animated card
	for ca: CardAnimationInstance in animated_cards.keys():
		var t := animated_cards[ca] as float
		if t > 1:
			animated_cards.erase(ca)
			continue
		ca.animate_card_sprite_pos(t)
		animated_cards[ca] += delta


func _physics_process(_delta: float) -> void:
	var card_input := get_card_input()
	if card_input != -1:
		use_card(card_input - 1)

	# If we are scrolling to send the card to the back, do that
	if Input.is_action_just_pressed("send_top_card_to_back") and scroll_ready:
		send_top_card_to_back()
		begin_scroll_reset_timer()
	# Like the first thing but backwards
	elif Input.is_action_just_pressed("send_back_card_to_top") and scroll_ready:
		send_back_card_to_top()
		begin_scroll_reset_timer()
