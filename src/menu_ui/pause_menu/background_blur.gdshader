shader_type canvas_item;

// Adapted from: https://godotshaders.com/shader/configurable-box-blur/

uniform int strength: hint_range(1, 512) = 2;
uniform sampler2D screen_texture: hint_screen_texture;
uniform vec4 tint_color: source_color;


void fragment() 
{
	vec4 color = vec4(0.0);
	float strengthFloat = float(strength);

	vec2 pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
	int x_min = max(int(pixel.x - strengthFloat), 0);
	int x_max = min(int(pixel.x + strengthFloat), int(1.0  / SCREEN_PIXEL_SIZE.x));
	int y_min = max(int(pixel.y - strengthFloat), 0);
	int y_max = min(int(pixel.y + strengthFloat), int(1.0 / SCREEN_PIXEL_SIZE.y));
	
	int count = 0;
	
	// Sum the pixels colors
	for(int x = x_min; x <= x_max; x++) {
		for(int y = y_min; y <= y_max; y++) {           
			color += texture(screen_texture, vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE) * tint_color;
			count++;
		}
	}
	
	// Divide the color by the number of colors you summed up
	COLOR = color / float(count);
}
