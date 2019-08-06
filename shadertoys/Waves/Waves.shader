shader_type canvas_item;
render_mode unshaded;

uniform float ratio = 2;

uniform int maxIter = 1000;
uniform float precision = 0.001;
uniform float clip = 1000.0;
uniform float fov = 1.0;

float distFunc(vec3 pos)
{
	return pos.y;
}

vec3 march(vec3 start, vec3 ray, out bool maxedOut, out int iters)
{
	float dist = 0.0;
	
	maxedOut = false;
	
	for(iters = 0 ; iters < maxIter && dist < clip ; iters++)
	{
		vec3 pos = start + ray * dist;
		
		float d = distFunc(pos);
		if(d < precision)
		{
			return pos;
		}
		
		dist += d;
	}
	
	maxedOut = true;
}

vec3 screenRay(vec3 eye, vec3 forward, vec2 uv)
{
	vec3 up = vec3(0,1,0);
	vec3 right = normalize(cross(forward, up));
	
	up = normalize(cross(right, forward));
	
	vec3 ray = forward + uv.x * right * fov - uv.y * up * fov;
	return normalize(ray);
}

void fragment()
{
	vec2 uv = vec2((UV.x - 0.5) * ratio, UV.y - 0.5);
	
	vec3 eye = vec3(0,10,0);
	vec3 forward = vec3(0,-0.5,1);
	vec3 ray = screenRay(eye, forward, uv);

	bool maxedOut;
	int iters;
	vec3 hit = march(eye, ray, maxedOut, iters);
	
	COLOR = vec4(0,uv,1);
}

