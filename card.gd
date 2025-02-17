extends Sprite2D

var card_data = {}

func set_card(data):
	card_data = data

	var texture_path = "res://Assets/Card_textures/%s_of_%s.png" % [data.suit, data.value]

	if ResourceLoader.exists(texture_path):
		texture = load(texture_path)
	else:
		print("Error: Card texture not found at", texture_path)

	var label = get_node_or_null("Label")
	if label:
		label.text = data.value
	else:
		print("Error: Label node not found in Card.tscn!")
