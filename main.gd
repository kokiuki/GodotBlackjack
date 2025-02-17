extends Control

var deck = []
var player_hand = []
var dealer_hand = []

func _ready():
	initialize_deck()
	shuffle_deck()
	deal_initial_cards()
	$VBoxContainer/GameOverLabel.visible = false
	$VBoxContainer/HitButton.connect("pressed", self._on_HitButton_pressed)
	$VBoxContainer/StandButton.connect("pressed", self._on_StandButton_pressed)


func initialize_deck():
	var suits = ["hearts", "diamonds", "clubs", "spades"]
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	for suit in suits:
		for value in values:
			deck.append({"suit": suit, "value": value})
		if deck.size() > 0:
			player_hand.append(deck.pop_back())

func shuffle_deck():
	deck.shuffle()

func deal_initial_cards():
	player_hand.append(deck.pop_back())
	dealer_hand.append(deck.pop_back())
	player_hand.append(deck.pop_back())
	dealer_hand.append(deck.pop_back())
	update_hand_display()

func update_hand_display():
	var player_hand_node = $VBoxContainer/Player_Hand
	var dealer_hand_node = $VBoxContainer/Dealer_Hand

	# Clear previous cards
	for child in player_hand_node.get_children():
		child.queue_free()
	for child in dealer_hand_node.get_children():
		child.queue_free()

	# Load Card Scene once
	var card_scene = preload("res://Card.tscn")

	# Display player's hand
	for card in player_hand:
		var card_instance = card_scene.instantiate()  
		card_instance.set_card(card)
		player_hand_node.add_child(card_instance)

	# Display dealer's hand
	for card in dealer_hand:
		var card_instance = card_scene.instantiate() 
		card_instance.set_card(card)
		dealer_hand_node.add_child(card_instance)


	# Display dealer's hand
	for card in dealer_hand:
		var card_instance = card_scene.instantiate() 
		card_instance.set_card(card)
		dealer_hand_node.add_child(card_instance)


func _on_HitButton_pressed():
	player_hit()

func _on_StandButton_pressed():
	player_stand()

func player_hit():
	if deck.size() > 0:
		player_hand.append(deck.pop_back())
		update_hand_display()
		if calculate_hand_value(player_hand) > 21:
			game_over("Player Busts!")
	else:
		game_over("No more cards in the deck!")

func player_stand():
	dealer_turn()

func calculate_hand_value(hand):
	var value = 0
	var aces = 0
	for card in hand:
		if card.value in ["J", "Q", "K"]:
			value += 10
		elif card.value == "A":
			aces += 1
			value += 11
		else:
			value += int(card.value)
	
	while value > 21 and aces > 0:
		value -= 10
		aces -= 1
	
	return value
	
func dealer_turn():
	while calculate_hand_value(dealer_hand) < 17 and deck.size() > 0:
		dealer_hand.append(deck.pop_back())

	update_hand_display()  # Update after dealer finishes drawing

	if calculate_hand_value(dealer_hand) > 21:
		game_over("Dealer Busts! Player Wins!")
	else:
		determine_winner()


func game_over(message):
	var game_over_label = $VBoxContainer.get_node_or_null("GameOverLabel")
	if game_over_label:
		game_over_label.text = message
		game_over_label.visible = true
	else:
		print("Error: GameOverLabel not found!")

	$VBoxContainer/GameOverLabel.visible = true
	$VBoxContainer/HitButton.disabled = true
	$VBoxContainer/StandButton.disabled = true

func determine_winner():
	var player_value = calculate_hand_value(player_hand)
	var dealer_value = calculate_hand_value(dealer_hand)
	
	if player_value > dealer_value:
		game_over("Player Wins!")
	elif player_value < dealer_value:
		game_over("Dealer Wins!")
	else:
		game_over("It's a Tie!")
