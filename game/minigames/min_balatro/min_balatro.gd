extends Minigame

@export var card_container : Control
@export var card_scene : PackedScene

var cards = []

var selected_card : BalatroCard

var highest_rule = true

var sfx = {
	"select":"res://game/minigames/min_balatro/card1.ogg"
}

func _ready():
	super._ready()
	
	# Pick music at random
	var variation = randi_range(1,5)
	main_music = load("res://resources/sound/music/minigames/balatro/mus_balatro"+ str(variation) +".wav")
	
	if level >= 2 and randi_range(0,1) == 1:
		highest_rule = false
		instruction = "Choose lowest!"
		$Label.text = "Please select the lowest card."

func _on_start():
	var available_ranks = range(1,13)
	var number_of_cards = 5
	match level:
		1:
			number_of_cards = 5
		2:
			number_of_cards = 7
		3:
			number_of_cards = 7
			available_ranks = range(1,9)
	
	for i in range(number_of_cards):
		var card_instance = card_scene.instantiate()
		var picked_rank = available_ranks.pick_random()
		available_ranks.erase(picked_rank)
		
		card_instance.rank = picked_rank
		card_instance.suit = BalatroCard.Suit.values().pick_random()
		
		add_card(card_instance)
		
		card_instance.update_card_sprite()

func add_card(card : BalatroCard):
	cards.append(card)
	
	card.connect("selected", _on_card_selected)
	
	card_container.add_child(card, true)

func _process(_delta):
	if !has_started: return
	
	$Label.rotation_degrees += 0.5 * _delta * speed_factor

func _on_end_minigame():
	# No cards selected, you lose
	if !selected_card:
		minigame_state = Minigame.State.LOST
		return
	
	# Else, check value of every other card to see if one is higher, if that's
	# The case then lose
	for c in cards:
		if c != selected_card:
			if !follows_rule(selected_card, c):
				minigame_state = Minigame.State.LOST
	
	# If the minigame is not lost yet, it means that the rank was the highest
	if minigame_state == Minigame.State.NEUTRAL:
		minigame_state = Minigame.State.WON

func follows_rule(selected_card : BalatroCard, compared_card):
	var higher = selected_card.rank > compared_card.rank
	if highest_rule: return higher
	
	return !higher

func _on_card_selected(card : BalatroCard):
	
	for c in cards:
		if c != card:
			if c.is_selected: c.deselect()
		else:
			if !c.is_selected:
				play_local_sfx(sfx["select"], 5)
				selected_card = c
				c.select()
