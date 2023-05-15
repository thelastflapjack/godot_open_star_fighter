shader_type spatial;

render_mode unshaded;

instance uniform vec3 color_base : source_color;

void fragment() 
{
	ALBEDO = color_base;
}
