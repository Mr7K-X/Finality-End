package tempo;

import flixel.FlxGame;

class TempoGame extends FlxGame
{
  public static var totalGameTime:Int = 0;

  /**
   * Creating a full-ass game for this engine
   * @param data Data for this game
   */
  public static function setup(w:Int, h:Int, i:flixel.util.typeLimit.NextState.InitialState, z:Float, f:Int, ss:Bool, sf:Bool):TempoGame
  {
    final stageWidth:Int = openfl.Lib.current.stage.stageWidth;
    final stageHeight:Int = openfl.Lib.current.stage.stageHeight;

    if (z == -1.0)
    {
      final ratios:FlxPoint = FlxPoint.get(stageWidth / w, stageHeight / h);
      z = Math.min(ratios.x, ratios.y);
      w = Math.ceil(stageWidth / z);
      h = Math.ceil(stageHeight / z);
    }

    var game = new TempoGame(w, h, i, f, f, ss, sf);
    game._customSoundTray = finality.display.FinalitySoundTray;
    return game;
  }

  /**
   * Skipping a next tick updating...
   */
  private var _skipNextTickUpdate:Bool = false;

  /**
   * If there is a state change requested during the update loop,
   * this function handles actual destroying the old state and related processes,
   * and calls creates on the new state and plugs it into the game object.
   */
  override function switchState():Void
  {
    super.switchState();

    draw();

    _total = ticks = getTicks();
    _skipNextTickUpdate = true;
  }

  /**
   * Handles the `onEnterFrame` call and figures out how many updates and draw calls to do.
   */
  override function onEnterFrame(_):Void
  {
    if (_skipNextTickUpdate != (_skipNextTickUpdate = false)) _total = ticks = getTicks();

    TempoGame.totalGameTime += Std.int(FlxG.elapsed);

    super.onEnterFrame(_);
  }
}
