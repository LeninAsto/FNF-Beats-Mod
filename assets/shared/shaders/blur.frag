#pragma header

uniform float amount;

void main()
{
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 texel = 1.0 / openfl_TextureSize.xy;

	float blurSize = amount;

	vec4 color = flixel_texture2D(bitmap, uv) * 0.2;

	color += flixel_texture2D(bitmap, uv + texel * vec2( 1.0, 0.0) * blurSize) * 0.15;
	color += flixel_texture2D(bitmap, uv + texel * vec2(-1.0, 0.0) * blurSize) * 0.15;
	color += flixel_texture2D(bitmap, uv + texel * vec2( 0.0, 1.0) * blurSize) * 0.15;
	color += flixel_texture2D(bitmap, uv + texel * vec2( 0.0,-1.0) * blurSize) * 0.15;

	color += flixel_texture2D(bitmap, uv + texel * vec2( 1.0, 1.0) * blurSize) * 0.05;
	color += flixel_texture2D(bitmap, uv + texel * vec2(-1.0, 1.0) * blurSize) * 0.05;
	color += flixel_texture2D(bitmap, uv + texel * vec2( 1.0,-1.0) * blurSize) * 0.05;
	color += flixel_texture2D(bitmap, uv + texel * vec2(-1.0,-1.0) * blurSize) * 0.05;
	
	gl_FragColor = color;
}