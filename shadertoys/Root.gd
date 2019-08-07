extends Control

export(Array, PackedScene) var scenes

var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	currentIndex = 0
	set_scene()

func set_scene():
	var current = get_child(0);
	remove_child(current)
	
	var scene = scenes[currentIndex].instance()
	add_child(scene)
	move_child(scene, 0)

func _on_Prev_pressed():
	currentIndex -= 1
	currentIndex %= scenes.size()
	set_scene()

func _on_Next_pressed():
	currentIndex += 1
	currentIndex %= scenes.size()
	set_scene()
