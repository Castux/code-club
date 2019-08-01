extends Control

var res = 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	res = int($Controls/LineEdit.text)
	
	$Canvas.material.set_shader_param("res", res)
