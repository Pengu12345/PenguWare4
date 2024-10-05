extends Node2D
class_name Stage

#Custom Enum types
enum GameState {
	BEGIN,
	NEUTRAL,
	IN_MINIGAME,
	WIN,
	LOSE,
	SPEED_UP,
	LEVEL_UP,
	BOSS,
	GAME_OVER
}

var global_sfx = {
	"careful": "res://resources/sound/sfx/careful.wav"
}


# Signals
signal signal_new_beat

# Variables
@export_category("UI")
@export var control_schemes = {}

@export var pause_screen : Control

@export_category("Music Variables")
@export var base_bpm = 120.00

@export var begin_music : AudioStream
@export var neutral_music : AudioStream
@export var win_music : AudioStream
@export var lose_music : AudioStream
@export var speedup_music : AudioStream
@export var levelup_music : AudioStream
@export var boss_music : AudioStream
@export var gameover_music : AudioStream

@export var nonstop_music : AudioStream
@export var enable_nonstop_music = false
var last_music_position = 0
var song_speed_factor = 1

@onready var jukebox = $main_music
@onready var minigame_slot = $minigame_slot
@onready var minigame_holder = $minigame_holder

var current_bpm = base_bpm

var current_time = 0.0 

var current_beat = 0
var next_beat_time = 0.0

var speed_factor = 1
var min_speed_factor = 0.5
var max_speed_factor = 100

@export_category("Game Variables")
@export var max_lives = 4

@export var is_boss_enabled = true

@onready var current_lives = max_lives
var current_score = 1
var current_level = 1
var is_game_over = false

var is_game_active = false

var current_state = GameState.NEUTRAL
var override_flag = GameState.NEUTRAL

var queued_event = null
var current_minigame : Minigame = null
var current_minigame_id = ""

var minigame_list : Array = ["min_dummy"]

@export_category("Debug variables")
@export var debug_always_win = false
@export var debug_always_lose = false
@export var debug_start_max_level = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_ready()
	pause_screen.visible = false
	init_game()

func init_game():
	is_game_active = true
	is_game_over = false
	is_boss_enabled = true
	
	if MenuManager.loaded_data.has("boss_enabled"):
		is_boss_enabled = MenuManager.loaded_data["boss_enabled"]
	
	current_lives = max_lives
	current_state = GameState.BEGIN
	
	current_score = 1
	current_level = 1
	
	if debug_start_max_level: current_level = 3
	
	current_time = 0
	current_beat = 0
	next_beat_time = 0
	
	if MenuManager.loaded_data.has("speed_factor"):
		set_speed_factor(MenuManager.loaded_data["speed_factor"])
	else:
		set_speed_factor(1)
	
	_play_state_music()
	if enable_nonstop_music:
		jukebox.stop()
		jukebox.stream = nonstop_music
		jukebox.play()
	
	_on_init_game()
	_new_beat()

func set_speed_factor(new_speed_factor):
	
	song_speed_factor = new_speed_factor
	
	current_bpm = base_bpm * new_speed_factor

	speed_factor = current_bpm / 120.0
	
	# Recalculate the new music values using the new factor
	next_beat_time = 1.0 / ( float(current_bpm)  / (60.0) )
	print("------")
	print("Updated speed to be " + str(new_speed_factor))
	print("Next beat: " + str(next_beat_time))
	print("New BPM: " + str(current_bpm))
	print("------")
	# Only for nonstop music
	if enable_nonstop_music:
		jukebox.pitch_scale = new_speed_factor
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		set_game_paused(true)
	
	
	if is_game_active:
		if enable_nonstop_music:
			delta = jukebox.get_playback_position() - last_music_position
			delta /= song_speed_factor
			last_music_position = jukebox.get_playback_position()
			
		current_time += delta
		
		if !is_game_over:
			_on_process(delta)
			
			if current_time >= next_beat_time:
				current_time -= next_beat_time
				current_beat += 1
				_new_beat()

func _new_beat():
	# Preload the minigame for any funny animations
	if current_state == GameState.NEUTRAL:
		if current_beat == get_state_length(current_state) - 2:
			minigame_holder.update_level(current_level)
			# choose at random from the minigame list
			_preload_minigame(current_minigame_id)
			
			var md = ResourcesManager.get_minigame_metadata(current_minigame_id)
			if md.has("special") and md["special"] == true:
				play_local_sfx(global_sfx["careful"], 8, true)

		
	
	# Unload the current minigame for any funny animations (offset)
	if current_state == GameState.WIN or current_state == GameState.LOSE:
		if current_beat == 1:
			_unload_loaded_minigame()
	
	# Change any steps if we finished it's animation length
	if current_beat >= get_state_length(current_state) and current_state != GameState.IN_MINIGAME:
		current_beat = 0
		_end_current_state()
	
	emit_signal("signal_new_beat", current_beat)
	_on_new_beat()

func _select_next_minigame_id():
	var minigame_id = minigame_list[ randi() % minigame_list.size() ]
	current_minigame_id = minigame_id

