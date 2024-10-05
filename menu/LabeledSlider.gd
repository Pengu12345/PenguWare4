extends HSlider

@onready var label = $Label
@export var description = "Value: "

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = description + str(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_value_changed(value):
	label.text = description + str(value)
