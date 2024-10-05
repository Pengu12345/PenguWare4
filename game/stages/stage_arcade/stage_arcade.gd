extends Stage

@export var arcade_sprite : Sprite2D
@export var background_image : ColorRect
@export var animator : AnimationPlayer

@export var arcade_animator : AnimationPlayer

@export var speed_label : Label
@export var stats_label : Label
@export var instruction : Label

func _on_ready():
	minigame_list = ["min_dummy"] # Default
	if MenuManager.loaded_data.has("loaded_minigames"):
		minigame_list = MenuManager.loaded_data["loaded_minigames"]

func _on_init_game():
	current_level = 1

func update_instruction_text():
	instruction.text = current_minigame.instruction

func _on_process(_delta):
	animator.speed_scale = speed_factor
	
	stats_label.text = "Score: " + str(current_score) + "   Lives: " + str(current_lives)
	speed_label.text = str(speed_factor)

func _on_new_beat():
	pass

func _on_minigame_end(minigame_state : Minigame.State):
	
	if minigame_state == Minigame.State.LOST:
		current_lives -= 1
		pass
	
	if current_lives <= 0:
		_game_over()
		return

	if current_level < 3:
		_queue_event(GameState.LEVEL_UP, false, func() :current_level += 1)
	else:
		current_level = 1
		_queue_event(GameState.SPEED_UP, false, func() : set_speed_factor(song_speed_factor + 0.2))
	

func _on_new_state(new_state :  GameState):
	match new_state:
		GameState.NEUTRAL:
			var controls_name = ResourcesManager.get_minigame_metadata(current_minigame_id)["controls"]
			
			animator.play("neutral")
			
		GameState.WIN:
			animator.play("win")
		GameState.LOSE:
			animator.play("win")
		GameState.SPEED_UP:
			pass
		GameState.LEVEL_UP:
			pass
		GameState.BOSS:
			pass

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
