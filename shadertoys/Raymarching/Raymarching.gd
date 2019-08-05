extends Control

var position = Vector3(3,1,0)
var direction = Vector3(0,-0.5,1);
var speed = 2
var rotSpeed = 2 * PI * 0.25

var twistStart = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Buttons/Op.add_item("Union")
	$Buttons/Op.add_item("Intersection")
	$Buttons/Op.add_item("Difference")
	
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
	
	$Canvas.material.set_shader_param("addPlane", int($Buttons/Plane.pressed))
	$Canvas.material.set_shader_param("maxIter", int($Buttons/MaxIter.text))
	$Canvas.material.set_shader_param("precision", float($Buttons/Precision.text))
	$Canvas.material.set_shader_param("op", float($Buttons/Op.selected))
	$Canvas.material.set_shader_param("useMod", float($Buttons/UseMod.pressed))

	var twistAmount = 0
	if(twistStart > 0):
		twistAmount = OS.get_ticks_msec() - twistStart
		twistAmount = sin(twistAmount / (8 * 1000.0) * 2 * PI) * (2 * PI / 6)
		
	$Canvas.material.set_shader_param("twist", twistAmount)	


func unfocus():
	set_focus_mode(Control.FOCUS_ALL);
	grab_focus();


func _on_Twist_toggled(button_pressed):
	if(button_pressed):
		twistStart = OS.get_ticks_msec()
	else:
		twistStart = -1
