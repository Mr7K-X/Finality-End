package finality.ui;

import psych.options.VisualsUISubState;
import finality.util.FileUtil;
import finality.util.plugins.*;
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
    CrashPlugin.init();
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
    ShaderFixPlugin.initialize();

    #if DISCORD_ALLOWED
    DiscordClient.prepare();
    #end

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    new FlxTimer().start(1, (_) ->
      {
        #if FEATURE_ONLY_ME
        FlxG.switchState(() -> new psych.states.debug.ChartEditorState());
        #else
        FlxG.switchState(() -> new FinalityMenu());
        #end
      });
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
