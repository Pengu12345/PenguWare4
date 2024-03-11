extends Node2D

var speed = 0

var game : Minigame

func _process(delta):
	if game:
		position.x -= delta * game.running_speed * game.speed_factor
	else:
		print_debug("Obstacle not attached to game.")
