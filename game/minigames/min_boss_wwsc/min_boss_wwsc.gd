extends Minigame

@onready var player = $Player
@onready var player_animator = $Player/animator

@onready var old_man = $Old_Man
@onready var controller = $"Nintendo-nes-controller"

@onready var flinger = $Flinger

@onready var spawn_path = $SpawnPath

@onready var score_text = $Score
@onready var goal_text = $Goal

@onready var instances_node = $Instances

@onready var background = $Background

@export var coin_scene : PackedScene

var game_over = false

var score_goal = 20

var timer = 0
var coin_spawn_frequency = 1

var score = 0

var sfx = {
	"walk":"res://game/minigames/min_boss_wwsc/sfx/footstep.wav",
	"coin":"res://game/minigames/min_boss_wwsc/sfx/coin.wav",
	"win":"res://game/minigames/min_boss_wwsc/sfx/winning.wav",
	"game_over":"res://game/minigames/min_boss_wwsc/sfx/gameOver.wav"
}

func _on_start():
	coin_spawn_frequency /= speed_factor
	
	player_animator.speed_scale = speed_factor
	
	match level:
		1: score_goal = 15
		2: score_goal = 20
		3: score_goal = 25
		_: score_goal = 10
	
	goal_text.text = "Goal: " + str(score_goal)
	
	spawn_path.minigame = self
	spawn_path.init()
	
	flinger.minigame = self
	flinger.speed_factor = speed_factor
	flinger.init()
	flinger.started = true

func _process(delta):
	
	if !has_started: return
	
	timer += delta
	
	if !game_over: 
		if timer >= coin_spawn_frequency:
			timer = 0
			spawn_coin()
		
		update_player_movements()
		
		controller.offset = get_local_mouse_position() * 0.1
	
	#Update text
	score_text.text = "Score:" + str(score)

func update_player_movements():
	# Always try to approach the player
	var approach_vector = get_local_mouse_position() - player.position
	
	if abs(approach_vector.length()) > 2 :
		if !player_animator.is_playing():
			play_local_sfx(sfx["walk"],-10)
		player_animator.play("jump")
		
	player.flip_h = approach_vector.x < 0
	player.position += approach_vector * 0.05 * speed_factor

func spawn_coin():
	if !coin_scene:
		print_debug("ERROR: Coin scene not defined in editor.")
		return
	
	var x = randi_range(50, background.get_rect().size.x - 50)
	var y = randi_range(50, background.get_rect().size.y - 50)
		
	var p = Vector2(x,y)
	
	var coin_node = coin_scene.instantiate()
	coin_node.position = p
	coin_node.speed_factor = speed_factor
	coin_node.init()
	instances_node.add_child(coin_node, true)
	


func _on_collision_area_area_entered(area):
	var collided_node = area.get_parent()
	
	print(collided_node.name)
	
	if collided_node.name.contains("Coin") :
		if collided_node.picked_up == false:
			collided_node.pickup()
			score += 1
			play_local_sfx(sfx["coin"], -5)
			
			if score >= score_goal && minigame_state == State.NEUTRAL:
				minigame_state = State.WON
				goal_text.text = "Amazing!"
				old_man.play("won")
				play_local_sfx(sfx["win"],-5)
	else:
		# We assume it's an enemy
		if !game_over && minigame_state == State.NEUTRAL:
			game_over = true
			player_animator.play("dies")
			play_local_sfx(sfx["game_over"], -3)
			minigame_state = State.LOST
