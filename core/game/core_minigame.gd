extends Node2D
class_name Minigame

signal signal_minigame_ended

enum State {
	NEUTRAL,
	WON,
	LOST,
}

@export var instruction = "Do something!"
@export var minigame_length = 8
@export var is_boss = false

@export var main_music : AudioStream = null
@onready var music_player = $music_player

@onready var clock_animator = $UI/clock/clock_animator
@onready var beat_animator = $UI/Label/beat_animator
@onready var beat_display = $UI/Label

var global_sfx = {
	"timer": "res://resources/sound/sfx/beep.wav"
}

var speed_factor = 1
var level = 1

var minigame_state = State.NEUTRAL
var has_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	has_started = false
	
	if is_boss:
		$UI.visible = false
	
	clock_animator.speed_scale = speed_factor
	beat_animator.speed_scale = speed_factor


func _start():
	has_started = true
	if main_music:
		music_player.stream = main_music
		music_player.pitch_scale = speed_factor
		music_player.stop()
		music_player.play()
	
	minigame_state = State.LOST
	
	_on_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _new_beat(beat):
	
	var beat_left = minigame_length - beat - 1
	
	if !is_boss and beat >= minigame_length:
		_end_minigame()
	
	clock_animator.stop()
	clock_animator.play("pulse")
	
	if beat_left <= 3 && beat_left >= 0:
		play_local_sfx(global_sfx["timer"])
	
	if beat_left >= 0:
		beat_animator.stop()
		beat_animator.play("fade")
		beat_display.text = str(beat_left)
	
	_on_new_beat()

func _end_minigame():
	_on_end_minigame()
	
	emit_signal("signal_minigame_ended")
	music_player.stop()

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

# Functions called by children classes
func _on_start():
	pass
func _on_new_beat():
	pass
func _on_end_minigame():
	pass
#
