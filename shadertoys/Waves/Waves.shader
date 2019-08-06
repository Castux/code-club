shader_type canvas_item;
render_mode unshaded;

uniform float ratio = 2;

uniform int maxIter = 100;
uniform float precision = 0.001;
uniform float clip = 1000.0;
uniform float fov = 2.0;
uniform float time = 0.0;
uniform vec3 sunDir = vec3(1,1,1);

float hash( float n )
{
  return fract(cos(n)*41415.92653);
}

float noise( in vec3 x )
{
  vec3 p  = floor(x);
  vec3 f  = smoothstep(0.0, 1.0, fract(x));
  float n = p.x + p.y*57.0 + 113.0*p.z;

  return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
    mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}


float pointy(float f)
{
	return pow(1.0 - abs(f), 2);
}

float distFunc(vec3 pos)
{
	vec2 p = pos.xz;
	float w = 0.0;
	
	float tshift = time / 5.0;
	vec2 shift1 = 0.001*vec2( time*160.0*2.0, time*120.0*2.0 );
	
	w += sin(dot(p, vec2(0.021, 0.0)) + tshift)*4.5;
	w += sin(dot(p, vec2(0.017, 0.01)) + tshift * 1.1)*4.1;
	w += sin(dot(p, vec2(0.00104, 0.005)) + tshift * 0.121)*4.0;
	
	shift1 *= 0.3;
	float amp = 6.0;
	
	mat2 m2 = mat2(vec2(1.6,1.2), vec2(-1.2,1.6));
	
	for (int i=0; i<7; i++)
	  {
	    w += abs(sin(noise(vec3(p*0.01 + shift1, 1.0)) - 0.5) * 3.14) * amp; 
	    amp *= .51;
	    shift1 *= 1.841;
	    p *= m2*0.9331;
	  }
	
	
	return pos.y + w;
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

vec3 normal(vec3 pos)
{
	float eps = precision/2.0;
	
	float atCenter = distFunc(pos);
	
	float dx = distFunc(pos + vec3(eps,0,0)) - atCenter;
	float dy = distFunc(pos + vec3(0,eps,0)) - atCenter;
	float dz = distFunc(pos + vec3(0,0,eps)) - atCenter;

	return normalize(vec3(dx,dy,dz));
}

vec3 sky(vec3 dir)
{
	float sundot = dot(dir, normalize(sunDir));
	
	vec3 skycol = vec3(0,0.62,0.95);
	vec3 suncol = pow(clamp(sundot,0,1), 10.0) * vec3(1.0,1.0,1.0);
	
	vec3 one =  vec3(1);
	
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
	
	vec3 eye = vec3(0,30,0);
	vec3 forward = vec3(sin(time / 15.0),-0.25,cos(time / 15.0));
	vec3 ray = screenRay(eye, forward, uv);

	bool maxedOut;
	int iters;
	vec3 hit = march(eye, ray, maxedOut, iters);
	
	vec3 s = maxedOut ? sky(ray) : shade(hit, ray);
	
	COLOR = vec4(s,1);
}

