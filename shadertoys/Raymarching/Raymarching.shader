shader_type canvas_item;
render_mode unshaded;

uniform vec3 position;
uniform vec3 direction;
uniform float clip;
uniform bool addPlane = false;
uniform float fov = 1;
uniform int maxIter = 1000;
uniform float precision = 0.001;
uniform bool useMod = false;
uniform float twist = 0.0;
uniform bool addTubes = true;
uniform int shading = 0;

uniform vec3 lightPos = vec3(10, 20, 30);

uniform int op = 0;

float random (vec2 st)
{
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
	vec3 col1 = vec3(
		oc * axis.x * axis.x + c, 
		oc * axis.x * axis.y + axis.z * s,
		oc * axis.z * axis.x - axis.y * s);
		
	vec3 col2 = vec3(
		oc * axis.x * axis.y - axis.z * s,
		oc * axis.y * axis.y + c,
		oc * axis.y * axis.z + axis.x * s);
	
	vec3 col3 = vec3(
	oc * axis.z * axis.x + axis.y * s,
	oc * axis.y * axis.z - axis.x * s,
	oc * axis.z * axis.z + c);
	
	
    return mat3(col1, col2, col3);
}

float union(float d1, float d2)
{
	return min(d1, d2);
}

float intersection(float d1, float d2)
{
	return max(d1, d2);
}

float difference(float d1, float d2)
{
	return max(d1, -d2);
}

float sphere(vec3 x, float rad)
{
	return length(x) - rad;
}

float cube(vec3 x, float size)
{
	vec3 tmp = abs(x) - vec3(size, size, size);
	return max(tmp.x, max(tmp.y, tmp.z));
}

float plane(vec3 pos, vec3 normal, float offset)
{
	return dot(pos, normal) - offset;
}

float cylinder(vec3 pos, vec3 axis, float diameter)
{
	return length(pos - dot(pos,axis) * axis) - diameter;
}

float distanceFunction(vec3 pos)
{
	float twoPi = 6.28318530718;
	
	// twist!
	float sx = sin(pos.x * twoPi / 50.0);
	float sz = sin(pos.z * twoPi / 50.0);
	pos += (sx * sz) * vec3(0.0,2.0,0.0) * twist;
	
	vec3 mainObjPos = pos;
	if(useMod)
	{
		mainObjPos = mod(pos, vec3(6.0,0,6.0));
	}
	
	float s = sphere(mainObjPos - vec3(3,0,3), 1.2);
	float c = cube(mainObjPos - vec3(3,0,3), 1);
	
	float mainObj;
	if(op == 0)
	{
		mainObj = union(c,s);
	}
	else if(op == 1)
	{
		mainObj = intersection(c,s);
	}
	else if(op == 2)
	{
		mainObj = difference(c,s);
	}
	
	if(addTubes)
	{
		mainObj = union(mainObj, cylinder(mainObjPos - vec3(3,0,3), vec3(1,0,0), 0.5));
		mainObj = union(mainObj, cylinder(mainObjPos - vec3(3,0,3), vec3(0,0,1), 0.5));
	}
	
	if(addPlane)
	{
		float disp = noise(pos.xz / 4.0) * 0.5;
		float p = abs(pos.y + 2.0) - 0.5 + disp;
		mainObj = union(mainObj, p);
	}
	
	return mainObj;
}

vec3 gradient(vec3 pos)
{
	float eps = 0.001;
	
	float dx = distanceFunction(pos + vec3(eps,0,0)) - distanceFunction(pos - vec3(eps,0,0));
	float dy = distanceFunction(pos + vec3(0,eps,0)) - distanceFunction(pos - vec3(0,eps,0));
	float dz = distanceFunction(pos + vec3(0,0,eps)) - distanceFunction(pos - vec3(0,0,eps));

	return vec3(dx,dy,dz)/(2.0*eps);
}

vec3 march(vec3 start, vec3 ray, out bool maxedOut, out int iters)
{
	float dist = 0.0;
	
	maxedOut = false;
	
	for(iters = 0 ; iters < maxIter && dist < clip ; iters++)
	{
		vec3 pos = start + ray * dist;
		
		float d = distanceFunction(pos);
		if(d < precision)
		{
			return pos;
		}
		
		dist += d;
	}
	
	maxedOut = true;
}

uniform float ambiant = 0.1;

vec4 normalShade(vec3 inter)
{
	vec3 grad = normalize(gradient(inter));
	float shade = dot(normalize(grad), normalize(vec3(1,1,1)));
	
	if(shade < 0.0)
	{
		shade = 0.0;
	}
	
	shade += ambiant;
	
	return vec4(shade,shade,shade,1);
}

vec4 perfShade(int iters)
{
	float x = float(iters) / float(maxIter);
	x = pow(x, 0.33);
	return mix(vec4(0.1, 0.0, 0.1, 1), vec4(1.0, 0, 0, 1), x) ;
}

vec4 shadowsShade(vec3 inter)
{
	vec3 dir = lightPos - inter;
	float lightDist = length(dir);
	dir = normalize(dir);
	
	bool maxedOut;
	int iters;
	
	vec3 normal = normalize(gradient(inter));
	
	// Direct illumination
	
	inter += normal * 0.001; 	// get out of the shape or it will intersect immediately!
	march(inter, dir, maxedOut, iters);
	float direct = maxedOut ? 1.0 : 0.0;
	
	// Orientation shading
	
	float orientation = dot(normalize(normal), dir) / 2.0 + 0.5;
	
	// Total
	
	float total = 0.4 * orientation + 0.6 * direct;
	
	return vec4(total, total, total, 1.0);
}

vec4 shade(vec3 inter, int iters)
{
	if(shading == 0)
	{
		return normalShade(inter);
	}
	else if(shading == 1)
	{
		return shadowsShade(inter);
	}
	else if(shading == 2)
	{
		return perfShade(iters);
	}
}

void fragment()
{
	vec3 up = vec3(0,1,0);
	vec3 right = normalize(cross(direction, up));
	
	up = normalize(cross(right, direction));
	
	vec2 pixel = UV - vec2(0.5, 0.5);	
	vec3 ray = direction + pixel.x * right * fov - pixel.y * up * fov;
	ray = normalize(ray);
	
	bool maxedOut;
	int iters;
	vec3 inter = march(position, ray, maxedOut, iters);
	
	if(maxedOut)
	{
		COLOR = vec4(0,0,0,1);
	}
	else
	{
		COLOR = shade(inter, iters);
	}	
}