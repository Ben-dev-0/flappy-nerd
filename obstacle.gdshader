shader_type canvas_item;

void vertex() {
}

void fragment() {
	COLOR = vec4(sin(UV.x * 11.0 + TIME), sin(UV.y * 15.0 + TIME), sin((UV.y/2.0 + UV.x/3.0) * 15.0 - TIME), 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
