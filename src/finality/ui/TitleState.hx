package finality.ui;

import openfl.filters.ShaderFilter;
import haxe.Json;
import psych.backend.WeekData;
import psych.backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

typedef TitleData =
{
  titlex:Float,
  titley:Float,
  startx:Float,
  starty:Float,
  gfx:Float,
  gfy:Float,
  backgroundSprite:String,
  bpm:Float
}

class TitleState extends MusicBeatState
{
  public static var initialized:Bool = false;

  var blackScreen:FlxSprite;
  var credGroup:FlxGroup;
  var credTextShit:Alphabet;
  var textGroup:FlxGroup;
  var ngSpr:FlxSprite;

  var titleTextColors:Array<FlxColor> = [0xFFFFFFFF, 0xFFFFFFFF];
  var titleTextAlphas:Array<Float> = [1, .64];

  var curWacky:Array<String> = [];

  var wackyImage:FlxSprite;

  var titleJSON:TitleData;

  public static var updateVersion:String = '';

  override public function create():Void
  {
    Paths.clearStoredMemory();

    #if LUA_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    curWacky = FlxG.random.getObject(getIntroTextShit());

    super.create();

    // IGNORE THIS!!!
    titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

    if (!initialized)
    {
      persistentUpdate = true;
      persistentDraw = true;

      new FlxTimer().start(1, function(tmr:FlxTimer) {
        startIntro();
      });
    }
    else
      startIntro();
  }

  var vcrEffect:VcrGlitchEffect;
  var logoBl:FlxSprite;
  var gfDance:FlxSprite;
  var danceLeft:Bool = false;
  var titleText:FlxSprite;
  var body:FlxSprite;
  var logoTween:FlxTween;
  var camGrp:FlxSpriteGroup;
  var camGame:FlxCamera;
  var camStuff:FlxCamera;

