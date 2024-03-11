extends Minigame

@export var target : PackedScene

@export var max_pears = 3
var score = 0

var sfx = {
	"kiss":"res://game/minigames/min_dummy/sfx/magic smack.wav",
	"eat":"res://game/minigames/min_dummy/sfx/munching.wav"
	
}

@onready var chef1 = $Chef1
@onready var chef2 = $Chef2
@onready var chef3 = $Chef3

func _on_start():
	max_pears = max_pears + (2*(level-1))
	
	# Spawn a pear at a random location
	if target:
		for i in range(max_pears):
			var instance = target.instantiate()
			
			instance.position.x = randi_range(150,1000)
			instance.position.y = randi_range(60,520)
			
			instance.collected.connect(on_pear_collected)
			
			$Pears.add_child(instance)


func _on_new_beat():
	pass

func _on_end_minigame():
	if score < max_pears:
		minigame_state = State.LOST

func on_pear_collected():
	play_local_sfx(sfx["eat"])
	
	score += 1
	if score >= max_pears:
		minigame_state = State.WON
		
		chef1.rise(speed_factor)
		if level > 1: chef2.rise(speed_factor)
		if level > 2: chef3.rise(speed_factor)
		
		play_local_sfx(sfx["kiss"], -3)
