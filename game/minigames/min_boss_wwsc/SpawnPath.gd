extends Path2D

@onready var spawn_point = $Point
@export var enemy_scene : PackedScene

var timer = 0
var spawn_timer = 1
var minigame = null

func _ready():
	pass

func init():
	match minigame.level:
		_: spawn_timer = 1.3
		2: spawn_timer = 0.9
		3: spawn_timer = 0.5

	spawn_timer /= minigame.speed_factor

func _process(delta):
	if !minigame: return
	
	timer += delta
	
	if timer > spawn_timer:
		timer = 0
		spawn_enemy()


func spawn_enemy():
	if !enemy_scene:
		print_debug("ERROR: Enemy Scene not set in editor.")
		return
	
	# Choose a random point on the curve
	spawn_point.progress_ratio = randf_range(0,1)
	
	var spawn_position = spawn_point.position
	var enemy_instance = enemy_scene.instantiate()
	
	var x = randi_range(50, minigame.background.get_rect().size.x - 50)
	var y = randi_range(50, minigame.background.get_rect().size.y - 50)
	
	enemy_instance.position = spawn_position
	enemy_instance.direction =   Vector2(x,y) - enemy_instance.position
	
	enemy_instance.speed_factor = minigame.speed_factor
	
	add_child(enemy_instance)
	
