shader_type canvas_item;

uniform vec2 particle_size = vec2(8.0, 8.0); // Size of each block
uniform vec2 texture_size = vec2(256.0, 256.0); // Size of the wall texture

void fragment() {
    vec2 grid_uv = fract(UV * texture_size / particle_size);
    if (grid_uv.x < 0.1 || grid_uv.y < 0.1) { // Add thin borders for blocks
        discard; // Discard the pixel outside the "block" boundary
    }
    COLOR = texture(TEXTURE, UV);
}
