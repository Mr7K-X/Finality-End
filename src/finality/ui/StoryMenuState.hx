package finality.ui;

import flixel.addons.transition.FlxTransitionableState;
import psych.backend.Highscore;
import psych.substates.StickerSubState;
import psych.backend.Song;
import psych.backend.WeekData;
import psych.substates.GameplayChangersSubstate;
import psych.substates.ResetScoreSubState;
import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import psych.objects.MenuCharacter;
import psych.objects.MenuItem;
import openfl.filters.ShaderFilter;

class StoryMenuState extends MusicBeatState
{
  public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

  var scoreText:FlxText;

  private static var curWeek:Int = 0;

  var curDifficulty:Int = 1;

  private static var lastDifficultyName:String = '';

  var backgrounds:FlxTypedGroup<FlxSprite>;

  var bgShader:FlxRuntimeShader;

  var lock:FlxSprite;

  var loadedWeeks:Array<WeekData> = [];

  var stickerSubState:StickerSubState;

  var camGame:FlxCamera;
  var camStick:FlxCamera;

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

    Paths.clearUnusedMemory();

    PlayState.isStoryMode = true;
    WeekData.reloadWeekFiles(true);

    if (curWeek >= WeekData.weeksList.length) curWeek = 0;

    persistentUpdate = persistentDraw = true;

    bgShader = new FlxRuntimeShader(shaderInfo);

    bgShader.setFloat('iTime', 0);
    bgShader.setFloat('vignetteMult', 1);
    backgrounds = new FlxTypedGroup<FlxSprite>();
    add(backgrounds);

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.instance.changePresence({details: "In the Menus"});
    #end

    var num:Int = 0;
    for (i in 0...WeekData.weeksList.length)
    {
      var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
      var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
      if (!isLocked || !weekFile.hiddenUntilUnlocked)
      {
        loadedWeeks.push(weekFile);
        WeekData.setDirectoryFromWeek(weekFile);

        addWeek(weekFile.weekBackground, weekFile.weekName, isLocked);
        num++;
      }
    }

    WeekData.setDirectoryFromWeek(loadedWeeks[0]);

    scoreText = new FlxText(0, 20, FlxG.width, 'Score: 0');
    scoreText.setFormat(Paths.font("HelpMe.ttf"), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
    scoreText.scrollFactor.set();
    add(scoreText);

    lock = new FlxSprite(0, 520).loadGraphic(Paths.image('storymenu/lock'));
    lock.screenCenter();
    lock.alpha = 0;
    lock.scale.set(1.2, 1.2);
    add(lock);

    var par:FlxSprite = new FlxSprite();
    par.frames = Paths.getSparrowAtlas('par');
    par.animation.addByPrefix('par', 'par', 1, false);
    par.animation.play('par');
    par.antialiasing = ClientPrefs.data.antialiasing;
    par.updateHitbox();
    par.scrollFactor.set();
    add(par);

    changeItem();

    super.create();

    camGame.filters = [new ShaderFilter(bgShader)];

    if (stickerSubState != null)
    {
      openSubState(stickerSubState);
      stickerSubState.degenStickers();
    }
  }

  function addWeek(name:String, iconName:String, ?isLocked:Bool = false):FlxSprite
  {
    var itemID = backgrounds.length;
    var spr = new FlxSprite(itemID * FlxG.width).loadGraphic(Paths.image('storymenu/backgrounds/' + name));
    spr.ID = itemID;
    backgrounds.add(spr);

    return spr;
  }

