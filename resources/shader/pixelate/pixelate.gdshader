shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float sprite_scale_begin : hint_range(0.0, 5.0) = 1.0;
uniform float sprite_scale_end : hint_range(0.0, 5.0) = 1.0;
uniform float particle_scale_begin : hint_range(0.0, 5.0) = 1.0;
uniform float particle_scale_end : hint_range(0.0, 5.0) = 1.0;
uniform float dissovle_weight : hint_range(0.0, 10.0) = 1.0;
uniform sampler2D dissolve_texture;
uniform float size = 128;

float easeInSine(float x) {
    return 1.0 - cos((x * PI) / 2.0);
}

float easeInExpo(float x) {
	if (x == 0.0) {
		return 0.0;
	}
   return pow(2.0, 10.0 * x - 10.0);
}

void vertex() {
    // GROW
	float scale = mix(sprite_scale_begin, sprite_scale_end, easeInExpo(progress));
    VERTEX *= scale;
	VERTEX -= (scale - 1.0) * size;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 modulate = COLOR / tex;
	
    // MOSAIC EFFECT
    const float pixel_step = 1.0;
    vec2 texure_size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 steps = texure_size/pixel_step;
    vec2 uv = floor(UV * steps) / (steps - 1.0);
    COLOR = texture(TEXTURE, uv);

    // PARTICLE SIZE
    vec2 fract_uv = fract(UV * steps);
    vec2 direction = UV - 0.5;
    vec2 quantized_direction = sign(direction);
    float angle = PI * 1.25 - atan(quantized_direction.y, quantized_direction.x);
    float angle_sin = sin(angle);
    float angle_cos = cos(angle);
    mat2 rotation_matrix = mat2(vec2(angle_cos, angle_sin), vec2(-angle_sin, angle_cos));
    vec2 rotated_fract_uv = (rotation_matrix * (fract_uv - 0.5)) + 0.5; 
    float inverse_particle_scale = 1.0 / mix(particle_scale_begin, particle_scale_end, progress);
    if (isinf(inverse_particle_scale)){
        COLOR.a = 0.0;
    }
    else
    {
        float step_position = max(rotated_fract_uv.x, rotated_fract_uv.y) * inverse_particle_scale;
        float inverse_sprite_scale = 1.0 / mix(sprite_scale_begin, sprite_scale_end, progress);
        COLOR.a *= step(step_position, inverse_sprite_scale);
    }

    // DISSOLVE EFFECT
    float dissolve = texture(dissolve_texture, uv).x;
    dissolve = step(progress * dissovle_weight, dissolve);
    COLOR.a *= dissolve;

	// https://github.com/godotengine/godot/issues/49781#issuecomment-1458559843
	COLOR.rgb *= modulate.rgb;
}