package tempo.util;

class TempoColor
{
	public static inline final TRANSPARENT:FlxColor = FlxColor.TRANSPARENT;
	public static inline final WHITE:FlxColor = FlxColor.WHITE;
	public static inline final GRAY:FlxColor = FlxColor.GRAY;
	public static inline final BLACK:FlxColor = FlxColor.BLACK;

	public static inline final GREEN:FlxColor = FlxColor.GREEN;
	public static inline final LIME:FlxColor = FlxColor.LIME;
	public static inline final YELLOW:FlxColor = FlxColor.YELLOW;
	public static inline final ORANGE:FlxColor = FlxColor.ORANGE;
	public static inline final RED:FlxColor = FlxColor.RED;
	public static inline final PURPLE:FlxColor = FlxColor.PURPLE;
	public static inline final BLUE:FlxColor = FlxColor.BLUE;
	public static inline final BROWN:FlxColor = FlxColor.BROWN;
	public static inline final PINK:FlxColor = FlxColor.PINK;
	public static inline final MAGENTA:FlxColor = FlxColor.MAGENTA;
	public static inline final CYAN:FlxColor = FlxColor.CYAN;

	public static inline function fromInt(value:Int):FlxColor
		return FlxColor.fromInt(value);

	public static inline function fromRGB(red:Int, green:Int, blue:Int, ?alpha:Int = 255):FlxColor
		return FlxColor.fromRGB(red, green, blue, alpha);

	public static inline function fromRGB_Float(red:Float, green:Float, blue:Float, ?alpha:Float = 1.00):FlxColor
		return FlxColor.fromRGBFloat(red, green, blue, alpha);

	public static inline function fromCMYK(cyan:Float, magenta:Float, yellow:Float, black:Float, ?alpha:Float = 1.00):FlxColor
		return FlxColor.fromCMYK(cyan, magenta, yellow, black, alpha);

	public static inline function fromHSB(hue:Float, saturation:Float, brightness:Float, ?alpha:Float = 1.00):FlxColor
		return FlxColor.fromHSB(hue, saturation, brightness, alpha);

	public static inline function fromHSL(hue:Float, saturation:Float, lightness:Float, ?alpha:Float = 1.00):FlxColor
		return FlxColor.fromHSL(hue, saturation, lightness, alpha);

	public static inline function fromString(value:String):Null<FlxColor>
		return FlxColor.fromString(value);
}
