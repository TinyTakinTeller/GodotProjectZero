/////////////////////////////////
// 2D Radial Distortion Shader //
/////////////////////////////////

// Screen space shader for Godot, based on: https://gist.github.com/aggregate1166877/a889083801d67917c26c12a98e7f57a7

shader_type canvas_item;

const float pi = 3.1415;

uniform float amp : hint_range(0,1) = 0.3;
uniform float period : hint_range(0,20) = 4.161;
uniform float aspect_base : hint_range(0,2) = 1.0;

uniform float amp2 : hint_range(0,1) = 0.05;
uniform float period2 : hint_range(0,20) = 4.161;
uniform float distortion_base : hint_range(0,2) = 0.3;

uniform float radius : hint_range(0,2) = 1.0;
uniform float alpha : hint_range(0,2) = 1.0;
uniform float crop : hint_range(0,2) = 1.0;
uniform vec4 crop_color = vec4(0, 0, 0, 1);

vec2 distort(vec2 p, float aspect, float distortion)
{
	float d = length(p);
	float z = sqrt(distortion + d * d * -distortion);
	float r = atan(d, z) / 3.1415926535;
	float phi = atan(p.y, p.x);
	return vec2(r * cos(phi) * (1.0 / aspect) + 0.5, r * sin(phi) + 0.5);
}

void fragment()
{
	float distortion = distortion_base + sin(TIME * period2) * amp2 * -1.0;
	float aspect = aspect_base + sin(TIME * period) * amp;
	
	vec2 xy = (UV * 2.0 - 1.0); // move origin of UV coordinates to center of screen

	xy = vec2(xy.x * aspect, xy.y); // adjust aspect ratio

	float d = length(xy); // distance from center

	vec4 tex;

	if (d < radius)
	{
		xy = distort(xy, aspect, distortion);
		tex = texture(TEXTURE, xy);
		COLOR = tex;
		COLOR.a = alpha;
	}

	// radial crop
	if (d > crop)
	{
		COLOR = crop_color;
	}

}