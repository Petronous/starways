shader_type canvas_item;

uniform vec4 color_tint;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	COLOR = col * color_tint;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
