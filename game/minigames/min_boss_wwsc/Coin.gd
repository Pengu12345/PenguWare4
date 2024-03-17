extends Node2D
class_name Coin

@export var decay_time = 10

var timer = 0
var speed_factor = 1
var picked_up = false

func _on_ready():
	pass

func init():
	decay_time /= speed_factor
	$Sprite.play("default")

func _process(delta):
	timer += delta
	
	if timer >= decay_time:
		destroy()


func destroy():
	queue_free()

func pickup():
	picked_up = true
	$AnimationPlayer.play("pickup")


func _on_animation_player_animation_finished(anim_name):
	queue_free()
