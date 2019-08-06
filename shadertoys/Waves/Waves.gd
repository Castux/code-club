extends Control

var ratio

func _ready():
	updateRatio()

func updateRatio():
	var rect = $Canvas.rect_size
	ratio = rect.x / rect.y
	$Canvas.material.set_shader_param("ratio", ratio)