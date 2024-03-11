extends Node

func get_minigame_metadata(name : String):
	var json = get_json("res://resources/metadata/minigames.json")
	
	return json[name]

func get_minigame_path_from_id(id : String) :
	return "res://game/minigames/" + id + "/" + id + ".tscn"

func get_json(filepath : String):
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json_object = JSON.new()
	
	var content = json_object.parse(file.get_as_text())
	return json_object.get_data()
