shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE:hint_screen_texture, filter_linear_mipmap;

uniform int levels = 3;
uniform float slice_factor = 0.0;
uniform float amp = 0.005;

vec3 chromatic_slice(float t){
	vec3 res = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
	return max(res, 0.0);
}

void fragment(){
	float spread = sin(TIME * 4.161) * amp;

	vec3 sum = vec3(0.0);
	COLOR.rgb = vec3(0.0,0.0,0.0);
	vec2 offset = (UV - vec2(0.5))*vec2(1,-1);
	for(int i = 0; i < levels; i++){
		float t = 2.0*float(i)/max(float(levels-1),0.001);
		vec3 slice = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
		slice = max(slice, slice_factor);
		sum += slice;
		vec2 slice_offset = (t-1.0)*spread*offset;
		COLOR.rgb += slice * texture(SCREEN_TEXTURE, SCREEN_UV + slice_offset).rgb;
	}
	COLOR.rgb /= sum;
}