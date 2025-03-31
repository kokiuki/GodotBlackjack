extends Control # This script extends the Control node, meaning it's used for UI management.

# Variable to store the selected difficulty level
var selected_difficulty = []

# This function runs when the scene is loaded.
func _ready():
	# Connect button signals to their respective functions
	$"Difficulty Selection/Easy".connect("pressed", self._on_Easy_pressed)
	$"Difficulty Selection/Normal".connect("pressed", self._on_Normal_pressed)
	$"Difficulty Selection/Hard".connect("pressed", self._on_Hard_pressed)
	$"Start Game".connect("pressed", self._on_StartGame_pressed)
	$Tutorial.connect("pressed", self._on_Tutorial_pressed)
	$"Quit Game".connect("pressed", self._on_QuitGame_pressed)

# Function called when the "Easy" button is pressed
func _on_Easy_pressed():
	selected_difficulty = "Easy"
	print("Difficulty set to Easy")

# Function called when the "Normal" button is pressed
func _on_Normal_pressed():
	selected_difficulty = "Normal"
	print("Difficulty set to Medium")

# Function called when the "Hard" button is pressed
func _on_Hard_pressed():
	selected_difficulty = "Hard"
	print("Difficulty set to Hard")

# Function called when the "Tutorial" button is pressed
func _on_Tutorial_pressed():
	# Load the tutorial scene or display tutorial information
	get_tree().change_scene_to_file("res://Tutorial.tscn")  

# Function called when the "Start Game" button is pressed
func _on_StartGame_pressed():
	# Load the main game scene and pass the selected difficulty
	var game_scene = preload("res://Main.tscn")  # Preload the main game scene
	var game_instantiate = game_scene.instantiate()  # Create an instance of the game scene
	game_instantiate.selected_difficulty = selected_difficulty  # Assign the selected difficulty
		# Change the scene to the main game scene
	get_tree().change_scene_to_file("res://Main.tscn")

# Function called when the "Quit Game" button is pressed
func _on_QuitGame_pressed():
	get_tree().quit() # Quit the game
