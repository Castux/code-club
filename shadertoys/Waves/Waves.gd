extends Control

func _ready():
	updateRatio()

func updateRatio():
	var ratio = rect_size.x / rect_size.y
	material.set_shader_param("ratio", ratio)