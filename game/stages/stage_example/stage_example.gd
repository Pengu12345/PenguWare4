extends Stage

@onready var sprite_animator : AnimationPlayer = $Front/sprite/animator
@onready var main_animator : AnimationPlayer = $animator
@onready var background_animator : AnimationPlayer = $Front/background_animator
@onready var event_label : Label = $Event

@export var start_speed = 1.0

func _on_ready():
	minigame_list = ["min_squareinator", "min_chrome", "min_dummy"]
	
	$Instruction.text = ""

func _on_init_game():
	background_animator.play("RESET")
	main_animator.play("RESET")
	
	set_speed_factor(start_speed)
	
	$Instruction.text = ""

func update_instruction_text():
	$Instruction.text = current_minigame.instruction

func _on_process(_delta):
	main_animator.speed_scale = speed_factor
	sprite_animator.speed_scale = speed_factor
	background_animator.speed_scale = speed_factor
	
	$Score.text = "Score: " + str(current_score) + "\n Lives: " + str(current_lives)

func _on_new_beat():
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

func _select_next_minigame_id():
	current_minigame_id = "min_boss_wwsc" #minigame_list[current_score % minigame_list.size()]

func _on_minigame_start():
	pass

func _on_minigame_end(minigame_state : Minigame.State):
	if minigame_state == Minigame.State.LOST:
		current_lives -= 1
		pass
	
	if current_lives <= 0:
		_game_over()
		return
		
	#if (current_score-1) % 3 == 0:
	current_level = (current_level + 1)
	if current_level > 3: current_level = 1
	_queue_event(GameState.LEVEL_UP, true, func() : set_speed_factor(speed_factor + 0.2))
	
	

func _on_game_over():
	pass
