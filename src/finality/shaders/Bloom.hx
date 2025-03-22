package finality.shaders;

class Bloom implements flixel.util.FlxDestroyUtil.IFlxDestroyable
{
  public var shader(default, null):BloomShader = new BloomShader();
  public var pos(default, set):{x:Float, y:Float} = {x: 0, y: 0};
  public var rgba(default, set):TypeRGBA =
    {
      r: 100,
      g: 100,
      b: 100,
      a: 255
    };

  private function set_pos(value)
  {
    pos = value;

    shader.LightPos.value[0] = pos.x;
    shader.LightPos.value[1] = pos.y;

    return pos;
  }

  private function set_rgba(value:TypeRGBA):TypeRGBA
  {
    rgba = value;

    shader.RGBA.value[0] = rgba.r;
    shader.RGBA.value[1] = rgba.g;
    shader.RGBA.value[2] = rgba.b;
    shader.RGBA.value[3] = rgba.a;

    return rgba;
  }

  public function new() {} // Constructor

  public function destroy()
  {
    pos = {x: 0, y: 0};
    rgba =
      {
        r: 100,
        g: 100,
        b: 100,
        a: 255
      };

    shader = null;
  }
}

class BloomShader extends flixel.system.FlxAssets.FlxShader
{
  @:glFragmentSource('
    #pragma header

		uniform vec2 LightPos;
		uniform vec4 RGBA;

		const int NUM_SAMPLES = 128;
		const float Exposure = 1.;
		const float MyDecay = 0.55;
		const float CircleSize = 0.35;

		const float Weight = 1.1 / float(NUM_SAMPLES);
		const float Decay = 1.0 - MyDecay / float(NUM_SAMPLES);

		vec3 occlusion(vec2 q){
			float i = clamp(length((q-LightPos)*vec2(openfl_TextureSize.x/openfl_TextureSize.y, 1.0))/CircleSize, 0.0, 1.0);
			i = 1.0 - i*i;
			vec4 deColor = texture2D( bitmap, q );
			deColor.rgb = deColor.rgb - 0.1;

			float k = max(max(deColor.r, deColor.b), deColor.g * 0.3);
			k = clamp( k * k , 0.0, 1.0 );

			return vec3(mix(k, i, k));
		}

		vec4 godray(vec2 texCoord)
		{
			vec3 originalColor = occlusion(texCoord).xyz;

			vec3 color = vec3(0);
			float illuminationDecay = 1.0;
			float floatNUM_SAMPLES = float(NUM_SAMPLES);
			vec3 sampl;
			vec2 uv ;

			for (int i = 0; i < NUM_SAMPLES; i++)
			{
				uv = mix(texCoord, LightPos, float(i) / floatNUM_SAMPLES);

				sampl = occlusion(uv);
				sampl *= illuminationDecay * Weight;
				color += sampl;
				illuminationDecay *= Decay;
			}
			return vec4(color * color * Exposure * Exposure, 1);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv.xy;
			vec3 iColor = vec3(RGBA[0], RGBA[1], RGBA[2]) / vec3(RGBA[3]);
			vec4 rays = godray(uv);
			vec4 coloredRays = vec4(rays.xyz * iColor, rays.w);

			gl_FragColor = coloredRays + vec4(texture2D(bitmap, uv).xyz * (iColor*0.8+0.3 + rays.xyz*rays.xyz/2.), 1.);
		}
  ')
  public function new():Void
  {
    super();

    LightPos.value = [0, 0];
    RGBA.value = [100, 100, 100, 255];
  }
}

private typedef TypeRGBA =
{
  r:Float,
  g:Float,
  b:Float,
  a:Float
}
