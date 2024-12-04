//
// Example blue light filter shader.
// 

//precision mediump float;
//varying vec2 v_texcoord;
//uniform sampler2D tex;
//
//void main() {
//
//    vec4 pixColor = texture2D(tex, v_texcoord);
//
//    pixColor[2] *= 0.;
//
//    gl_FragColor = pixColor;
//}
// Example grayscale shader.

precision mediump float; // Set the precision for floating-point calculations.
varying vec2 v_texcoord; // Varying texture coordinate passed from the vertex shader.
uniform sampler2D tex;   // The texture sampler.

void main() {
    // Sample the texture at the given coordinates.
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Compute the grayscale value using standard luminance weights.
    float gray = 0.299 * pixColor.r + 0.587 * pixColor.g + 0.114 * pixColor.b;

    // Set the fragment color to the grayscale value, keeping the original alpha.
    gl_FragColor = vec4(vec3(gray), pixColor.a);
}

