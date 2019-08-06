extends Control

var time = 0.0

func _ready():
	updateRatio()

func updateRatio():
	var ratio = rect_size.x / rect_size.y
	material.set_shader_param("ratio", ratio)

func _process(delta):
	time += delta
	material.set_shader_param("time", time)