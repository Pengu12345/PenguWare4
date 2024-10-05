extends Node2D
class_name DoodleThwomp

@onready var thwomp_animation = $AnimationPlayer
@onready var thwomp_collision_area = $Collision

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_animation_speed(speed : float):
	thwomp_animation.speed_scale = speed

func play_appear():
	thwomp_animation.stop()
	thwomp_animation.play("appear")

func play_ready():
	thwomp_animation.stop()
	thwomp_animation.play("ready")

func play_fall():
	thwomp_animation.stop()
	thwomp_animation.play("fall")

func get_entities_in_area():
	return thwomp_collision_area.get_overlapping_areas()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
