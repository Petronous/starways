shader_type canvas_item;
uniform vec2 stars_pos[1024];
uniform vec3 stars_cols[1024];
uniform int stars_num;
uniform float scale;

void vertex() {
	// Called for every vertex the material is visible on.
}

float lerp(float start, float end, float time) {
	return start*(clamp(1.-time, 0., 1.)) + end*clamp(time, 0., 1.);
}

void fragment() {
	vec4 col = vec4(0, 0, 0, .7);
	float aspect = SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;
	float min_dist = scale/6.;
	float second_min_dist = scale/6.;
	float third_min_dist = scale/6.;
	vec4 s_min_col = col;
	vec4 t_min_col = col;
	for (int i = 0; i < stars_num; i++) {
		float dist = distance(vec2(UV.x/aspect, UV.y), stars_pos[i]);
		if (dist < min_dist) {
			t_min_col = s_min_col;
			s_min_col = col;
			col.xyz = stars_cols[i];
			third_min_dist = second_min_dist;
			second_min_dist = min_dist;
			min_dist = dist;
		} else if (dist < second_min_dist) {
			third_min_dist = second_min_dist;
			second_min_dist = dist;
			t_min_col = s_min_col;
			s_min_col.xyz = stars_cols[i];
		} else if (dist < third_min_dist) {
			third_min_dist = dist;
			t_min_col.xyz = stars_cols[i];
		}
	}
	float factor = max(1.5-(second_min_dist - min_dist)*160./scale, 0);
	float t_factor = max(1.5-(third_min_dist - min_dist)*160./scale, 0);
	vec4 border = vec4(1.);
	if (s_min_col.xyz == vec3(0.) ||
			(t_min_col.xyz == vec3(0.) && third_min_dist - min_dist < scale/100.)) {
		border = (1.-t_factor)*border;
	}
	if (col != s_min_col) col = factor*border + (1.-factor)*col;
	else if (col != t_min_col) {
		factor = t_factor;
		col = factor*border + (1.-factor)*col;
	}
	COLOR = col;
}

//void fragment() {
	//COLOR = vec4(UV, 0, 1);
//}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
