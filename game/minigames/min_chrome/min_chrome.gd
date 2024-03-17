extends Minigame

@onready var node_ground = $Ground
@onready var node_ground2 = $Ground2
@onready var dinosaur_sprite = $Dinosaur/Sprite
@onready var dinosaur = $Dinosaur

@onready var obstacles_node = $Obstacles

@export var obstacle_scene : PackedScene

var sfx = {
	"jump": "res://game/minigames/min_chrome/sfx/jump.wav",
	"die": "res://game/minigames/min_chrome/sfx/die.wav",
	"point": "res://game/minigames/min_chrome/sfx/point.wav"
}

var ground_pos = 0
var running_speed = 500

var controls_enabled = false
var is_on_ground = false
var velocity_y = 0

var gravity = 30

var has_lost = false

var timer = 0
var spawn_rate = 0.5

func _on_start():
	ground_pos = dinosaur.position.y
	dinosaur_sprite.play("default")
	gravity = gravity * speed_factor
	controls_enabled = true
	
	if level == 1: spawn_rate = 1 *   (1/speed_factor)
	if level == 2: spawn_rate = 0.5 * (1/speed_factor)
	if level >= 3: spawn_rate = 0 *   (1/speed_factor)

func _process(delta):
	# Move ground
	node_ground.position.x -= delta * running_speed * speed_factor
	node_ground2.position.x -= delta * (running_speed * 0.6) * speed_factor
	
	if !has_started: return
	
	# Dinosaur actions
	if !is_on_ground:
		dinosaur.position.y -= velocity_y
		
		velocity_y -= gravity * delta * speed_factor
		
		if dinosaur.position.y >= ground_pos:
			is_on_ground = true
			dinosaur.position.y = ground_pos
	else:
		if Input.is_action_just_pressed("ui_accept") && controls_enabled:
			velocity_y = 10 * speed_factor
			is_on_ground = false
			play_local_sfx(sfx["jump"])
	
	# Spawning obstacles
	timer += delta
	if timer >= spawn_rate:
		timer = 0
		spawn_obstacle()
		
		# Adapt spawn rate depending on level
		if level == 1: spawn_rate = 4 *   (1/speed_factor)
		if level == 2: spawn_rate = 1.3 * (1/speed_factor)
		if level >= 3: spawn_rate = 0.8 * (1/speed_factor)

func spawn_obstacle():
	if !obstacle_scene:
		print_debug("ERROR: Obstacle scene not set in editor.")
		return
	
	var obstacle = obstacle_scene.instantiate()
	obstacle.game = self
	
	obstacles_node.add_child(obstacle)

func _on_end_minigame():
	if !has_lost:
		minigame_state = State.WON
		play_local_sfx(sfx["point"],-8)


func _on_collision_area_entered(area):
	has_lost = true
	minigame_state = State.LOST
	dinosaur_sprite.play("hurt")
	controls_enabled = false
	
	play_local_sfx(sfx["die"])
	
	running_speed = 0
