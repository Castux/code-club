extends Control

var position = Vector3(8,3,5)
var direction = Vector3(-0.77,-0.54,-0.30).normalized();
var speed = 4
var rotSpeed = 2 * PI * 0.25

var lightPos = Vector3(10,20,30);
var twistStart = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Buttons/Op.add_item("Union")
	$Buttons/Op.add_item("Intersection")
	$Buttons/Op.add_item("Difference")
	
	$Buttons/Shading.add_item("Normal")
	$Buttons/Shading.add_item("Shadows")
	$Buttons/Shading.add_item("Perf")
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lightPos = lightPos.rotated(Vector3.UP, delta * 2.0 * PI / 20.0)
	
	var up = Vector3.UP
	var right = direction.cross(up).normalized()

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
	
	if(Input.is_key_pressed(KEY_UP)):
		direction = direction.rotated(right, rotSpeed * delta)
		
	if(Input.is_key_pressed(KEY_DOWN)):
		direction = direction.rotated(right, -rotSpeed * delta)
	
	
	$OutputLabel.text = str(position, " ", direction)
	$Canvas.material.set_shader_param("position", position)
	$Canvas.material.set_shader_param("direction", direction)
	
	$Canvas.material.set_shader_param("addPlane", int($Buttons/Plane.pressed))
	$Canvas.material.set_shader_param("maxIter", int($Buttons/MaxIter.text))
	$Canvas.material.set_shader_param("precision", float($Buttons/Precision.text))
	$Canvas.material.set_shader_param("clip", float($Buttons/Clip.text))
	$Canvas.material.set_shader_param("op", $Buttons/Op.selected)
	$Canvas.material.set_shader_param("useMod", float($Buttons/UseMod.pressed))
	$Canvas.material.set_shader_param("addTubes", float($Buttons/Tubes.pressed))
	$Canvas.material.set_shader_param("shading", $Buttons/Shading.selected)

	$Canvas.material.set_shader_param("lightPos", lightPos)

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
