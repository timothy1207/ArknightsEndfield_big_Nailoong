shader_type canvas_item;

uniform vec2 light_position = vec2(-0.35, -0.45);

uniform float light_strength : hint_range(0.0, 2.0) = 0.4;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.03;
uniform float specular_strength : hint_range(0.0, 1.0) = 0.03;


void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec4 final_color = tex;

	// 只处理非透明像素
	if (tex.a > 0.01) {
		vec2 p = UV * 2.0 - 1.0;

		float distance_from_center = length(p);

		// 只对圆形区域进行球面光照
		if (distance_from_center <= 1.0) {
			float z = sqrt(
				max(
					0.0,
					1.0 - dot(p, p)
				)
			);

			vec3 normal = normalize(
				vec3(
					p.x,
					p.y,
					z
				)
			);

			vec3 light_dir = normalize(
				vec3(
					light_position.x,
					light_position.y,
					1.0
				)
			);

			// 漫反射
			float diffuse = max(
				dot(normal, light_dir),
				0.0
			);

			float lighting =
				0.65 +
				diffuse * light_strength;

			// 边缘阴影
			float edge_shadow = smoothstep(
				0.55,
				1.0,
				distance_from_center
			);

			lighting *= (
				1.0 -
				edge_shadow * shadow_strength
			);

			// 高光
			vec3 view_dir = vec3(
				0.0,
				0.0,
				1.0
			);

			vec3 half_dir = normalize(
				light_dir + view_dir
			);

			float specular = pow(
				max(
					dot(normal, half_dir),
					0.0
				),
				32.0
			);

			lighting += (
				specular *
				specular_strength
			);

			final_color = vec4(
				tex.rgb * lighting,
				tex.a
			);
		}
	}

	COLOR = final_color;
}