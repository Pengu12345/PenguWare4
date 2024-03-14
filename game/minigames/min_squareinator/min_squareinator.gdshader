shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform int shung : hint_range(1,128) = 16; 
uniform vec2 aspect = vec2(16,9); 
 

void fragment()
{
    // quantize the UV value to a stepped value
    // based on number of divisions.
    // the 0.5 added ensures we sample from 
    // the centre of the "pixel"
    vec2 st = (vec2(ivec2( SCREEN_UV * float(shung)*aspect ))+0.5)/float(shung)/aspect;
    // read the texture using the highest LOD to avoid 
    // filtering problems on discontinuities
    vec4 tex_col = textureLod( screen_texture, st, 0 );
    // set the output
    COLOR = tex_col;  
}
