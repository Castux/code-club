shader_type canvas_item;
render_mode unshaded;

uniform vec2 center;
uniform float zoom;
uniform bool applySqrt;

void fragment()
{
	int maxIter = 1000;
	
	highp vec2 c = (UV.xy - vec2(0.5,0.5)) * 2.0; // Centered on 0, -1 to 1
	
	
	c = c / pow(10, zoom);
	c = c + center;
	
	
	vec2 x = vec2(0.0, 0.0);
	int i = 0;
	
	while(i < maxIter && length(x) < 2.0)
	{
		x = vec2(x.x*x.x - x.y*x.y, 2.0 * x.x*x.y);
		x = x + c;
		i++;
	}
	
	float shade = (float(i) / float(maxIter));
	if(applySqrt)
	{
		shade = sqrt(shade);
	}
	
	COLOR = vec4(shade,shade,shade,1);

	
}