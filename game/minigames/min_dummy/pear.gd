extends Node2D

signal collected

func _ready():
	pass

func _process(delta):
	pass


func _on_collision_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("collected")
		queue_free()
