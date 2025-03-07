package finality.display;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
import psych.backend.ClientPrefs;

/**
  The FPS class provides an easy-to-use monitor to display
  the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends openfl.text.TextField
{
  /**
    The current frame rate, expressed using frames-per-second
  **/
  public var currentFPS(default, null):Int;

  @:noCompletion private var cacheCount:Int;
  @:noCompletion private var currentTime:Float;
  @:noCompletion private var times:Array<Float>;

  public function new(x:Float = 10, y:Float = 10, color:UInt = 0x000000)
  {
    super();

    this.x = x;
    this.y = y;

    currentFPS = 0;
    selectable = false;
    mouseEnabled = false;
    defaultTextFormat = new openfl.text.TextFormat("_sans", 12, color);
    text = "FPS: ";
    width = 400;

    cacheCount = 0;
    currentTime = 0;
    times = [];

    #if flash
    addEventListener(openfl.events.Event.ENTER_FRAME, function(e) {
      var time = Lib.getTimer();
      __enterFrame(time - currentTime);
    });
    #end
  }

  // Event Handlers
  @:noCompletion
  private #if !flash override #end function __enterFrame(deltaTime:Float):Void
  {
    currentTime += deltaTime;
    times.push(currentTime);

    while (times[0] < currentTime - 1000)
    {
      times.shift();
    }

    var currentCount = times.length;
    currentFPS = Math.round((currentCount + cacheCount) / 2);

    if (currentCount != cacheCount /*&& visible*/)
    {
      text = "FPS: " + currentFPS;
    }

    cacheCount = currentCount;
  }
}