  function weekIsLocked(name:String):Bool
  {
    var leWeek:WeekData = WeekData.weeksLoaded.get(name);
    trace(name);
    return (!leWeek.startUnlocked
      && leWeek.weekBefore.length > 0
      && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
  }

  override function closeSubState()
  {
    persistentUpdate = true;
    changeItem();
    super.closeSubState();
  }

  var selectedWeek:Bool = false;

  override function update(elapsed:Float)
  {
    lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
    if (Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

    scoreText.text = "WEEK SCORE:" + lerpScore;

    bgShader.setFloat('iTime', bgShader.getFloat('iTime') + elapsed);

    if (!selectedWeek)
    {
      if (controls.UI_LEFT_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(-1);
      }

      if (controls.UI_RIGHT_P)
      {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(1);
      }

      if (controls.ACCEPT)
      {
        selectedWeek = true;

        FlxTween.tween(FlxG.camera, {alpha: 0, zoom: 5}, 0.8, {ease: FlxEase.quartInOut, startDelay: 0, onComplete: _ -> selectWeek()});
        FlxTween.num(1, 0, 0.8, {ease: FlxEase.quartInOut, startDelay: 0}, _ -> bgShader.setFloat('vignetteMult', _));
      }
      if (controls.BACK)
      {
        selectedWeek = true;
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new FinalityMenu());
      }
    }
    super.update(elapsed);
  }

  var stopspamming:Bool = false;

  function selectWeek()
  {
    if (!weekIsLocked(loadedWeeks[curWeek].fileName))
    {
      // We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
      var songArray:Array<String> = [];
      var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
      for (i in 0...leWeek.length)
      {
        songArray.push(leWeek[i][0]);
      }

      // Nevermind that's stupid lmao
      try
      {
        PlayState.storyPlaylist = songArray;
        PlayState.isStoryMode = true;

        var diffic = Difficulty.getFilePath(curDifficulty);
        if (diffic == null) diffic = '';

        PlayState.storyDifficulty = curDifficulty;

        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
      }
      catch (e:Dynamic)
      {
        trace('ERROR! $e');
        return;
      }

      LoadingState.loadAndSwitchState(new PlayState(), true);
      FreeplayState.destroyFreeplayVocals();
    }
    else
      FlxG.sound.play(Paths.sound('cancelMenu'));
  }

  var lerpScore:Int = 0;
  var intendedScore:Int = 0;

  function changeItem(?v:Int = 0)
  {
    curWeek += v;

    if (curWeek < 0) curWeek = backgrounds.length - 1;

    if (curWeek > backgrounds.length - 1) curWeek = 0;

    var leWeek:WeekData = loadedWeeks[curWeek];
    WeekData.setDirectoryFromWeek(leWeek);

    PlayState.storyWeek = curWeek;

    Difficulty.loadFromWeek();

    if (Difficulty.list.contains(Difficulty.getDefault())) curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
    else
      curDifficulty = 0;

    var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
    // trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
    if (newPos > -1) curDifficulty = newPos;

    #if ! switch
    intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
    #end

    FlxTween.cancelTweensOf(FlxG.camera.scroll);
    FlxTween.tween(FlxG.camera.scroll, {x: FlxG.width * (curWeek)}, 0.8, {ease: FlxEase.sineInOut, startDelay: 0.2});

    backgrounds.forEach(spr -> {
      FlxTween.cancelTweensOf(spr);
      FlxTween.color(spr, 0.6, spr.color, spr.ID == curWeek ? 0xFFFFFFFF : 0xFF000000, {ease: FlxEase.sineInOut});
    });

    if (weekIsLocked(loadedWeeks[curWeek].fileName))
    {
      var nowCurrent = curWeek;
      FlxTween.cancelTweensOf(lock);
      FlxTween.tween(lock, {y: 300, alpha: 1}, 0.4,
        {
          ease: FlxEase.sineInOut,
          startDelay: 0.9,
          onStart: _ -> {
            lock.x = 560 + FlxG.width * nowCurrent;
            lock.y = 280;
            lock.alpha = 0;
          }
        });
    }
    else
    {
      // lock.visible = false;
    }
  }

  private static var shaderInfo:String = '
   #pragma header

uniform float iTime;

#define texture flixel_texture2D
#define fragColor gl_FragColor

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = uv * openfl_TextureSize;

    float warp = 1.5;
    float scan = 1.0;

    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    uv.x -= 0.5;
    uv.x *= 1.0 + (dc.y * (0.3 * warp));
    uv.x += 0.5;

    uv.y -= 0.5;
    uv.y *= 1.0 + (dc.x * (0.4 * warp));
    uv.y += 0.5;

    if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        float scanline = 0.5 + 0.5 * sin(fragCoord.y * 3.1415);
        float apply = scan * scanline * 0.5;
        vec4 texColor = texture(bitmap, uv);
        fragColor = vec4(mix(texColor.rgb, vec3(0.0), apply), texColor.a);
    }
}

    ';
}
