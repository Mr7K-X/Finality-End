package finality.shaders;

class SharpEffect
{
  public var shader(default, null):Sharp = new Sharp();
  public var intensity(default, set):Float = 1.;

  public function new()
  {
    shader.intent.value = [1.];
  }

  function set_intensity(v:Float):Float
  {
    intensity = v;
    shader.intent.value = [intensity];

    return v;
  }
}

class Sharp extends flixel.system.FlxAssets.FlxShader
{
  @:glFragmentSource('
  // Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// variables which are empty, they need just to avoid crashing shader
#define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))

// end of ShadertoyToFlixel header

uniform float intent = 1.;

vec3 texsample(const int x, const int y, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy * iChannelResolution[0].xy;
	uv = (uv + vec2(x, y)) / iChannelResolution[0].xy;
	return texture(iChannel0, uv).xyz;
}

vec3 texfilter(in vec2 fragCoord, in float intensity)
{
    vec3 sum = texsample(-1, -1, fragCoord) * -intensity
             + texsample(-1,  0, fragCoord) * -intensity
             + texsample(-1,  1, fragCoord) * -intensity
             + texsample( 0, -1, fragCoord) * -intensity
             + texsample( 0,  0, fragCoord) * (intensity * 8. + 1.) // sum should always be +1
             + texsample( 0,  1, fragCoord) * -intensity
             + texsample( 1, -1, fragCoord) * -intensity
             + texsample( 1,  0, fragCoord) * -intensity
             + texsample( 1,  1, fragCoord) * -intensity;

	return sum;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float u = iResolution.x;
    float m = fragCoord.y / iResolution.x;
    float i = fragCoord.x / iResolution.y * intent;

    float l = smoothstep(0., 1. / iResolution.y, abs(m - u));

    vec2 fc = fragCoord.xy;
    fc.y = fragCoord.y;

    vec3 cf = texfilter(fc, i);
    vec3 cl = texsample(0, 0, fc);
    vec3 cr = (u < m ? cl : cf) * l;

    fragColor = vec4(cr, texture(iChannel0, fragCoord / iResolution.xy).a);
}


void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
  ')
  public function new():Void
  {
    super();
  }
}
