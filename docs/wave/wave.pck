GDPC                                                                                $   res://Mandelbrot/Mandelbrot.gd.remap��      0       �OC-b;�aeU�ֳ�    res://Mandelbrot/Mandelbrot.gdc `      �      D�mwM$9W�!���eM$   res://Mandelbrot/Mandelbrot.shader  �      U      6��	wa����u��    res://Mandelbrot/Mandelbrot.tscnP      �      U�$gn8C�|{#a�   res://Primes/Primes.gd.remap�      (       �[�%}.�v��>_�ۓ   res://Primes/Primes.gdc       �      =$[���fA�`�ft�5   res://Primes/Primes.shader  �      �      �7�5?�?1���In�8   res://Primes/Primes.tscn`      z      ��$
�"��s2wgo~>(   res://Raymarching/Raymarching.gd.remap   �      2       '�j�`*b'���]��$   res://Raymarching/Raymarching.gdc   �"      �      U"���%-B5F;�$   res://Raymarching/Raymarching.shader�0      �      �.*��ָ\=ʵV�$   res://Raymarching/Raymarching.tscn  pH      �      �B���4�o55�G   res://Root.gd.remap `�             ���q�3` +b}�)4Y2   res://Root.gdc  `V             �O�[�����$���d   res://Root.tscn �Y            ��Bbxm�����X��   res://Waves/Waves.gd.remap  ��      &       �@�D�<=s	5�TZ   res://Waves/Waves.gdc   �^      
      �n.�r#�6߅��JݍO   res://Waves/Waves.shader�h      �      YKu� �,�1�d�?�   res://Waves/Waves.tscn  @}      x      �+u,�$;� ���"�   res://project.binary��      �      ���hf�݅	a~�c�        GDSC   "      *   K     ������ڶ   �����Ķ�   ����Ҷ��   ���۶���   ��������Ҷ��   �����϶�   �������Ŷ���   ����׶��   ��Ŷ   ������Ŷ   �ƶ�   ������Ҷ   ����¶��   �������������Ҷ�   ����ᶶ�   ���Ӷ���   ���ض���   ����嶶�   ���¶���   ��������   ����¶��   ����򶶶   �ض�   �����涶   ��¶   ������������   ����������ڶ   ���¶���   ζ��   ϶��   �����Ŷ�   �������ڶ���   ���������������۶���   ���¶���      ?                �������?     �?   
         ,         
         center        zoom   	   applySqrt                                                       	   %   
   '      (      )      0      1      =      >      P      a      b      t      �      �      �      �      �      �      �      �      �      �      �       �   !   �   "   �   #     $     %   !  &   -  '   >  (   ?  )   F  *   3YY;�  �  PR�  QY;�  Y;�  �  Y;�  �  YYY0�  PQV�  -YYY0�  P�  QV�  �  ;�  �  �  P�  R�  QY�  &PW�	  �
  T�  �  T�  P�  QQV�  �  P�  P�  R�  Q�  �  �  Q�  �  &PW�	  �  T�  �  T�  P�  QQV�  �  P�  P�  R�  Q�  �  �  Q�  �  &PW�	  �  T�  �  T�  P�  QQV�  �  P�  P�  R�  Q�  �  �  Q�  �  &PW�	  �  T�  �  T�  P�  QQV�  �  P�  P�  R�  Q�  �  �  Q�  �  &PW�	  �  T�  �  T�  P�  QQV�  �  �  �  �  �  &PW�	  �  T�  �  T�  P�  QQV�  �  �  �  �  �  W�  T�  �7  P�  T�  R�  R�  T�  R�  R�  QY�  W�  T�  T�   P�  R�  Q�  W�  T�  T�   P�	  R�  Q�  W�  T�  T�   P�
  RW�	  �!  T�  QYY0�  P�  QV�  �  �  `            shader_type canvas_item;
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

	
}           [gd_scene load_steps=4 format=2]

[ext_resource path="res://Mandelbrot/Mandelbrot.gd" type="Script" id=1]
[ext_resource path="res://Mandelbrot/Mandelbrot.shader" type="Shader" id=2]

[sub_resource type="ShaderMaterial" id=1]
shader = ExtResource( 2 )
shader_param/center = Vector2( -0.5, 0 )
shader_param/zoom = 0.0
shader_param/applySqrt = false

[node name="Mandelbrot" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource( 1 )

[node name="Background" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color( 0, 0, 0, 1 )

[node name="Canvas" type="ColorRect" parent="."]
material = SubResource( 1 )
margin_right = 600.0
margin_bottom = 600.0
color = Color( 0.45098, 0.172549, 0.172549, 1 )

[node name="OutputLabel" type="Label" parent="."]
margin_left = 684.333
margin_top = 348.333
margin_right = 800.333
margin_bottom = 383.333
text = "Label "

[node name="Buttons" type="VBoxContainer" parent="."]
editor/display_folded = true
anchor_left = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
margin_left = -351.0
margin_top = 38.0
margin_right = -269.0
margin_bottom = -429.0

[node name="Up" type="Button" parent="Buttons"]
margin_right = 82.0
margin_bottom = 20.0
text = "Up"

[node name="Down" type="Button" parent="Buttons"]
margin_top = 24.0
margin_right = 82.0
margin_bottom = 44.0
text = "Down"

[node name="Left" type="Button" parent="Buttons"]
margin_top = 48.0
margin_right = 82.0
margin_bottom = 68.0
text = "Left"

[node name="Right" type="Button" parent="Buttons"]
margin_top = 72.0
margin_right = 82.0
margin_bottom = 92.0
text = "Right"

[node name="In" type="Button" parent="Buttons"]
margin_top = 96.0
margin_right = 82.0
margin_bottom = 116.0
text = "In"

[node name="Out" type="Button" parent="Buttons"]
margin_top = 120.0
margin_right = 82.0
margin_bottom = 140.0
text = "Out"

[node name="Sqrt" type="CheckBox" parent="Buttons"]
margin_top = 144.0
margin_right = 82.0
margin_bottom = 168.0
text = "sqrt"
          GDSC            p      ������ڶ   �����϶�   �������Ŷ���   ���Ӷ���   �������۶���   �������Ŷ���   ����׶��   ��Ŷ   �������¶���   ���¶���   ���Ӷ���   �������Ҷ���   ����Ķ��   ����Ķ��   �����Ŷ�   �������ڶ���   ���������������۶���      Primes        GCD       res       mode      power                      	                              &   	   3   
   =      J      K      W      c      3YY0�  PQV�  W�  �  T�  PQ�  W�  �  T�  P�  QYYY0�  P�  QV�  ;�  �  PW�  �  T�	  Q�  ;�
  W�  �  T�  �  ;�  �  PW�  �  T�	  Q�  �  W�  T�  T�  P�  R�  Q�  W�  T�  T�  P�  R�
  Q�  W�  T�  T�  P�  R�  Q`shader_type canvas_item;
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
    [gd_scene load_steps=4 format=2]

