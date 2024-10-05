extends Node2D

@export var sprite : AnimatedSprite2D
@export var speed = 600
@export var walking_sound : AudioStreamPlayer


var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active: move_character(delta)

func move_character(delta : float):
	
	var vel = Vector2()
		
	if Input.is_action_pressed("ui_left") and position.x > 0:
		vel.x -= speed * delta
	if Input.is_action_pressed("ui_right") and position.x < 1150:
		vel.x += speed * delta
	
	if vel != Vector2.ZERO:
		sprite.play("default")
		if !walking_sound.playing: walking_sound.play()
	else:
		sprite.pause()
		walking_sound.stop()
	position += vel

func squish():
	active = false
	walking_sound.stop()
	sprite.play("death")
