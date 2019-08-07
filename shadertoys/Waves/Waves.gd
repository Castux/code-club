extends Control

var time = 0.0

export(float) var sunWidth;
export(Color) var sunColor;
export(Vector3) var sunDir;

export(float) var fogWidth;
export(Color) var fogColor;

export(Color) var skyColor;
export(Color) var cloudColor;

func _ready():
	updateRatio()

func updateRatio():
	var ratio = rect_size.x / rect_size.y
	material.set_shader_param("ratio", ratio)

func camera(t):
	var x = 0.0 + 40.0 * sin(t / 25.0 * 2.0 * PI);
	var y = 45.0 + 7.0 * sin(t / 20.0 * 2.0 * PI + 1234.0);
	var z = 30.0 * t
	
	return Vector3(x,y,z)

func cameraUp(t):
	var roll = sin(t / 31.0 * 2.0 * PI) * 0.12;
	return Vector3(sin(roll), cos(roll), 0.0);

func _process(delta):
	
	if not Engine.editor_hint:
		time += delta
	
	var pos = camera(time)
	var forward = (camera(time + 2.0) - pos).normalized()
	
	if Engine.editor_hint:
		forward = Vector3(0,0,1)
	
	var up = cameraUp(time)
	
	material.set_shader_param("camera", pos)
	material.set_shader_param("cameraForward", forward)
	material.set_shader_param("cameraUp", up)
	
	material.set_shader_param("sunWidth", sunWidth)
	material.set_shader_param("sunColor", sunColor)
	material.set_shader_param("sunDir", sunDir)
	material.set_shader_param("fogWidth", fogWidth)
	material.set_shader_param("fogColor", fogColor)
	material.set_shader_param("sunWidth", sunWidth)
	material.set_shader_param("skyColor", skyColor)
	material.set_shader_param("cloudColor", cloudColor)
			
	material.set_shader_param("time", time)