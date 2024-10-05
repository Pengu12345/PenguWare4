extends Node

@onready var loaded_data : Dictionary

# Loaded data properies used by the engine:
# "loaded_minigames":[] => List of all the loaded minigames the stage should use
# "boss_enabled":bool => Indicates wether the boss should be enabled in a given stage
# "speed_factor":float => Indicates the speed factor the stage should immediatly have.

# /!\ Note that the stage has handles and parse the data loaded. It is not an automatic toggle.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset_stage_properties():
	var properties_to_erase = ["loaded_minigames", "boss_enabled", "speed_factor"]
	
	for prop in properties_to_erase:
		loaded_data.erase(prop)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
