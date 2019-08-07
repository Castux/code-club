tool
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
	$AnimationPlayer.play("DayNight")

func updateRatio():
	var ratio = rect_size.x / rect_size.y
	material.set_shader_param("ratio", ratio)

func _process(delta):
	
	if not Engine.editor_hint:
		time += delta
	
	material.set_shader_param("sunWidth", sunWidth)
	material.set_shader_param("sunColor", sunColor)
	material.set_shader_param("sunDir", sunDir)
	material.set_shader_param("fogWidth", fogWidth)
	material.set_shader_param("fogColor", fogColor)
	material.set_shader_param("sunWidth", sunWidth)
	material.set_shader_param("skyColor", skyColor)
	material.set_shader_param("cloudColor", cloudColor)
			
	material.set_shader_param("time", time)