// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment()
{
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 color;
	
    // `fragCoord` is `FRAGCOORD` in Godot.
	vec2 uv = FRAGCOORD.xy / i_resolution.xy;
	
	float distanceFromCenter = length(uv - vec2(0.5,0.5));
	
	float vignetteAmount;
	float lum;
	
	vignetteAmount = 0.6;
	vignetteAmount = smoothstep(0.1, 1.0, vignetteAmount);
	
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
	color = texture(SCREEN_TEXTURE, uv);
	
	// luminance hack, responses to red channel most
	lum = dot(color.rgb, vec3(0.85, 0.30, 0.10));
	
	color.rgb = vec3(0.0, lum, 0.0);
	
	// scanlines
	color += 0.1 * sin(uv.y * i_resolution.y * 2.0);
	
	// screen flicker
    // Instead of `iTime` we use the global `TIME`.
	color += 0.005 * sin(TIME * 16.0);
	
	// vignetting
	color *=  vignetteAmount * 1.0;
	
    // `fragColor` is `COLOR` in Godot.
	COLOR = color;
}