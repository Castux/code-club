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

float plane(vec3 pos, vec3 normal, float offset)
{
	return dot(pos, normal) - offset;
}

vec3 gradient(vec3 pos)
{
	float eps = 0.001;
	
	float dx = distanceFunction(pos + vec3(eps,0,0)) - distanceFunction(pos - vec3(eps,0,0));
	float dy = distanceFunction(pos + vec3(0,eps,0)) - distanceFunction(pos - vec3(0,eps,0));
	float dz = distanceFunction(pos + vec3(0,0,eps)) - distanceFunction(pos - vec3(0,0,eps));

	return vec3(dx,dy,dz)/(2.0*eps);
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

uniform float ambiant = 0.15;

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
		vec3 grad = normalize(gradient(intersection));
		float shade = dot(normalize(grad), normalize(vec3(1,1,1)));
		
		if(shade < 0.0)
		{
			shade = 0.0;
		}
		
		shade += ambiant;
		
		COLOR = vec4(shade,shade,shade,1);
	}	
}