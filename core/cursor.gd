extends Node2D

var cursor_path = "res://resources/texture/cursor.png"

var cursor_node = null

func _ready():
	var image = load(cursor_path)
	if image:
		cursor_node = Sprite2D.new()
		cursor_node.texture = image
		
		cursor_node.z_index = 1000
		
		add_child(cursor_node)
		
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	else:
		print("ERROR: Cursor not loaded, path not found.")

func _process(delta):
	if cursor_node:
		cursor_node.position.x = get_viewport().get_mouse_position().x
		cursor_node.position.y = get_viewport().get_mouse_position().y
