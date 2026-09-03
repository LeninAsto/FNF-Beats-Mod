package objects.results;

class LeftMaskShader extends FlxShader
{
	public var swagMaskX(default, set):Float = 0;
	public var swagSprX(default, set):Float = 0;

	function set_swagSprX(x:Float):Float
	{
		if (this.data != null && this.data.sprX != null)
			this.data.sprX.value = [x];
		return swagSprX = x;
	}

	function set_swagMaskX(x:Float):Float
	{
		if (this.data != null && this.data.maskX != null)
			this.data.maskX.value = [x];
		return swagMaskX = x;
	}

	public function new()
	{
		super();
		swagSprX = 0;
		swagMaskX = 0;
	}

	@:glFragmentHeader('
		#pragma header

		uniform float sprX;
		uniform float maskX;
	')
	@:glFragmentSource('
		#pragma header

		void main()
		{
			float cutOff = maskX - sprX;
			float sprPos = cutOff / openfl_TextureSize.x;
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
			if (openfl_TextureCoordv.x < sprPos)
				color = vec4(0.0, 0.0, 0.0, 0.0);
			gl_FragColor = color;
		}
	')
}
