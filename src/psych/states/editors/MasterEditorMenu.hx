package psych.states.editors;

import flixel.addons.transition.FlxTransitionableState;
import psych.backend.WeekData;
import psych.objects.Character;
import finality.ui.MainMenuState;
import finality.ui.FreeplayState;

class MasterEditorMenu extends MusicBeatState
{
  var options:Array<String> = [
    'Chart Editor',
    'Character Editor',
    'Week Editor',
    'Menu Character Editor',
    'Dialogue Editor',
    'Dialogue Portrait Editor',
    'Note Splash Debug'
  ];
  private var grpTexts:FlxTypedGroup<Alphabet>;
  private var directories:Array<String> = [null];

  private var curSelected = 0;
  private var curDirectory = 0;
  private var directoryTxt:FlxText;

  override function create()
  {
    FlxG.camera.bgColor = FlxColor.BLACK;
    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.instance.changePresence({details: "Editors Main Menu"});
    #end

    var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.fromString('0x130B2B'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.scrollFactor.set();
    add(bg);

    grpTexts = new FlxTypedGroup<Alphabet>();
    add(grpTexts);

    for (i in 0...options.length)
    {
      var leText:Alphabet = new Alphabet(90, 320, options[i], true);
      leText.isMenuItem = true;
      leText.targetY = i;
      grpTexts.add(leText);
      leText.snapToPosition();
    }

    changeSelection();

    FlxG.mouse.visible = false;
    super.create();
  }

  override function update(elapsed:Float)
  {
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
      FlxTransitionableState.skipNextTransIn = true;
      FlxTransitionableState.skipNextTransOut = true;

      MusicBeatState.switchState(new finality.ui.FinalityMenu());
    }

    if (controls.ACCEPT)
    {
      switch (options[curSelected])
      {
        case 'Chart Editor': // felt it would be cool maybe
          LoadingState.loadAndSwitchState(new ChartingState(), false);
        case 'Character Editor':
          LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
        case 'Week Editor':
          MusicBeatState.switchState(new WeekEditorState());
        case 'Menu Character Editor':
          MusicBeatState.switchState(new MenuCharacterEditorState());
        case 'Dialogue Editor':
          LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
        case 'Dialogue Portrait Editor':
          LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
        case 'Note Splash Debug':
          MusicBeatState.switchState(new NoteSplashDebugState());
      }
      FlxG.sound.music.volume = 0;
      FreeplayState.destroyFreeplayVocals();
    }

    var bullShit:Int = 0;
    for (item in grpTexts.members)
    {
      item.targetY = bullShit - curSelected;
      bullShit++;

      item.alpha = 0.6;
      // item.setGraphicSize(Std.int(item.width * 0.8));

      if (item.targetY == 0)
      {
        item.alpha = 1;
        // item.setGraphicSize(Std.int(item.width));
      }
    }
    super.update(elapsed);
  }

  function changeSelection(change:Int = 0)
  {
    FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

    curSelected += change;

    if (curSelected < 0) curSelected = options.length - 1;
    if (curSelected >= options.length) curSelected = 0;
  }
}
