package finality.util;

import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.Lib;
import openfl.events.Event;

class WindowsUtil
{
  public static final windowExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

  public static function initWindowExitDispatch():Void
    Lib.current.stage.application.onExit.add((c:Int) -> windowExit.dispatch(c));

  #if FEATURE_DEBUG_TRACY
  public static function initDebugTracy():Void
    Lib.current.stage.addEventListener(Event.EXIT_FRAME, (e:Event) -> cpp.vm.tracy.TracyProfiler.frameMark());
  #end
}
