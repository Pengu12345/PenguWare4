extends Minigame

@export var thwomps : Array[Node2D]
@export var player : Node

var sfx = {
	"fall":"res://resources/sound/sfx/explosion.wav",
	"ready":"res://resources/sound/sfx/wiggle.wav",
	"bummed":"res://resources/sound/sfx/bummed.wav",
}


var time_appear = 0.5
var time_ready  = 1.9
var time_fall = 3

var current_timer = 0

var action_state = 0

var active_thwomps = []
var fake_thwomps = []	

func _on_start():
	player.active = true
	
	# Update timer speeds
	time_appear = time_appear / speed_factor
	time_ready = time_ready / speed_factor
	time_fall = time_fall / speed_factor
	
	player.speed *= speed_factor
	
	# Pick out the active thwomps
	var n_active = 0
	if level <= 1: n_active = 2
	if level == 2: n_active = 3
	if level == 3: n_active = 4
	
	for i in range(n_active):
		var chosen = thwomps.pick_random()
		thwomps.erase(chosen)
		active_thwomps.append(chosen)
	
	# Update animation speeds of the active (and fake) thwomps
	for t in active_thwomps:
		t.update_animation_speed(speed_factor)
	
	# Pick a fakeout thwomp
	if level >= 3:
		var chosen = active_thwomps.pick_random()
		active_thwomps.erase(chosen)
		fake_thwomps.append(chosen)
		
		# Do it a second time at fast speeds so it's not impossible
		if speed_factor > 2:
			chosen = active_thwomps.pick_random()
			active_thwomps.erase(chosen)
			fake_thwomps.append(chosen)

func _process(_delta):
	if !has_started: return
	
	current_timer += _delta
	
	# Appear state
	if current_timer > time_appear and action_state == 0:
		action_state = 1
		for t in active_thwomps:
			t.play_appear()
		for t in fake_thwomps: t.play_appear()
	
	# Ready state
	if current_timer > time_ready and action_state == 1:
		action_state = 2
		for t in active_thwomps: t.play_ready()
		play_local_sfx(sfx["ready"])
	
	# Fall state
	if current_timer > time_fall and action_state == 2:
		action_state = 3
		play_local_sfx(sfx["fall"])
		
		# Check if collided
		var collided = false 
		for t in active_thwomps:
			t.play_fall()
			if !collided:
				var areas = t.get_entities_in_area()
				if areas.size() > 0:
					collided = true
		
		if collided:
			player.squish()
			minigame_state = Minigame.State.LOST
			play_local_sfx(sfx["bummed"])

func _on_end_minigame():
	if minigame_state == Minigame.State.NEUTRAL:
		minigame_state = Minigame.State.WON

