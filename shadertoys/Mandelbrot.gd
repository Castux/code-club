extends Control

var center = Vector2(-0.5, 0.0)
var speed = 0.5
var zoom = 0
var zoomSpeed = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var res = 1.0 / pow(10, zoom)

	if($Buttons/Up.pressed || Input.is_key_pressed(KEY_UP)):
		move(Vector2(0.0, -1.0) * speed * delta * res)
	
	if($Buttons/Down.pressed || Input.is_key_pressed(KEY_DOWN)):
		move(Vector2(0.0, 1.0) * speed * delta * res)
	
	if($Buttons/Left.pressed || Input.is_key_pressed(KEY_LEFT)):
		move(Vector2(-1.0, 0.0) * speed * delta * res)
	
	if($Buttons/Right.pressed || Input.is_key_pressed(KEY_RIGHT)):
		move(Vector2(1.0, 0.0) * speed * delta * res)
	
	if($Buttons/In.pressed || Input.is_key_pressed(KEY_Q)):
		zoom += zoomSpeed * delta
	
	if($Buttons/Out.pressed || Input.is_key_pressed(KEY_W)):
		zoom -= zoomSpeed * delta
	
	$OutputLabel.text = str(center.x, ",", center.y, "\n", zoom)

	$Canvas.material.set_shader_param("center", center)
	$Canvas.material.set_shader_param("zoom", zoom)
	$Canvas.material.set_shader_param("applySqrt", $Buttons/Sqrt.pressed)	

func move(delta):
	center += delta