  function startIntro()
  {
    if (!initialized)
    {
      if (FlxG.sound.music == null)
      {
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
      }
    }

    camGame = initPsychCamera();

    camStuff = new FlxCamera();
    camStuff.bgColor.alpha = 0;
    FlxG.cameras.add(camStuff, false);

    #if DISCORD_ALLOWED
    DiscordClient.instance.changePresence({details: "Title Screen"});
    #end

    Conductor.bpm = 130;
    persistentUpdate = true;

    var backdrop4ik1:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xF04B0298, 0x0));
    backdrop4ik1.velocity.set(40, 40);
    add(backdrop4ik1);

    var bg = new FlxSprite().loadGraphic(Paths.image('bars'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.screenCenter();
    bg.updateHitbox();
    add(bg);

    logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
    logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
    logoBl.antialiasing = ClientPrefs.data.antialiasing;
    logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
    logoBl.animation.play('bump');
    logoBl.updateHitbox();

    var da:FlxSprite = new FlxSprite(50);
    da.y = 210;
    da.frames = Paths.getSparrowAtlas('da');
    da.animation.addByPrefix('da', 'da', 24, true);
    da.animation.play('da');
    da.antialiasing = ClientPrefs.data.antialiasing;
    da.updateHitbox();
    da.scrollFactor.set();
    add(da);

    var bt1 = new FlxSprite().loadGraphic(Paths.image('auratitle'));
    bt1.antialiasing = ClientPrefs.data.antialiasing;
    bt1.screenCenter();
    bt1.scrollFactor.set(0.15, 0.15);
    bt1.updateHitbox();
    add(bt1);

    camGrp = new FlxSpriteGroup();
    camGrp.scrollFactor.set();
    camGrp.cameras = [camStuff];
    add(camGrp);

    gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
    gfDance.antialiasing = ClientPrefs.data.antialiasing;
    gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
    gfDance.animation.addByPrefix('idle', 'gfDance', 24, true);
    gfDance.animation.play('idle');
    add(gfDance);
    add(logoBl);

    titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
    titleText.frames = Paths.getSparrowAtlas('titleEnter');
    var animFrames:Array<FlxFrame> = [];
    @:privateAccess {
      titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
      titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
    }

    if (animFrames.length > 0)
    {
      newTitle = true;

      titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
      titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
    }
    else
    {
      newTitle = false;

      titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
      titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
    }

    titleText.animation.play('idle');
    titleText.updateHitbox();
    add(titleText);

    FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

    credGroup = new FlxGroup();
    add(credGroup);
    textGroup = new FlxGroup();

    blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    credGroup.add(blackScreen);

    credTextShit = new Alphabet(0, 0, "", true);
    credTextShit.screenCenter();
    credTextShit.visible = false;

    ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
    ngSpr.visible = false;
    ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
    ngSpr.updateHitbox();
    ngSpr.screenCenter(X);
    ngSpr.antialiasing = ClientPrefs.data.antialiasing;
    add(ngSpr);

    var staticLol:FlxSprite = new FlxSprite();
    staticLol.frames = Paths.getSparrowAtlas('staticShit');
    staticLol.animation.addByPrefix('idle', 'StaticIdle', 24, true);
    staticLol.animation.play('idle');
    staticLol.visible = ClientPrefs.data.flashing;
    staticLol.setGraphicSize(staticLol.width * 1.6);
    staticLol.setPosition(-100, -100);
    staticLol.scrollFactor.set();
    staticLol.updateHitbox();
    camGrp.add(staticLol);

    if (initialized) skipIntro();
    else
      initialized = true;

    if (ClientPrefs.data.shaders)
    {
      vcrEffect = new VcrGlitchEffect();
      initPsychCamera().setFilters([new ShaderFilter(vcrEffect.shader)]);
    }

    Paths.clearUnusedMemory();
    // credGroup.add(credTextShit);
  }

  function getIntroTextShit():Array<Array<String>>
  {
    #if MODS_ALLOWED
    var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
    #else
    var fullText:String = Assets.getText(Paths.txt('introText'));
    var firstArray:Array<String> = fullText.split('\n');
    #end
    var swagGoodArray:Array<Array<String>> = [];

    for (i in firstArray)
    {
      swagGoodArray.push(i.split('--'));
    }

    return swagGoodArray;
  }

  var transitioning:Bool = false;

  private static var playJingle:Bool = false;

  var newTitle:Bool = false;
  var titleTimer:Float = 0;

  override function update(elapsed:Float)
  {
    if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

    var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

    #if mobile
    for (touch in FlxG.touches.list)
    {
      if (touch.justPressed)
      {
        pressedEnter = true;
      }
    }
    #end

    var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

    if (gamepad != null)
    {
      if (gamepad.justPressed.START) pressedEnter = true;

      #if switch
      if (gamepad.justPressed.B) pressedEnter = true;
      #end
    }

    if (newTitle)
    {
      titleTimer += FlxMath.bound(elapsed, 0, 1);
      if (titleTimer > 2) titleTimer -= 2;
    }

    // EASTER EGG

    if (initialized && !transitioning && skippedIntro)
    {
      if (newTitle && !pressedEnter)
      {
        var timer:Float = titleTimer;
        if (timer >= 1) timer = (-timer) + 2;

        timer = FlxEase.quadInOut(timer);

        titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
        titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
      }

      if (pressedEnter)
      {
        titleText.color = FlxColor.WHITE;
        titleText.alpha = 1;

        if (titleText != null) titleText.animation.play('press');

        if (logoTween != null) logoTween.cancel();

        FlxTween.tween(logoBl.scale, {x: 1.2, y: 1.2}, 0.6,
          {
            ease: FlxEase.elasticIn,
            onComplete: (t:FlxTween) -> {
              t = null;
            },
            startDelay: 0.25
          });

        FlxG.camera.fade(FlxColor.BLACK, 1);

        FlxG.camera.flash(FlxColor.BLACK, 4);

        FlxTween.tween(FlxG.camera, {angle: (FlxG.random.bool(50) ? 360 : -360)}, 3, {ease: FlxEase.cubeIn});
        FlxTween.tween(FlxG.camera, {zoom: 1.4}, 1.74, {ease: FlxEase.quadOut});

        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

        transitioning = true;

        new FlxTimer().start(0.3, (t:FlxTimer) -> {
          FlxG.camera.fade(FlxColor.BLACK, 0.6);
        });

        new FlxTimer().start(1, function(tmr:FlxTimer) {
          MusicBeatState.switchState(new MainMenuState());
          closedState = true;
        });
        // FlxG.sound.play(Paths.music('titleShoot'), 0.7);
      }
    }

    if (initialized && pressedEnter && !skippedIntro)
    {
      skipIntro();
    }

    if (ClientPrefs.data.shaders) if (vcrEffect != null) vcrEffect.update(elapsed);

    super.update(elapsed);
  }

  function createCoolText(textArray:Array<String>, ?offset:Float = 0)
  {
    for (i in 0...textArray.length)
    {
      var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
      money.screenCenter(X);
      money.y += (i * 60) + 200 + offset;
      if (credGroup != null && textGroup != null)
      {
        credGroup.add(money);
        textGroup.add(money);
      }
    }
  }

  function addMoreText(text:String, ?offset:Float = 0)
  {
    if (textGroup != null && credGroup != null)
    {
      var coolText:Alphabet = new Alphabet(0, 0, text, true);
      coolText.screenCenter(X);
      coolText.y += (textGroup.length * 60) + 200 + offset;
      credGroup.add(coolText);
      textGroup.add(coolText);
    }
  }

  function deleteCoolText()
  {
    while (textGroup.members.length > 0)
    {
      credGroup.remove(textGroup.members[0], true);
      textGroup.remove(textGroup.members[0], true);
    }
  }

  private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

  public static var closedState:Bool = false;

  override function beatHit()
  {
    super.beatHit();

    if (logoBl != null) logoBl.animation.play('bump', true);

    if (body != null) body.animation.play('body', true);

    if (!closedState)
    {
      sickBeats++;
      switch (sickBeats)
      {
        case 1:
          // FlxG.sound.music.stop();
          FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
          FlxG.sound.music.fadeIn(4, 0, 0.7);

        case 2:
          skipIntro();
      }
    }
  }

  var skippedIntro:Bool = false;
  var increaseVolume:Bool = false;

  function skipIntro():Void
  {
    if (!skippedIntro)
    {
      remove(ngSpr);
      remove(credGroup);

      if (ClientPrefs.data.flashing) FlxG.camera.flash(FlxColor.BLACK, 4);

      var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
      if (easteregg == null) easteregg = '';
      easteregg = easteregg.toUpperCase();
      skippedIntro = true;
    }
  }
}
