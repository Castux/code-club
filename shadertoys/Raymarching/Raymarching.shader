shader_type canvas_item;
render_mode unshaded;

uniform vec3 position;
uniform vec3 direction;
uniform float fov = 1;

float sphere(vec3 x, vec3 center, float rad)
{
	return length(x - center) - rad;
}

float distanceFunction(vec3 pos)
{
	return sphere(pos, vec3(0,0,-5), 2);
}

vec3 march(vec3 start, vec3 ray, float precision, int maxIter, out bool maxedOut)
{
	vec3 pos = start;
	maxedOut = false;
	
	for(int i = 0 ; i < maxIter ; i++)
	{
		float d = distanceFunction(pos);
		if(d < precision)
		{
			return pos;
		}
		
		pos += ray * d;
	}
	
	maxedOut = true;
	return pos;
}

void fragment()
{
	vec3 up = vec3(0,1,0);
	vec3 right = cross(direction, up);
	
	up = cross(right, direction);
	
	vec2 pixel = UV - vec2(0.5, 0.5);	
	vec3 ray = direction + pixel.x * right * fov - pixel.y * up * fov;
	ray = normalize(ray);
	
	bool maxedOut;
	vec3 intersection = march(position, ray, 0.01, 100, maxedOut);
	
	if(maxedOut)
	{
		COLOR = vec4(0,0,0,1);
	}
	else
	{
		COLOR = vec4(1,1,1,1);
	}	
}