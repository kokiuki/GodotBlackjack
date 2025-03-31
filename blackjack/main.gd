extends Control

# Arrays to store the deck and hands of the player and dealer
var deck = []
var player_hand = []
var dealer_hand = []
#var set_card = []
var player_lost = false # Track if the player has lost
var player_wins = 0 # Count of player wins
var player_losses = 0  # Count of player losses

# Difficulty settings, affecting gameplay mechanics
var difficulty_parameters = {
	"Easy": {
		"max_dealer_score": 17,
		"player_starting_money": 1000,
		"deck_size": 6,
		"dealer_hit_threshold": 16
	},
	"Normal": {
		"max_dealer_score": 17,
		"player_starting_money": 500,
		"deck_size": 4,
		"dealer_hit_threshold": 17
	},
	"Hard": {
		"max_dealer_score": 16,
		"player_starting_money": 300,
		"deck_size": 2,
		"dealer_hit_threshold": 18
	}
}

# Game parameters, initially set to Normal difficulty
var max_dealer_score = 17
var player_starting_money = 500
var deck_size = 4
var dealer_hit_threshold = 17
var selected_difficulty = "Normal"  # Default difficulty

var auto_ready_timer = Timer.new()  # Timer for auto-starting next round

# Signals
signal game_started

# UI element references
@onready var ready_button = $"Ready Button"
@onready var hit_button = $HitButton
@onready var stand_button = $StandButton
@onready var game_over_label = $GameOverLabel
@onready var score_label = $"Labels/Score Label"
@onready var player_hand_value = $Labels/PlayerHandValue
@onready var dealer_hand_value = $"Labels/DealerHand Value"
@onready var go_back_button = $GoBackButton
@onready var ready_timer = $"Ready Button/AutoReadyTimer"

# Called when the scene is loaded
func _ready():
	# Apply the selected difficulty settings
	set_difficulty_parameters(selected_difficulty)
	initialize_deck()
	shuffle_deck()
	start_game_loop()
	
	# Hide the cards and hand values initially
	$VBoxContainer/Player_Hand.visible = false
	$VBoxContainer2/Dealer_Hand.visible = false
	player_hand_value.visible = false
	dealer_hand_value.visible = false
	
	# Set up and attach the auto-ready timer
	auto_ready_timer.wait_time = 5.0
	auto_ready_timer.one_shot = true
	auto_ready_timer.connect("timeout", Callable(self, "_on_AutoReadyTimer_timeout"))
	add_child(auto_ready_timer)
	
	# Connect button signals to their respective functions
	$"Ready Button".connect("pressed", self._on_ReadyButton_pressed)
	$GameOverLabel.visible = false
	$HitButton.connect("pressed", self._on_HitButton_pressed)
	$StandButton.connect("pressed", self._on_StandButton_pressed)
	$GoBackButton.connect("pressed", self._on_GoBackButton_pressed)

# Sets the game parameters based on the selected difficulty
func set_difficulty_parameters(difficulty):
	var params = difficulty_parameters[difficulty]
	max_dealer_score = params["max_dealer_score"]
	player_starting_money = params["player_starting_money"]
	deck_size = params["deck_size"]
	dealer_hit_threshold = params["dealer_hit_threshold"]

# Shows the ready screen before starting a game round
func show_ready_screen():
	$GameOverLabel.visible = true
	$GameOverLabel.text = "Press Ready to Start"
	$"Ready Button".visible = true
	$GoBackButton.visible = true
	$Labels.visible = true

# Handles the ready button press, resetting and starting the game
func _on_ReadyButton_pressed():
	ready_button.visible = false 
	game_over_label.visible = false  
	deal_initial_cards() #deals the cards
	reset_game()  # Reset game state
	start_game_loop()
	
	# Show UI elements for gameplay
	$VBoxContainer/Player_Hand.visible = true
	$VBoxContainer2/Dealer_Hand.visible = true
	player_hand_value.visible = true
	dealer_hand_value.visible = true
	$Labels.visible = true
	$GoBackButton.visible = false
	$HitButton.visible = true
	$StandButton.visible = true
	
# Resets game state before a new round
func reset_game():
	player_hand.clear()
	dealer_hand.clear()
	deck.clear()
	initialize_deck()
	shuffle_deck()
	deal_initial_cards()
	player_lost = false

# Main game loop that runs rounds
func start_game_loop():
	while not player_lost:
		play_round()
		await get_tree().create_timer(10).timeout  # Delay before next round
		
		if player_lost:
			await game_started
			player_lost = false  # Reset game state

# Simulates a round with a random outcome
func play_round():
	var random_outcome = randi() % 2  # Random win (0) or lose (1)
	
	if random_outcome == 1:
		print("You lost the round!")
		player_lost = true
	else:
		print("You won the round!")

