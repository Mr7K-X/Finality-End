package psych.options;

import psych.objects.Note;
import psych.objects.StrumNote;
import psych.objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
  var noteOptionID:Int = -1;
  var notes:FlxTypedGroup<StrumNote>;
  var notesTween:Array<FlxTween> = [];
  var noteY:Float = 90;

  public function new()
  {
    title = 'Visuals and UI';
    rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence

    var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
    if (noteSplashes.length > 0)
    {
      if (!noteSplashes.contains(ClientPrefs.data.splashSkin))
        ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; // Reset to default if saved splashskin couldnt be found

      noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); // Default skin always comes first
      var option:Option = new Option('Note Splashes:', "Select your prefered Note Splash variation or turn it off.", 'splashSkin', 'string', noteSplashes);
      addOption(option);
    }

    var option:Option = new Option('Note Splash Opacity', 'How much transparent should the Note Splashes be.', 'splashAlpha', 'percent');
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    addOption(option);

    var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool');
    addOption(option);

    var option:Option = new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', 'string',
      ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
    addOption(option);

    var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool');
    addOption(option);

    var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool');
    addOption(option);

    var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom', 'bool');
    addOption(option);

    var option:Option = new Option('Health Bar Opacity', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', 'percent');
    option.scrollSpeed = 1.6;
    option.minValue = 0.0;
    option.maxValue = 1;
    option.changeValue = 0.1;
    option.decimals = 1;
    addOption(option);

    #if !mobile
    var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', 'bool');
    option.onChange = onChangeCounters;
    addOption(option);

    var option:Option = new Option('RAM Counter', "Uncheck this, for hide RAM counter", 'showRAM', 'bool');
    option.onChange = onChangeCounters;
    addOption(option);
    #end

    var option:Option = new Option('Pause Screen Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', 'string',
      ['None', 'Breakfast', 'Tea Time']);
    addOption(option);
    option.onChange = onChangePauseMusic;

    #if DISCORD_ALLOWED
    var option:Option = new Option('Discord Rich Presence',
      "Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord", 'discordRPC', 'bool');
    option.onChange = onChangeDiscordRPC;
    addOption(option);
    #end

    var option:Option = new Option('Combo Stacking', "If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
      'comboStacking', 'bool');
    addOption(option);

    super();
    var par2:FlxSprite = new FlxSprite();
    par2.frames = Paths.getSparrowAtlas('par2');
    par2.animation.addByPrefix('par2', 'par2', 1, false);
    par2.animation.play('par2');
    par2.antialiasing = ClientPrefs.data.antialiasing;
    par2.updateHitbox();
    par2.scrollFactor.set();
    add(par2);
    add(notes);
  }

  override function changeSelection(change:Int = 0)
  {
    super.changeSelection(change);

    if (noteOptionID < 0) return;

    for (i in 0...Note.colArray.length)
    {
      var note:StrumNote = notes.members[i];
      if (notesTween[i] != null) notesTween[i].cancel();
      if (curSelected == noteOptionID) notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
      else
        notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
    }
  }

  public static function onChangeCounters()
  {
    for (fps in Setup.fpsVars)
      fps.visible = ClientPrefs.data.showFPS;
    for (ram in Setup.ramVars)
      ram.visible = ClientPrefs.data.showRAM;
  }

  var changedMusic:Bool = false;

  function onChangePauseMusic()
  {
    if (ClientPrefs.data.pauseMusic == 'None') FlxG.sound.music.volume = 0;
    else
      FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

    changedMusic = true;
  }

  #if DISCORD_ALLOWED
  function onChangeDiscordRPC():Void
  {
    DiscordClient.check();
  }
  #end

  function onChangeNoteSkin()
  {
    notes.forEachAlive(function(note:StrumNote) {
      changeNoteSkin(note);
      note.centerOffsets();
      note.centerOrigin();
    });
  }

  function changeNoteSkin(note:StrumNote)
  {
    var skin:String = Note.defaultNoteSkin;
    var customSkin:String = skin + Note.getNoteSkinPostfix();
    if (Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

    note.texture = skin; // Load texture and anims
    note.reloadNote();
    note.playAnim('static');
  }

  override function destroy()
  {
    if (changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
    super.destroy();
  }
}
