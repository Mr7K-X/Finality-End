package finality.util.plugins;

#if !flash
import flixel.FlxBasic;

@:access(openfl.display.Sprite)
class ShaderFixPlugin extends FlxBasic
{
  /**
   * Initialize a Shader Bitmap Rebooting Fix Plugin.
   */
  public static function initialize():Void
    FlxG.signals.gameResized.add(s);

  /**
   * Shader bitmap reboot function
   * @param w Game new resized Width
   * @param h Game new resized Height
   */
  static function s(w:Int, h:Int):Void
  {
    if (FlxG.cameras != null)
    {
      for (c in FlxG.cameras.list)
        if (c != null && c.filters != null) r(c.flashSprite);
    }

    if (FlxG.game != null) r(FlxG.game);
  }

  /**
   * Reboot a bitmap caching.
   * @param s Rebooting `Sprite`
   */
  static function r(s:openfl.display.Sprite):Void
  {
    s.__cacheBitmap = null;
    s.__cacheBitmapData = null;
  }
}
#end
