package psych.backend;

import openfl.Lib;
import flixel.FlxGame;
import tempo.display.FPS;
import tempo.display.RAM;

class PsychSetup
{
  static var gameData =
    {
      w: 1280, // width
      h: 720, // height
      i: finality.ui.InitState, // initializing state
      z: -1.0, // zoom
      f: 60, // framerate
      sS: true, // skip splash
      sF: false // start fullscreen
    };

  public static var fpsVars:Array<FPS> = [];
  public static var ramVars:Array<RAM> = [];

  @:access(flixel.FlxGame)
  static function addGame():Void
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

    var sw:Int = Lib.current.stage.stageWidth;
    var sh:Int = Lib.current.stage.stageHeight;

    if (gameData.z == -1.0)
    {
      final ratio:FlxPoint = new FlxPoint(sw / gameData.w, sh / gameData.h);
      gameData.z = Math.min(ratio.x, ratio.y);
      gameData.w = Math.ceil(sw / gameData.z);
      gameData.h = Math.ceil(sh / gameData.z);
    }

    ClientPrefs.loadBinds();
    #if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psych.scripts.CallbackHandler.call)); #end

    var game:FlxGame = new FlxGame(gameData.w, gameData.h, gameData.i, gameData.f, gameData.f, gameData.sS, gameData.sF);
    game._customSoundTray = finality.objects.FinalitySoundTray;
    finality.Finality.instance.addChild(game);

    #if desktop
    for (fpsVar in fpsVars)
      finality.Finality.instance.addChild(fpsVar);
    for (ramVar in ramVars)
      finality.Finality.instance.addChild(ramVar);
    #end

    #if !flash
    FlxG.signals.gameResized.add((w:Int, h:Int) -> {
      if (FlxG.cameras != null) for (camera in FlxG.cameras.list)
        if (camera != null && camera.filters != null) _sprite_resetCache(camera.flashSprite);

      if (game != null) _sprite_resetCache(game);
    });
    #end
  }

  #if !flash
  @:access(openfl.display.Sprite)
  static function _sprite_resetCache(spr:openfl.display.Sprite):Void
  {
    spr.__cacheBitmap = null;
    spr.__cacheBitmapData = null;
  }
  #end
}
