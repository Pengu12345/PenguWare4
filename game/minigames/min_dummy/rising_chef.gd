extends Node2D

func _ready():
	visible = false

func rise(speed = 1):
	visible = true
	$Happychef/animator.speed_scale = speed
	$Happychef/animator.play("RESET")
	$Happychef/animator.play("rise")
