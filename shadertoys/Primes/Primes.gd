extends Control

func _ready():
	$Controls/Mode.add_item("Primes")
	$Controls/Mode.add_item("GCD")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var res = int($Controls/LineEdit.text)
	var mode = $Controls/Mode.selected
	var power = float($Controls/Power.text)
	
	$Canvas.material.set_shader_param("res", res)
	$Canvas.material.set_shader_param("mode", mode)
	$Canvas.material.set_shader_param("power", power)