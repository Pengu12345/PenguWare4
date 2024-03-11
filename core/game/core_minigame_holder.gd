extends Node2D

var level = 1

var colors = {
	"1":"b5d2b0",
	"2":"bfc2ff",
	"3":"ffafb7"
}

@onready var rectangles = [
	$top,
	$left,
	$right,
	$down
]

func update_level(new_level):
	level = new_level
	for rect in rectangles:
		rect.color = colors[str(level)]
