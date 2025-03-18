package finality.util;

import flixel.util.FlxSignal.FlxTypedSignal;
import openfl.Lib;
import openfl.events.Event;

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
')
#end
class WindowsUtil
{
  public static final windowExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

  public static function initWindowExitDispatch():Void
    Lib.current.stage.application.onExit.add((c:Int) -> windowExit.dispatch(c));

  #if windows
  @:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
  @:noCompletion
  public static function _setWindowColorMode(mode:Int) {}

  public static function setWindowColorMode(mode:WindowColorMode)
  {
    var darkMode:Int = cast(mode, Int);

    if (darkMode > 1 || darkMode < 0)
    {
      trace("WindowColorMode Not Found...");

      return;
    }

    _setWindowColorMode(darkMode);
  }

  public static function goAheadIco():Void
  {
    FileUtil.createFolderIfNotExist('Resource');

    if (!FileSystem.exists('./Resource/icon.ico')
      && FileSystem.exists('./icon.ico')) FileSystem.rename('./icon.ico', './Resource/icon.ico');
    else if (FileSystem.exists('./Resource/icon.ico') && FileSystem.exists('./icon.ico')) FileSystem.deleteFile('icon.ico');
  }
  #end

  #if FEATURE_DEBUG_TRACY
  public static function initDebugTracy():Void
    Lib.current.stage.addEventListener(Event.EXIT_FRAME, (e:Event) -> cpp.vm.tracy.TracyProfiler.frameMark());
  #end
}

enum abstract WindowColorMode(Int) from Int to Int
{
  var DARK = 1;
  var LIGHT = 0;
}
