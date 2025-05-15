package finality.shaders;

import flixel.system.FlxAssets.FlxShader;

// coded by mrzkX
class VcrGlitchEffect
{
  public var shader(default, null):VcrGlitchShader = new VcrGlitchShader();

  public function new() {}

  var theTime:Float = 0;

  public function update(elapsed:Float)
  {
    theTime += elapsed;
  }
}

class VcrGlitchShader extends FlxShader
{
  @:glFragmentSource('
#pragma header

uniform float iTime;

#define texture flixel_texture2D
#define fragColor gl_FragColor

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = uv * openfl_TextureSize;

    float warp = 1.5;
    float scan = 1.0;

    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    uv.x -= 0.5;
    uv.x *= 1.0 + (dc.y * (0.3 * warp));
    uv.x += 0.5;

    uv.y -= 0.5;
    uv.y *= 1.0 + (dc.x * (0.4 * warp));
    uv.y += 0.5;

    if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        float scanline = 0.5 + 0.5 * sin(fragCoord.y * 3.1415);
        float apply = scan * scanline * 0.5;
        vec4 texColor = texture(bitmap, uv);
        fragColor = vec4(mix(texColor.rgb, vec3(0.0), apply), texColor.a);
    }
}

    ')
  public function new()
  {
    super();
  }
}
