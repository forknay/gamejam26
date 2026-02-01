shader_type canvas_item;

// This grabs the rendered 3D scene behind the ColorRect
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float color_levels : hint_range(2.0, 24.0) = 8.0; 
uniform int pixel_size : hint_range(1, 8) = 3;

void fragment() {
    // 1. Pixelate UV coordinates
    vec2 uv = SCREEN_UV;
    uv -= mod(uv, SCREEN_PIXEL_SIZE * float(pixel_size));
    
    // 2. Fetch the color from the screen
    vec3 color = texture(screen_texture, uv).rgb;
    
    // 3. Apply Posterization (Crush the colors)
    color = floor(color * color_levels) / color_levels;
    
    COLOR = vec4(color, 1.0);
}