[ext_resource path="res://Primes/Primes.gd" type="Script" id=1]
[ext_resource path="res://Primes/Primes.shader" type="Shader" id=2]

[sub_resource type="ShaderMaterial" id=1]
shader = ExtResource( 2 )
shader_param/res = 60
shader_param/mode = 0
shader_param/power = 2.0

[node name="Primes" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource( 1 )

[node name="Background" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color( 0, 0, 0, 1 )

[node name="Canvas" type="ColorRect" parent="."]
material = SubResource( 1 )
anchor_bottom = 1.0
margin_right = 600.0
color = Color( 0.45098, 0.172549, 0.172549, 1 )

[node name="Controls" type="VBoxContainer" parent="."]
margin_left = 654.0
margin_top = 67.0
margin_right = 834.0
margin_bottom = 389.0

[node name="Label" type="Label" parent="Controls"]
margin_right = 180.0
margin_bottom = 14.0
text = "Resolution:"

[node name="LineEdit" type="LineEdit" parent="Controls"]
margin_top = 18.0
margin_right = 180.0
margin_bottom = 42.0
text = "60"

[node name="Label2" type="Label" parent="Controls"]
margin_top = 46.0
margin_right = 180.0
margin_bottom = 60.0
text = "Mode:"

[node name="Mode" type="OptionButton" parent="Controls"]
margin_top = 64.0
margin_right = 180.0
margin_bottom = 84.0

[node name="Label3 " type="Label" parent="Controls"]
margin_top = 88.0
margin_right = 180.0
margin_bottom = 102.0
text = "Coloring power:"

[node name="Power" type="LineEdit" parent="Controls"]
margin_top = 106.0
margin_right = 180.0
margin_bottom = 130.0
text = "2"

      GDSC   3   #   Y   �     ������ڶ   �������ض���   ��������ض��   ���������Ҷ�   ����Ҷ��   �������Ҷ���   �������Ŷ���   ���������¶�   �����϶�   ������Ŷ   �ƶ�   �������۶���   ������Ѷ   �������Ŷ���   ����׶��   ������Ҷ   �涶   �ƶ�   ����¶��   ����Ŷ��   ����¶��   �������������Ҷ�   ����ᶶ�   ����嶶�   ��������   ����򶶶   �������ⶶ��   ��������ⶶ�   �����涶   ������������   ����������ڶ   ���¶���   �����Ŷ�   �������ڶ���   ���������������۶���   ������Ҷ   ������Ķ   ��������ض��   ���ƶ���   �������Ҷ���   �����Ҷ�   ����Ŷ��   ����������¶   �嶶   �������������ն�   ������Ŷ   �������������Ӷ�   ������������   ���������Ŷ�   ����������������Ҷ��   �������������Ҷ�                    �p=
ף�?  H�z�G�?  333333�?           �>   
                           Union         Intersection   
   Difference        Normal        Shadows       Perf      @     �A                position   	   direction         addPlane      maxIter    	   precision         clip      op        useMod        addTubes      shading       lightPos            zD      twist                            #      (      1      2      ?   	   E   
   F      G      M      W      a      k      l      v      �      �      �      �      �      �      �      �      �      �      �      �      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (     )     *     +     ,   +  -   ,  .   7  /   G  0   H  1   S  2   `  3   a  4   l  5   z  6   {  7   |  8   �  9   �  :   �  ;   �  <   �  =   �  >   �  ?   �  @     A     B   ,  C   =  D   >  E   J  F   K  G   P  H   X  I   b  J   s  K   t  L   �  M   �  N   �  O   �  P   �  Q   �  R   �  S   �  T   �  U   �  V   �  W   �  X   �  Y   3YY;�  �  PR�  R�  QY;�  �  P�  R�  R�  QT�  PQSY;�  Y;�  �  Z�  YY;�  �  P�  R�	  R�
  QSY;�  �  YYY0�  PQV�  W�	  �
  T�  P�  Q�  W�	  �
  T�  P�  Q�  W�	  �
  T�  P�  Q�  �  W�	  �  T�  P�  Q�  W�	  �  T�  P�  Q�  W�	  �  T�  P�  Q�  �  -YYY0�  P�  QV�  �  �  �  T�  P�  T�  R�  �  Z�  Q�  �  ;�  �  T�  �  ;�  �  T�  P�  QT�  PQY�  &P�  T�  P�  QQV�  �  �  �  �  �  �  &P�  T�  P�  QQV�  �  �  �  �  Y�  &P�  T�  P�  QQV�  �  �  �  �  Y�  &P�  T�  P�  QQV�  �  �  �  �  �  �  &P�  T�  P�  QQV�  �  �  T�  P�  T�  R�  �  Q�  �  &P�  T�  P�  QQV�  �  �  T�  P�  T�  R�  �  Q�  �  &P�  T�  P�  QQV�  �  �  T�  P�  R�  �  Q�  �  &P�  T�  P�  QQV�  �  �  T�  P�  R�  �  Q�  �  �  W�  T�  �7  P�  R�  R�  Q�  W�   T�!  T�"  P�  R�  Q�  W�   T�!  T�"  P�  R�  Q�  �  W�   T�!  T�"  P�  R�  PW�	  �	  T�#  QQ�  W�   T�!  T�"  P�  R�  PW�	  �$  T�  QQ�  W�   T�!  T�"  P�  R�  PW�	  �%  T�  QQ�  W�   T�!  T�"  P�  R�  PW�	  �&  T�  QQ�  W�   T�!  T�"  P�  RW�	  �
  T�'  Q�  W�   T�!  T�"  P�  R�  PW�	  �(  T�#  QQ�  W�   T�!  T�"  P�  R�  PW�	  �)  T�#  QQ�  W�   T�!  T�"  P�  RW�	  �  T�'  QY�  W�   T�!  T�"  P�  R�  QY�  ;�*  �   �  &P�  �   QV�  �*  �+  T�,  PQ�  �  �*  P�*  P�!  Q�  ZQ�  �  W�   T�!  T�"  P�"  R�*  QYYY0�-  PQV�  �.  PT�/  QS�  �0  PQSYYY0�1  P�2  QV�  &P�2  QV�  �  �+  T�,  PQ�  (V�  �  �  Y`          shader_type canvas_item;
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

vec3 gradient2(vec3 pos)
{
	float eps = precision/2.0;
	
	float atCenter = distanceFunction(pos);
	
	float dx = distanceFunction(pos + vec3(eps,0,0)) - atCenter;
	float dy = distanceFunction(pos + vec3(0,eps,0)) - atCenter;
	float dz = distanceFunction(pos + vec3(0,0,eps)) - atCenter;

	return vec3(dx,dy,dz)/eps;
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
	vec3 grad = normalize(gradient2(inter));
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
	
	vec3 normal = normalize(gradient2(inter));
	
	// Direct illumination
	
	inter += normal * (2.0 * precision); 	// get out of the shape or it will intersect immediately!
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
}          [gd_scene load_steps=4 format=2]

[ext_resource path="res://Raymarching/Raymarching.gd" type="Script" id=1]
[ext_resource path="res://Raymarching/Raymarching.shader" type="Shader" id=2]

[sub_resource type="ShaderMaterial" id=1]
shader = ExtResource( 2 )
shader_param/position = null
shader_param/direction = null
shader_param/clip = null
shader_param/addPlane = false
shader_param/fov = 1.0
shader_param/maxIter = 1000
shader_param/precision = 0.001
shader_param/useMod = false
shader_param/twist = 0.0
shader_param/addTubes = true
shader_param/shading = 0
shader_param/lightPos = Vector3( 10, 20, 30 )
shader_param/op = 0
shader_param/ambiant = 0.1

[node name="Raymarching" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource( 1 )

[node name="Background" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color( 0, 0, 0, 1 )

[node name="Canvas" type="ColorRect" parent="."]
material = SubResource( 1 )
margin_top = -1.0
margin_right = 600.0
margin_bottom = 599.0
color = Color( 0.45098, 0.172549, 0.172549, 1 )

[node name="OutputLabel" type="Label" parent="."]
margin_left = 684.333
margin_top = 533.333
margin_right = 800.333
margin_bottom = 568.333
text = "Label "

[node name="Buttons" type="VBoxContainer" parent="."]
anchor_left = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
margin_left = -351.0
margin_top = 38.0
margin_right = -269.0
margin_bottom = -429.0

[node name="Plane" type="CheckBox" parent="Buttons"]
margin_right = 95.0
margin_bottom = 24.0
text = "Add plane"

[node name="Label" type="Label" parent="Buttons"]
margin_top = 28.0
margin_right = 95.0
margin_bottom = 42.0
text = "Max iterations:"

[node name="MaxIter" type="LineEdit" parent="Buttons"]
margin_top = 46.0
margin_right = 95.0
margin_bottom = 70.0
focus_mode = 1
text = "1000"
focus_mode = 1

[node name="Label2" type="Label" parent="Buttons"]
margin_top = 74.0
margin_right = 95.0
margin_bottom = 88.0
text = "Precision:"

[node name="Precision" type="LineEdit" parent="Buttons"]
margin_top = 92.0
margin_right = 95.0
margin_bottom = 116.0
focus_mode = 1
text = "0.001"
focus_mode = 1

[node name="Label4" type="Label" parent="Buttons"]
margin_top = 120.0
margin_right = 95.0
margin_bottom = 134.0
text = "Clip:"

[node name="Clip" type="LineEdit" parent="Buttons"]
margin_top = 138.0
margin_right = 95.0
margin_bottom = 162.0
focus_mode = 1
text = "1000"
focus_mode = 1

[node name="Label3" type="Label" parent="Buttons"]
margin_top = 166.0
margin_right = 95.0
margin_bottom = 180.0
text = "Operation:"

[node name="Op" type="OptionButton" parent="Buttons"]
margin_top = 184.0
margin_right = 95.0
margin_bottom = 204.0

[node name="UseMod" type="CheckBox" parent="Buttons"]
margin_top = 208.0
margin_right = 95.0
margin_bottom = 232.0
text = "Use mod()"

[node name="Tubes" type="CheckBox" parent="Buttons"]
margin_top = 236.0
margin_right = 95.0
margin_bottom = 260.0
text = "Add tubes"

[node name="Twist" type="CheckBox" parent="Buttons"]
margin_top = 264.0
margin_right = 95.0
margin_bottom = 288.0
text = "Twist!"

[node name="Shading" type="OptionButton" parent="Buttons"]
margin_top = 292.0
margin_right = 95.0
margin_bottom = 312.0

[connection signal="mouse_entered" from="Background" to="." method="unfocus"]
[connection signal="mouse_entered" from="Canvas" to="." method="unfocus"]
[connection signal="toggled" from="Buttons/Twist" to="." method="_on_Twist_toggled"]
              GDSC            �      ������ڶ   ����������Ӷ   �����Ŷ�   �����������ζ���   �����϶�   ��������Ӷ��   ������¶   ��������Ҷ��   �����������Ҷ���   ����Ӷ��   �������Ӷ���   ��������Ҷ��   ���������Ҷ�   ���������������Ҷ���   ���Ӷ���   ���������������Ҷ���                                                                 	      
   "      #      )      2      7      8      D      I      P      Q      W      [      c      g      h      n      r      z      ~      3YY8P�  R�  Q;�  YY;�  YYY0�  PQV�  �  �  �  PQYY0�  PQV�  ;�  �  PQS�  �  P�  Q�  �  ;�	  �  L�  MT�
  PQ�  �  P�	  Q�  �  P�	  RQYY0�  PQV�  �  �  �  �  �  T�  PQ�  �  PQYY0�  PQV�  �  �  �  �  �  T�  PQ�  �  PQY`[gd_scene load_steps=6 format=2]

[ext_resource path="res://Root.gd" type="Script" id=1]
[ext_resource path="res://Mandelbrot/Mandelbrot.tscn" type="PackedScene" id=2]
[ext_resource path="res://Primes/Primes.tscn" type="PackedScene" id=3]
[ext_resource path="res://Raymarching/Raymarching.tscn" type="PackedScene" id=4]
[ext_resource path="res://Waves/Waves.tscn" type="PackedScene" id=5]

[node name="Root" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource( 1 )
scenes = [ ExtResource( 2 ), ExtResource( 3 ), ExtResource( 4 ), ExtResource( 5 ) ]

[node name="DummyScene" type="Node" parent="."]

[node name="HBoxContainer" type="HBoxContainer" parent="."]
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
margin_left = -97.0
margin_top = -40.0
alignment = 2

[node name="Prev" type="Button" parent="HBoxContainer"]
margin_left = 13.0
margin_right = 53.0
margin_bottom = 40.0
rect_min_size = Vector2( 40, 0 )
text = "<"

[node name="Next" type="Button" parent="HBoxContainer"]
margin_left = 57.0
margin_right = 97.0
margin_bottom = 40.0
rect_min_size = Vector2( 40, 0 )
text = ">"
[connection signal="pressed" from="HBoxContainer/Prev" to="." method="_on_Prev_pressed"]
[connection signal="pressed" from="HBoxContainer/Next" to="." method="_on_Next_pressed"]
  GDSC   '      N   �     ������ڶ   ���Ӷ���   ����Ӷ��   �������޶���   �������Ķ���   �����Ķ�   �������޶���   �������Ķ���   �������Ķ���   ���������Ķ�   �����϶�   ����������ٶ   ��������������Ķ   ���϶���   ����ٶ��   ��������Ӷ��   ζ��   ϶��   �������ڶ���   ���������������۶���   �����׶�   ¶��   ̶��   �������ƶ���   ���ڶ���   �������Ŷ���   ����׶��   �����Ӷ�   ����������¶   ��Ŷ   ������Ҷ   ���������Ҷ�   �ƶ�   �����¶�   ����   ����¶��   ���������������������Ҷ�   �嶶   ����������������ض��                    DayNight      ratio         B     B      @     �B     �@     �A    @�D     �A     B  ���Q��?                   camera        cameraForward         cameraUp      sunWidth      sunColor      sunDir        fogWidth      fogColor      skyColor   
   cloudColor        time      toggle_fullscreen                            
                           	   !   
   )      *      2      :      ;      C      K      L      R      V      ^      _      e      p      y      z      �      �      �      �      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *     +     ,     -     .   )  /   *  0   2  1   3  2   <  3   E  4   N  5   O  6   X  7   a  8   j  9   s  :   |  ;   �  <   �  =   �  >   �  ?   �  @   �  A   �  B   �  C   �  D   �  E   �  F   �  G   �  H   �  I   �  J   �  K   �  L   �  M   �  N   6Y3YY;�  YY;�  �  YY8P�  Q;�  SY8P�  Q;�  SY8P�  Q;�  SYY8P�  Q;�  SY8P�  Q;�  SYY8P�  Q;�  SY8P�  Q;�	  SYY0�
  PQV�  �  PQ�  W�  T�  P�  QYY0�  PQV�  ;�  �  T�  �  T�  �  �  T�  P�  R�  QYY0�  P�  QV�  ;�  �  P�  �  �  ZQS�  ;�  �  �  P�  �	  �  Z�
  QS�  ;�  �  �  �  �  .�  P�  R�  R�  QYY0�  P�  QV�  ;�  P�  �  �  ZQ�  S�  .�  PP�  QR�  P�  QRQSYY0�  P�  QV�  �  &�  T�  �  V�  �  �  �  �  ;�  �  P�  Q�  ;�  P�  P�  �  Q�  QT�  PQ�  �  &�  T�  V�  �  �  P�  R�  R�  Q�  �  ;�   �  P�  Q�  �  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�   Q�  �  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�  Q�  �  T�  P�  R�	  Q�  �  �  T�  P�  R�  Q�  YY0�!  P�"  QV�  &P�#  T�$  P�  QQV�  �%  T�&  �%  T�&  �  YYYYYY�  �  �  `  shader_type canvas_item;
render_mode unshaded;

uniform float ratio = 2;

uniform int maxIter = 100;
uniform float precision = 0.1;
uniform float clip = 1000.0;
uniform float fov = 2.0;
uniform float time = 0.0;

uniform vec3 camera = vec3(0,45,0);
uniform vec3 cameraForward = vec3(0,-0.05,1);
uniform vec3 cameraUp = vec3(0,1,0);

uniform vec3 sunDir = vec3(0,0.5,1);
uniform float sunWidth = 20.0;

uniform float fogWidth = 0.2;
uniform float fogAngle = 0.0;
uniform vec4 fogColor : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec4 sunColor : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 skyColor : hint_color = vec4(0, 0.62, 0.95, 1.0);
uniform vec4 waterColor : hint_color; // = vec4(35.0 / 255.0, 158.0 / 255.0, 133.0 / 255.0, 1.0);
uniform vec4 cloudColor : hint_color;

float map(float x, float a, float b, float u, float v)
{
	return u + (x - a) / (b - a) * (v - u);
}

float hash( float n )
{
  return fract(cos(n)*41415.92653);
}

vec2 randDir(float n)
{
	float phi = hash(n) * 6.28318530718;
	return vec2(cos(phi), sin(phi));
}

mat2 rotation2d(float phi)
{
	float c = cos(phi);
	float s = sin(phi);
	
	return mat2(
		vec2(c, s),
		vec2(-s, c)
	);
}

float noise2d(vec2 x)
{
	vec2 p  = floor(x);
	vec2 f  = fract(x);
	float n = p.x + p.y*57.0;
	
	return mix(
		mix( hash(n +  0.0), hash(n +  1.0),f.x),
    	mix( hash(n + 57.0), hash(n + 58.0),f.x),
		f.y);
}

float softNoise2d(vec2 x)
{
	vec2 p  = floor(x);
	vec2 f  = smoothstep(0.0, 1.0, fract(x));
	float n = p.x + p.y*57.0;
	
	return mix(
		mix( hash(n +  0.0), hash(n +  1.0),f.x),
    	mix( hash(n + 57.0), hash(n + 58.0),f.x),
		f.y);
}

vec4 cloud(vec2 pos)
{
	float density = 0.0;
	float amp = 1.0;
	float totalWeight = 0.0;
	
	for(int i = 0 ; i < 6 ; i++)
	{
		density += softNoise2d(pos) * amp;
		totalWeight += amp;
		
		amp /= 2.0;
		pos *= 2.7;
	}
	
	density /= totalWeight;
	density -= 0.5;
	density *= 4.5;
	density = clamp(density, 0.0, 1.0);
	
	return vec4(cloudColor.xyz, density);
}

float water(vec2 p)
{
	float w = 0.0;
	
	float tshift = time / 5.0;
	vec2 shift1 = 0.001*vec2( time*160.0*2.0, time*120.0*2.0 );
	
	w += sin(dot(p, vec2(0.021, 0.0)) + tshift)*4.5;
	w += sin(dot(p, vec2(0.017, 0.01)) + tshift * 1.1)*4.1;
	w += sin(dot(p, vec2(0.00104, 0.005)) + tshift * 0.121)*4.0;
	
	float amp = 5.0;
	float noiseLen = 50.0;
	
	for (int i = 0; i < 7; i++)
	{
		vec2 p2 = p / noiseLen + vec2(1,0) * (time * 0.15);
		
		float randAngle = hash(float(10 * i)) * 6.28318530718;
		p2 = rotation2d(randAngle) * p2;
		
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
		
		// Looking up!
		if(ray.y > 0.0)
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
	vec4 suncol = pow(clamp(sundot,0,1), sunWidth) * sunColor;
	
	suncol = clamp(suncol, 0.0, 1.0);
	
	vec3 one = vec3(1);
	
    return one - (one - skyColor.xyz) * (one - suncol.xyz);
	//return suncol.xyz * suncol.a + skyColor.xyz * (1.0 - suncol.a);
}

vec3 skyAndClouds(vec3 eye, vec3 ray)
{
	// Solve for cloud layer distance
	
	float cloudHeight = 300.0;
	float d = (cloudHeight - eye.y) / ray.y;
	
	vec3 pos = eye + d * ray;
	
	// Shade!
	
	vec4 cloudCol = cloud(pos.xz / 1000.0);
	vec3 skyCol = sky(ray);
	
	return cloudCol.xyz * cloudCol.a + skyCol * (1.0 - cloudCol.a);
}

vec4 fog(vec3 ray)
{
	float ang = asin(ray.y / sqrt(ray.x * ray.x + ray.z * ray.z));
	
	float angFactor = exp(-ang*ang / fogWidth / fogWidth);
	
	vec4 res = fogColor;
	res.a *= angFactor;
	
	return res;
}

vec3 shade(vec3 pos, vec3 ray)
{
	vec3 n = normal(pos);
	
	// Reflect
	
	float nray = dot(n,ray);
	vec3 reflected = normalize(ray - 2.0 * nray * n);
	vec3 skyRefl = skyAndClouds(pos, reflected);
	
	// Sun shading
	
	float d = dot(n,normalize(sunDir));
	d = clamp(d, 0, 1) * 2.0 - 0.5;
	
	// Reflection factor: more when incident, less when orthogonal
	
	float reflFact = (1.0 - abs(nray));
	
	reflFact = map(reflFact, 0.0, 1.0, 0.6, 0.8); 
	
	// Combine!
	
	vec3 total = waterColor.xyz * d * (1.0 - reflFact) + skyRefl * reflFact;
	return total;
}

vec3 screenRay(vec2 uv)
{
	vec3 right = normalize(cross(cameraForward, cameraUp));	
	vec3 up = normalize(cross(right, cameraForward));
	
	vec3 ray = cameraForward + uv.x * right * fov - uv.y * up * fov;
	return normalize(ray);
}

void fragment()
{	
	vec2 uv = vec2((UV.x - 0.5) * ratio, UV.y - 0.5);
	vec3 ray = screenRay(uv);

	bool maxedOut;
	int iters;
	vec3 hit = march(camera, ray, maxedOut, iters);
	
	vec3 s = maxedOut ? skyAndClouds(camera, ray) : shade(hit, ray);
	
	vec4 fogRes = fog(ray);
	s = fogRes.xyz * fogRes.a + s * (1.0 - fogRes.a);
	
	COLOR = vec4(s,1);
}

            [gd_scene load_steps=6 format=2]

[ext_resource path="res://Waves/Waves.shader" type="Shader" id=1]
[ext_resource path="res://Waves/Waves.gd" type="Script" id=2]

[sub_resource type="ShaderMaterial" id=1]
shader = ExtResource( 1 )
shader_param/ratio = 1.70667
shader_param/maxIter = 1000
shader_param/precision = 0.01
shader_param/clip = 9000.0
shader_param/fov = 1.5
shader_param/time = 0.0
shader_param/camera = Vector3( 0, 79.2135, 0 )
shader_param/cameraForward = Vector3( 0, 0, 1 )
shader_param/cameraUp = Vector3( 0, 1, 0 )
shader_param/sunDir = Vector3( 0, -0.1168, 1 )
shader_param/sunWidth = 47.6744
shader_param/fogWidth = 0.06496
shader_param/fogAngle = 1.46
shader_param/fogColor = Color( 0.496471, 0.496471, 0.496471, 0.788235 )
shader_param/sunColor = Color( 1, 0.977255, 0.955294, 1 )
shader_param/skyColor = Color( 0.545882, 0.355294, 0.263529, 1 )
shader_param/waterColor = Color( 0.0186157, 0.220939, 0.238281, 1 )
shader_param/cloudColor = Color( 0.32549, 0.181961, 0.181961, 1 )

[sub_resource type="Animation" id=2]
resource_name = "DayNight"
length = 105.0
loop = true
step = 1.0
tracks/0/type = "value"
tracks/0/path = NodePath(".:sunColor")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/keys = {
"times": PoolRealArray( 5, 15, 20, 30, 35, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 1 ), Color( 1, 0.666667, 0, 1 ), Color( 1, 0.972549, 0.917647, 1 ), Color( 1, 0.972549, 0.917647, 1 ), Color( 1, 0.972549, 0.917647, 1 ), Color( 1, 0.980392, 0.980392, 1 ) ]
}
tracks/1/type = "value"
tracks/1/path = NodePath(".:sunDir")
tracks/1/interp = 2
tracks/1/loop_wrap = true
tracks/1/imported = false
tracks/1/enabled = true
tracks/1/keys = {
"times": PoolRealArray( 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ Vector3( 0, 0.35, 1 ), Vector3( 0, 0.66, 1 ), Vector3( 0, 0.35, 1 ), Vector3( 0, 0.15, 1 ), Vector3( 0, 0, 1 ), Vector3( 0, -0.15, 1 ), Vector3( 0, -0.35, 1 ), Vector3( 0, -0.66, 1 ), Vector3( 0, -0.35, 1 ), Vector3( 0, -0.15, 1 ), Vector3( 0, 0, 1 ), Vector3( 0, 0.15, 1 ), Vector3( 0, 0.35, 1 ), Vector3( 0, 0.15, 1 ), Vector3( 0, 0, 1 ), Vector3( 0, -0.15, 1 ), Vector3( 0, -0.35, 1 ), Vector3( 0, -0.35, 1 ), Vector3( 0, -0.15, 1 ), Vector3( 0, 0, 1 ), Vector3( 0, 0.15, 1 ) ]
}
tracks/2/type = "value"
tracks/2/path = NodePath(".:sunWidth")
tracks/2/interp = 2
tracks/2/loop_wrap = true
tracks/2/imported = false
tracks/2/enabled = true
tracks/2/keys = {
"times": PoolRealArray( 5, 15, 20, 25, 35, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ 30.0, 30.0, 5.0, 50.0, 50.0, 50.0, 46.2731 ]
}
tracks/3/type = "value"
tracks/3/path = NodePath(".:fogWidth")
tracks/3/interp = 2
tracks/3/loop_wrap = true
tracks/3/imported = false
tracks/3/enabled = true
tracks/3/keys = {
"times": PoolRealArray( 5, 15, 20, 25, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ 0.04, 0.04, 0.064, 0.04, 0.04, 0.08 ]
}
tracks/4/type = "value"
tracks/4/path = NodePath(".:fogColor")
tracks/4/interp = 2
tracks/4/loop_wrap = true
tracks/4/imported = false
tracks/4/enabled = true
tracks/4/keys = {
"times": PoolRealArray( 5, 15, 20, 30, 35, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ Color( 0.74902, 0.854902, 1, 0.835294 ), Color( 0.74902, 0.854902, 1, 0.478431 ), Color( 0.333333, 0.266667, 0.156863, 0.654902 ), Color( 0, 0, 0, 1 ), Color( 0, 0, 0, 1 ), Color( 0, 0, 0, 1 ), Color( 0.827451, 0.827451, 0.827451, 0.647059 ) ]
}
tracks/5/type = "value"
tracks/5/path = NodePath(".:skyColor")
tracks/5/interp = 2
tracks/5/loop_wrap = true
tracks/5/imported = false
tracks/5/enabled = true
tracks/5/keys = {
"times": PoolRealArray( 5, 15, 20, 30, 35, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ Color( 0.607843, 0.890196, 1, 1 ), Color( 0.607843, 0.890196, 1, 1 ), Color( 0.827451, 0.0901961, 0.0901961, 1 ), Color( 0, 0, 0, 1 ), Color( 0, 0, 0, 1 ), Color( 0, 0, 0, 1 ), Color( 0.909804, 0.592157, 0.439216, 1 ) ]
}
tracks/6/type = "value"
tracks/6/path = NodePath(".:cloudColor")
tracks/6/interp = 2
tracks/6/loop_wrap = true
tracks/6/imported = false
tracks/6/enabled = true
tracks/6/keys = {
"times": PoolRealArray( 5, 15, 20, 30, 35, 90, 100 ),
"transitions": PoolRealArray( 1, 1, 1, 1, 1, 1, 1 ),
"update": 0,
"values": [ Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 1 ), Color( 0.537255, 0.270588, 0.0313726, 1 ), Color( 0.231373, 0.231373, 0.231373, 1 ), Color( 0.231373, 0.231373, 0.231373, 1 ), Color( 0.231373, 0.231373, 0.231373, 1 ), Color( 0.388235, 0.14902, 0.14902, 1 ) ]
}

[sub_resource type="GDScript" id=3]
script/source = "extends Label

var secPerFrame = 1.0
var lastTime = 0.0

var show = false

func _ready():
	lastTime = OS.get_ticks_msec() / 1000.0

func _process(delta):
	
	var now = OS.get_ticks_msec() / 1000.0
	var d = now - lastTime
	
	secPerFrame += (d - secPerFrame) * 0.2  ## smoothing
	var fps = 1.0 / secPerFrame
	
	if show:
		text = str(round(fps), \" FPS\")
	else:
		text = \"\"
	
	lastTime = now

func _input(ev):
	if Input.is_key_pressed(KEY_SPACE):
		show = not show"

[node name="Canvas" type="ColorRect"]
material = SubResource( 1 )
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource( 2 )
__meta__ = {
"_edit_lock_": true
}
sunWidth = 47.6744
sunColor = Color( 1, 0.977255, 0.955294, 1 )
sunDir = Vector3( 0, -0.1168, 1 )
fogWidth = 0.06496
fogColor = Color( 0.496471, 0.496471, 0.496471, 0.788235 )
skyColor = Color( 0.545882, 0.355294, 0.263529, 1 )
cloudColor = Color( 0.32549, 0.181961, 0.181961, 1 )

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
pause_mode = 1
anims/DayNight = SubResource( 2 )

[node name="FPSCounter" type="Label" parent="."]
anchor_left = 1.0
anchor_right = 1.0
margin_left = -56.0
margin_bottom = 14.0
custom_colors/font_color = Color( 1, 0, 0, 1 )
text = "?? FPS"
script = SubResource( 3 )
[connection signal="item_rect_changed" from="." to="." method="updateRatio"]
        [remap]

path="res://Mandelbrot/Mandelbrot.gdc"
[remap]

path="res://Primes/Primes.gdc"
        [remap]

path="res://Raymarching/Raymarching.gdc"
              [remap]

path="res://Root.gdc"
 [remap]

path="res://Waves/Waves.gdc"
          ECFG      _global_script_classes             _global_script_class_icons             application/config/name      
   shadertoys     application/run/main_scene          res://Waves/Waves.tscn     input/ui_accept8               deadzone      ?      events            input/ui_select8               deadzone      ?      events            input/ui_cancel8               deadzone      ?      events            input/ui_focus_next8               deadzone      ?      events            input/ui_focus_prev8               deadzone      ?      events            input/ui_left8               deadzone      ?      events            input/ui_right8               deadzone      ?      events            input/ui_up8               deadzone      ?      events            input/ui_down8               deadzone      ?      events            input/ui_page_up8               deadzone      ?      events            input/ui_page_down8               deadzone      ?      events            input/ui_home8               deadzone      ?      events            input/ui_end8               deadzone      ?      events            input/toggle_fullscreend              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   F      unicode           echo          script            input/paused              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode          unicode           echo          script                 GDPC