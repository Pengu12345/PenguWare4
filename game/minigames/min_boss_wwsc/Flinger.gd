extends Node2D
class_name Flinger

# Meta variables
var speed_factor = 1
var minigame = null
var started = false

# Visuals variables
@onready var sprite = $Sprite

# Entity states
enum Flinger_State {
	IDLE, FLING
}
var current_state = Flinger_State.IDLE

# Behavioral variables
@export var waiting_time = 3
var timer = 0
var fling_range = 600
var wait_variance = 0
var velocity = Vector2(0,0)

var sfx = {
	"ready":"res://game/minigames/min_boss_wwsc/sfx/ready.wav",
	"fling":"res://game/minigames/min_boss_wwsc/sfx/fling.wav"
}

func _on_ready():
	pass

func init():
	init_new_waiting_time()
	sprite.play("default")

	print(speed_factor)

func init_new_waiting_time():
	waiting_time += randf_range(-0.5,0.5) - wait_variance
	waiting_time /= speed_factor

func init_new_fling_time():
	waiting_time = 0.7
	waiting_time /= speed_factor

func _process(delta):
	
	if !started: return
	
	timer += delta
	
	if timer >= waiting_time:
		timer = 0
		
		match current_state:
			Flinger_State.IDLE:
				readying()
			Flinger_State.FLING:
				fling()
	
	position += velocity * delta
	velocity *= 0.98

func readying():
	current_state = Flinger_State.FLING
	minigame.play_local_sfx(sfx["ready"],-8, false)
	sprite.play("ready")
	init_new_fling_time()

func fling():
	velocity = minigame.player.position - position
	velocity = velocity.normalized() * fling_range
	
	sprite.flip_h = velocity.x < 0
	
	minigame.play_local_sfx(sfx["fling"], -8, false)
	sprite.play("default")
	init_new_waiting_time()
	current_state = Flinger_State.IDLE
