shader_type canvas_item;
render_mode unshaded;

bool is_prime(int i)
{
	int k = 2;
	while(k*k <= i)
	{
		if(i % k == 0)
		{
			return false;
		}
		k++;
	}

	return true;
}

int gcd(int a, int b)
{
	if(a <= 0)
	{
		return b;
	}

	if(b <= 0)
	{
		return a;
	}

	while(a != b)
	{
		if(a > b)
		{
			a = a - b;
		}
		else
		{
			b = b - a;
		}
	}

	return a;
}

uniform int res = 60;
uniform int mode = 0;
uniform float power = 2;

void fragment()
{
	ivec2 pos = ivec2(floor(UV.xy * float(res)));
	int i = pos.x + res * pos.y;

	if(mode == 0)
	{
		if(is_prime(i))
		{
			COLOR = vec4(0.5,0.5,0.5,1.0);
		}
		else
		{
			COLOR = vec4(1.0,1.0,0.5,1.0);
		}
	}
	else
	{
		int d = gcd(pos.x + 1, pos.y + 1);
		if(d == 1)
		{
			d = 0;
		}
		
		float shade = pow(float(d) / float(res), 1.0 / power);
		COLOR = vec4(0.0,0.0,shade,1.0);
	}
}
