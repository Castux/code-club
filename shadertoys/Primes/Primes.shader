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

uniform int res = 60;

void fragment()
{	
	ivec2 pos = ivec2(floor(UV.xy * float(res)));
	int i = pos.x + res * pos.y;
	
	if(is_prime(i))
	{
		COLOR = vec4(0.5,0.5,0.5,1.0);
	}
	else
	{
		COLOR = vec4(1.0,1.0,0.5,1.0);
	}	
}