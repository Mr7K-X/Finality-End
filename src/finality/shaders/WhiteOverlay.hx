package finality.shaders;

class WhiteOverlay extends flixel.graphics.tile.FlxGraphicsShader
{
  @:glFragmentSource("
    #pragma header

    uniform float progress;

    void main(void)
    {
      vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
      gl_FragColor = mix(color, vec4(color.a), progress);
    }
  ")
  public function new()
  {
    super();

    progress.value = [0.0];
  }
}
