extends TextureRect  # This script extends TextureRect, allowing it to display a card's texture.

# Dictionary to store textures for each card, using suit and value as keys.
var card_textures = {} 

# Called when the node is added to the scene.
func _ready():
	load_card_textures() # Preload all card textures when the scene starts.
			
# Loads all card textures and stores them in the card_textures dictionary.
func load_card_textures():
	var suits = ["hearts", "diamonds", "clubs", "spades"]
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]  # List of card values.
	
# Iterate through each suit and value to generate texture file paths.
	for suit in suits:
		for value in values:
			var texture_path = "res://Assets/Card_textures/%s_of_%s.png" % [suit, value]  # Construct the file path.
			card_textures.get_or_add(suit + "_of_" + value, load(texture_path)) # Load and store the texture.

# Sets the texture of the card based on the provided card data.
func set_card(card_data):
	load_card_textures()  # Ensure textures are loaded before assigning one.
	
	var cardName: StringName = card_data.suit + "_of_" + card_data.value
# Check if the texture exists in the dictionary and assign it to the TextureRect.
	if card_textures.has(cardName):
		texture = card_textures[cardName]
	else:
		print("Texture not found for: ", cardName) # Print an error message if the texture is missing.
	
