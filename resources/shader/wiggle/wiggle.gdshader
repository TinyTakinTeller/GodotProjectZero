shader_type canvas_item;

uniform float Strength : hint_range(0,20) = 5;
uniform float RandomOffset = 1.0;
uniform float offset : hint_range(0, 1) = 0;

uniform int enabled: hint_range(0, 1, 1) = 1;

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46 + RandomOffset, -54.3415 ) ) ) );
}

void vertex()
{
	if (enabled == 1) {
		vec2 VERTEX_OFFSET = VERTEX;
		VERTEX_OFFSET.x += (
			random(
				( trunc( VERTEX_OFFSET.y))
			+	TIME
			) - offset
		) * Strength ;

		VERTEX_OFFSET.y += (
			random(
				( trunc( VERTEX_OFFSET.x))
			+	TIME
			) - offset
		) * Strength;
		
		VERTEX = VERTEX_OFFSET;	
	}
}