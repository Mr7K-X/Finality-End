package finality.util;

class SoundUtil
{
  public static function volumeMax(max:Float = 0.8, adding:Float = 0.5, sound:FlxSound):Void
  {
    if (sound != null && sound.playing)
    {
      if (sound.volume < max) sound.volume += adding * FlxG.elapsed;
    }
  }
}
