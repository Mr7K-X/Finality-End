package finality.display;

import psych.backend.ClientPrefs;
import finality.util.MemoryUtil;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class RAM extends openfl.text.TextField
{
  /**
   * The current memory of game
   */
  public var currentRAM(default, null):Float;

  /**
   * The peak of memory
   */
  public var peakRAM(default, null):Float;

  @:noCompletion private var cacheCount:Int;
  @:noCompletion private var currentTime:Float;
  @:noCompletion private var times:Array<Float>;

  public function new(x:Float = 10, y:Float = 10, color:UInt = 0x000000)
  {
    super();

    this.x = x;
    this.y = y;

    currentRAM = 0;
    selectable = false;
    mouseEnabled = false;

    defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
    text = "RAM: ";
    width = 400;

    cacheCount = 0;
    currentTime = 0;
    times = [];

    #if flash
    addEventListener(Event.ENTER_FRAME, (e) -> {
      var time = Lib.getTimer();
      __enterFrame(time - currentTime);
    });
    #end
  }

  @:noCompletion
  private #if !flash override #end function __enterFrame(deltaTime:Float):Void
  {
    currentTime += deltaTime;
    times.push(currentTime);

    while (times[0] < currentTime - 1000)
      times.shift();

    var currentCount:Int = times.length;
    currentRAM = MemoryUtil.getMemoryUsed();

    if (currentRAM > peakRAM) peakRAM = currentRAM;

    if (currentCount != cacheCount)
    {
      text = "RAM: " + flixel.util.FlxStringUtil.formatBytes(currentRAM) + " / " + flixel.util.FlxStringUtil.formatBytes(peakRAM);

      cacheCount = currentCount;
    }
  }
}
