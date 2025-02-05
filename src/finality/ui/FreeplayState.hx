package finality.ui;

import flixel.effects.FlxFlicker;
import openfl.filters.ShaderFilter;
import haxe.Json;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.tweens.misc.NumTween;
import psych.backend.WeekData;
import psych.backend.Highscore;
import psych.backend.Song;
import psych.objects.HealthIcon;
import psych.objects.MusicPlayer;
import psych.substates.GameplayChangersSubstate;
import psych.substates.ResetScoreSubState;
import psych.substates.StickerSubState;

typedef CharData =
{
  var charImage:String;
  var fadeTime:Float;
  var index:Int;
}

typedef CharFile =
{
  var data:Array<CharData>;
}

class FreeplayState extends MusicBeatState
{
  var songs:Array<SongMetadata> = [];

  var selector:FlxText;

  private static var curSelected:Int = 0;

  var lerpSelected:Float = 0;
  var curDifficulty:Int = -1;

  private static var lastDifficultyName:String = Difficulty.getDefault();

  var scoreBG:FlxSprite;
  var scoreText:FlxText;
  var diffText:FlxText;
  var lerpScore:Int = 0;
  var lerpRating:Float = 0;
  var intendedScore:Int = 0;
  var intendedRating:Float = 0;

  private var grpSongs:FlxTypedGroup<Alphabet>;
  private var curPlaying:Bool = false;
  private var vcrEffect:VcrGlitchEffect;
  private var iconArray:Array<HealthIcon> = [];

  var bg:FlxSprite;
  var intendedColor:Int;
  var colorTween:FlxTween;

  var camGame:FlxCamera;
  var camStat:FlxCamera;

  var missingTextBG:FlxSprite;
  var missingText:FlxText;

  var bottomString:String;
  var bottomText:FlxText;
  var bottomBG:FlxSprite;

  var player:MusicPlayer;

  var char:FlxSprite;
  var charJson:CharFile;
  var blackfuck:FlxSprite;

  var stickerSubState:StickerSubState;

  public function new(?stickers:StickerSubState = null)
  {
    super();

    if (stickers != null)
    {
      stickerSubState = stickers;
    }
  }

  override function create()
  {
    if (stickerSubState != null) {}
    else
      Paths.clearStoredMemory();

    FlxG.sound.playMusic(Paths.music('themfreepl'), 0.0);

    charJson = tjson.TJSON.parse(Paths.getTextFromFile('data/freeplay.json', false));

    camGame = initPsychCamera();

    camStat = new FlxCamera();
    camStat.bgColor.alpha = 0;
    FlxG.cameras.add(camStat, false);

    persistentUpdate = true;

    PlayState.isStoryMode = false;
    WeekData.reloadWeekFiles(false);

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.instance.changePresence({details: "Freeplay"});
    #end

    for (i in 0...WeekData.weeksList.length)
    {
      if (weekIsLocked(WeekData.weeksList[i])) continue;

      var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
      var leSongs:Array<String> = [];
      var leChars:Array<String> = [];

      for (j in 0...leWeek.songs.length)
      {
        leSongs.push(leWeek.songs[j][0]);
        leChars.push(leWeek.songs[j][1]);
      }

      WeekData.setDirectoryFromWeek(leWeek);
      for (song in leWeek.songs)
      {
        var colors:Array<Int> = song[2];
        if (colors == null || colors.length < 3)
        {
          colors = [146, 113, 253];
        }
        addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
      }
    }
    Mods.loadTopMod();

    var bg1:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('BGFR'));
    bg1.updateHitbox();
    bg1.screenCenter();
    add(bg1);

    char = new FlxSprite(0, 0).makeGraphic(1, 1, 0x0);
    add(char);

