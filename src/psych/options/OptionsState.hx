package psych.options;

import flixel.addons.transition.FlxTransitionableState;
import finality.ui.MainMenuState;
import flixel.util.FlxDestroyUtil;
import openfl.display.BlendMode;
import psych.backend.StageData;
import psych.substates.StickerSubState;

class OptionsState extends MusicBeatState
{
  var options:Array<String> = ['Controls', 'Graphics', 'Visuals and UI', 'Gameplay'];
  private var grpOptions:FlxTypedGroup<Alphabet>;

  private static var curSelected:Int = 0;
  public static var menuBG:FlxSprite;
  public static var onPlayState:Bool = false;
  private static var vcrEffect:VcrGlitchEffect;

  function openSelectedSubstate(label:String)
  {
    persistentUpdate = false;
    switch (label)
    {
      case 'Controls':
        openSubState(new psych.options.ControlsSubState());
      case 'Graphics':
        openSubState(new psych.options.GraphicsSettingsSubState());
      case 'Visuals and UI':
        openSubState(new psych.options.VisualsUISubState());
      case 'Gameplay':
        openSubState(new psych.options.GameplaySettingsSubState());
    }
  }

  var selectorLeft:Alphabet;
  var selectorRight:Alphabet;

  var stickerSubState:StickerSubState;

  public function new(?stickers:StickerSubState = null)
  {
    super();

    if (stickers != null)
    {
      stickerSubState = stickers;
    }
  }

  var camGame:FlxCamera;
  var camStick:FlxCamera;

  override function create()
  {
    camGame = initPsychCamera();

    camStick = new FlxCamera();
    camStick.bgColor.alpha = 0;
    FlxG.cameras.add(camStick, false);

    if (stickerSubState != null)
    {
      stickerSubState.cameras = [camStick];
      @:privateAccess
      stickerSubState.grpStickers.cameras = [camStick];
    }
    else
      Paths.clearStoredMemory();

    #if DISCORD_ALLOWED DiscordClient.instance.changePresence({details: "Options Menu"}); #end

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgnew'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    grpOptions = new FlxTypedGroup<Alphabet>();
    add(grpOptions);

    for (i in 0...options.length)
    {
      var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
      optionText.screenCenter();
      optionText.y += (100 * (i - (options.length / 2))) + 50;
      grpOptions.add(optionText);
    }

    selectorLeft = new Alphabet(0, 0, '>', true);
    add(selectorLeft);
    selectorRight = new Alphabet(0, 0, '<', true);
    add(selectorRight);

    if (ClientPrefs.data.shaders)
    {
      vcrEffect = new VcrGlitchEffect();
      camGame.setFilters([new ShaderFilter(vcrEffect.shader)]);
    }

    changeSelection();
    ClientPrefs.saveSettings();

    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
    }

    super.create();
  }

  override function closeSubState()
  {
    super.closeSubState();
    persistentUpdate = true;
    ClientPrefs.saveSettings();
    #if DISCORD_ALLOWED
    DiscordClient.instance.changePresence({details: "Options Menu"});
    #end
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (ClientPrefs.data.shaders) vcrEffect.update(elapsed);

    if (controls.UI_UP_P)
    {
      changeSelection(-1);
    }
    if (controls.UI_DOWN_P)
    {
      changeSelection(1);
    }

    if (controls.BACK)
    {
      FlxG.sound.play(Paths.sound('cancelMenu'));

      if (onPlayState)
      {
        StageData.loadDirectory(PlayState.SONG);
        LoadingState.loadAndSwitchState(new PlayState());
        FlxG.sound.music.volume = 0;
      }
      else
      {
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        MusicBeatState.switchState(new finality.ui.FinalityMenu());
      }

      FlxG.camera.fade();

      FlxTween.tween(FlxG.camera, {zoom: 0.15}, 3, {ease: FlxEase.quadInOut});
    }
    else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
  }

  function changeSelection(change:Int = 0)
  {
    curSelected += change;
    if (curSelected < 0) curSelected = options.length - 1;
    if (curSelected >= options.length) curSelected = 0;

    var bullShit:Int = 0;

    for (item in grpOptions.members)
    {
      item.targetY = bullShit - curSelected;
      bullShit++;

      item.alpha = 0.6;
      if (item.targetY == 0)
      {
        item.alpha = 1;
        selectorLeft.x = item.x - 63;
        selectorLeft.y = item.y;
        selectorRight.x = item.x + item.width + 15;
        selectorRight.y = item.y;
      }
    }
    FlxG.sound.play(Paths.sound('scrollMenu'));
  }

  override function destroy()
  {
    ClientPrefs.loadPrefs();

    if (ClientPrefs.data.shaders) initPsychCamera().setFilters([]); // idk, if game will crash/lagging

    super.destroy();
  }
}
