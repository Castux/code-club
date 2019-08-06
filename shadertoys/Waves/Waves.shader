shader_type canvas_item;
render_mode unshaded;

uniform float ratio = 2;

uniform int maxIter = 100;
uniform float precision = 0.1;
uniform float clip = 1000.0;
uniform float fov = 2.0;
uniform float time = 0.0;
uniform vec3 sunDir = vec3(1,1,1);

float hash( float n )
{
  return fract(cos(n)*41415.92653);
}

vec2 randDir(float n)
{
	float phi = hash(n) * 6.28318530718;
	return vec2(cos(phi), sin(phi));
}

float noise2d(vec2 x)
{
	vec2 p  = floor(x);
	vec2 f  = smoothstep(0.0, 1.0, fract(x));
	float n = p.x + p.y*57.0;
	
	return mix(
		mix( hash(n +  0.0), hash(n +  1.0),f.x),
    	mix( hash(n + 57.0), hash(n + 58.0),f.x),
		f.y);
}

float water(vec2 p)
{
	float w = 0.0;
	
	float tshift = time / 5.0;
	vec2 shift1 = 0.001*vec2( time*160.0*2.0, time*120.0*2.0 );
	
	w += sin(dot(p, vec2(0.021, 0.0)) + tshift)*4.5;
	w += sin(dot(p, vec2(0.017, 0.01)) + tshift * 1.1)*4.1;
	w += sin(dot(p, vec2(0.00104, 0.005)) + tshift * 0.121)*4.0;
	
	float amp = 4.0;
	float noiseLen = 50.0;
	
	for (int i = 0; i < 7; i++)
	{
		vec2 dir = randDir(float(i));
		vec2 p2 = p / noiseLen + dir * (time * 0.05);
		
		w += -abs(sin(noise2d(p2) - 0.5) * 3.14) * amp;
		amp *= .5;
		noiseLen /= 1.8;
	}
	
	return w;
}

vec3 surface(vec2 p)
{
	return vec3(p.x, water(p), p.y);
}

vec3 march(vec3 start, vec3 ray, out bool maxedOut, out int iters)
{
	float dist = 0.0;
	
	maxedOut = false;
	
	for(iters = 0 ; iters < maxIter && dist < clip ; iters++)
	{
		vec3 pos = start + ray * dist;
		
		// Too high to hit anything
		if(pos.y > 100.0 || ray.y > 0.0)
			break;
		
		float d = pos.y - water(pos.xz);
		if(d < precision)
		{
			return pos;
		}
		
		dist += d;
	}
	
	maxedOut = true;
}

vec3 normal(vec3 pos)
{
	float eps = precision / 2.0;
	
	float c = water(pos.xz);
	float dx = water(pos.xz + vec2(eps,0.0)) - c;
	float dz = water(pos.xz + vec2(0.0,eps)) - c;
	
	return normalize(vec3(-dx/eps, 1.0, -dz/eps));
}

vec3 sky(vec3 dir)
{
	float sundot = dot(dir, normalize(sunDir));
	
	vec3 skycol = vec3(0,0.62,0.95);
	vec3 suncol = pow(clamp(sundot,0,1), 10.0) * vec3(1.0,1.0,1.0);
	
	vec3 one = vec3(1);
	
    return one - (one - skycol) * (one - suncol);
}

vec3 shade(vec3 pos, vec3 ray)
{
	vec3 n = normal(pos);
	
	// Own color
	
	vec3 ownCol = vec3(0.03,0.34,0.64);
	
	// Reflect
	
	float nray = dot(n,ray);
	vec3 reflected = normalize(ray - 2.0 * nray * n);
	vec3 skyRefl = sky(reflected);
	
	// Sun shading
	
	float d = dot(n,normalize(sunDir));
	
	// Combine!
	
	vec3 total = ownCol * d * 0.5 + skyRefl * 0.5;
	return total;
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
	
	vec3 eye = vec3(0,25,0);
	vec3 forward = vec3(sin(time / 15.0),-0.35,cos(time / 15.0));
	vec3 ray = screenRay(eye, forward, uv);

	bool maxedOut;
	int iters;
	vec3 hit = march(eye, ray, maxedOut, iters);
	
	vec3 s = maxedOut ? sky(ray) : shade(hit, ray);
	
	COLOR = vec4(s,1);
}

