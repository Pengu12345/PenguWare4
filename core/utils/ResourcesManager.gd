extends Node

var minigame_metadata : Dictionary


# Only load the metadata once to avoid querying the json constantly
func _init():
	var json = get_json("res://resources/metadata/minigames.json")
	minigame_metadata = json

# Return the metadata of one minigame relative to it's id (is read-only)
func get_minigame_metadata(name : String):
	print("Getting data of '", name, "'")
	return minigame_metadata[name].duplicate(true)

# Return the loaded minigames metadata (is read-only)
func get_all_minigame_metadata():
	return minigame_metadata.duplicate(true)

func get_minigame_path_from_id(id : String) :
	return "res://game/minigames/" + id + "/" + id + ".tscn"

func get_json(filepath : String):
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json_object = JSON.new()
	
	var content = json_object.parse(file.get_as_text())
	return json_object.get_data()
