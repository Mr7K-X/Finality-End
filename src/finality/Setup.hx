package finality;

import finality.util.WindowsUtil;
import finality.display.FPS;
import finality.display.RAM;

class Setup
{
  public static var fpsVars:Array<FPS> = [];
  public static var ramVars:Array<RAM> = [];

  static function create():Void
  {
    #if desktop
    for (i in 0...5)
    {
      final constParams =
        {
          x: (i == 0 || i == 2) ? Constants.COUNTER_POS.x + 1 : (i == 1 || i == 3) ? Constants.COUNTER_POS.x - 1 : Constants.COUNTER_POS.x,
          y: (i == 0 || i == 1) ? Constants.COUNTER_POS.y - 1 : (i == 2 || i == 3) ? Constants.COUNTER_POS.y + 1 : Constants.COUNTER_POS.y,
          c: (i == 4) ? Constants.COUNTER_COLOR : Constants.COUNTER_BACK_COLOR
        };

      final newFPS:FPS = new FPS(constParams.x, constParams.y, constParams.c);
      fpsVars.push(newFPS);

      final newRAM:RAM = new RAM(constParams.x, constParams.y + Constants.COUNTER_Y_PL, constParams.c);
      ramVars.push(newRAM);
    }
    #end

    #if FEATURE_DEBUG_TRACY
    WindowsUtil.initDebugTracy();
    #end

    WindowsUtil.initWindowExitDispatch();

    flixel.FlxSprite.defaultAntialiasing = true;

    #if VIDEOS_ALLOWED
    hxvlc.util.Handle.init(['--no-lua']);
    #end

    ClientPrefs.loadBinds();
    #if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psych.scripts.CallbackHandler.call)); #end

    Finality.instance.addChild(tempo.TempoGame.setup(Constants.SETUP_GAME.width, Constants.SETUP_GAME.height, Constants.SETUP_GAME.initialState,
      Constants.SETUP_GAME.zoom, Constants.SETUP_GAME.framerate, Constants.SETUP_GAME.skipSplash, Constants.SETUP_GAME.startFullScreen));

    #if desktop
    for (fpsVar in fpsVars)
      Finality.instance.addChild(fpsVar);
    for (ramVar in ramVars)
      Finality.instance.addChild(ramVar);
    #end
  }
}
