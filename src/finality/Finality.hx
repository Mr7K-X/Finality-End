package finality;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
#if (linux && !debug)
@:cppInclude('./engine/external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
#if windows
@:buildXml('
<target id="haxe">
  <lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end
@:access(psych.backend.PsychSetup)
class Finality extends openfl.display.Sprite
{
  public static var instance:Finality;

  public static function main():Void
    openfl.Lib.current.addChild(new Finality());

  public function new():Void
  {
    /* In this mod, this not allowed :///
      #if windows
      untyped __cpp__("SetProcessDPIAware();");
      final display:lime.system.Display = lime.system.System.getDisplay(0);
      if (display != null)
      {
        final dpiScale:Float = display.dpi / Constants.DPI_DIVIDE;
        lime.app.Application.current.window.setMaxSize(Std.int(psych.backend.PsychSetup.gameData.w * dpiScale),
          Std.int(psych.backend.PsychSetup.gameData.h * dpiScale));
      }
      #end */

    #if desktop
    @:privateAccess
    tempo.util.SysUtil.__alsoft__init__();
    #end

    instance = this;

    super();

    if (stage != null) _init();
    else
      addEventListener(openfl.events.Event.ADDED_TO_STAGE, _init);
  }

  function _init(?e:openfl.events.Event):Void
  {
    if (hasEventListener(openfl.events.Event.ADDED_TO_STAGE)) removeEventListener(openfl.events.Event.ADDED_TO_STAGE, _init);

    psych.backend.PsychSetup.addGame();
  }
}