# Initializes a deck of cards
func initialize_deck():
	var suits = ["hearts", "diamonds", "clubs", "spades"]
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	
	for i in range(deck_size):
		for suit in suits:
			for value in values:
				deck.append({"suit": suit, "value": value})
	print("Total cards in deck:", deck.size())  # Prints total cards in deck
	print("Number of decks:", deck.size() / 52)  # Prints number of 52-card decks

# Shuffles the deck
func shuffle_deck():
	deck.shuffle()
	print("Deck after shuffle:", deck.size()) 

# Deals initial hands to player and dealer
func deal_initial_cards():
	if deck.size() < 4:
		print("Error: Not enough cards to deal!")
		return
		
	player_hand.append(deck.pop_back())
	dealer_hand.append(deck.pop_back())
	player_hand.append(deck.pop_back())
	dealer_hand.append(deck.pop_back())
	update_hand_display()

	# Check for immediate blackjack
	if calculate_hand_value(player_hand) == 21:
		game_over("Blackjack! Player Wins!")
	elif calculate_hand_value(dealer_hand) == 21:
		game_over("Blackjack! Dealer Wins!")

# Updates UI to display hands and scores
func update_hand_display():
	var player_hand_node = $VBoxContainer/Player_Hand
	var dealer_hand_node = $VBoxContainer2/Dealer_Hand

	# Remove old card instances
	for child in player_hand_node.get_children():
		child.queue_free()
	for child in dealer_hand_node.get_children():
		child.queue_free()

	var card_scene = preload("res://Card.tscn")

	#Add player's cards side by side
	for card in player_hand:
		var card_instantiate = card_scene.instantiate()  
		card_instantiate.set_card(card)
		player_hand_node.add_child(card_instantiate)
		
		
	# Add dealer's cards side by side
	for card in dealer_hand:
		var card_instantiate = card_scene.instantiate() 
		card_instantiate.set_card(card)
		dealer_hand_node.add_child(card_instantiate)
		
	var player_total = calculate_hand_value(player_hand)
	var dealer_total = calculate_hand_value(dealer_hand)
		
	player_hand_value.text = "Player: " + str(player_total)
	dealer_hand_value.text = "Dealer: " + str(dealer_total)

# Handles hit button press
func _on_HitButton_pressed():
	player_hit()

# Handles stand button press
func _on_StandButton_pressed():
	player_stand()
	
# Player chooses to hit
func player_hit():
	if deck.size() > 0:
		player_hand.append(deck.pop_back())
		update_hand_display()
		
		# Check for blackjack or bust
		if calculate_hand_value(player_hand) == 21:
			game_over("Blackjack! Player Wins!")
		elif calculate_hand_value(player_hand) > 21:
			game_over("Player Busts!")
	else:
		game_over("No more cards in the deck!")

# Player chooses to stand
func player_stand():
	# Check if the player has 21 before proceeding to dealer's turn
	if calculate_hand_value(player_hand) == 21:
		game_over("Blackjack! Player Wins!")
		return
	
	dealer_turn()

# Calculates the value of a hand
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

# Dealer's turn to play
func dealer_turn():
	while calculate_hand_value(dealer_hand) < dealer_hit_threshold and deck.size() > 0:
		dealer_hand.append(deck.pop_back())

	update_hand_display()

	var dealer_value = calculate_hand_value(dealer_hand)

	if dealer_value == 21:
		game_over("Blackjack! Dealer Wins!")
	elif dealer_value > 21:
		game_over("Dealer Busts! Player Wins!")
	else:
		determine_winner()

# Ends the game with a message
func game_over(message):
	$GameOverLabel.text = message
	$GameOverLabel.visible = true
	$HitButton.visible = false
	$StandButton.visible = false
	$"Ready Button".visible = true  # Show Ready button for restart
	$GoBackButton.visible  = true
	$Labels.visible = true
	player_lost = true

	# If the player wins, start the auto-ready timer
	if "Player Wins" in message:
		player_wins += 1
		auto_ready_timer.start()
	elif "Player Busts" in message or "Dealer Wins" in message:
		player_losses += 1

	update_score_label()  # Update score after the game ends
	player_lost = true

# Handles auto-ready timer expiration
func _on_AutoReadyTimer_timeout():
	print("Auto-pressing Ready Button...")
	_on_ReadyButton_pressed()  # Call the function as if the button was pressed

# Handles going back to the main menu
func _on_GoBackButton_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

# Updates score label in the UI
func update_score_label():
	score_label.text = "Wins: %d | Losses: %d" % [player_wins, player_losses]

# Determines the Winner and updates the scores and send out a message
func determine_winner():
	var player_value = calculate_hand_value(player_hand)
	var dealer_value = calculate_hand_value(dealer_hand)
	
	if player_value > dealer_value:
		game_over("Player Wins!")
	elif player_value < dealer_value:
		game_over("Dealer Wins!")
	else:
		game_over("It's a Tie!")
