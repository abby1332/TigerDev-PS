extends CanvasLayer
class_name CardManager

@export var initial_card_position: Node2D
@export var distance_between_cards: float = 50

@export var max_cards: int = 5

var cards: Array[Card] = []

@onready var player: Player = get_parent()

func give_card(card: Card) -> bool:
	if cards.size() >= max_cards:
		return false
	var sprite := card.sprite
	sprite.reparent(self)
	sprite.position = initial_card_position.position
	sprite.position.x += distance_between_cards * cards.size()
	sprite.show()
	cards.push_back(card)
	return true

func update_card_positions() -> void:
	for i in range(0, cards.size()):
		cards[i].sprite.position.x = initial_card_position.position.x + (distance_between_cards * i)

func use_card(card_index: int) -> bool:
	if card_index >= cards.size() or cards[card_index] == null:
		return false
	var card := cards[card_index]
	card.use(player)
	cards.remove_at(card_index)
	update_card_positions()
	return true

func send_top_card_to_back() -> void:
	if cards.size() < 2:
		return
	var card := cards.pop_front() as Card
	cards.push_back(card)
	update_card_positions()

func send_back_card_to_top() -> void:
	if cards.size() < 2:
		return
	var card := cards.pop_back() as Card
	cards.push_front(card)
	update_card_positions()

# This looks more elegant than 5 if statements but is probably less efficient.
func get_card_input() -> int:
	for i in range(1, max_cards + 1):
		if Input.is_action_just_pressed("card_" + str(i)):
			return i
	return -1

func _ready() -> void:
	for child in get_children():
		print(child.name)
		if child is TestCard:
			give_card(child as TestCard)
	print(cards)

func _physics_process(delta: float) -> void:
	var card_input := get_card_input()
	if card_input != -1:
		use_card(card_input - 1)
	
	if Input.is_action_just_pressed("send_top_card_to_back"):
		send_top_card_to_back()
	elif Input.is_action_just_pressed("send_back_card_to_top"):
		send_back_card_to_top()
