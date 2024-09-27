extends Node2D
class_name CardManager

@export var max_cards: int = 5

var cards: Array[Card] = []

@onready var player: Player = get_parent()

# This looks more elegant than 5 if statements but is probably less efficient.
func get_card_input() -> int:
	for i in range(1, max_cards + 1):
		if Input.is_action_just_pressed("card_" + str(i)):
			return i
	return -1

func _ready() -> void:
	cards.resize(max_cards)
	for child in get_parent().get_children():
		print(child.name)
		if child is TestCard:
			cards[0] = child as TestCard
			return

func _physics_process(delta: float) -> void:
	var card_input := get_card_input()
	if card_input != -1 && cards[card_input - 1] != null:
		cards[card_input - 1].use(player)