    var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('nothing'));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    var bt1 = new FlxSprite().loadGraphic(Paths.image('sasasa'));
    bt1.antialiasing = ClientPrefs.data.antialiasing;
    bt1.screenCenter();
    bt1.scrollFactor.set(0.15, 0.15);
    bt1.updateHitbox();
    add(bt1);

    var bt1 = new FlxSprite().loadGraphic(Paths.image('whaaaa'));
    bt1.antialiasing = ClientPrefs.data.antialiasing;
    bt1.screenCenter();
    bt1.scrollFactor.set(0.15, 0.15);
    bt1.updateHitbox();
    add(bt1);

    var bt1 = new FlxSprite().loadGraphic(Paths.image('pvccc'));
    bt1.antialiasing = ClientPrefs.data.antialiasing;
    bt1.screenCenter();
    bt1.scrollFactor.set(0.15, 0.15);
    bt1.updateHitbox();
    add(bt1);

    var bt1 = new FlxSprite().loadGraphic(Paths.image('aurada2'));
    bt1.antialiasing = ClientPrefs.data.antialiasing;
    bt1.screenCenter();
    bt1.scrollFactor.set(0.15, 0.15);
    bt1.updateHitbox();
    add(bt1);

    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);

    blackfuck = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    add(blackfuck);

    for (i in 0...songs.length)
    {
      var songText:Alphabet = new Alphabet(11500, 40, songs[i].songName, true);
      songText.targetY = i;
      songText.zIndex = i;
      songText.alpha = 0;
      grpSongs.add(songText);

      songText.scaleX = Math.min(1, 980 / songText.width);
      songText.snapToPosition();
      Mods.currentModDirectory = songs[i].folder;
      var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
      icon.sprTracker = songText;

      // too laggy with a lot of songs, so i had to recode the logic for it
      songText.visible = songText.active = songText.isMenuItem = false;
      icon.visible = icon.active = true;

      // using a FlxGroup is too much fuss!
      iconArray.push(icon);
      add(icon);

      // songText.x += 40;
      // DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
      // songText.screenCenter(X);
    }
    WeekData.setDirectoryFromWeek();

    scoreText = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
    scoreText.setFormat(Paths.font("HelpMe.ttf"), 32, FlxColor.WHITE, RIGHT);

    scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x8D000000);
    scoreBG.alpha = 0.6;
    add(scoreBG);

    diffText = new FlxText(scoreText.x, scoreText.y + 34, 0, "", 24);
    diffText.font = scoreText.font;
    add(diffText);

    add(scoreText);
    scoreText.screenCenter(X);

    missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    missingTextBG.alpha = 0.6;
    missingTextBG.visible = false;
    add(missingTextBG);

    missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
    missingText.setFormat(Paths.font("HelpMe.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    missingText.scrollFactor.set();
    missingText.visible = false;
    add(missingText);

    if (curSelected >= songs.length) curSelected = 0;
    bg.color = songs[curSelected].color;
    intendedColor = bg.color;
    lerpSelected = curSelected;

    curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

    bottomBG = new FlxSprite(0, FlxG.height - 0).makeGraphic(FlxG.width, 0, 0xFF000000);
    bottomBG.alpha = 0.6;
    add(bottomBG);

    var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
    bottomString = leText;
    var size:Int = 16;
    bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
    bottomText.setFormat(Paths.font("HelpMe.ttf"), size, FlxColor.WHITE, CENTER);
    bottomText.scrollFactor.set();
    add(bottomText);

    player = new MusicPlayer(this);
    add(player);

    if (ClientPrefs.data.shaders)
    {
      vcrEffect = new VcrGlitchEffect();
      initPsychCamera().setFilters([new ShaderFilter(vcrEffect.shader)]);
    }

    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
      // FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }

    changeSelection(0, false);
    updateTexts();
    super.create();
  }

  override function closeSubState()
  {
    persistentUpdate = true;
    super.closeSubState();
  }

  public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
  {
    songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
  }

  function weekIsLocked(name:String):Bool
  {
    var leWeek:WeekData = WeekData.weeksLoaded.get(name);
    return (!leWeek.startUnlocked
      && leWeek.weekBefore.length > 0
      && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
  }

  var instPlaying:Int = -1;

  public static var vocals:FlxSound = null;

  var holdTime:Float = 0;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music.volume < 0.7)
    {
      FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
    }
    lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
    lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

    if (ClientPrefs.data.shaders)
    {
      if (vcrEffect != null) vcrEffect.update(elapsed);
    }
    if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
    if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;

    var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
    if (ratingSplit.length < 2)
    { // No decimals, add an empty space
      ratingSplit.push('');
    }

    while (ratingSplit[1].length < 2)
    { // Less than 2 decimals in it, add decimals then
      ratingSplit[1] += '0';
    }

    var shiftMult:Int = 1;
    if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

    if (!player.playingMusic)
    {
      scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
      positionHighscore();
      if (songs.length > 1)
      {
        if (FlxG.keys.justPressed.HOME)
        {
          curSelected = 0;
          changeSelection();
          holdTime = 0;
        }
        else if (FlxG.keys.justPressed.END)
        {
          curSelected = songs.length - 1;
          changeSelection();
          holdTime = 0;
        }
        if (controls.UI_UP_P)
        {
          changeSelection(-shiftMult);
          holdTime = 0;
        }
        if (controls.UI_DOWN_P)
        {
          changeSelection(shiftMult);
          holdTime = 0;
        }

        if (controls.UI_DOWN || controls.UI_UP)
        {
          var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
          holdTime += elapsed;
          var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

          if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
        }

        if (FlxG.mouse.wheel != 0)
        {
          FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
          changeSelection(-shiftMult * FlxG.mouse.wheel, false);
        }
      }

      if (controls.UI_LEFT_P)
      {
        changeDiff(-1);
        _updateSongLastDifficulty();
      }
      else if (controls.UI_RIGHT_P)
      {
        changeDiff(1);
        _updateSongLastDifficulty();
      }
    }

    if (controls.BACK)
    {
      if (player.playingMusic)
      {
        FlxG.sound.music.stop();
        destroyFreeplayVocals();
        FlxG.sound.music.volume = 0;
        instPlaying = -1;

        player.playingMusic = false;
        player.switchPlayMusic();

        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
      }
      else
      {
        FlxG.sound.music.stop();
        persistentUpdate = false;
        if (colorTween != null)
        {
          colorTween.cancel();
        }
        FlxG.sound.play(Paths.sound('cancelMenu'));
        FlxG.camera.fade();
        FlxTween.tween(FlxG.camera, {zoom: 0.15}, 3, {ease: FlxEase.quadInOut});
        MusicBeatState.switchState(new MainMenuState());
      }
    }
    else if (FlxG.keys.justPressed.SPACE)
    {
      if (instPlaying != curSelected && !player.playingMusic)
      {
        destroyFreeplayVocals();
        FlxG.sound.music.volume = 0;

        Mods.currentModDirectory = songs[curSelected].folder;
        var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
        PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
        if (PlayState.SONG.needsVoices)
        {
          vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
          FlxG.sound.list.add(vocals);
          vocals.persist = true;
          vocals.looped = true;
        }
        else if (vocals != null)
        {
          vocals.stop();
          vocals.destroy();
          vocals = null;
        }

        FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
        if (vocals != null) // Sync vocals to Inst
        {
          vocals.play();
          vocals.volume = 0.8;
        }
        instPlaying = curSelected;

        player.playingMusic = true;
        player.curTime = 0;
        player.switchPlayMusic();
      }
      else if (instPlaying == curSelected && player.playingMusic)
      {
        player.pauseOrResume(player.paused);
      }
    }
    else if (controls.ACCEPT && !player.playingMusic)
    {
      persistentUpdate = false;
      var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
      var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
      /*#if MODS_ALLOWED
        if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
        #else
        if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
        #end
          poop = songLowercase;
          curDifficulty = 1;
          trace('Couldnt find file');
      }*/
      trace(poop);

      try
      {
        PlayState.SONG = Song.loadFromJson(poop, songLowercase);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = curDifficulty;

        trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
        if (colorTween != null)
        {
          colorTween.cancel();
        }
      }
      catch (e:Dynamic)
      {
        Sys.println('Freeplay: ERROR! $e');

        var errorStr:String = e.toString();
        if (errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1); // Missing chart
        missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
        missingText.screenCenter(Y);
        missingText.visible = true;
        missingTextBG.visible = true;
        FlxG.sound.play(Paths.sound('cancelMenu'));

        updateTexts(elapsed);
        super.update(elapsed);
        return;
      }

      FlxG.camera.flash(FlxColor.BLACK, 1.0);
      FlxTween.tween(FlxG.camera, {zoom: 1.4}, 4, {ease: FlxEase.quadOut});
      FlxTween.tween(FlxG.camera, {angle: (FlxG.random.bool(50) ? 360 : -360)}, 7, {ease: FlxEase.cubeIn});
      FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

      new FlxTimer().start(1.0, (_) -> LoadingState.loadAndSwitchState(new PlayState()));

      FlxG.sound.music.stop();

      destroyFreeplayVocals();
    }
    else if (controls.RESET && !player.playingMusic)
    {
      persistentUpdate = false;
      openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
      FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    updateTexts(elapsed);
    super.update(elapsed);
  }

  public static function destroyFreeplayVocals()
  {
    if (vocals != null)
    {
      vocals.stop();
      vocals.destroy();
    }
    vocals = null;
  }

  function changeDiff(change:Int = 0)
  {
    if (player.playingMusic) return;

    curDifficulty += change;

    if (curDifficulty < 0) curDifficulty = Difficulty.list.length - 1;
    if (curDifficulty >= Difficulty.list.length) curDifficulty = 0;

    #if ! switch
    intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
    intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
    #end

    lastDifficultyName = Difficulty.getString(curDifficulty);
    if (Difficulty.list.length > 1) diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
    else
      diffText.text = lastDifficultyName.toUpperCase();

    positionHighscore();
    missingText.visible = false;
    missingTextBG.visible = false;
  }

  var charTween:FlxTween;

  function changeSelection(change:Int = 0, playSound:Bool = true)
  {
    if (player.playingMusic) return;

    _updateSongLastDifficulty();
    if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

    var lastList:Array<String> = Difficulty.list;
    curSelected += change;

    if (curSelected < 0) curSelected = songs.length - 1;
    if (curSelected >= songs.length) curSelected = 0;

    if (char != null)
    {
      for (i in 0...charJson.data.length)
      {
        if (curSelected == charJson.data[i].index)
        {
          char.loadGraphic(Paths.image(charJson.data[i].charImage));

          blackfuck.alpha = 1;

          if (charTween != null) charTween.cancel();

          charTween = FlxTween.tween(blackfuck, {alpha: 0}, charJson.data[i].fadeTime,
            {
              ease: FlxEase.quadOut,
              onComplete: (t:FlxTween) -> t = null
            });
        }
      }
    }

    var newColor:Int = songs[curSelected].color;
    if (newColor != intendedColor)
    {
      if (colorTween != null)
      {
        colorTween.cancel();
      }
      intendedColor = newColor;
      colorTween = FlxTween.color(bg, 1, bg.color, intendedColor,
        {
          onComplete: function(twn:FlxTween) {
            colorTween = null;
          }
        });
    }

    // selector.y = (70 * curSelected) + 30;

    #if DISCORD_ALLOWED
    DiscordClient.instance.changePresence({details: "Freeplay", state: '${songs[curSelected].songName}'});
    #end

    var bullShit:Int = 0;

    for (i in 0...iconArray.length)
    {
      iconArray[i].alpha = 0;
    }

    iconArray[curSelected].alpha = 1;

    for (item in grpSongs.members)
    {
      bullShit++;
      item.alpha = 0;
      if (item.targetY == curSelected) item.alpha = 1;
    }

    Mods.currentModDirectory = songs[curSelected].folder;
    PlayState.storyWeek = songs[curSelected].week;
    Difficulty.loadFromWeek();

    var savedDiff:String = songs[curSelected].lastDifficulty;
    var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
    if (savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff)) curDifficulty = Math.round(Math.max(0,
      Difficulty.list.indexOf(savedDiff)));
    else if (lastDiff > -1) curDifficulty = lastDiff;
    else if (Difficulty.list.contains(Difficulty.getDefault())) curDifficulty = Math.round(Math.max(0,
      Difficulty.defaultList.indexOf(Difficulty.getDefault())));
    else
      curDifficulty = 0;

    changeDiff();
    _updateSongLastDifficulty();
  }

  inline private function _updateSongLastDifficulty()
  {
    songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
  }

  private function positionHighscore()
  {
    scoreText.x = FlxG.width - scoreText.width - 6;
    scoreText.screenCenter(X);
    scoreBG.scale.x = 10000;
    scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
    scoreBG.y = 10;
    scoreBG.screenCenter(X);
    diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
    diffText.x -= diffText.width / 2;
  }

  var _drawDistance:Int = 4;
  var _lastVisibles:Array<Int> = [];

  public function updateTexts(elapsed:Float = 0.0)
  {
    lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
    for (i in _lastVisibles)
    {
      grpSongs.members[i].visible = grpSongs.members[i].active = false;
      iconArray[i].visible = iconArray[i].active = false;
    }
    _lastVisibles = [];

    var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
    var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
    for (i in min...max)
    {
      var item:Alphabet = grpSongs.members[i];
      item.visible = item.active = true;

      var icon:HealthIcon = iconArray[i];
      icon.visible = icon.active = false;
      _lastVisibles.push(i);
    }
  }

  override function destroy():Void
  {
    super.destroy();

    FlxG.autoPause = ClientPrefs.data.autoPause;
    if (!FlxG.sound.music.playing) FlxG.sound.playMusic(Paths.music('freakyMenu'));
  }
}

class SongMetadata
{
  public var songName:String = "";
  public var week:Int = 0;
  public var songCharacter:String = "";
  public var color:Int = -7179779;
  public var folder:String = "";
  public var lastDifficulty:String = null;

  public function new(song:String, week:Int, songCharacter:String, color:Int)
  {
    this.songName = song;
    this.week = week;
    this.songCharacter = songCharacter;
    this.color = color;
    this.folder = Mods.currentModDirectory;
    if (this.folder == null) this.folder = '';
  }
}
