extends Control
class_name BalatroCard

signal selected(c : BalatroCard)

enum Suit {
	HEART,
	CLUB,
	DIAMOND,
	SPADE
}

var suit = Suit.DIAMOND
var rank = 1

@export var card_sprite : Sprite2D
@export var animation_player : AnimationPlayer

var t = 0

var is_selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	update_card_sprite()

func update_card_sprite():
	# Get the height and width
	var card_region = card_sprite.region_rect
	var card_dim = Vector2(card_region.size.x, card_region.size.y)
	
	# Coords for the RANK
	var reg_x = ((rank - 1)*card_dim.x) + ((rank-1) * 4)
	
	# Coords for the SUIT
	var suit_n = parse_suit()
	
	var reg_y = ((suit_n - 1)*card_dim.y) + ((suit_n-1) * 4)
	
	var new_region = Rect2( 2 + reg_x, 2 + reg_y, card_dim.x, card_dim.y)
	
	card_sprite.region_rect = new_region

func parse_suit():
	match(suit):
		Suit.HEART: return 1
		Suit.CLUB: return 2
		Suit.DIAMOND: return 3
		Suit.SPADE: return 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func select():
	is_selected = true
	animation_player.play("select")

func deselect():
	is_selected = false
	animation_player.play("deselect")

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("selected", self)
