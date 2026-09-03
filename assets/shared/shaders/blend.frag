#pragma header

uniform int blendMode;
uniform float blendAmount;

void main() {
    vec4 colorA = texture2D(bitmap, openfl_TextureCoordv);
    vec4 finalColor = colorA;
    
    if (blendMode == 1) { // add
        finalColor.rgb = colorA.rgb * blendAmount;
    }
    else if (blendMode == 2) { // multiply
        finalColor.rgb = pow(colorA.rgb, vec3(blendAmount));
    }
    else if (blendMode == 3) { // screen
        finalColor.rgb = 1.0 - pow(1.0 - colorA.rgb, vec3(blendAmount));
    }

    finalColor.a = colorA.a;
    gl_FragColor = finalColor;
}