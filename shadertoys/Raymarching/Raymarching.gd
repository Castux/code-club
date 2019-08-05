extends Control

var position = Vector3(0,0,0)
var direction = Vector3(0,0,-1);
var speed = 2
var rotSpeed = 2 * PI * 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var up = Vector3.UP
	var right = direction.cross(up)

	if(Input.is_key_pressed(KEY_W)):
		position += direction * speed * delta
	
	if(Input.is_key_pressed(KEY_S)):
		position -= direction * speed * delta

	if(Input.is_key_pressed(KEY_A)):
		position -= right * speed * delta

	if(Input.is_key_pressed(KEY_D)):
		position += right * speed * delta
	
	if(Input.is_key_pressed(KEY_LEFT)):
		direction = direction.rotated(Vector3.UP, rotSpeed * delta)
		
	if(Input.is_key_pressed(KEY_RIGHT)):
		direction = direction.rotated(Vector3.UP, -rotSpeed * delta)
	
	$OutputLabel.text = str(position)
	$Canvas.material.set_shader_param("position", position)
	$Canvas.material.set_shader_param("direction", direction)
	
	$Canvas.material.set_shader_param("maxIter", int($Buttons/MaxIter.text))
	$Canvas.material.set_shader_param("precision", float($Buttons/Precision.text))

func unfocus():
	set_focus_mode(Control.FOCUS_ALL);
	grab_focus();
