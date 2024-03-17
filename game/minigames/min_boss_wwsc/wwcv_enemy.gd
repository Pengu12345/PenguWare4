extends Node2D
class_name WWSC_Enemy

var direction = Vector2(0,0)

@export var speed = 200

var speed_factor = 1

func _ready():
	$Sprite.play("default")

func init():
	pass

func _process(delta):
	position += direction.normalized() * speed * delta * speed_factor
