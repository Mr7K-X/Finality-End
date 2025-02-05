package finality.ui;

import finality.data.CursorPlugin;
import psych.options.VisualsUISubState;
import tempo.util.FileUtil;
import tempo.util.plugins.ScreenshotPlugin;
import tempo.util.log.CrashLog;
import psych.backend.Highscore;
import psych.backend.Controls;
import psych.backend.ClientPrefs;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import sys.thread.Thread;

class InitState extends FlxState
{
  public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
  public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
  public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

  @:unreflective private static var _thread:Thread = null;

  override function create():Void
  {
    #if CRASH_HANDLER
    CrashLog.init();
    #end

    #if debug
    FileUtil.createFolderIfNotExist('mods');
    #end

    super.create();

    Controls.instance = new Controls();
    ClientPrefs.loadDefaultKeys();

    ClientPrefs.loadPrefs();
    trace('saves loaded!');
    Highscore.load();
    trace('score saves loaded!');

    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxG.keys.preventDefaultKeys = [TAB];

    if (FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
    if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

    FlxG.mouse.visible = false;
    trace('FlxG stuff completed!');

    VisualsUISubState.onChangeCounters();

    CursorPlugin.init();

    ScreenshotPlugin.initialize();

    #if DISCORD_ALLOWED
    DiscordClient.prepare();
    #end

    #if FREEPLAY
    MusicBeatState.switchState(new FreeplayState());
    trace('GO TO FREEPLAY!');
    #elseif CHARTING
    MusicBeatState.switchState(new ChartingState());
    trace('GO TO CHART EDITOR!');
    #else
    if (FlxG.save.data.flashing == null && !psych.states.FlashingState.leftState)
    {
      FlxTransitionableState.skipNextTransIn = true;
      FlxTransitionableState.skipNextTransOut = true;
      MusicBeatState.switchState(new psych.states.FlashingState());
      trace('GO TO FLASHING LIGHT WARNING MENU!');
    }
    else
    {
      MusicBeatState.switchState(new TitleState());
    }
    #end
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