func _begin_current_state():
	if current_state == GameState.NEUTRAL:
		if queued_event != null:
			if typeof(queued_event) == TYPE_CALLABLE :
				queued_event.call()
				queued_event = null
		
		_select_next_minigame_id()
	
	if current_state == GameState.GAME_OVER:
		set_speed_factor(1)
	
	_play_state_music()
	
	_on_new_state(current_state)

func _end_current_state():
	if current_state == GameState.GAME_OVER:
		is_game_over = true
		is_game_active = false
		return
		
	# Effect changes depending on the state
	# When we're in neutral, we switch to a Minigame.
	if current_state == GameState.NEUTRAL:
		current_state = GameState.IN_MINIGAME
		_start_loaded_minigame()
	else:
		if override_flag != GameState.NEUTRAL:
			current_state = override_flag
			override_flag = GameState.NEUTRAL
		else:
			current_state = GameState.NEUTRAL
	
	# Whatever happens, begin the new state
	_begin_current_state()

func _preload_minigame(minigame_name : String):
	var minigame_path = ResourcesManager.get_minigame_path_from_id( minigame_name )
	
	var loaded_minigame = load(minigame_path)
	current_minigame = loaded_minigame.instantiate()
	
	current_minigame.speed_factor = speed_factor
	current_minigame.level = current_level
	
	signal_new_beat.connect(current_minigame._new_beat)
	current_minigame.signal_minigame_ended.connect(_minigame_end)
	
	$minigame_slot.add_child(current_minigame)

func _unload_loaded_minigame():
	current_minigame.queue_free()
	current_minigame_id = ""

func _start_loaded_minigame():
	if !current_minigame:
		print("ERROR: Can't start the loaded minigame as no minigame was loaded")
		return
	if current_minigame.has_started:
		print("ERROR: Minigame already started.")
		return
	
	current_minigame.ignore_music = enable_nonstop_music
	current_minigame._start()
	_on_minigame_start()

func _minigame_end():
	current_beat = 0
	
	signal_new_beat.disconnect(current_minigame._new_beat)
	
	if debug_always_win:
		current_state = GameState.WIN
		current_minigame.minigame_state = Minigame.State.WON
	if debug_always_lose:
		current_state = GameState.LOSE
		current_minigame.minigame_state = Minigame.State.LOST
	
	if current_minigame.minigame_state != Minigame.State.WON:
		current_state = GameState.LOSE
		current_score += 1
	else:
		current_state = GameState.WIN
		current_score += 1
	
	_on_minigame_end(current_minigame.minigame_state)
	_begin_current_state()

func _queue_event(next_state : GameState, play_animation : bool, event : Callable):
	if play_animation:
		override_flag = next_state
	
	queued_event = event

func _game_over():
	override_flag = GameState.GAME_OVER
	_on_game_over()

# Music functions
func _play_state_music():
	var chosen_music : AudioStream
	
	match current_state:
		GameState.BEGIN : chosen_music =  begin_music
		GameState.NEUTRAL : chosen_music = neutral_music
		GameState.WIN     : chosen_music = win_music
		GameState.LOSE    : chosen_music = lose_music
		GameState.SPEED_UP: chosen_music = speedup_music
		GameState.LEVEL_UP: chosen_music = levelup_music
		GameState.BOSS    : chosen_music = boss_music
		GameState.GAME_OVER: chosen_music = gameover_music
		_ : chosen_music = null
		
	if chosen_music && !enable_nonstop_music:
		jukebox.stop()
		jukebox.stream = chosen_music
		jukebox.pitch_scale = speed_factor
		jukebox.play(0.0)
#

# Children functions
func _on_ready():
	pass
func _on_init_game():
	pass
func _on_process(_delta):
	pass
func _on_new_beat():
	pass
func _on_new_state(new_state : GameState):
	pass
func _on_minigame_start():
	pass
func _on_minigame_end(minigame_state : Minigame.State):
	pass
func _on_game_over():
	pass
#-----

# Helper functions
func get_state_length(state : GameState):
	match state:
		GameState.BEGIN : return 0
		GameState.NEUTRAL : return 4
		GameState.WIN     : return 4
		GameState.LOSE    : return 4
		GameState.SPEED_UP: return 8
		GameState.LEVEL_UP: return 8
		GameState.BOSS    : return 8
		GameState.GAME_OVER: return 8
		_ : return 4
#

func _on_main_music_finished():
	if enable_nonstop_music:
		last_music_position = 0
		jukebox.play()

func set_game_paused(paused : bool):
			is_game_active = !paused
			get_tree().paused = paused
			pause_screen.visible = paused


func _on_button_unpause_pressed():
	set_game_paused(false)


func _on_button_return_pressed():
	MenuManager.reset_stage_properties()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")

func play_local_sfx(path : String, db = 0, adapt_speed = false):
	var jukebox = AudioStreamPlayer.new()
	var stream = load(path)
	if stream:
		jukebox.stream = stream
		jukebox.volume_db = db
		
		if adapt_speed: jukebox.pitch_scale = speed_factor
		
		add_child(jukebox)
		jukebox.finished.connect( func(): jukebox.queue_free())
		jukebox.play()
	else:
		print("ERROR: Could not find the sound at path " + path)
