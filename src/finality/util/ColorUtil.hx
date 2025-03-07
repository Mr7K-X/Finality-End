package finality.util;

import flixel.util.FlxColor;

class ColorUtil
{
  public static function int_desat(col:FlxColor, sat:Float)
  { // except this one
    var hsv = rgb2hsv(int2rgb(col));
    hsv.saturation *= (1 - sat);
    var rgb = hsv2rgb(hsv);
    return FlxColor.fromRGBFloat(rgb.red, rgb.green, rgb.blue);
  }

  public static function int2rgb(col:Dynamic)
    return {red: (col >> 16) & 0xff, green: (col >> 8) & 0xff, blue: col & 0xff}; // and this one

  public static function rgb2hsv(col:Dynamic)
  {
    var hueRad = Math.atan2(Math.sqrt(3) * (col.green - col.blue), 2 * col.red - col.green - col.blue);
    var hue:Float = 0;
    if (hueRad != 0) hue = 180 / Math.PI * hueRad;
    hue = hue < 0 ? hue + 360 : hue;
    var bright:Float = Math.max(col.red, Math.max(col.green, col.blue));
    var sat:Float = (bright - Math.min(col.red, Math.min(col.green, col.blue))) / bright;
    return {hue: hue, saturation: sat, brightness: bright};
  }

  public static function hsv2rgb(col:Dynamic)
  {
    var chroma = col.brightness * col.saturation;
    var match = col.brightness - chroma;

    var hue:Float = col.hue % 360;
    var hueD:Float = hue / 60;
    var mid = chroma * (1 - Math.abs(hueD % 2 - 1)) + match;
    chroma += match;

    chroma /= 255; // joy emoji
    mid /= 255;
    match /= 255;

    switch (Std.int(hueD))
    {
      case 0:
        return {red: chroma, green: mid, blue: match};
      case 1:
        return {red: mid, green: chroma, blue: match};
      case 2:
        return {red: match, green: chroma, blue: mid};
      case 3:
        return {red: match, green: mid, blue: chroma};
      case 4:
        return {red: mid, green: match, blue: chroma};
      case 5:
        return {red: chroma, green: match, blue: mid};
    }

    return {red: 0, green: 0, blue: 0};
  }
}
