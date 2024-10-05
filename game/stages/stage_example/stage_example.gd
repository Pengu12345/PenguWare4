extends Stage

@onready var sprite_animator : AnimationPlayer = $Front/sprite/animator
@onready var main_animator : AnimationPlayer = $animator
@onready var background_animator : AnimationPlayer = $Front/background_animator
@onready var event_label : Label = $Event

var boss_id = "min_boss_wwsc"
var next_minigames = []

func _on_ready():
	minigame_list = [
		"min_chrome",
		"min_dummy",
		"min_squareinator",
		"min_doodle",
		"min_balatro"
		] # Default
	if MenuManager.loaded_data.has("loaded_minigames"):
		minigame_list = MenuManager.loaded_data["loaded_minigames"]
		
	$Instruction.text = ""

func _on_init_game():
	background_animator.play("RESET")
	main_animator.play("RESET")
	
	next_minigames = minigame_list.duplicate()
	next_minigames.shuffle()
	
	current_level = 1
	
	$Instruction.text = ""

func update_instruction_text():
	$Instruction.text = current_minigame.instruction

func _on_process(_delta):
	main_animator.speed_scale = speed_factor
	sprite_animator.speed_scale = speed_factor
	background_animator.speed_scale = speed_factor
	
	$Score.text = "Score: " + str(current_score) + "\n Lives: " + str(current_lives)

func _on_new_beat():
	sprite_animator.stop()
	sprite_animator.play("pulse")
	
func _on_new_state(new_state :  GameState):
	match new_state:
		GameState.NEUTRAL:
			background_animator.play("neutral")
			main_animator.play("neutral_animation")
			
			var controls_name = ResourcesManager.get_minigame_metadata(current_minigame_id)["controls"]
			$Controls/Sprite.texture = control_schemes[controls_name]
			
		GameState.WIN:
			main_animator.play("win_animation")
		GameState.LOSE:
			main_animator.play("lose_animation")
		GameState.SPEED_UP:
			event_label.text = "Speed up!"
			main_animator.play("event_animation")
		GameState.LEVEL_UP:
			event_label.text = "Level up!"
			main_animator.play("event_animation")
		GameState.BOSS:
			event_label.text = "!!!Boss Stage!!!"
			main_animator.play("event_animation")

func _select_next_minigame_id():
	if next_minigames.size() > 0:
		current_minigame_id = next_minigames[0]
		next_minigames.remove_at(0)

func _on_minigame_start():
	pass

func _on_minigame_end(minigame_state : Minigame.State):
	
	if minigame_state == Minigame.State.LOST:
		current_lives -= 1
		pass
	
	if current_lives <= 0:
		_game_over()
		return

	
	if next_minigames.size() == 0:
		# If we weren't in a boss fight, enter it
		if current_minigame_id != boss_id && is_boss_enabled:
			_queue_event(GameState.BOSS, true, func() : current_minigame_id = boss_id)
		else:
			# Re-shuffle the minigame list, and level up, or speed up
			next_minigames = minigame_list.duplicate()
			next_minigames.shuffle()
			if current_level < 3:
				_queue_event(GameState.LEVEL_UP, true, func() :current_level += 1)
			else:
				_queue_event(GameState.SPEED_UP, true, func() : set_speed_factor(song_speed_factor + 0.2))
	
func get_state_length(state : GameState):
	match state:
		GameState.BEGIN : return 2
		GameState.NEUTRAL : return 4
		GameState.WIN     : return 4
		GameState.LOSE    : return 4
		GameState.SPEED_UP: return 8
		GameState.LEVEL_UP: return 8
		GameState.BOSS    : return 8
		GameState.GAME_OVER: return 8
		_ : return 4	

func _on_game_over():
	next_minigames = minigame_list.duplicate()
