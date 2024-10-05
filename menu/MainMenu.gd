extends Node2D

@export var button_start_normal : Button
@export var button_start_unique : Button
@export var speed_slider : Slider

@export var list_minigame_ids : ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	# Empty and re-fill out the itemized minigame list
	list_minigame_ids.clear()
	var minigame_metadata = ResourcesManager.get_all_minigame_metadata()
	for meta in minigame_metadata:
		list_minigame_ids.add_item(meta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_start_normal_pressed():
	# Change scene to be the stage example
	MenuManager.loaded_data["speed_factor"] = speed_slider.value
	get_tree().change_scene_to_file("res://game/stages/stage_example/stage_example.tscn")


func _on_button_start_specific_pressed():
	if list_minigame_ids.get_selected_items().is_empty():
		return
		
	var selected_item = list_minigame_ids.get_selected_items()[0]
	var selected_minigame = list_minigame_ids.get_item_text(selected_item)
	
	MenuManager.loaded_data["loaded_minigames"] = [selected_minigame]
	MenuManager.loaded_data["boss_enabled"] = false
	MenuManager.loaded_data["speed_factor"] = speed_slider.value
	get_tree().change_scene_to_file("res://game/stages/stage_arcade/stage_arcade.tscn")
