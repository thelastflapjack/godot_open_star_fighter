shader_type spatial;

render_mode unshaded, cull_disabled;

instance uniform float visibility : hint_range(0.0, 1.0, 0.02) = 1.0;

uniform vec3 tint : source_color;
uniform float fesnelAmount : hint_range(0.0, 10.0, 0.1);
uniform sampler2D noise;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() 
{
	float fresnelValue = fresnel(fesnelAmount, NORMAL, VIEW);
	float noiseValue = texture(noise, UV + (TIME * 0.03)).x;
	
	ALBEDO = tint * clamp(noiseValue + fresnelValue, 0.0, 1.0);
	ALPHA = clamp((noiseValue * 0.2)  + fresnelValue, 0.0, 0.3) * visibility;
}
